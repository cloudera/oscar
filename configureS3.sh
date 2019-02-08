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

# Import environmental parameters.

source /config.txt

toolsDir='/hadoop/hadoop-tools/hadoop-aws/src/test/resources'
if [ ! -d $toolsDir ] ; then
  echo "ERROR: ${toolsDir} doesn't exist, something's gone horrible wrong. Exiting!"
  exit 1
fi

cd ${toolsDir} || exit 1
cat > "${toolsDir}/auth-keys.xml" <<EOF
<configuration>
  <property>
    <name>fs.s3a.secret.key</name>
    <value>${SECRET_KEY}</value>
  </property>
  <property>
    <name>fs.s3a.access.key</name>
    <value>${ACCESS_KEY}</value>
  </property>
  <property>
    <name>fs.s3.awsAccessKeyId</name>
    <value>${ACCESS_KEY}</value>
  </property>
  <property>
    <name>test.fs.s3a.name</name>
    <value>s3a://${AWS_BUCKET}/</value>
  </property>
  <property>
    <name>fs.contract.test.fs.s3a</name>
    <value>s3a://${AWS_BUCKET}/</value>
  </property>
  <property>
    <name>fs.s3a.endpoint</name>
    <value>${ENDPOINT}</value>
  </property>
</configuration>
EOF

# EOF