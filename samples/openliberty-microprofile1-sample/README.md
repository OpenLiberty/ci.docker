# Docker Sample for Open Liberty MicroProfile

We will use a simple hello world example application
called `sample.war` here to demonstrate how easy it is
to run your own application in docker.

## Build the image

    docker build -t "openliberty/openliberty-microprofile1-sample" .

## Run the image

    docker run -d -p 9080:9080 --name sample openliberty/openliberty-microprofile1-sample

## Test the image

Check the logs for the container to see Open Liberty booting up:

    docker logs -f sample

OpenLiberty will prompt the following message, when it's finished starting:

    CWWKZ0001I: Application sample started in 1.930 seconds.
    ...
    CWWKF0011I: The server defaultServer is ready to run a smarter planet.


Hit `Ctrl + c` to exit the log tail. Call the following URL in your browser:

    http://localhost:9080/sample/resources/hello

You should be greeted with the following message:

    Hello, this is the OpenLiberty docker sample app!

## Stop the image
To clean up afterwards, run these commands that will stop and delete the container:

    docker stop sample
    docker rm sample

## Run your own app

Just copy the Dockerfile to your application folder and point the 'sample.war'
to your packaged application.

Execute the build and run commands, as shown above but of course should change
the image name from `openliberty/openliberty-microprofile1-sample` to something more
meaningful to you.
