#!/bin/bash
#commands must be performed by developer in this order
aclocal
#run autoreconf to reconfigure
autoconf
automake --add-missing --foreign
