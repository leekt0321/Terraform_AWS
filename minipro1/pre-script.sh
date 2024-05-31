#!/bin/bash
# 키 생성 자동화 스크립트
echo -n "Enter Your filename(ex: leekey): "
read SSH_KEY_FILE

ssh-keygen -t rsa -f ~/.ssh/$SSH_KEY_FILE -N ''
# ssh-keygen -t rsa -f ~/.ssh/test1 -N ''