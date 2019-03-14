#!/bin/sh

find official -type d -name "helpers" | xargs -n 1 cp -a common/helpers/*
find official -type d -name "configure.sh" | xargs -n 1 cp -a common/helpers/*
find official -type f -name "configure.sh" | egrep ibmsfj | xargs -n 1 cp -a common/configure_ibmsfj.sh

find community -type d -name "helpers" | xargs -n 1 cp -a common/helpers/*
