#!/bin/bash
#=============================================================================
# Name: MySQLBackup                    
# Creator: Volodja                    
# CreationDate: 01.06.2022                              
# LastModified: 06.09.2022                               
# Version: 0.2
# GitHub: https://github.com/SynkMas1er/MySQLBackup
# 
# How to create telegram bot https://sendpulse.com/knowledge-base/chatbot/telegram/create-telegram-chatbot
#
#
# Description: Copying MySQL db to ftp and sends message to telegram
# for example zabbix db
# Only Change Variables in Variables Section
# 
#
#=============================================================================


name='zabbix.backup.sql.'$(date +%Y.%m.%d_%H.%M.%S)'.gz'                                             					     # Name of backup created db 

#db credentials
log="DBLogin"
pass="DBPass"
db="DBName"

#ftp credentials
logf='FTPLogin'
passf='FTPPass'
host='FTPIP'
file='/var/tmp/zbackup/'$name

function message {
	curl -s -X POST "https://api.telegram.org/bot<<<TOKEN>>>/sendMessage" -d chat_id=<<<ID>>> -d text=$1					 # Input your token ob telegram bot and chat id
}

if [ ! -d /var/tmp/zbackup ]; then
	mkdir /var/tmp/zbackup
fi

mysqldump -u $log -p$pass $db | gzip > $file

chmod 744 $file

filesize=$(wc -c <"$file")

if [ $filesize -gt 200 ] ; then																							     # Checking db size for debug

ftp -n $host <<END_SCRIPT
quote USER $logf
quote PASS $passf
binary
put $file $name
quit
END_SCRIPT
message "Backup_"$name"_zabbix_maybe_uploaded_to_ftp"                                                                        # Enter message thah you want to receive from bot

else
	message "Error_creating_zabbix_backup_"$name																			 # Error message if something go wrong
fi

rm $file																													 # Deleting dump file

exit
