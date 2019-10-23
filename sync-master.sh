#!/bin/sh

find official -type d -name "helpers" | xargs -n 1 cp -a common/helpers/*
find official -type d -name "configure.sh" | xargs -n 1 cp -a common/helpers/*
find community -type d -name "helpers" | xargs -n 1 cp -a common/helpers/*
