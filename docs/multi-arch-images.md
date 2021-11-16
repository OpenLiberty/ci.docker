# How to Create a Multi-Arch Image

If you often create container images on multiple architectures, creating a single multi-architecture image can be useful. It is important to know that a multi-architecture image is not a standard image, it is actually what we call a "fat manifest" or "manifest list". A manifest list is created from images that have the same function, but were created on different platforms/OS. The manifest list is only comprised of a list of image manifest references for the images that were created on different platforms. The manifest list can then be used as a standard image when running `docker pull` or `docker run`. To create a multi-arch image, we will use [estesp/manifest-tool](https://github.com/estesp/manifest-tool).

## Installation 
To install the manifest-tool, download the [latest release](https://github.com/estesp/manifest-tool/releases/).

## Usage 
There are two methods of creating the manifest list: `from-spec` and `from-args`. We will go through both methods in the following examples. For this guide I will be using this [sample app](https://github.com/OpenLiberty/ci.docker/tree/master/community/samples/spring-petclinic). 

### from-spec
To begin, we will create an image on two different platforms. The image will be called `multi-arch` and we will name the tag after our architecture. If you do not know your architecture you can run `uname -p` from your terminal.

First we will build an image for MacOS.

`docker build -t <your_registry>/<your_repo>/multi-arch:amd64 -f Dockerfile .`

Next, push the image to your registry.

`docker push <your_registry>/<your_repo>/multi-arch:amd64` 

Now we will perform the same steps for a Linux s390x system.

`docker build -t <your_registry>/<your_repo>/multi-arch:s390x -f Dockerfile .`
`docker push <your_registry>/<your_repo>/multi-arch:s390x` 

After the images have been pushed and appear in your registry, create a yaml file composed of your source images and a target image. The image key that appears first in the file defines the target image while the others define a source image. From the two images we created, our file will contain the following values.

```yaml
image: <your_registry>/<repo_name>/multi-arch:latest
manifests:
  -
    image: <your_registry>/<repo_name>/multi-arch:s390x
    platform:
      architecture: s390x
      os: linux
  -
    image: <your_registry>/<repo_name>/multi-arch:amd64
    platform:
      architecture: amd64
      os: linux
```

Finally, to build our manifest list we use the manifest tool's `push from-spec` command.
`./manifest-tool push multi-arch.yaml`
NOTE: Users on MacOS will have to specify `--username` and `--password` for their registry from the terminal when using `./manifest-tool`. 
`./manifest-tool --username <your_username> --password <your_password> push multi-arch.yaml`

We can run the `inspect` command on our multi-arch image to verify that both of our manifest references appear in the manifest list.
`/manifest-tool inspect <your_registry>/<your_repo>/multi-arch:latest`

Now you will be able to execute a `docker run` on the multi-arch image from either platform as if it were a standard image.
`docker run <your_registry>/<your_repo>/multi-arch`

### from-args
Continuing from the last example, after the images have been pushed to their registry. You may run command line arguments to push your manifest list. Remember if you are on Mac you must specify `--username` and `--password`. 

```
./manifest-tool push from-args \
    --platforms linux/amd64,linux/s390x \
    --template <your_registry>/<your_repo>/multi-arch:ARCH \
    --target <your_registry>/<your_repo>/multi-arch:latest
```

Subsequently, you will be able to execute `docker run <your_registry>/<your_repo>/multi-arch` from either platform as if it were a standard image.

## Closing Remarks

When updating the source manifests for your multi-arch image, it is important to ensure that all of the images have been updated in your registry before pushing the new manifest. For more information on the `manifest-tool` check out the source Github [estesp/manifest-tool](https://github.com/estesp/manifest-tool).
