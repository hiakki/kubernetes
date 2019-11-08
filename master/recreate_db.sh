#!/bin/bash
hdhxmovies() {
mysql   -u chutiya \
        --password=asdf1234 \
        -h hddb.c8tjsfky7e62.ap-south-1.rds.amazonaws.com \
        -e "
#       drop user chutiyatv;
#       CREATE USER chutiyatv@'%' IDENTIFIED BY 'asdf1234';
#        create database hddb;
        drop database hddb;
        create database hddb;
        GRANT ALL PRIVILEGES ON hddb.* TO chutiyatv@'%';
        FLUSH PRIVILEGES;"

mysql   -u chutiyatv \
        --password=asdf1234 \
        -h hddb.c8tjsfky7e62.ap-south-1.rds.amazonaws.com \
        -e 'show tables;' hddb
}

tricksvibe() {
mysql   -u chutiya \
        --password=asdf1234 \
        -h tvdb.c8tjsfky7e62.ap-south-1.rds.amazonaws.com \
        -e "
#       drop user chutiyatv;
#       CREATE USER chutiyatv@'%' IDENTIFIED BY 'asdf1234';
#        create database tvdb;
        drop database tvdb;
        create database tvdb;
        GRANT ALL PRIVILEGES ON tvdb.* TO chutiyatv@'%';
        FLUSH PRIVILEGES;"

mysql   -u chutiyatv \
        --password=asdf1234 \
        -h tvdb.c8tjsfky7e62.ap-south-1.rds.amazonaws.com \
        -e 'show tables;' tvdb
}

case "$1" in
hd)
hdhxmovies
;;
tv)
tricksvibe
;;
*)
echo "Usage: recreate_db.sh <hd/tv>"
esac
