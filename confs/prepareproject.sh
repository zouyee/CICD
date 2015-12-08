#!/bin/bash

yum install tox

yum install libxml2-python.x86_64 libxml2-devel.x86_64 -y
yum install libxslt-python.x86_64 libxslt-devel.x86_64 -y
pip install git-review

