# Using ingress to expose services

## What is Ingress?

An Ingress Kubernetes resource is a collection of rules to allow inbound connections to the Kubernetes cluster services. It can be configured to give Kubernetes services externally reachable URLs, terminate TLS connections, offer name-based virtual hosting, and more. Exposing services using Ingress is a better choice than NodePort for production environments. Therefore, if you are enabling ingress, you can set `service.type` to ClusterIP instead of NodePort.

This document provides information on how to configure Ingress resource in [Liberty Helm charts](https://github.com/IBM/charts/tree/master/stable).

## Exposing applications deployed through Liberty Helm chart

If `ingress.enabled` is set to `true` when deploying a Liberty Helm chart, one Ingress resource is created in the specified namespace. The Ingress resource exposes the Kubernetes service created by the Helm chart. In this case, all incoming traffic on  the Ingress controller's address and port is forwarded to the service created by the Helm chart and then forwarded to pods running Liberty servers.

Example Ingress YAML deployed through Liberty Helm chart:

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/affinity: cookie
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/secure-backends: "true"
    nginx.ingress.kubernetes.io/session-cookie-hash: sha1
    nginx.ingress.kubernetes.io/session-cookie-name: route
    ...
  labels:
    app: my-release-ibm-open-libe
    chart: ibm-open-liberty-1.10.0
    heritage: Tiller
    release: my-release
  name: my-release-ibm-open-libe
  namespace: my-namespace
spec:
  rules:
  - host: foo.bar
    http:
      paths:
      - backend:
          serviceName: my-release-ibm-open-libe
          servicePort: 9443
        path: /app1
  tls:
  - hosts:
    - foo.bar
    secretName: foo-bar-tls
```

### Configurations

#### `ingress.host`

Set this to your domain. The domain should resolves to the IP address or DNS of your cluster's Ingress controller.

_Tip_: It is highly recommended to not leave this property empty. Otherwise, some of Ingress features would not work such as session affinity, accessing Ingress on `http://` when `ssl.enabled` is set to `false`.

When a domain name is not available, [nip.io](https://nip.io) service can be used instead. [nip.io](https://nip.io) maps `<anything>[.]<IP Address>.nip.io` to the corresponding `<IP Address>`.  For example, `dev.<IP>.nip.io` where `<IP>` would be replaced with the IP address or DNS of your cluster’s Ingress controller.

On IBM Cloud Private, run the following command to get your Ingress controller address: `kubectl get configmap ibmcloud-cluster-info -n kube-public -o=jsonpath="{.data.proxy_address}"`.

On IBM Cloud Kubernetes Services, `ingress.host` must be provided. See [IBM Cloud Kubernetes Service documentation](https://cloud.ibm.com/docs/containers?topic=containers-ingress#public_inside_2) on how to get this address.

#### `ingress.secretName`

Set to the name of the TLS secret containing Ingress TLS certificate and key. If this is not provided, the default certificate of cluster's Ingress controller is used.

To create a TLS secret you would need a TLS certificate. [LetsEncrypt](https://letsencrypt.org/) is a free TLS certificate authority you could use to obtain a certificate. However, if you are just doing some testing you can create your own self-signed certificate using `openssl`:

```console
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /path/to/tls.key -out /path/to/tls.crt -subj "/CN=${HOST}/O=${HOST}"
```

The above command creates a certificate file and a key file. Then create the TLS secret in the cluster via:

```console
$ kubectl create secret foo-bar-tls my-tls-secret --key /path/to/tls.key --cert /path/to/tls.crt
```

The above command will generate a TLS secret called `foo-bar-tls`. This secret name can be specified for `ingress.secretName`.

On IBM Cloud Private, you can create IBM Cloud Private Certificate manager certificates and use as Ingress TLS secret. The following steps demonstrates how this is done:

1. Defines a certificate that uses the default ClusterIssuer that is provided by IBM Cloud Private:

    ```yaml
    apiVersion: certmanager.k8s.io/v1alpha1
    kind: Certificate
    metadata:
      name: foo-bar-tls
      namespace: foobar
    spec:
      # name of the tls secret to store the generated certificate/key pair
      secretName: foo-bar-tls
      issuerRef:
        # ClusterIssuer Name
        name: icp-ca-issuer
        # Issuer can be referenced by changing the kind here.
        # The default value is Issuer (i.e. a locally namespaced Issuer)
        kind: ClusterIssuer
      commonName: "foo.bar"
      dnsNames:
      # One or more fully-qualified domain names can be defined here
      - foo.bar
    ```

1. Set `ingress.secretName` to the `secretName` field specified in the certificate YAML definition. For example, `foo-bar-tls` in the above YAML.

On IBM Cloud Kubernetes Services, `ingress.secretName` **must** be provided. If you are using the IBM-provided Ingress domain, set this parameter to the name of the IBM-provided Ingress secret. However, if you are using a custom domain, set this parameter to a secret name that holds your custom TLS certificate and key. See [IBM Cloud Kubernetes Service documentation](https://cloud.ibm.com/docs/containers/cs_ingress.html#public_inside_2) for more info on how to get these value.

#### `ingress.path`

Replace this parameter with a slash or the path that you Ingress is listening on. The path is appended to your custom domain to create a unique route to your app. When you enter this route into a web browser, network traffic is routed to the Ingress Controller. The Ingress Controller looks up the associated service and sends network traffic to the service. The service then forwards the traffic to the pods where the app is running.

Examples:

* For https://foo.bar/app1 enter `foo.bar` as the `ingress.host` and `/app1` as the `ingress.path`.

* For https://dev.foo.bar/ enter `app.foo.bar` as the `ingress.host` and `/` as the `ingress.path`.

**Note:** If your `ingress.path` uses regular expression, you need to set `nginx.ingress.kubernetes.io/session-cookie-path` to the path that will be set on the session affinity cookie. See [Sticky sessions](https://kubernetes.github.io/ingress-nginx/examples/affinity/cookie/) for more info.

#### `ingress.rewriteTarget`

You can specify this parameter to routes incoming traffic on an Ingress domain path to a different path that your back-end applications listens on. Normally, applications listen on `/` but you can specify other values depending on your need. See [Rewrite Target](https://kubernetes.github.io/ingress-nginx/examples/rewrite/) for more details.

_**Attention:**_ IBM Cloud Private Version 3.2.0 uses NGINX Ingress Controller Version 0.23.0. Starting in NGINX Ingress Controller Version 0.22.0, ingress definitions that use the annotation `nginx.ingress.kubernetes.io/rewrite-target` are not compatible with an earlier version. For more information, see [Rewrite Target](https://kubernetes.github.io/ingress-nginx/examples/rewrite/).

##### Name-based virtual hosting

Name-based virtual hosts support routing incoming traffic to multiple host names at the same IP address. This is specially useful when multiple Ingress resources have to use the same `ingress.path`. In the following example, two Liberty Helm charts are deployed with endpoints available at `/hello-world`:

Development release:

```yaml
ingress:
  enabled: true
  rewriteTarget: /
  path: /
  host: dev.foo.bar
```

Production release:

```yaml
ingress:
  enabled: true
  rewriteTarget: /
  path: /
  host: "prod.foo.bar"
  secretName: foo-bar-prod-tls
```

The `/hello-world` endpoint can be accessed at `http://dev.foo.bar/hello-world` and `http://prod.foo.bar/hello-world`

```console
dev.foo.bar  --|           |-> dev.foo.bar  liberty-svc1:9443
               |  1.2.3.4  |
prod.foo.bar --|           |-> prod.foo.bar liberty-svc2:9443
```

In DNS, `dev.foo.bar` and `prod.foo.bar` can be either an A record or a CNAME that points to the Ingress controller DNS name or IP address.

When using [nip.io](https://nip.io), you can set `ingress.host` to `<sub_domain>.<IP>.nip.io` where `<IP>` would be replaced with the IP address of your cluster’s Ingress controller. For example, `dev.1.2.3.4.nip.io` and `prod.1.2.3.4.nip.io`.


#### `ingress.annotations`

Set this to extra annotations you want to be added to the Ingress resource. The value should be specified in YAML format. For example:

```yaml
  nginx.ingress.kubernetes.io/enable-cors: "true"
  nginx.ingress.kubernetes.io/cors-allow-methods: "PUT, GET, POST, OPTIONS"
```

See [NGINX Ingress Controller Annotations](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/) for more information on available annotations when deploying to IBM Cloud Private.

See [Customizing Ingress with annotations](https://cloud.ibm.com/docs/containers?topic=containers-ingress_annotation#ingress_annotation) when deploying to IBM Cloud Kubernetes Services.

**Note:** NGINX Ingress controller annotations are in transition from `ingress.kubernetes.io` to `nginx.ingress.kubernetes.io`. This means annotations defined in `ingress.annotaions` must match the configuration for your Kubernetes clusters. To validate which Ingress annotations are in use for your cluster, query the configuration:

```console
$ kubectl -n kube-system get pod $(kubectl -n kube-system get pods --selector=app=nginx-ingress-controller -o jsonpath='{.items[0].metadata.name}') -o=yaml | grep annotations-prefix

    - --annotations-prefix=ingress.kubernetes.io
```

**Note:** Due to an issue in Open Liberty and WebSphere Liberty 19.0.0.3 you might experience redirect schema and port mismatch. See the [GitHub issue](https://github.com/OpenLiberty/open-liberty/issues/6987) for more details. To workaround the problem you can specify the following annotations in `ingress.annotations`. Replace `<IP Address>` with the the value of `ingress.host`. If `ingress.host` is not specified, Replace `<IP Address>` with the IP address or DNS of your cluster’s Ingress controller.

```yaml
  nginx.ingress.kubernetes.io/proxy-redirect-from: ~*^https?://<IP Address>(:\d+)?/(.*)$
  nginx.ingress.kubernetes.io/proxy-redirect-to: $scheme://$http_host/$2
```

#### `ingress.labels`

Set this to extra labels you want to be added to the Ingress resource. The value should be specified in YAML format. For example:

```yaml
  environment: "dev"
  tier: "backend"
```
