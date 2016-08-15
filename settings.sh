#!/bin/bash

#####################
#  Common Settings  #
#####################

#path to backup and migrate manual backups folder 
#e.g sites/default/files/private/backup_migrate/manual
PATH_TO_BM_MANUAL="sites/default/files/private/backup_migrate/manual"

##################################
#  Settings for DEV-STAGE sync  #
##################################

# Password for webmaster on dev environment.
# lets use project name by default
WEBMASTER_PASS=""

#absolute path to site root on stage-server (without last /)
#example: /home/stage/public_html
STAGE_PATH_TO_DOCROOT=""

#full adress of STAGE site
#example: http://www.example.com
#example when using HTTP Basic Authentication: http://myusername:letme%26in@example.com
STAGE_SITE_ADRESS=""

#other remote host parameters
#will connect like: ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_SERVER
STAGE_REMOTE_USER=""
STAGE_REMOTE_SERVER=""
STAGE_REMOTE_PORT="22"

##################################
#  Settings for STAGE-PROD sync  #
##################################

#absolute path to site root on prod-server (without last /)
#example: /home/prod/public_html
PROD_PATH_TO_DOCROOT=""

#other remote host parameters
#will connect like: ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_SERVER
PROD_REMOTE_USER=""
PROD_REMOTE_SERVER=""
PROD_REMOTE_PORT="22"
