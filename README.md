# Build and push a new version

0. Clone repo: `gh repo clone funatic-nl/openliberty-docker`
1. `cd openliberty-docker/build`
2Build and push image:
   `docker login ghcr.io`
   `docker buildx build --push --platform linux/arm64/v8,linux/amd64 --tag ghcr.io/funatic-nl/keycloak:15 .`
