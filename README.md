# Build and push a new version

0. Clone repo: `gh repo clone funatic-nl/openliberty-docker`
1. `cd openliberty-docker/build`
2. Build and push image:
   `docker login ghcr.io`
   `./build.sh --dir=../releases/latest/full --dockerfile=Dockerfile.ubuntu.openjdk8 --tag=ghcr.io/funatic-nl/open-liberty:full`
