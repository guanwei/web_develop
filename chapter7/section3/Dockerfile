FROM ubuntu:16.04

MAINTAINER GuanWei <285006386@qq.com>

RUN echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse\n \
    deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse\n \
    deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse\n \
    deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse\n \
    deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse\n \
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse\n \
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse\n \
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse\n \
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse\n \
    deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse\n \
    ' > /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -yq
RUN apt-get install sysv-rc-conf salt-minion -yq

ADD minion.conf /etc/salt/minion.d/

RUN sysv-rc-conf salt-minion on
