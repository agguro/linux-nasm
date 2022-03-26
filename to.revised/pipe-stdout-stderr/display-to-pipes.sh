#!/bin/bash
#
# This script is used to show stdout and stderr in separate terminals
# It creates two pipes pipe2stdout and pipe2stderr and runs a program 
# given as argument to the script.
# The messages send from the program to stdout are displayed in the stdout terminal,
# the messages send from the program to stderr are displayed in the stderr terminal.


if [[ ! -e pipe2stdout ]]; then
    mknod pipe2stdout p
fi
if [[ ! -e pipe2stderr ]]; then
    mknod pipe2stderr p
fi

exec > >(xterm -e sh -c 'tail -f pipe2stdout'&)
exec > >(xterm -e sh -c 'tail -f pipe2stderr'&)

#add some colors to the terminals
printf "\033[32m\n" | tee pipe2stdout	#green for stdout
printf "\033[31m\n" | tee pipe2stderr	#red for stderr


((./hello | tee pipe2stdout) 3>&1 1>&2 2>&3 | tee pipe2stderr) &> /dev/null

read -n 1 -s -r -p $'Press any key to continue\n'

pkill tail		#stop tail command and all terminals

rm -f pipe2stdout			#remove pipe2stdout 
rm -f pipe2stderr			#remove pipe2stderr
