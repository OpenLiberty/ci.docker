#!/bin/bash

# commented out for now to force user to specify checkpoint-1.0 feature
#Enable checkpoint-1.0 feature
#echo "<server><featureManager><feature>checkpoint-1.0</feature></featureManager></server>" > /config/configDropins/defaults/checkpoint.xml
#touch -t 210001010100 /config/configDropins/defaults/checkpoint.xml

# run configure to get the checkpoint-1.0 feature installed
#echo "Running configure to enable checkpoint-1.0 feature"
#configure.sh

# hack to bump up the pid by 100
for i in {1..100}
do
    pidplus.sh
done

echo "Performing checkpoint --at=$1"
/opt/ol/wlp/bin/server checkpoint defaultServer --at=$1 -Dcom.ibm.ws.beta.edition=true

exit 0
