<!--
  Copyright 2018-2019 Cloudera, Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
      http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->

# FAQ

## Big Picture Stuff

Q. When you say "suitable for use with Apache Hadoop" what does that mean?  
A. When an object store adheres to the [Hadoop FileSystem API Definition](http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/filesystem/index.html).

## Running

Q. How long does it take to build the image?  
A. Under 10 minutes on a 4 core system. YMMV.

Q. How long does it take to run the tests?  
A. `runHadoopAwsTests` takes less than 2 minutes if in the same datacenter; across the WAN it might take 6-7 minutes. `runBenchmark` should take about 15 minutes.

Q. Where should I run this thing?  
A. Ideally on the same network as your clients reside, or perhaps your end users if they're the ones making the calls to the object store. Or try it from different places and see how the results vary. You do **not** need to run OSCAR from the nodes that host your object store, but it can be beneficial to run OSCAR from nodes with a similar hardware and network profile as the nodes running CDH.


## Troubleshooting

Q. Are your Hadoop contract tests hanging?  
A. Did you add your self-signed certificate's CA and root cert to the Java truststore?

Q. How do I add my CA and root cert to the Java truststore?  
A. Try this little script, which assumes your certs are located on a webserver (ca-server) in the `certs` directory.

```shell
#!/bin/ash

web_root=http://ca-server/certs
for cert in intemediate_ca.cert.pem root_ca.cert.pem ; do
  if [ ! -f $cert ] ; then
    wget "$web_root/$cert"
  fi
  keytool -import -trustcacerts -keystore /usr/lib/jvm/java-1.8-openjdk/jre/lib/security/cacerts \
    -noprompt -file $cert -alias $cert --storepass changeit
done
```

Q. I'm not able to use [AWS Command Line Interface](https://aws.amazon.com/cli/) with my object store...  
A. For AWS CLI, the following is needed for Python to use self-signed certificates. Concatenate your root and intemediate CA certs together.

```shell
export REQUESTS_CA_BUNDLE=~/custom_ca_bundle.pem
aws --profile objectStore --endpoint-url https://endpoint s3 ls
```

Note: After exporting the CA bundle for Python to use, requests to AWS S3 will fail. Run `unset REQUESTS_CA_BUNDLE` before issuing commands to AWS S3.

## Common Error Messages

### Error uploading object

Most commonly seen when running `runBenchmark` against AWS S3.

```
2018/12/11 17:31:14 FATAL: Error uploading object https://s3.us-west-2.amazonaws.com/oscar/Object-434: Put https://s3.us-west-2.amazonaws.com/oscar/Object-434: EOF
2018/12/11 17:39:17 FATAL: Error uploading object https://s3.us-west-2.amazonaws.com/oscar/Object-246: Put https://s3.us-west-2.amazonaws.com/oscar/Object-246: EOF
```

If this persists, trying a different bucket name will often result in a passing test.

### TooManyBuckets

Most commonly seen when running `runBenchmark` against AWS S3.

```
2018/12/11 17:32:01 FATAL: Unable to create bucket oscar (is your access and secret correct?): 
    TooManyBuckets: You have attempted to create more buckets than allowed  
    status code: 400, request id: ABCDEFG1234567, host id: abcdefg123456=
```

Two possibilities:

* the bucket already exists
* you really do have too many buckets, such that creating one more would exceed your account limit

Try a different bucket name or delete a bucket, then try again. If the errors persist, request your account limits be raised.

## Store-Specific Things

### Ceph

If the Hadoop contract tests are hanging, make sure your bucket name is all uppercase.

