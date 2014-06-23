#!/bin/sh
service nginx start
service elasticsearch start
service td-agent start

/usr/sbin/sshd -D
