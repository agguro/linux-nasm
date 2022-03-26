#!/bin/bash
#
# This script is used to show stdout and stderr in separate terminals
# The pipes are created in the program hell3pipes 
# The messages send from the program to stdout are displayed in the stdout terminal,
# the messages send from the program to stderr are displayed in the stderr terminal.

exec > >(./create-pipes)

exec > >(gnome-terminal -- /bin/sh -c 'tail -f pipe2stdout;' && gnome-terminal -- /bin/sh -c 'tail -f pipe2stderr')

#add some colors to the terminals
printf "\033[32m\n" | tee pipe2stdout	#green for stdout
printf "\033[31m\n" | tee pipe2stderr	#red for stderr

exec > >(./redirect-pipes)

read -n 1 -s -r -p $'Press any key to continue\n'

pkill tail		#stop tail command and all terminals

rm -f pipe2stdout			#remove pipe2stdout 
rm -f pipe2stderr			#remove pipe2stderr