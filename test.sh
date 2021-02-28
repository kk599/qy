#!/bin/bash

PATH="/usr/local/bin:/usr/bin:/bin"
ENV_PATH="$(dirname $0)/.env"
COOKIE_PATH="./.1.cook"
PUSH_TMP_PATH="./.2.tmp"
log_text=""

if [ -f ${ENV_PATH} ]; then
    source ${ENV_PATH}
fi

function rand(){   
    min=$1   
    max=$(($2-$min+1))   
    num=$(date +%s%N)   
    echo $(($num%$max+$min))   
}

function send_message() {
    # Server 酱通知
    if [ "${PUSH_KEY}" ]; then
        echo -e "text=${log_text}&desp=${log_text}" >${PUSH_TMP_PATH}
        push=$(curl -k -s --data-binary @${PUSH_TMP_PATH} "https://sc.ftqq.com/${PUSH_KEY}.send")
        push_code=$(echo ${push} | jq -r ".errno" 2>&1)
        if [ ${push_code} -eq 0 ]; then
            echo -e "【Server 酱推送结果】: 成功\n"
        else
            echo -e "【Server 酱推送结果】: 失败\n"
        fi
    fi
}

users_array=($(echo ${USERS} | tr ';' ' '))

if [ "${users_array}" ]; then
    user_count=0
    for user in ${users_array[@]}; do
        un=$(echo ${user} | awk -F'----' '{print $1}')
        pw=$(echo ${user} | awk -F'----' '{print $2}')
	echo -e $(date '+%Y-%m-%d %H:%M:%S')
        login=$(curl -s --location --request POST "${domain0}" --header 'authorization: Basic bXBtMjRfYW5kcm9pZDpHOEo5NXQ1aWtMaXdEZnU5UWdQT0k5d3RsNVFvNTJ2cA==' --header 'content-type: application/x-www-form-urlencoded' --header 'user-agent: okhttp/3.14.0' --data-raw "password=${pw}&grant_type=password&admin=${un}%3A86&username=local%3A${un}%3A86")		
        login_access_token=$(echo ${login} | jq -r '.access_token')
	login_state=$(echo ${login} | jq -r '.scope')
        userid=$(echo ${login} | jq -r '.user_id')
	echo -e ${login_state}
	get_gid=$(curl -s --location --request POST "${domain2}" --header 'user-agent: Mozilla/5.0 (Linux; Android 10; C106 Build/QQ3A.200805.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/87.0.4280.86 Mobile Safari/537.36mpm24_android' --header 'content-type: application/x-www-form-urlencoded' --header "authorization: Bearer ${login_access_token}")
	gid=$(echo ${get_gid} | jq -r '.object[0].orgId')
	get_gid_message=$(echo ${get_gid} | jq -r '.message')
	echo -e ${get_gid_message}
	hour=$(date "+%-H")
	echo -e ${hour}
	if [ ${hour} -lt 12 ]; then
		flag=0
	else
		flag=1
	fi
	echo -e ${flag}
	checkin0=$(curl -s --location --request GET "${domain1}?onOffFlag=${flag}&userId=${userid}&companyId=${gid}" --header "authorization: Bearer ${login_access_token}" --header 'user-agent: Mozilla/5.0 (Linux; Android 10; C106 Build/QQ3A.200805.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/87.0.4280.86 Mobile Safari/537.36mpm24_android' --header "comomorgid: ${gid}")	           
        check_in_status0=$(echo ${checkin0} | jq -r '.code')
        check_in_status1=$(echo ${checkin0} | jq -r '.message')
	checkin_log_text="${check_in_status0}-${check_in_status1}"
        echo -e ${checkin_log_text}
	log_text="${log_text}--${checkin_log_text}"
        user_count=$(expr ${user_count} + 1)
	if [ ${#users_array[@]} -eq ${user_count} ]; then
		break
	fi
	rnd=$(rand 50 90)
	echo -e ${rnd}
	sleep ${rnd}
    done
    send_message 
    fi
    rm -rf ${COOKIE_PATH}
    rm -rf ${PUSH_TMP_PATH}

