#!/bin/bash
# Color Validation
DF='\e[39m'
Bold='\e[1m'
Blink='\e[5m'
yell='\e[33m'
red='\e[31m'
green='\e[32m'
blue='\e[34m'
PURPLE='\e[35m'
CYAN='\e[36m'
Lred='\e[91m'
Lgreen='\e[92m'
Lyellow='\e[93m'
NC='\e[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
CYAN='\e[36m'
LIGHT='\033[0;37m'
MYIP=$(wget -qO- ipinfo.io/ip);
IP=$(wget -qO- ipinfo.io/ip)
date=$(date +"%Y-%m-%d")
name=$(curl -sS https://raw.githubusercontent.com/vpnlegasi/client-ip/main/access | grep $MYIP | awk '{print $4}')
echo "Checking VPS"
cek=$( curl -sS https://raw.githubusercontent.com/vpnlegasi/client-ip/main/access | awk '{print $2}'  | grep $MYIP )
if [ $cek = $MYIP ]; then
echo -e "${green}Permission Accepted...${NC}"
else
echo -e "${red}Permission Denied!${NC}";
echo "Your IP NOT REGISTER / EXPIRED | Contact me at Telegram @vpnlegasi to Unlock"
exit 0
fi
clear
source /etc/.maAsiss/.botku
Token=$(sed -n '1 p' /etc/.maAsiss/backup.conf | cut -d' ' -f2)
get_AdminID=$(sed -n '2 p' /etc/.maAsiss/backup.conf | cut -d' ' -f2)
ShellBot.init --token $Token --monitor --return map --flush
ShellBot.username

msg_welcome() {
    curl -sS https://raw.githubusercontent.com/KDevN9/ipscvps/main/user >/etc/userList
    alluser=/etc/.alluser
    if [ "$(grep -wc ${message_from_id[$id]} $alluser)" = '1' ]; then
        echo "Do Nothing"
    else
        echo "${message_from_id[$id]}" >>$alluser
    fi
    if [ "${message_from_id[$id]}" == "$get_AdminID" ]; then
        ShellBot.deleteMessage --chat_id ${message_chat_id[$id]} \
            --message_id ${message_message_id[$id]}
        local msg
        msg="━━━━━━━━━━━━━━━━━━━━━\n"
        msg+="Welcome <b>Admin</b>\n"
        msg+="━━━━━━━━━━━━━━━━━━━━━\n"
        msg+="Here Are The Command Available\n"
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$(echo -e $msg)" \
            --reply_markup "$bkp" \
            --parse_mode html
        return 0
    else
        ShellBot.deleteMessage --chat_id ${message_chat_id[$id]} \
            --message_id ${message_message_id[$id]}
        msg="Permission Denied\n"
        ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
            --text "$(echo -e $msg)" \
            --parse_mode html
        return 0
    fi
}

backup() {
    ShellBot.deleteMessage --chat_id ${callback_query_message_chat_id[$id]} \
        --message_id ${callback_query_message_message_id[$id]}

    ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
        --text "Starting To Backup Server . "

    IP=$(wget -qO- ipinfo.io/ip)
    date=$(date +"%Y-%m-%d")
    rm -rf /root/$IP-$name-$date.zip
    rm -rf /root/backup
    mkdir /root/backup
    cp /etc/passwd /root/backup/
    cp /etc/group /root/backup/
    cp /etc/shadow /root/backup/
    cp /etc/gshadow /root/backup/
    cp -r /etc/wireguard /root/backup/wireguard
    cp /etc/shadowsocks-libev/akun.conf /root/backup/ss.conf
    cp -r /var/lib/premium-script/ /root/backup/premium-script
    cp -r /usr/local/etc/xray /root/backup/xray
    cp -r /etc/xray-mini /root/backup/xray-mini
    cp -r /etc/trojan /root/backup/trojan
    cp -r /usr/local/shadowsocksr/ /root/backup/shadowsocksr
    cp -r /home/vps/public_html /root/backup/public_html
    cd /root
    zip -r /root/$IP-$name-$date.zip backup/
    ShellBot.sendDocument --chat_id ${callback_query_message_chat_id[$id]} \
        --document "@/root/$IP-$name-$date.zip" \
        --caption "Here Is The Backed UP File ." \
        --parse_mode html
    rm -f /root/download
    return 0
}

autobackup() {
    ShellBot.deleteMessage --chat_id ${callback_query_message_chat_id[$id]} \
        --message_id ${callback_query_message_message_id[$id]}

    ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
        --text "Checking AutoBackup Status... "

    cek=$(grep -c -E "^# BEGIN_Backupp" /etc/crontab)
    if [[ "$cek" = "1" ]]; then
        stts="On"
        ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
            --text "AutoBackup Is Turned On !"
    else
        ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
            --text "AutoBackup Is Turned Off !"
        stts="Off"
    fi

    local msg

    msg="<b>AutoBackup Menu</b>\n"
    msg+="Status : ${stts}\n"
    msg+="Do You Want To Turn On Or Off AutoBackup?"

    ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
        --text "$(echo -e $msg)" \
        --reply_markup "$abkp" \
        --parse_mode html
    return 0

}

onautobackup() {
    ShellBot.deleteMessage --chat_id ${callback_query_message_chat_id[$id]} \
        --message_id ${callback_query_message_message_id[$id]}
    cek=$(grep -c -E "^# BEGIN_Backupp" /etc/crontab)
    if [[ "$cek" = "1" ]]; then
        ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
            --text "AutoBackup Is Already Turned On !"
        --parse_mode html
        return 0
    fi

    ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
        --text "Turning On AutoBackup..."
    cat >>/etc/crontab <<END
# BEGIN_Backupp
5 0 * * * root autobckp
# END_Backupp
END
    service cron restart

    local msg
    msg+="Succesfully Turned On AutoBackup !\n"
    msg="Data Will Be Automatically Backed Up On 00:05\n"
    ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
        --text "$(echo -e $msg)" \
        --parse_mode html
    return 0

}

offautobackup() {
    ShellBot.deleteMessage --chat_id ${callback_query_message_chat_id[$id]} \
        --message_id ${callback_query_message_message_id[$id]}
    if [[ "$cek" = "0" ]]; then
        ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
            --text "AutoBackup Is Already Turned Off !"
        --parse_mode html
        return 0
    fi

    ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
        --text "Turning Off AutoBackup..."
    sed -i "/^# BEGIN_Backupp/,/^# END_Backupp/d" /etc/crontab
    service cron restart

    local msg
    msg+="Succesfully Turned Off AutoBackup !\n"
    msg="Data Will Not Be Automatically Backed Up !\n"
    ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
        --text "$(echo -e $msg)" \
        --parse_mode html
    return 0
}

unset button
button=''
ShellBot.InlineKeyboardButton --button 'button' --line 1 --text 'Backup Data' --callback_data 'bekap'
ShellBot.regHandleFunction --function backup --callback_data bekap
ShellBot.InlineKeyboardButton --button 'button' --line 2 --text 'AutoBackup Data' --callback_data 'autobackup'
ShellBot.regHandleFunction --function autobackup --callback_data autobackup
unset bkp
bkp="$(ShellBot.InlineKeyboardMarkup -b 'button')"

unset btnn
btnn=''
ShellBot.InlineKeyboardButton --button 'btnn' --line 1 --text 'Turn On Auto Backup Data' --callback_data 'obkp'
ShellBot.regHandleFunction --function onautobackup --callback_data obkp
ShellBot.InlineKeyboardButton --button 'btnn' --line 2 --text 'Turn Off AutoBackup Data' --callback_data 'ofbkp'
ShellBot.regHandleFunction --function offautobackup --callback_data ofbkp
unset abkp
abkp="$(ShellBot.InlineKeyboardMarkup -b 'btnn')"

while :; do
    ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 35
    for id in $(ShellBot.ListUpdates); do
        (
            ShellBot.watchHandle --callback_data ${callback_query_data[$id]}
            [[ ${message_chat_type[$id]} != 'private' ]] && {
                ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                    --text "$(echo -e "⛔ This Bot Only Run At Personal Chat !")" \
                    --parse_mode html
                >$CAD_ARQ
                break
                ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
                    --text "Func Error Do Nothing" \
                    --reply_markup "$(ShellBot.ForceReply)"
            }
            CAD_ARQ=/tmp/cad.${message_from_id[$id]}
            if [[ ${message_entities_type[$id]} == bot_command ]]; then
                case ${message_text[$id]} in
                *)
                    :
                    comando=(${message_text[$id]})
                    [[ "${comando[0]}" = "/start" ]] && msg_welcome
                    ;;
                esac
            fi
        ) &
    done
done
rm -rf /root/$IP-$name-$date.zip