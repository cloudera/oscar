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

source /config.txt

url="https://${ENDPOINT}"
threads=10
duration=180
sizes="1M 10M 128M 1G"

cd /data || exit 1
for size in ${sizes} ; do

  /usr/bin/s3-benchmark -a ${ACCESS_KEY} -s ${SECRET_KEY} -b ${AWS_BUCKET} \
    -r ${REGION} -t ${threads} -d ${duration} -z ${size} -u ${url}

  # brief pause between runs
  sleep 5

done

# move benchmark log to archive for retrieval
if [ -f 'benchmark.log' ] ; then
  testArchiveFile="/data/benchmark_$(date +%Y%m%d%H%M.%S)_.log"
  if mv benchmark.log "${testArchiveFile}" ; then
    echo "Test output archived to ${testArchiveFile}."
    echo
    echo "Please consider sending a copy of your test output to us for review."
  else
    echo "ERROR: Couldn't move benchmark log to ${testArchiveFile}."
  fi
else
  echo "ERROR: benchmark.log is missing!"
  exit 1
fi

# EOF