#!/bin/ash
# shellcheck shell=dash
#
# Copyright 2018-2019 Cloudera, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

testDir=/hadoop/hadoop-tools/hadoop-aws
authKeys=${testDir}/src/test/resources/auth-keys.xml

if [ ! -d $testDir ] ; then
  echo "$testDir doesn't exist, something is very wrong. Exiting."
  exit 1
fi

if [ ! -f $authKeys ] ; then
  echo "Auth keys file does not exist. Did you run configureS3.sh yet?"
  exit 1
else 

  #
  # DFS Contract Tests
  #
  cd ${testDir} || exit 1
  mvn verify -Dtest=none -Dit.test=ITestS3AContract*

  testResult=$?
  testStatus='UNKNOWN'

  if  [ $testResult -eq 0 ] ; then
    testStatus='PASS'
  else
    testStatus='FAIL'
  fi
  echo "${testStatus} DFS Contract Tests"

  # archive the output for review
  if [ -d ${testDir}/target ] ; then
    cd ${testDir}/target || exit 1

    testArchiveFile="/data/surefire_$(date +%Y%m%d%H%M.%S)_${testStatus}.tar.gz"
    tar zcf "${testArchiveFile}" failsafe-reports/

    # clear output for fresh runs
    rm -rf ${testDir}/target/failsafe-reports/*

    echo "Test output archived to ${testArchiveFile}."
    echo
    echo "Please consider sending a copy of your test output to us for review."
  fi

  cat /README
fi

# EOF