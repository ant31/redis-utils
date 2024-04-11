#!/bin/bash
set -e
BACKUPDIR=${BACKUPDIR:-/backups}
WEEK=`date +'%Y-w%U'`
MONTH=`date +'%Y-%m'`
DAY=`date +"%Y-%m-%d"`
BDATE=`date +"%Y-%m-%dT%H:%M:%S"`
REDIS_NAME=${REDIS_NAME:-redis}
REDISDUMPBIN=${REDISDUMPBIN=-redis-utils.py}
ARCHIVE_FILE=${REDIS_NAME}
ARCHIVE=${BACKUPDIR}/hourly/${DAY}/${BDATE}-${ARCHIVE_FILE}
ARCHIVE_DAY=${BACKUPDIR}/daily/${DAY}/${ARCHIVE_FILE}
ARCHIVE_MONTH=${BACKUPDIR}/monthly/${MONTH}-${ARCHIVE_FILE}
ARCHIVE_WEEK=${BACKUPDIR}/weekly/${WEEK}-${ARCHIVE_FILE}

mkdir -p ${BACKUPDIR}/hourly/${DAY}
mkdir -p ${BACKUPDIR}/daily/${DAY}
mkdir -p ${BACKUPDIR}/weekly
mkdir -p ${BACKUPDIR}/monthly


archive_hourly() {
    echo ${BACKUPDIR}/hourly/${DAY}/${BDATE}-$1
}
archive_day() {
    echo ${BACKUPDIR}/daily/${DAY}/$1
}
archive_month() {
    echo ${BACKUPDIR}/monthly/${MONTH}-$1
}
archive_week() {
    echo ${BACKUPDIR}/weekly/${WEEK}-$1
}

FILENAME=$(basename "${ARCHIVE}")
DIRPATH=$(dirname "${ARCHIVE}")
# $REDISDUMPBIN -db $REDIS_DB -host $REDIS_HOST > ${ARCHIVE}
DESTS=$($REDISDUMPBIN -s $REDIS_URI --dump-method=both --name $ARCHIVE_FILE --dir $DIRPATH)

for archive in $DESTS; do
    echo $archive
    gzip -q -f $archive
    archive_base=$(basename $archive)
    echo cp ${archive}.gz $(archive_hourly $archive_base).gz
    echo cp ${archive}.gz $(archive_day $archive_base).gz
    echo cp ${archive}.gz $(archive_week $archive_base).gz
    echo cp ${archive}.gz $(archive_month $archive_base).gz
    cp ${archive}.gz $(archive_hourly $archive_base).gz
    cp ${archive}.gz $(archive_day $archive_base).gz
    cp ${archive}.gz $(archive_week $archive_base).gz
    cp ${archive}.gz $(archive_month $archive_base).gz
done
