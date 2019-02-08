# OSCAR
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

# s3-benchmark
#
# https://github.com/wasabi-tech/s3-benchmark
# https://medium.com/travis-on-docker/multi-stage-docker-builds-for-creating-tiny-go-images-e0e1867efe5a

FROM golang:alpine as builder-s3-benchmark
RUN apk update && apk add git

WORKDIR /app
ADD . /app

# install s3-benchmark
RUN git clone https://github.com/wasabi-tech/s3-benchmark.git
COPY s3-benchmark.go.patch /app/s3-benchmark
WORKDIR /app/s3-benchmark
RUN patch < s3-benchmark.go.patch
RUN go get github.com/aws/aws-sdk-go code.cloudfoundry.org/bytefmt
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' .
RUN mkdir -p /export/bin

# Export dependencies
RUN cp /app/s3-benchmark/s3-benchmark /export/bin/


# protobufs
#
# (adapted) https://gist.github.com/rizo/513849f35178d19a13adcddf2d045a19

FROM alpine:latest as builder-protobuf

# setup
RUN apk update && apk add curl build-base autoconf automake libtool

# install protoc
ENV PROTOBUF_URL https://github.com/google/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz
RUN curl -L -o /tmp/protobuf.tar.gz $PROTOBUF_URL
WORKDIR /tmp/
RUN tar xvzf protobuf.tar.gz
WORKDIR /tmp/protobuf-2.5.0
RUN mkdir /export
RUN ./autogen.sh && \
    ./configure --prefix=/export && \
    make -j 3 && \
    make check && \
    make install

# Export dependencies
RUN cp /usr/lib/libstdc++* /export/lib/
RUN cp /usr/lib/libgcc_s* /export/lib/


#
# start with lightweight JDK image
#

FROM java:8-alpine

# Maven
#
# (adapted) https://github.com/Zenika/alpine-maven
# SUREFIRE-1422 Forking fails on Linux if /bin/ps isn't available

RUN set -euxo pipefail && \
    apk add --no-cache --update ca-certificates procps && rm -rf /var/cache/apk/* 

ENV MAVEN_VERSION 3.5.4
ENV MAVEN_HOME /usr/lib/mvn
ENV PATH $MAVEN_HOME/bin:$PATH

RUN wget http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
  tar -zxvf apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
  rm apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
  mv apache-maven-${MAVEN_VERSION} /usr/lib/mvn

# protobufs <-- builder, needed for Hadoop stage
COPY --from=builder-protobuf /export /usr

# Hadoop
#
# (adapted) https://github.com/HariSekhon/Dockerfiles

ENV HADOOP_VERSION=branch-3.0.3
WORKDIR /

# clone the hadoop repo
RUN set -euxo pipefail && \
    apk add --update ca-certificates git && rm -rf /var/cache/apk/* && \
    git clone git://github.com/apache/hadoop.git && \
    cd /hadoop && \
    git checkout ${HADOOP_VERSION} && \
    apk del git

# once it's all working, add this to previous layer
WORKDIR /hadoop
RUN mvn -pl hadoop-tools/hadoop-aws install -DskipTests -DskipShade

# wrapping up
#
COPY --from=builder-s3-benchmark /export /usr

WORKDIR /
COPY entrypoint.sh /
COPY README /
COPY configureS3.sh /
COPY runHadoopAwsTests.sh /
COPY runBenchmark.sh /
COPY config.txt /
CMD "/entrypoint.sh"

# EOF
