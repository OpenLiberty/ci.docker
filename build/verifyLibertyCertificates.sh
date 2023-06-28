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
   cid=$1
   # Validate that openssl package is present in the Liberty image
   $DOCKER exec -it $cid sh -c "which openssl"
   if [ $? != 0 ]
   then
      echo "Server failed to generate keystore"
      $DOCKER logs $cid
      $DOCKER rm -f $cid >/dev/null
      exit 1
   fi

   # Validate that the certificate is added to the Liberty default keystore
   $DOCKER exec -it $cid sh -c "ls /output/resources/security/key.p12"
   if [ $? != 0 ]
   then
      echo "Server failed to add certificate to keystore"
      $DOCKER logs $cid
      $DOCKER rm -f $cid >/dev/null
      exit 1
   fi

   # Validate that the certificate is added to the Liberty default truststore
   $DOCKER exec -it $cid sh -c "ls /output/resources/security/trust.p12"
   if [ $? != 0 ]
   then
      echo "Server failed to add certificate to truststore"
      $DOCKER logs $cid
      $DOCKER rm -f $cid >/dev/null
      exit 1
   fi
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