#!/usr/bin/env bash

backup() {
    echo "Backing up [$FOUR] on [$TWO] with user [$THREE] as backup.sql.gz..."
    mysqldump --column-statistics=0 -h $TWO -u $THREE -p $FOUR | gzip > backup.sql.gz
}

migrate() {
    echo "Migrating..."
}

restore() {
    echo "Restoring..."
}

ONE=$1
TWO=$2
THREE=$3
FOUR=$4

if [ $1 == "help" ]
then
    echo "wpbmr <backup | migrate | restore> <db-host> <db-user> <db-name>"
fi

if [ $1 == "backup" ] || [ $1 == "b" ]
then
    backup 
fi

if [ $1 == "migrate" ]
then
    migrate
fi

if [ $1 == "restore" ]
then
    restore
fi