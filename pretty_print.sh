#!/bin/bash

print_message () {
	local type=$1
	case ${type} in
		-w | warning)
				type="\e[0;30;43m WARNING \e[0m"
				;;
		-i | info)
				type="\e[0;30;46m  INFO   \e[0m"
				;;
		-e | error)
				type="\e[0;30;41m  ERROR  \e[0m"
				;;
		-s | success)
				type="\e[0;30;42m SUCCESS \e[0m"
	esac
	
	section=$2
	section_fmt="\e[32m[${section}]\e[0m"
	message=$3
	printf "%-20b %-20b %b\n" "${type}"  "${section_fmt}" "${message}"
}
