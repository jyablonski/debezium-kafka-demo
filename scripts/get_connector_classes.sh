#!/usr/bin/env bash

curl -s -XGET http://localhost:8083/connector-plugins| jq '.[].class'