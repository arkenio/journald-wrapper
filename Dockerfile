# Journald wrapper to cloudwatch
#
# VERSION               0.0.1

FROM       ubuntu:trusty
MAINTAINER Nuxeo <contact@nuxeo.com>

RUN locale-gen --no-purge en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# First install apt needed utility package
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y build-essential ruby-dev

RUN gem install em-eventsource
# Need to install aws-skd v2 preview version
RUN gem install aws-sdk --pre

ADD wrapper.rb /root/wrapper.rb

CMD /root/wrapper.rb
