#! /bin/bash
#####################################################################################
#                                                                                   #
#  Script to verify an Open Liberty image certificates                              #
#                                                                                   #
#                                                                                   #
#  Usage : verifyLibertyCertificates.sh <Image name>                                #                   #
#                                                                                   #
#####################################################################################

image=$1
tag=`echo $image | cut -d ":" -f2`
cname="${tag}test"
DOCKER=docker

testLibertyCertificates()
{
    cid=$($DOCKER run -d $image)
    # Wait until the server starts to know that the certs have been loaded 
    maxRetry=10
    i=0
    serverLaunched=false
    while [ $serverLaunched = false ] && [ $i -lt $maxRetry ]; do
        sleep 1
        echo "Checking logs ($(( $i + 1 ))/$maxRetry)"
        launchMessage=$($DOCKER logs $cid | grep "Launching defaultServer" -c)
        if [ $launchMessage -eq 1 ]; then
            echo "Launch message found!"
            serverLaunched=true
        fi
        i=$(( $i + 1 ))
    done
    if [ $serverLaunched = false ]; then
        echo "Server failed to start"
        $DOCKER logs $cid
        $DOCKER stop $cid >/dev/null
        $DOCKER rm -f $cid >/dev/null
        exit 1
    fi

    # Validate that openssl package is present in the Liberty image
    $DOCKER exec -it $cid sh -c "which openssl"
    if [ $? != 0 ]
    then
        echo "Server failed to generate keystore"
        $DOCKER logs $cid
        $DOCKER stop $cid >/dev/null
        $DOCKER rm -f $cid >/dev/null
        exit 1
    fi

    # Validate that the certificate is added to the Liberty default keystore
    $DOCKER exec -it $cid sh -c "ls /output/resources/security/key.p12"
    if [ $? != 0 ]
    then
        echo "Server failed to add certificate to keystore"
        $DOCKER logs $cid
        $DOCKER stop $cid >/dev/null
        $DOCKER rm -f $cid >/dev/null
        exit 1
    fi

    # Validate that the certificate is added to the Liberty default truststore
    $DOCKER exec -it $cid sh -c "ls /output/resources/security/trust.p12"
    if [ $? != 0 ]
    then
        echo "Server failed to add certificate to truststore"
        $DOCKER logs $cid
        $DOCKER stop $cid >/dev/null
        $DOCKER rm -f $cid >/dev/null
        exit 1
    fi
    $DOCKER stop $cid >/dev/null
    $DOCKER rm -f $cid >/dev/null
}

tests=$(declare -F | cut -d" " -f3 | grep "test")
for name in $tests
do
   timestamp=$(date '+%Y/%m/%d %H:%M:%S')
   echo "$timestamp *** $name - Executing"
   eval $name
   timestamp=$(date '+%Y/%m/%d %H:%M:%S')
   echo "$timestamp *** $name - Completed successfully"
done