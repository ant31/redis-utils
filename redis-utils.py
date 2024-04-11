#!/usr/bin/env python3
import subprocess
from urllib.parse import urlparse
from dataclasses import dataclass
import argparse
import subprocess, os


@dataclass
class RedisURI:
    db: int | None
    password: str | None
    user: str | None
    uri: str | None
    host: str = "localhost"
    port: int = 6379

    def to_uri(self):
        uri = "redis://"
        if self.user:
            uri += self.user + ":" + self.password + "@"
        uri += f"{self.host}:{self.port}"
        if self.db is not None:
            uri += f"/{self.db}"

        return uri

    @classmethod
    def parse(cls, uri: str):
        url = urlparse(uri)
        host = url.hostname
        port = url.port
        user = url.username
        password = url.password
        db = None
        if user is not None and password is None:
            password = user
            user = "default"

        if port is None:
            port = "6379"

        if url.path != "":
            db = int(url.path[1:])

        return cls(db=db, host=host, port=port, user=user, password=password, uri=uri)

def print_uri(uri, password):
    if password:
        return uri.replace(password, "********")
    else:
        return uri

def dump_redis(cli: str, source_uri: str, name: str, dirdest: str):
    suri = RedisURI.parse(source_uri)
    print(print_uri(suri.to_uri(), suri.password))
    dump_args = []
    dbname = "all"
    my_env = os.environ.copy()
    if suri.db is not None:
        dump_args += ["-db", str(suri.db)]
        dbname = f"db-{suri.db}"
    if suri.user:
        dump_args += ["-user", suri.user]
    if suri.password:
        my_env["REDISDUMPGO_AUTH"] = suri.password
    dump_args += ["-host", suri.host, "-port", str(suri.port)]
    archive = f"{dirdest}/{name}-{dbname}.txt"
    cmdline = [cli] + dump_args
    print(f"executing: {" ".join(cmdline)} > {archive}")
    with open(archive, "wb") as f:
        subprocess.call(cmdline, stdout=f, env=my_env)
    return archive


def restore_redis(archive: str, dest_uri: str):
    duri = RedisURI.parse(dest_uri)
    print(print_uri(duri.to_uri(), duri.password))
    if duri.db:
        print("clearing SELECT db from dump")
        subprocess.call(["sed", "-ri", f"5s/[0-9]+/{duri.db}/", archive])
    cmdline = ["redis-cli", "-u", dest_uri, "--pipe"]
    print(f"executing: {print_uri(' '.join(cmdline), duri.password)} < {archive}")
    with open(archive, "rb") as f:
        res = subprocess.call(cmdline, stdin=f)
    return res


def main():
    parser = argparse.ArgumentParser(description='clone a redis')
    group = parser.add_mutually_exclusive_group()

    group.add_argument('-s', '--source',
                        help='Redis source as uri')
    parser.add_argument('-d', '--dest',
                        help='Redis destination as uri')
    parser.add_argument('-n', '--name', default="redis-dump",
                        help='a name to create the dump file')
    parser.add_argument('--dumpcli', default="redis-dump-go", help="path to the redis-dump-go client if it's not in $PATH")
    parser.add_argument('--dir', default=".", help="directory to dump the file")
    group.add_argument('-a', '--archive', help="path to archive to restore")
    args = parser.parse_args()
    path = args.archive
    if args.source != None:
        print("dumping source")
        path = dump_redis(cli=args.dumpcli, source_uri=args.source, name=args.name, dirdest=args.dir)
    if args.dest != None:
        print("restoring dump")
        path = restore_redis(archive=path, dest_uri=args.dest)



if __name__ == "__main__":
    main()
