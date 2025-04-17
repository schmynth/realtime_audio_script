# realtime_audio_script
Script to apply realtime audio tweaks to arch based distros

This script applies real time audio tweaks as suggested in the [Arch Wiki](https://wiki.archlinux.org/title/Professional_audio).

It also authorizes $USER to run cpupower without password. I use this in a script that sets the governor to performance and launches my DAW. When the DAW is closed, this script sets the governor back to powersave.

The script is called launch_bitwig.sh. You can rename it and place it anywhere. Replace bitwig-studio with the command of your DAW. Then replace the command in your DAWs .desktop file with the full path to this script.
