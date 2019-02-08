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

# OSCAR

OSCAR is a diagnostic tool that assesses whether an object store is suitable for use with [Apache Hadoop](https://hadoop.apache.org/).

Two types of evaluations are included:

* filesystem operations, via [Hadoop FileSystem contract tests](https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/filesystem/testing.html)
* performance assessment, via simple GET/PUT/DELETE benchmarking

OSCAR is a small repo to clone, fast to deploy, and easy to configure.

:warning: OSCAR is an information gathering tool only; its usage in no way implies product certification or support from Cloudera.

## Requirements

* Docker 17.05 or higher (for multi-stage builds)

## Setup

Clone the repo.

```shell
git clone https://github.com/cloudera/oscar
```

Follow the [getting started](https://docs.docker.com/get-started/) instructions to install and start Docker.

Short version:

```shell
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo systemctl enable docker  
sudo systemctl start docker
```

System packages are OK, too, so long as the Docker version requirement is met.

Create a dedicated bucket to use for the testing. For example, to create a bucket on S3 using the [AWS CLI](https://aws.amazon.com/cli/):

```shell
aws s3 mb s3://oscar-test
```

Creation method will vary depending on the object store being used.

## Build

```shell
docker build -t oscar .
```

This will take 25-30 minutes, but only needs to be done once.

## Run

```shell
docker run -it -v /tmp/oscar:/data oscar
```

Follow the instructions at login, also visible in [README](README).

Having problems? Check out the [FAQ](FAQ.md).

When you're all done, [detach](https://docs.docker.com/engine/reference/commandline/attach/#extended-description) (CTRL-p CTRL-q) from or exit the container; output files will be in `/tmp/oscar` on your host.

:warning: The Docker image is intended to be launched, configured, used to run a handful of tests, and be discarded afterward. If you exit, your configuration will be discarded. This is in part to protect the object store secret keys present on disk. If you wish to retain configuration files or other data, move them to the container's `/data` directory before exiting. (Files in the `/data` directory will be retained in the `/tmp/oscar` directory on the host machine.)

## Results


### runHadoopAwsTests

The desired result of `runHadoopAwsTests` is for Maven to return "BUILD SUCCESS" at the end.

```shell
OSCAR [root@b239929eca3b] / # ./runHadoopAwsTests.sh
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running org.apache.hadoop.fs.contract.s3a.ITestS3AContractCreate
[WARNING] Tests run: 11, Failures: 0, Errors: 0, Skipped: 2, Time elapsed: 31.522 s - in org.apache.hadoop.fs.contract.s3a.ITestS3AContractCreate
[INFO] Running org.apache.hadoop.fs.contract.s3a.ITestS3AContractDelete
[INFO] Tests run: 8, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 21.601 s - in org.apache.hadoop.fs.contract.s3a.ITestS3AContractDelete
[INFO] Running org.apache.hadoop.fs.contract.s3a.ITestS3AContractDistCp
[INFO] Tests run: 4, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 73.149 s - in org.apache.hadoop.fs.contract.s3a.ITestS3AContractDistCp
[INFO] Running org.apache.hadoop.fs.contract.s3a.ITestS3AContractGetFileStatus
[INFO] Tests run: 18, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 78.664 s - in org.apache.hadoop.fs.contract.s3a.ITestS3AContractGetFileStatus
[INFO] Running org.apache.hadoop.fs.contract.s3a.ITestS3AContractMkdir
[INFO] Tests run: 7, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 38.436 s - in org.apache.hadoop.fs.contract.s3a.ITestS3AContractMkdir
[INFO] Running org.apache.hadoop.fs.contract.s3a.ITestS3AContractOpen
[INFO] Tests run: 6, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 12.291 s - in org.apache.hadoop.fs.contract.s3a.ITestS3AContractOpen
[INFO] Running org.apache.hadoop.fs.contract.s3a.ITestS3AContractRename
[INFO] Tests run: 8, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 32.802 s - in org.apache.hadoop.fs.contract.s3a.ITestS3AContractRename
[INFO] Running org.apache.hadoop.fs.contract.s3a.ITestS3AContractRootDir
[INFO] Tests run: 9, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 12.724 s - in org.apache.hadoop.fs.contract.s3a.ITestS3AContractRootDir
[INFO] Running org.apache.hadoop.fs.contract.s3a.ITestS3AContractSeek
[INFO] Tests run: 18, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 42.37 s - in org.apache.hadoop.fs.contract.s3a.ITestS3AContractSeek
[INFO] Running org.apache.hadoop.fs.s3a.ITestS3AContractGetFileStatusV1List
[INFO] Tests run: 18, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 70.802 s - in org.apache.hadoop.fs.s3a.ITestS3AContractGetFileStatusV1List
[INFO]
[INFO] Results:
[INFO]
[WARNING] Tests run: 107, Failures: 0, Errors: 0, Skipped: 2
[INFO]
[INFO]
[INFO] --- animal-sniffer-maven-plugin:1.16:check (signature-check) @ hadoop-aws ---
[INFO] Checking unresolved references to org.codehaus.mojo.signature:java18:1.0
[INFO]
[INFO] --- maven-enforcer-plugin:3.0.0-M1:enforce (depcheck) @ hadoop-aws ---
[INFO]
[INFO] --- maven-failsafe-plugin:2.21.0:verify (default) @ hadoop-aws ---
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 07:08 min
[INFO] Finished at: 2018-11-30T17:03:50Z
[INFO] ------------------------------------------------------------------------
```

If the run doesn't return "BUILD SUCCESS", you may need to adjust object store configuration parameters. Each object store is little different, so we'd like to know what actions were taken so we can provide better guidance.

### runBenchmark

The desired result of `runBenchmark` is four sets of the following output, one for each size of object we're benchmarking.

```
Parameters: url=https://s3.us-west-2.amazonaws.com, bucket=oscar, region=us-west-2, duration=60, threads=10, loops=1, size=10M
Loop 1: PUT time 62.8 secs, objects = 722, speed = 115MB/sec, 11.5 operations/sec. Slowdowns = 0
Loop 1: GET time 61.7 secs, objects = 650, speed = 105.4MB/sec, 10.5 operations/sec. Slowdowns = 0
Loop 1: DELETE time 5.0 secs, 143.2 deletes/sec. Slowdowns = 0
```

## License

Apache License, Version 2.0
http://www.apache.org/licenses/LICENSE-2.0
