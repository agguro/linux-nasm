#!/bin/bash -u
#
testvar=`printenv TESTVAR`;
if [ -n "${testvar}" ]; then
  echo "value of TESTVAR as defined in ./exeapp3 is $testvar"
else
  echo "TESTVAR is not defined, you should run this script with ./exeapp3"
fi

  