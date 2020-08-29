#!/bin/bash
sed "s/tagstring/$1/g" manifests/temp.yml > manifests/deploy.yml
