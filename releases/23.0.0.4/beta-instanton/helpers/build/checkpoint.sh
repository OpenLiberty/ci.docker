#!/bin/bash

# hack to bump up the pid by 100
for i in {1..100}
do
    pidplus.sh
done

echo "Performing checkpoint --at=$1"
/opt/ol/wlp/bin/server checkpoint defaultServer --at=$1

rc=$?
if [ $rc -ne 0 ] && [ -f "/logs/checkpoint/checkpoint.log" ]; then
    echo "Checkpoint failed. The following is the checkpoint.log from CRIU ..."
    cat /logs/checkpoint/checkpoint.log
fi

exit $rc
