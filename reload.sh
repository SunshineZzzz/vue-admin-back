#!/bin/sh

#####################################################################
# usage:
# sh reload.sh -- reload application @dev
# sh reload.sh ${env} -- reload application @${env}

# examples:
# sh reload.sh prod -- use conf/nginx-prod.conf to reload OpenResty
# sh reload.sh -- use conf/nginx-dev.conf to reload OpenResty
#####################################################################

if [ -n "$1" ];then
	PROFILE="$1"
else
	PROFILE=dev
fi

mkdir -p logs & mkdir -p tmp
echo "reload lor application with profile: "${PROFILE}
kill -HUP $(cat `pwd`/tmp/${PROFILE}-nginx.pid)
