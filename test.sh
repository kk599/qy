#!/bin/bash

PATH="/usr/local/bin:/usr/bin:/bin"
ENV_PATH="$(dirname $0)/.env"
IS_MACOS=$(uname | grep 'Darwin' | wc -l)
TITLE="12"
COOKIE_PATH="./.1.cook"
PUSH_TMP_PATH="./.2.tmp"

if [ -f ${ENV_PATH} ]; then
    source ${ENV_PATH}
fi


users_array=($(echo ${USERS} | tr ';' ' '))


if [ "${users_array}" ]; then
    user_count=1
    for user in ${users_array[@]}; do
        un=$(echo ${user} | awk -F'----' '{print $1}')
        pw=$(echo ${user} | awk -F'----' '{print $2}')
	
        login=$(curl --location --request POST "${domain0}" --header 'authorization: Basic bXBtMjRfYW5kcm9pZDpHOEo5NXQ1aWtMaXdEZnU5UWdQT0k5d3RsNVFvNTJ2cA==' --header 'content-type: application/x-www-form-urlencoded' --header 'user-agent: okhttp/3.14.0' --data-raw "password=${pw}&grant_type=password&admin=${un}%3A86&username=local%3A${un}%3A86")
		
		
        login_access_token=$(echo ${login} | jq -r '.access_token')
        userid=$(echo ${login} | jq -r '.user_id')	
		echo -e ${login}
		
        #start_time=$(date -u "+%Y-%m-%dT%H:%M:%SZ")

		#checkin0=$(curl --location --request POST '{domain1}' --header 'user-agent: Mozilla/5.0 (Linux; Android 10; Mi9 Build/QQ3A.200805.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/87.0.4280.86 Mobile Safari/537.36mpm24_android' --header 'authorization: Bearer ${login_access_token}' --header 'comomorgid: {gid}' --header 'content-type: application/json;charset=UTF-8' --data-raw '{"day":"${start_time}"}')
			
		#login_scheduleDetailId=$(echo ${checkin0} | jq -r '.object.employeeAttendances[${no1}].scheduleDetailId')
		
		checkin0=$(curl --location --request GET "${domain1}?onOffFlag=1&userId=${userid}&companyId=${gid}" \
--header "authorization: Bearer ${login_access_token}" \
--header 'user-agent: Mozilla/5.0 (Linux; Android 10; C106 Build/QQ3A.200805.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/87.0.4280.86 Mobile Safari/537.36mpm24_android' \
--header "comomorgid: ${gid}")
		
           
        check_in_status0=$(echo ${checkin0} | jq -r '.code')
        check_in_status1=$(echo ${checkin0} | jq -r '.message')
		checkin_log_text="- 【签到状态】: ${check_in_status1}\n\n"
        result_log_text="${checkin_log_text}\n\n"

        log_text="${result_log_text}---------------------------------------\n\n"
        echo -e ${log_text}
        user_count=$(expr ${user_count} + 1)
    done

        
    fi
    rm -rf ${COOKIE_PATH}
    rm -rf ${PUSH_TMP_PATH}

