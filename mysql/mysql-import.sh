#!/bin/bash
#----------------------------------------
# OPTIONS
#----------------------------------------
USER='root'       # MySQL User
PASSWORD='password' # MySQL Password
DAYS_TO_KEEP=0    # 0 to keep forever
GZIP=0            # 1 = Compress
BACKUP_PATH='/opt/mysql/backup'
#----------------------------------------

files=`ls $BACKUP_PATH/*.sql`
for eachfile in $files
do
   db="$(basename $eachfile | cut -d. -f1)"
   exist=`mysql -u$USER -p$PASSWORD -e "SHOW DATABASES" | grep $db`
   if [ "$exist" == "$db" ]; then
      echo "Database $db exist"
   else   
      echo "Create database $db"
      mysqladmin -u $USER -p$PASSWORD create $db
      echo "Importing $db < $eachfile"
      mysql -u $USER -p$PASSWORD $db < $eachfile
   fi
done