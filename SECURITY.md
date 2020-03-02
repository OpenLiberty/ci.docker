## Configuring Security


The following variables configure container security using the socialLogin-1.0 feature.  

### Configuration needed at image build time:

 * The environment variable `sec_sso_providers` must be defined and contain a space delimited list of the identity providers to use. If more than one is specified, the user will be able to choose which one to authenticate with. Valid values are any of `oidc oauth facebook twitter github google linkedin`.  Specify `ARG sec_sso_providers="(your choice goes here)"` in your Dockerfile.

 * Providers usually require the use of HTTPS.  Specify `ARG TLS=true` in your Dockerfile. 

 * To automatically trust certificates from well known identity providers, specify  `ARG SEC_TLS_TRUSTDEFAULTCERTS=true` in your Dockerfile.

### Configuration needed at image build time or at container deploy time:

Each provider needs some additional configuration to be functional -  a client Id, client secret and sometimes more. These variables can be supplied in several ways:
  * At build time, they can be variables in a server.xml file (`<variable name="foo" value="bar" />`).
  * At build time, they can be ENV variables in the Dockerfile, this is less secure (`ENV name=value`).
  * They can be passed as environment variables to the Docker container when it is deployed. 
  * They can be supplied in a deployment yaml file or by the Liberty operator, which will pass them to the container at deploy time.

Client ID and Client Secret are obtained from the provider.  RedirectToRPHostAndPort (`sec_sso_redirectToRPHostAndPort`) is the protocol, host, and port that the provider should send the browser back to after authentication, for example `https://myApp-myNamespace-myClusterHostname.mycompany.com`  (In some container environments, the pod cannot figure this out and it will need to be specified.) Other variables may be needed in some situations and are documented in detail in the [Open Liberty Documentation](https://openliberty.io/docs/ref/feature/#socialLogin-1.0.html) under each type of provider. The `oidc` and `oauth2` configurations are general purpose configurations for use with any provider that uses the OpenID Connect 1.0 or OAuth 2.0 specifications.  


#### Common properties for all providers:

 name                                 | required  |
|------------------------------------ | ------ |
|sec_sso_redirectToRPHostAndPort | n |
|sec_sso_mapToUserRegistry       | n |

#### Provider-specific additional properties:
(The Id attribute for all providers has a fixed default value).

 name                                 | required for this provider |
|------------------------------------ | ------ |
|sec_sso_google_clientId       | y |
|sec_sso_google_clientSecret   | y |
|||
|sec_sso_github_clientId       | y |
|sec_sso_github_clientSecret   | y  |
|sec_sso_github_hostName <br> (needed for Github Enterprise)<br>`(example: github.mycompany.com)`     | n| 
|||
|sec_sso_facebook_clientId       | y |
|sec_sso_facebook_clientSecret   | y |
|||
|sec_sso_twitter_consumerKey     | y |
|sec_sso_twitter_consumerSecret  | y |
|||
sec_sso_linkedin_clientId             | y |
sec_sso_linkedin_clientSecret         | y |
|||
|sec_sso_oidc_clientId                | y |
|sec_sso_oidc_clientSecret            | y |
|sec_sso_oidc_discoveryEndpoint       | y |
|sec_sso_oidc_groupNameAttribute      | n |
|sec_sso_oidc_userNameAttribute       | n |
|sec_sso_oidc_displayName             | n |
|sec_sso_oidc_userInfoEndpointEnabled | n |
|sec_sso_oidc_realmNameAttribute      | n |
|sec_sso_oidc_scope                   | n |
|sec_sso_oidc_tokenEndpointAuthMethod | n |
|sec_sso_oidc_hostNameVerificationEnabled     | n |
|||
|sec_sso_oauth2_clientId                 |y|
|sec_sso_oauth2_clientSecret             |y|
|sec_sso_oauth2_tokenEndpoint            |y|
|sec_sso_oauth2_authorizationEndpoint    |y|
|sec_sso_oauth2_scope                   | n |
|sec_sso_oauth2_groupNameAttribute      | n |
|sec_sso_oauth2_userNameAttribute       | n |
|sec_sso_oauth2_displayName             | n |
|sec_sso_oauth2_realmNameAttribute      | n |
|sec_sso_oauth2_realmName               | n |
|sec_sso_oauth2_tokenEndpointAuthMethod | n |
|sec_sso_oauth2_accessTokenHeaderName   | n |
|sec_sso_oauth2_accessTokenRequired     | n |
|sec_sso_oauth2_accessTokenSupported    | n |
|sec_sso_oauth2_userApiType             | n |
|sec_sso_oauth2_userApi                 | n |
|sec_sso_oauth2_userApiToken            | n |


