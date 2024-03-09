#!/usr/bin/bash

: '
Author: Marco D. Mosna

Program description: Generates X number of passwords with a set of S user defined characters

Argument operations:
	-i
	<string> <number>
	-h

In-program operations: 
	-c Create a file that contains all passwords generated
	-r Remove specific passwords that has a user specified pattern
	-u Update password list to
		-uA Append more passwords
		-uR Remove all passwords
		-uG Re-generate passwords
	-dF Delete generated file
	-dP Delete specific passwords that has a user specified pattern

Usage example
	passgen -h					:			shows help menu
	passgen "ABcd123@!#" 10				:			generates 10 random password from specified character list
	passgen						:			generates a single password
	passgen -interactive				:			interactive mode of passgen
'

showHelp() {
	echo "Help is on the way"
}

generatePassword() {
	characters=$1
	length=$2
	password=$(head /dev/urandom | tr -dc "$characters" | head -c "$length")
	echo "Generated password: $password"
}

handleInteractiveMode() {
	PS3="Select option: "
	select opt in create read update delete quit; do
		case $opt in
			create)
				echo "create"
				;;
			read)
				echo "read"
				;;
			update)
				echo "update"
				;;
			delete)
				echo "delete"
				;;
			quit)
				break
				;;
			*)
				echo "Invalid option $REPLY";;
		esac
	done

}

# validate user input
if [ -z "$1" ]  &&  [ -z "$2" ]; then
	default="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()"
	generatePassword "$default" 8 
elif [ "$1" = "-h" ]; then
	showHelp
elif [ "$1" = "-i" ]; then
	handleInteractiveMode
else
	generatePassword "$1" "$2"
fi 


