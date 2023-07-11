#!/bin/bash

# hack to bump up the pid by 100
for i in {1..100}
do
    pidplus.sh
done

echo "Performing checkpoint --at=$1"
/opt/ol/wlp/bin/server checkpoint --at=$1

rc=$?
exit $rc
