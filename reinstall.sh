#!/bin/bash

# Script for syncing stage server with Prod site.

# Environment variables
CURRENT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DATE_TIME=`date "+%Y-%m-%d_%H-%M-%S"`
CURRENT_USER=$(whoami)

# include file with settings
. "$CURRENT_PATH"/settings.sh


if [ "$CURRENT_USER" = "vagrant" ]; then
    echo "#####################################################"
    echo "#     This is Local DEV. Run DEV-STAGE sync...      #"
    echo "#####################################################"

    # create file settings.php from local.settings.php if it doesn't exist
    if [ ! -f $CURRENT_PATH/docroot/sites/default/settings.php ]; then
        if cp $CURRENT_PATH/docroot/sites/default/default.settings.php $CURRENT_PATH/docroot/sites/default/settings.php; then
            # Default credentials for database on vagrant machine.
            LOCAL_BASE_CODNFIG="\$databases = array (
              'default' =>
                array (
                  'default' =>
                    array (
                      'database' => 'local_db',
                      'username' => 'local_db_user',
                      'password' => 'local_db_pass',
                      'host' => 'localhost',
                      'port' => '',
                      'driver' => 'mysql',
                      'prefix' => '',
                    ),
                ),
            );"

            echo -e "$LOCAL_BASE_CODNFIG" >> $CURRENT_PATH/docroot/sites/default/settings.php
            echo "Settings file created!"
        else
            echo "Error can't create file settings.php!\n Check permissions on sites/default folder."
            exit 1;
        fi
    fi

    echo "create base dump on stage site"
    ssh -p $STAGE_REMOTE_PORT $STAGE_REMOTE_USER@$STAGE_REMOTE_SERVER "cd $STAGE_PATH_TO_DOCROOT; drush sql-dump --gzip --result-file=./${DATE_TIME}_base-dump.sql"
    echo "copy base dump"
    scp -P $STAGE_REMOTE_PORT $STAGE_REMOTE_USER@$STAGE_REMOTE_SERVER:$STAGE_PATH_TO_DOCROOT/${DATE_TIME}_base-dump.sql.gz $CURRENT_PATH/docroot/
    echo "delete dump on remote"
    ssh -p $STAGE_REMOTE_PORT $STAGE_REMOTE_USER@$STAGE_REMOTE_SERVER "cd $STAGE_PATH_TO_DOCROOT; rm ${DATE_TIME}_base-dump.sql.gz"

    # cd ro site root
    cd "$CURRENT_PATH"/docroot

    #drop current db
    echo "Current job: drop local DB"
    drush sql-drop -y

    echo "Current job: restoring local DB from dump $BASE_DUMP"
    gunzip < ./${DATE_TIME}_base-dump.sql.gz | drush sql-cli
    rm ${DATE_TIME}_base-dump.sql.gz

    # we need to ensure that stage_file_proxy and devel modules is downloaded and enabled
    STAGE_FILE_PROXY_EXIST=$(drush pm-list --pipe --type=module --no-core | grep "stage_file_proxy")
    STAGE_FILE_PROXY_ENABLE=$(drush pm-list --pipe --type=module --status=enabled --no-core | grep "stage_file_proxy")
    if [ -z "$STAGE_FILE_PROXY_EXIST" ]; then
      drush pm-download stage_file_proxy
    fi
    if [ -z "$STAGE_FILE_PROXY_ENABLE" ]; then
      drush pm-enable --yes stage_file_proxy
      drush variable-set stage_file_proxy_origin "$STAGE_SITE_ADRESS"
    fi
    DEVEL_EXIST=$(drush pm-list --pipe --type=module --no-core | grep "devel")
    DEVEL_ENABLE=$(drush pm-list --pipe --type=module --status=enabled --no-core | grep "devel")
    if [ -z "$DEVEL_EXIST" ]; then
      drush pm-download devel
    fi
    if [ -z "$DEVEL_ENABLE" ]; then
      drush pm-enable --yes devel
    fi

    # set webmaster and manager passwords to something more simple.
    drush upwd webmaster --password="$WEBMASTER_PASS"
    drush upwd manager --password="$WEBMASTER_PASS"

    echo "Done! Servers were synchronized"

elif [ "$CURRENT_USER" = "$STAGE_REMOTE_USER" ]; then
    echo "#####################################################"
    echo "#       This is STAGE. Run STAGE-PROD sync...       #"
    echo "#####################################################"

    # run sql dumb on remote (via Backup and Migrate module)
    echo "Current job: run 'drush bam-backup' on the server $PROD_REMOTE_SERVER in folder $PROD_PATH_TO_DOCROOT."
    ssh -p $PROD_REMOTE_PORT $PROD_REMOTE_USER@$PROD_REMOTE_SERVER "
        cd $PROD_PATH_TO_DOCROOT
        drush bam-backup
        cd $PATH_TO_BM_MANUAL
        (ls -t|head -n 3;ls)|sort|uniq -u|xargs --no-run-if-empty rm -rf
        "
    # Run file synchronisation (sync sites/default/files/ folder)
    echo "Current job: sync files folder with remote"
    SSH_OPT="ssh -p $PROD_REMOTE_PORT"
    rsync -avh --delete -e "$SSH_OPT" $PROD_REMOTE_USER@$PROD_REMOTE_SERVER:$PROD_PATH_TO_DOCROOT/sites/default/files $CURRENT_PATH/docroot/sites/default/

    # cd ro site root
    cd "$CURRENT_PATH"/docroot

    # drop current db
    echo "Current job: drop local DB"
    drush sql-drop -y

    # Restore database from latest dump
    BASE_DUMP=$(ls -t $PATH_TO_BM_MANUAL/*.mysql.gz | head -1)

    echo "Current job: restoring local DB from dump $BASE_DUMP"
    gunzip < $BASE_DUMP | drush sql-cli

    echo "Done! Servers were synchronized"
else
    echo "Cant run on this machine. Username doesn't match!"
    exit 1;
fi
