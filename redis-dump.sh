#!/bin/bash
BACKUPDIR=${BACKUPDIR:-/backups}
WEEK=`date +'%Y-w%U'`
MONTH=`date +'%Y-%m'`
DAY=`date +"%Y-%m-%d"`
BDATE=`date +"%Y-%m-%dT%H:%M:%S"`
REDIS_DB=all
REDIS_NAME=${REDIS_NAME:-redis}
ARCHIVE_FILE=${REDIS_NAME}-db-${REDIS_DB}
ARCHIVE=${BACKUPDIR}/hourly/${DAY}/${BDATE}-${ARCHIVE_FILE}
ARCHIVE_DAY=${BACKUPDIR}/daily/${DAY}/${ARCHIVE_FILE}
ARCHIVE_MONTH=${BACKUPDIR}/monthly/${MONTH}-${ARCHIVE_FILE}
ARCHIVE_WEEK=${BACKUPDIR}/weekly/${WEEK}-${ARCHIVE_FILE}

mkdir -p ${BACKUPDIR}/hourly/${DAY}
mkdir -p ${BACKUPDIR}/daily/${DAY}
mkdir -p ${BACKUPDIR}/weekly
mkdir -p ${BACKUPDIR}/monthly




REDISDUMPBIN=redis-dump-go
REDISCLIBIN=redis-cli


# $REDISDUMPBIN -db $REDIS_DB -host $REDIS_HOST > ${ARCHIVE}
$REDISDUMPBIN -host $REDIS_HOST > ${ARCHIVE}.txt
$REDISCLIBIN --rdb ${ARCHIVE}.rdb  -h ${REDIS_HOST}

gzip ${ARCHIVE}.rdb
gzip ${ARCHIVE}.txt

for ext in rdb txt; do
    cp ${ARCHIVE}.${ext}.gz ${ARCHIVE_DAY}.${ext}.gz
    cp ${ARCHIVE}.${ext}.gz ${ARCHIVE_MONTH}.${ext}.gz
    cp ${ARCHIVE}.${ext}.gz ${ARCHIVE_WEEK}.${ext}.gz
done
