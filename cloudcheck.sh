#!/bin/bash

if [[ $# -eq 0 ]]; then
	scriptname=`basename "$0"`
	echo "Usage: $scriptname 'http://target.site/' 'This text is on the webpage'"
	exit 1
fi



## TOOL CHECK ##
command -v python3 >/dev/null 2>&1 || { echo >&2 "I require python3 but it's not installed.  Aborting."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo >&2 "I require curl but it's not installed.  Aborting."; exit 1; }
command -v grep >/dev/null 2>&1 || { echo >&2 "I require grep but it's not installed.  Aborting."; exit 1; }
command -v gethostip >/dev/null 2>&1 || { echo >&2 "I require syslinux-utils but it's not installed.  Aborting."; exit 1; }
command -v sed >/dev/null 2>&1 || { echo >&2 "I require sed but it's not installed.  Aborting."; exit 1; }
##################



cat custom.ans
echo 'Cloudcheck V1'
echo '' ; echo "Reminder: Make sure your /etc/hosts file has a extra empty line at the end, else this tool may not work!" ; echo ''
TARGET_UNSTRIPPED=$1
COMPARESTRING=$2
STRIPPED_TARGET=`echo $TARGET_UNSTRIPPED | sed 's/^http\(\|s\):\/\///g' | sed 's#/*$##;s#^/*##'`
TESTSTRING="__cf"
echo -e  "Original cookies: \e[1;49;37m"$(curl -A 'Mozilla/5.0 (Windows NT 6.1; rv:60.0) Gecko/20100101 Firefox/60.0' -k --max-time 10 -s -c - "$TARGET_UNSTRIPPED" | egrep -iao "#HTTPONLY.*")"\e[0m"
for check in $(python3 cloudfail.py -t $STRIPPED_TARGET -s none.txt | fgrep -a "FOUND:" | fgrep -iav "ON CLOUDFLARE" | cut -d ' ' -f 3 | egrep -ia "([0-9]{1,3}[\.]){3}[0-9]{1,3}"); do
	echo "$check	$STRIPPED_TARGET" >> /etc/hosts
	trap ctrl_c INT
	function ctrl_c() {
		echo "CTRL_C caught, removing last check from hosts..."
		sed -i '$d' /etc/hosts
		echo "Stopping..."
		exit 1
	}
	HOSTCHECK=`gethostip -d $STRIPPED_TARGET`
	if [[ $HOSTCHECK == $check ]]; then
		echo -e "\e[1;49;37mHost check: $STRIPPED_TARGET = \e[1;49;33m$check\e[0m"
		DATA=`curl -A 'Mozilla/5.0 (Windows NT 6.1; rv:60.0) Gecko/20100101 Firefox/60.0' -k --max-time 10 -s -c - "$TARGET_UNSTRIPPED"`
		COOKIEDATA=`echo $DATA | egrep -iao "#HTTPONLY.*"`
		if [[ $DATA =~ ^"# Netscape HTTP Cookie File" ]]; then
			echo -e "\e[1;49;33m$check \e[1;49;37m-- \e[1;49;91mFalse\e[0m"
		else
			grep -aiq "$COMPARESTRING" <<< $DATA && printf "\e[1;49;33m$check\e[1;49;37m contains comparestring -- \e[0m"
			if `echo "$COOKIEDATA" | grep -iaq "$TESTSTRING"`; then
				printf "\e[1;49;91mFalse\e[0m\n"
			else
				printf "\e[1;49;96mTrue\e[0m\n"
			fi
		fi
		sed -i '$d' /etc/hosts
	else
		exit 1
	fi
done
