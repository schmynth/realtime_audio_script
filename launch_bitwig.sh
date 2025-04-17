#!/bin/bash

set_powersave() {
	sudo cpupower frequency-set -r -g powersave
	notify-send "set cpu governor to powersave"
}

set_performance() {
	sudo cpupower frequency-set -r -g performance
	notify-send "set cpu governor to performance"
}

set_performance 
bitwig-studio
trap "set_powersave" EXIT
