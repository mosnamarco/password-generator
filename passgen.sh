#!/usr/bin/bash

: '
Author: Marco D. Mosna

Program description: Generates X number of passwords with a set of S user defined characters

Argument operations:
	-i
	<string> <number>
	-h

In-program operations: 
	Create a file that contains all passwords generated
	Remove specific passwords that has a user specified pattern
	Update password list to

Usage example
	passgen -h					:			shows help menu
	passgen "ABcd123@!#" 10				:			generates 10 random password from specified character list
	passgen						:			generates a single password
	passgen -interactive				:			interactive mode of passgen
'

showHelp() {
    echo -e  "Usage:\npassgen -h\t\t\tshow help menu\npassgen <string> <num>\t\tgenerate password from string with length num\npassgen -i\t\t\tnteractive mode"
}

generatePassword() {
	characters=$1
	length=$2
	password=$(head /dev/urandom | tr -dc "$characters" | head -c "$length")

	if [ "$3" = "append" ]; then 
		if test -f password_list; then
			echo $password >> password_list
		fi	
	else
		echo "Generated password: $password"
	fi
}

handleCreate() {
	if test -f password_list; then
		echo "Cannot create list, there is already an existing one. Update instead."
		return
	fi

	echo >> password_list
	read -p "Character list i.e., \"ABC123\": " characters
	read -p "Password length: " length 
	read -p "Number of passwords: " num

	for ((i=0; i<$num; i++)); do
		generatePassword $characters $length "append"
	done

	echo -e "\nPassword list of size $num was created.\nCharacter list = \"$characters\"\nPassword length = $length\n"
}

handleRead() {
	if test -f password_list; then
		awk '{ print $0 }' password_list	
	else
		echo "List not found, generate one first."
	fi
}

handleDelete() {
	read -p "Are you sure you want to delete existing password list? [yes/no]: " confirm
	if [ "$confirm" = "yes" ]; then
		rm $(pwd)/password_list
		if ! test -f password_list; then
			echo -e "Password list successfully deleted!\n"
			return
		fi
	else
		echo "You must explicitly type \"yes\" to confirm."
	fi

	read -p "Go back to option select? [y/n]: " choice
	if [ "$choice" = "y" ]; then
		return
	else
		handleDelete
	fi
}

handleUpdate() {
	if ! test -f password_list; then
		echo "There is nothing to update..."
		return
	fi

	rm $(pwd)/password_list
	
	echo -e "\nCreate a new password list\n"
	
	handleCreate	
}

handleInteractiveMode() {
	PS3="Select option: "
	select opt in create read update delete quit; do
		case $opt in
			create)
				handleCreate	
				;;
			read)
				handleRead
				;;
			update)
				handleUpdate	
				;;
			delete)
				handleDelete
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
elif [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
	showHelp
elif [ "$1" = "-i" ] || [ "$1" = "-interactive" ]; then
	handleInteractiveMode
else
	generatePassword "$1" "$2"
fi 


