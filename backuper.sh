#!/bin/bash

#---===Backup for zabbix db===---

name='zabbackup.sql.'$(date +%Y.%m.%d_%H.%M.%S)'.gz'

function message {
	curl -s -X POST "https://api.telegram.org/bot<<<TOKEN>>>/sendMessage" -d chat_id=<<<ID>>> -d text=$1
}

#db
log="DBLogin"
pass="DBPass"
db="DBName"

#ftp
logf='FTPLogin'
passf='FTPPass'
host='FTPIP'
file='/var/tmp/zbackup/'$name

if [ ! -d /var/tmp/zbackup ]; then
	mkdir /var/tmp/zbackup
fi

mysqldump -u $log -p$pass $db | gzip > $file

chmod 744 $file

filesize=$(wc -c <"$file")

if [ $filesize -gt 200 ] ; then

ftp -n $host <<END_SCRIPT
quote USER $logf
quote PASS $passf
binary
put $file $name
quit
END_SCRIPT
message "Backup_"$name"_zabbix_maybe_uploaded_to_ftp"

else
	message "Error_creating_zabbix_backup_"$name
fi

rm $file

exit
