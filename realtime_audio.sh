#!/bin/bash

if ! source "${scrDir}/pretty_print.sh"; then
	printf "\e[0;30;41m ERROR \e[0m :: \e[1;31m pretty_print.sh (needed for logging) not found!\e[0m"
	exit 1
fi

tabs 40


get_kernel_parameters () {
		local line6=$(echo | awk 'NR>5 && NR<7' $1)
		local params=$(echo $line6 | cut -d '"' -f2)
		echo $params
}

add_kernel_parameter ()  {
	if [[ ! " ${kernel_parameters_list[*]} " =~ $1 ]]; then
			print_message info GRUB "${1} kernel parameter not found"
			print_message info GRUB "add ${1} kernel parameter to grub config"
	
sudo -i -u root bash <<EOF
sed -i "6s/.$/ $1\"/" /etc/default/grub
EOF
	
	else
			print_message info GRUB "kernel parameter ${1} already in place"
	fi
}

update_grub () {
sudo -i -u root bash <<EOF
grub-mkconfig -o /boot/grub/grub.cfg
EOF
}

group_exists () {
		if grep -q $1 /etc/group
		then
			print_message info "System" "Group $1 exists"
		else
			print_message info "System" "Group $1 does not exist. Create group $1"
sudo -i -u root bash <<EOF
groupadd $1
EOF
		fi
}


user_in_realtime_group () {
	if id -nG "$USER" | grep -qw realtime; then
		print_message info "System" "User already in realtime group"	
	else
		print_message info "System" "User not in realtime group. Add user to it"
sudo -i -u root bash <<EOF
usermod -a -G realtime $USER
EOF
	fi

}

cpupower_user_auth () {
	print_message info "System" "authorize $USER to run sudo cpupower without password to launch DAW"
	print_message info "System" "echo \"$USER ALL=(ALL:ALL) NOPASSWD: /usr/bin/cpupower\" > /etc/sudoers.d/20-cpupower"
	sudo -i -u root bash <<EOF
echo "$USER ALL=(ALL:ALL) NOPASSWD: /usr/bin/cpupower" > /etc/sudoers.d/20-cpupower
EOF
}

add_interrupt_service () {
	sudo cp "${scrDir}/extra/interrupt_freq.service" /etc/systemd/system/
	sudo cp "${scrDir}/extra/interrupt_freq.sh" /usr/bin/
	sudo systemctl enable interrupt_freq.service
}

max_user_watches () {
	print_message info "Config" "setting max_user_watches.conf to 600000"
	
sudo -i -u root bash << EOF
echo "fs.inotify.max_user_watches = 600000" > /etc/sysctl.d/90-max_user_watches.conf
EOF
}

swappiness () {
	print_message info "Config" "setting swappiness to 10"
	
sudo -i -u root bash << EOF
echo "vm.swappiness = 10" > /etc/sysctl.d/90-swappiness.conf
EOF
}

apply_optimizations () {
	group_exists realtime
	user_in_realtime_group
	print_message info Package "installing realtime-privileges"
	sudo pacman -S realtime-privileges --needed || print_message error Package "installation of realtime-privileges failed."
	
	max_user_watches	
	swappiness
	print_message info "Service" "setting max-user-freq to 2048 at boot"
	add_interrupt_service	
	cpupower_user_auth
	
	
	kernel_parameters_list=($(get_kernel_parameters /etc/default/grub))
	
	print_message info GRUB "current kernel parameters:"
	print_message info GRUB "\e[34m${kernel_parameters_list[*]}"
	add_kernel_parameter "threadirqs"
	print_message info GRUB "update GRUB"
	update_grub
	print_message info "System" "Be sure to reboot after applying these optimizations."
}
# apply_optimization end

print_message info General "This script optimizes the system for realtime audio processing as proposed in the Arch Linux Wiki."
print_message warning General "This script is meant for Arch Linux. Do NOT run this on any other distro!"
print_message warning General "\e[31mTHIS SCRIPT WILL MODIFY SYSTEM FILES AS ROOT! MAKE SURE YOU READ THE SCRIPT BEFORE EXECUTING IT! (install_scripts/realtime_audio.sh)\e[0m"

read -p "Are you sure you want to apply these realtime optimizations? (yY)" -n 1 -r
echo 
if [[ $REPLY =~ ^[Yy]$ ]]
then
		apply_optimizations
else
		print_message info Quit "Execution of script cancelled by the user"
fi

