# Configuring Security

## TLS certificate configuration

### Automatically trust known certificate authorities

To enable trust certificates from known certificate authorities `SEC_TLS_TRUSTDEFAULTCERTS` environment variable can be set.
Default value is `false`. If set to true, then the default certificates are used in addition to the configured truststore file to establish trust.

### Providing custom certificates

It is possible to provide custom PEM certifacates by mounting the files into the container. Files that will be imported are `tls.key`, `tls.crt` and `ca.crt`.

The location can be specified by `TLS_DIR` environment variable. Default location
for certificates is `/etc/x509/certs/`.

The container will automatically convert PEM file and create a keystore and truststore files (key.p12 and trust.p12).

Container also can import certificates from Kubernetes.
If `SEC_IMPORT_K8S_CERTS` is set to `true` and `/var/run/secrets/kubernetes.io/serviceaccount` folder is mounted into container the `.crt` files will be imported into the the truststore file. Default value is `false`.


### Providing custom keystore

A custom keystore can be provided during the application image's build phase by simply copying the keystore into the image's  `/output/resources/security/key.p12` location. 

You must then override the keystore's password by including your copy of the `keystore.xml` file inside the `/config/configDropins/defaults/` directory.


## Social Login configuration
The following variables configure container security using the socialLogin-1.0 feature.  

### Configuration needed at image build time:

 * The environment variable `SEC_SSO_PROVIDERS` must be defined and contain a space delimited list of the identity providers to use. If more than one is specified, the user will be able to choose which one to authenticate with. Valid values are any of `oidc oauth facebook twitter github google linkedin`.  Specify `ARG SEC_SSO_PROVIDERS="(your choice goes here)"` in your Dockerfile.

 * Providers usually require the use of HTTPS.  Specify `ARG TLS=true` in your Dockerfile. 

 * To automatically trust certificates from well known identity providers, specify  `ARG SEC_TLS_TRUSTDEFAULTCERTS=true` in your Dockerfile.

 * To automatically trust certificates issued by the Kubernetes cluster, specify `ARG IMPORT_K8S_CERTS=true` in your Dockerfile.

 * Your Dockerfile must call configure.sh for these to take effect. 

### Configuration needed at image build time or at container deploy time:

Each provider needs some additional configuration to be functional -  a client Id, client secret and sometimes more. These variables can be supplied in several ways:
  * At build time, they can be variables in a server.xml file (`<variable name="foo" value="bar" />`).
  * At build time, they can be ENV variables in the Dockerfile, this is less secure (`ENV name=value`).
  * They can be passed as environment variables to the Docker container when it is deployed. 
  * They can be supplied in a deployment YAML file or by the [Liberty operator](https://github.com/OpenLiberty/open-liberty-operator/tree/master/doc), which will pass them to the container at deploy time.

Client ID and Client Secret are obtained from the provider.  RedirectToRPHostAndPort (`SEC_SSO_REDIRECTTORPHOSTANDPORT`) is the protocol, host, and port that the provider should send the browser back to after authentication, for example `https://myApp-myNamespace-myClusterHostname.mycompany.com`  (In some container environments, the pod cannot figure this out and it will need to be specified.) Other variables may be needed in some situations and are documented in detail in the [Open Liberty Documentation](https://openliberty.io/docs/ref/feature/#socialLogin-1.0.html) under each type of provider. The `oidc` and `oauth2` configurations are general purpose configurations for use with any provider that uses the OpenID Connect 1.0 or OAuth 2.0 specifications.

A sample Dockerfile and Liberty operator YAML file are [here](samples/security).


#### Common properties for all providers:

 name                                 | required  |
|------------------------------------ | ------ |
|SEC_SSO_REDIRECTTORPHOSTANDPORT | n |
|SEC_SSO_MAPTOUSERREGISTRY       | n |

#### Provider-specific additional properties:
(The Id attribute for all providers has a fixed default value).

 name                                 | required for this provider |
|------------------------------------ | ------ |
|SEC_SSO_GOOGLE_CLIENTID       | y |
|SEC_SSO_GOOGLE_CLIENTSECRET   | y |
|||
|SEC_SSO_GITHUB_CLIENTID       | y |
|SEC_SSO_GITHUB_CLIENTSECRET   | y  |
|SEC_SSO_GITHUB_HOSTNAME <br> (needed for Github Enterprise)<br>`(example: github.mycompany.com)`     | n| 
|||
|SEC_SSO_FACEBOOK_CLIENTID       | y |
|SEC_SSO_FACEBOOK_CLIENTSECRET   | y |
|||
|SEC_SSO_TWITTER_CONSUMERKEY     | y |
|SEC_SSO_TWITTER_CONSUMERSECRET  | y |
|||
SEC_SSO_LINKEDIN_CLIENTID             | y |
SEC_SSO_LINKEDIN_CLIENTSECRET         | y |
|||
|SEC_SSO_OIDC_CLIENTID                | y |
|SEC_SSO_OIDC_CLIENTSECRET            | y |
|SEC_SSO_OIDC_DISCOVERYENDPOINT       | y |
|SEC_SSO_OIDC_GROUPNAMEATTRIBUTE      | n |
|SEC_SSO_OIDC_USERNAMEATTRIBUTE       | n |
|SEC_SSO_OIDC_DISPLAYNAME             | n |
|SEC_SSO_OIDC_USERINFOENDPOINTENABLED | n |
|SEC_SSO_OIDC_REALMNAMEATTRIBUTE      | n |
|SEC_SSO_OIDC_SCOPE                   | n |
|SEC_SSO_OIDC_TOKENENDPOINTAUTHMETHOD | n |
|SEC_SSO_OIDC_HOSTNAMEVERIFICATIONENABLED  | n |
|||
|SEC_SSO_OAUTH2_CLIENTID                 |y|
|SEC_SSO_OAUTH2_CLIENTSECRET             |y|
|SEC_SSO_OAUTH2_TOKENENDPOINT            |y|
|SEC_SSO_OAUTH2_AUTHORIZATIONENDPOINT    |y|
|SEC_SSO_OAUTH2_SCOPE                   | n |
|SEC_SSO_OAUTH2_GROUPNAMEATTRIBUTE      | n |
|SEC_SSO_OAUTH2_USERNAMEATTRIBUTE       | n |
|SEC_SSO_OAUTH2_DISPLAYNAME             | n |
|SEC_SSO_OAUTH2_REALMNAMEATTRIBUTE      | n |
|SEC_SSO_OAUTH2_REALMNAME               | n |
|SEC_SSO_OAUTH2_TOKENENDPOINTAUTHMETHOD | n |
|SEC_SSO_OAUTH2_ACCESSTOKENHEADERNAME   | n |
|SEC_SSO_OAUTH2_ACCESSTOKENREQUIRED     | n |
|SEC_SSO_OAUTH2_ACCESSTOKENSUPPORTED    | n |
|SEC_SSO_OAUTH2_USERAPITYPE             | n |
|SEC_SSO_OAUTH2_USERAPI                 | n |
|SEC_SSO_OAUTH2_USERAPITOKEN            | n |


