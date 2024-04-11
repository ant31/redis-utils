
Execution example:

``` shell
# Dump all db
REDISDUMPBIN=`pwd`/redis-utils.py BACKUPDIR=/tmp/redis REDIS_URI=redis://default:password@localhost:6379 ./redis-dump.sh
# Dump db 2
REDISDUMPBIN=`pwd`/redis-utils.py BACKUPDIR=/tmp/redis REDIS_URI=redis://default:password@localhost:6379/2 ./redis-dump.sh
```


