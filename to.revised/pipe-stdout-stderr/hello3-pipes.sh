#!/bin/bash --init-file
#
# This script is used to show stdout and stderr in separate terminals
# The pipes are created in the program hell3pipes 
# The messages send from the program to stdout are displayed in the stdout terminal,
# the messages send from the program to stderr are displayed in the stderr terminal.

exec > >(./create-pipes)

exec > >(qterminal -- /bin/sh -c 'tail -f pipe2stdout;' && qterminal -- /bin/sh -c 'tail -f pipe2stderr')

#add some colors to the terminals
printf "\033[32m\n" | tee pipe2stdout	#green for stdout
printf "\033[31m\n" | tee pipe2stderr	#red for stderr


(((./hello2 | tee pipe2stdout) 3>&1 1>&2 2>&3 | tee pipe2stderr ) &> /dev/null)

exec > >(./waitforenterkeypress)

pkill tail		#stop tail command and all terminals

rm -f pipe2stdout			#remove pipe2stdout 
rm -f pipe2stderr			#remove pipe2stderr
