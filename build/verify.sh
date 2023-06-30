#! /bin/bash
#####################################################################################
#                                                                                   #
#  Script to verify an Open Liberty image                                       #
#                                                                                   #
#                                                                                   #
#  Usage : verify.sh <Image name>                                                   #
#                                                                                   #
#####################################################################################

image=$1
tag=`echo $image | cut -d ":" -f2`
cname="${tag}test"
DOCKER=docker

waitForServerStart()
{
   image=$1
   count=${2:-1}
   end=$((SECONDS+120))
   while (( $SECONDS < $end ))
   do
      result=$($DOCKER logs $image 2>&1 | grep "CWWKF0011I" | wc -l)
      if [ $result = $count ]
      then
         return 0
      fi
   done

   echo "Liberty failed to start the expected number of times"
   return 1
}

waitForServerStop()
{
   image=$1
   end=$((SECONDS+120))
   while (( $SECONDS < $end ))
   do
      result=$($DOCKER logs $image 2>&1 | grep "CWWKE0036I" | wc -l)
      if [ $result = 1 ]
      then
         return 0
      fi
   done

   echo "Liberty failed to stop within a reasonable time"
   return 1
}

testLibertyStopsAndRestarts()
{
   staticImage=$2
   if [ "$1" == "OpenShift" ]; then
      timestamp=$(date '+%Y/%m/%d %H:%M:%S')
      echo "$timestamp *** testLibertyStopsAndRestarts on OpenShift"
      $DOCKER run -d -u 1005:0 $security_opt $image
   else
      $DOCKER run -d $security_opt $image
   fi
   
   if [ $? != 0 ]
   then
      echo "Failed to run container; exiting"
      exit 1
   fi
   
   waitForServerStart $image
   if [ $? != 0 ]
   then
      echo "Liberty failed to start; exiting"
      $DOCKER logs $image
      $DOCKER rm -f $image >/dev/null
      exit 1
   fi
   sleep 45
   $DOCKER stop $image >/dev/null
   if [ $? != 0 ]
   then
      echo "Error stopping container or server; exiting"
      $DOCKER logs $image
      $DOCKER rm -f $image >/dev/null
      exit 1
   fi

   $DOCKER start $image >/dev/null
   if [ $? != 0 ]
   then
      echo "Failed to rerun container; exiting"
      $DOCKER logs $image
      $DOCKER rm -f $image >/dev/null
      exit 1
   fi

   if [ "$staticImage" = "true" ]; then
      waitForServerStart $image 2
   else
      waitForServerStart $image
   fi
   if [ $? != 0 ]
   then
      echo "Server failed to restart; exiting"
      $DOCKER logs $image
      $DOCKER rm -f $image >/dev/null
      exit 1
   fi

   $DOCKER logs $image 2>&1 | grep "ERROR"
   if [ $? = 0 ]
   then
      echo "Errors found in logs for container; exiting"
      echo "DEBUG START full log"
      $DOCKER logs $image
      echo "DEBUG END full log"
      $DOCKER rm -f $image >/dev/null
      exit 1
   fi

   $DOCKER rm -f $image >/dev/null
}

testDockerOnOpenShift()
{
   testLibertyStopsAndRestarts "OpenShift"
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
