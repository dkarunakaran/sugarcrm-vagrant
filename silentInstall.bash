#!/bin/bash

if [ -z "$1" ]
then
	echo "Invalid arguments. Run silentInstall.bash <folder name of the installer file>"
	exit
fi

if [ -d "/var/www/$1" ]; then

cd /var/www

#Copying config of silent install
cp config_si.php $1/config_si.php

#Change the config
sed -i "s/sugarcrm_db/sugarcrm_$1/" $1/config_si.php

#Run the silent installation
php-cgi -f $1/install.php goto=SilentInstall cli=true

else
echo "No folder exists"
fi


