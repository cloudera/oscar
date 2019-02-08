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

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

export JAVA_HOME="${JAVA_HOME:-/usr}"

export PATH="$PATH:/hadoop/sbin:/hadoop/bin"

export PS1='OSCAR [\u@\h] \w # '

if [ ! -d /data ] ; then
  echo "ERROR: /data doesn't exist; did you start the container with a bind mount?"
  echo "Hint: docker run -it -v /tmp/oscar:/data oscar"
  exit 1
fi

cat /README
/bin/ash

# EOF
