#!/usr/bin/env bash

# 2023-07-08 confirmed ghost doesnt seem to fuck w/ the debezium connector after an alter table migration and
# load the 1000 existing records into debezium, it will only track new inserts as expected.
gh-ost \
--user="ghost_user" \
--password="password" \
--host=localhost \
--database="demo" \
--table="movies" \
--verbose \
--alter="alter table demo.movies modify column id bigint" \
--switch-to-rbr \
--allow-on-master \
--cut-over=default \
--exact-rowcount \
--initially-drop-ghost-table \
--panic-flag-file=/tmp/ghost.panic.flag \
--postpone-cut-over-flag-file=ghost.postpone.flag \
--execute