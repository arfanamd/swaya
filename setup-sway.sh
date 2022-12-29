#!/usr/bin/env bash
#
notice() {
	cat <<- __note
	Setup-sway

	Before running this script, you must setup your installation first
	using setup-alpine command and already create another user in the
	system. Also do not forget to enable the community repository and
	network connection.

	__note
}
install() {
	echo "[32mInstalling[0m: ${@}"
	apk add ${@}
}
prompt() {
	echo -e "\nIf you see an error, please abort the installation!"
	local input
	read -p "Continue installation? [Y/n] " input
	case "${input}" in
		'N'|'No') exit 1;;
		'n'|'no') exit 1;;
		'Y'|'Yes') ;;
		'y'|'yes') ;;
		'');;
		*) prompt;;
	esac
}
systemPrep() {
	echo "[ [32mSetting-up services[0m ]"
	setup-devd udev
	rc-update add seatd && rc-service seatd start
	
	local input
	read -p 'name of the another user ? ' input
	
	[[ ${#input} -eq 0 ]] && exit 1

	cut -d':' -f1 /etc/passwd | grep -qwF "${input}"
	if [[ $? -ne 0 ]]; then
		echo "user ${input} not exist! Aborting..."
		exit 1
	fi

	echo 'group setting...'
	addgroup "${input}" input
	addgroup "${input}" video
	addgroup "${input}" seat
	
	echo 'shell setting...'
	chsh "${input}"
	
	echo 'done'
}

# only root user can run this program.
if [[ $(whoami) != 'root' ]]; then
	echo 'You must run this script as root!'
	exit 1
fi

BASE_PKGS=( \
	'eudev' 'libinput' 'xrandr' 'seatd' 'xwayland' 'libunwind' 'dbus' 'udev' 'eudev' \
	'mesa-dri-intel' 'mesa-gl' 'mesa-demos' 'xf86-video-intel' \
)
FONT_PKGS=('ttf-dejavu')
SWAY_PKGS=('sway' 'sway-doc' 'swaylock-effects' 'swaylock-effects-doc' 'swaylockd' 'swaylockd-doc' \
	'swaybg' 'swaybg-doc' 'swayidle' 'swayidle-doc' 'waybar' 'waybar-doc' \
	'weston' 'weston-shell-desktop' 'weston-shell-fullscreen' 'weston-terminal' \
	'weston-clients'  'weston-backend-drm' \
)
ADDI_PKGS=('bash' 'git' 'foot' 'fuzzel' 'command-not-found' 'doas' 'shadow' 'man')

notice
prompt; install ${BASE_PKGS[@]}
prompt; install ${FONT_PKGS[@]}
prompt; install ${SWAY_PKGS[@]}
prompt; install ${ADDI_PKGS[@]}
prompt; systemPrep
