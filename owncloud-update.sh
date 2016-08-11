#!/bin/bash

# manual upgrade documentation
# https://doc.owncloud.org/server/8.2/admin_manual/maintenance/manual_upgrade.html

# set variables
APP_PATH="/var/www/webapps/owncloud/"
NEW_APP_NAME="owncloud-8.2.7"
OLD_APP_NAME="owncloud-8.2.5"
DOWNLOAD_URI="https://download.owncloud.org/community/"
WEB_ROOT="/var/www/html/"

# safety first
if [ -d ${APP_PATH}${NEW_APP_NAME} ]; then
    echo "Yeah, um...the directory already exists.";
    exit 1;
fi

# only root can run
if [ `id -u` != 0 ]; then
    echo "You must be root to run this script";
    exit 1;
fi

cd ${APP_PATH}

# get the latest version
wget ${DOWNLOAD_URI}${NEW_APP_NAME}.zip

# unzip in place
unzip ${NEW_APP_NAME}.zip

# clean up
rm ${NEW_APP_NAME}.zip

# change directory name
mv owncloud ${NEW_APP_NAME}

# get in there
cd ${NEW_APP_NAME}

# modify file permissions
find . -type f -exec chmod 0640 {} \;
find . -type d -exec chmod 0750 {} \;
cd ${APP_PATH}
chown -R root:apache ${NEW_APP_NAME}
chown -R apache:apache ${NEW_APP_NAME}/apps/
chown -R apache:apache ${NEW_APP_NAME}/config/
chown -R apache:apache ${NEW_APP_NAME}/themes/
chmod 0644 ${NEW_APP_NAME}/.htaccess

# copy the config file
cp -p ${APP_PATH}${OLD_APP_NAME}/config/config.php ${APP_PATH}${NEW_APP_NAME}/config/

# copy apps
cp -Rp ${APP_PATH}${OLD_APP_NAME}/apps/calendar/ ${APP_PATH}${NEW_APP_NAME}/apps/
cp -Rp ${APP_PATH}${OLD_APP_NAME}/apps/contacts/ ${APP_PATH}${NEW_APP_NAME}/apps/
cp -Rp ${APP_PATH}${OLD_APP_NAME}/apps/documents/ ${APP_PATH}${NEW_APP_NAME}/apps/

# put owncloud in maintenenace mode
# cd ${APP_PATH}${OLD_APP_NAME}
# sudo -u apache php occ maintenance:mode --on

# update the symbolic link
# cd ${WEB_ROOT}
# rm owncloud
# ln -s ${APP_PATH}${NEW_APP_NAME} owncloud

# command line upgrade
# cd ${APP_PATH}${NEW_APP_NAME}
# sudo -u apache php occ upgrade