# Learning Kubernetes using _Apple-Banana_ 🍎 🍌

Review the [Kubernetes Gateway API docs](https://gateway-api.sigs.k8s.io/) which explain the Gateway API and how it replaces Ingress for routing traffic into a Kubernetes cluster.

> Kubernetes moves _fast_. The Gateway API reached GA with `gateway.networking.k8s.io/v1` in Kubernetes 1.28, replacing the older `networking.k8s.io/v1` Ingress resource for advanced routing.

## Prerequisites

Some tool to view, edit, and interact with your K8s objects. Can be...

- Loft GUI
- OpenLens * my recommendation
- K9s
- Kubectl only

We'll use a mix of these

## Let's get started

We're going to use a Loft space for this. We deliberately won't use DevSpace. We're going to do things, by hand ✋

1. pull down this repo
1. create and use your Loft space `loft create space AB-<your username>` `loft use space AB-<your username>`

## Create the Apple Deployment

1. look at the `apple.yaml` file. It's set up to deploy two things, a k8s `deployment` and a k8s `service`
1. apply the `apple.yaml` file using kubectl `kubectl apply -f apple.yaml`
1. inspect what was created
    1. `kubectl get pods`
    1. `kubectl get deployments`
    1. `kubectl get services`
1. hit the apple-service by creating a forwarded port
    1. `kubectl port-forward service/apple-service 5678:5678` this will "take over" your terminal until you ctrl+c to stop it.
    1. open your browser and navigate to `http://localhost:5678` or `curl http://localhost:5678`

Questions:

1. What are the Pod labels for the `apple` pod?
1. How many containers are in the `apple` pod?
1. What happens if you delete the `apple` pod?
1. What content is returned by the `apple` pod?
1. What does the `selector` in the `service` section of `apple.yaml` say?
1. Challenge: change the `apple` service to listen on port 8080 and check it by creating a port forward using kubectl.


## What is the _Gateway API_?

Please bookmark [kubernetes.io](https://kubernetes.io/) as you will use it frequently. You may also wish to add the CNCF Slack #gateway-api and #kubernetes channels.

[kubernetes.io explains the Gateway API](https://kubernetes.io/docs/concepts/services-networking/gateway/)

The Gateway API works at TCP/IP layer 7. It is a set of CRDs (Custom Resource Definitions) that define how traffic enters a Kubernetes cluster. The key resources are:

- **GatewayClass** — defines the type of gateway (provisioned by your infrastructure, e.g. nginx)
- **Gateway** — represents a deployed gateway instance with one or more listeners (HTTP, HTTPS, etc.)
- **HTTPRoute** — defines routing rules that map hostnames and paths to backend services

The Gateway API is more expressive and role-oriented than the older Ingress resource, supporting TLS termination, path-based routing, and more — all without controller-specific annotations.

### Why we moved from ingress-nginx to Gateway API

**What ingress-nginx was**

ingress-nginx was (and still is) a widely-used Ingress controller. It watched for `networking.k8s.io/v1 Ingress` resources and configured an nginx reverse proxy to route external traffic to services inside the cluster. It worked well for simple cases, but any behavior beyond basic path routing — timeouts, retries, traffic splitting, header manipulation — had to be expressed through nginx-specific annotations like `nginx.ingress.kubernetes.io/proxy-read-timeout`. That tied your config tightly to one controller. Swap to a different Ingress controller and your annotations silently stop working.

**The problem with the Ingress resource**

The `Ingress` resource was intentionally kept minimal by Kubernetes. There was never a standard way to express advanced routing in the spec itself, so every controller invented its own annotation vocabulary. The result: non-portable YAML, inconsistent behavior across environments, and a growing gap between what teams actually needed and what the API provided.

**Why Gateway API**

| | ingress-nginx | Gateway API |
|---|---|---|
| API group | `networking.k8s.io/v1` (core, minimal) | `gateway.networking.k8s.io/v1` (CRD, expressive) |
| Advanced routing | Controller-specific annotations | Native spec fields |
| Portability | Tied to nginx controller | Works with nginx, Istio, Envoy, Cilium, and more |
| Role separation | Single resource owned by app teams | `GatewayClass`/`Gateway` for infra, `HTTPRoute` for apps |
| Status | Effectively frozen | Actively developed, GA in Kubernetes 1.28 |

The Kubernetes community has signaled that Gateway API is the long-term successor to Ingress. Migrating now means writing YAML that is portable across gateway implementations, supported by all major service mesh and CNI projects, and backed by a stable, versioned API.

## Let's add some TLS to the mix

> NOTE: Google Chrome won't allow self-signed certificates. As of writing, Firefox and Safari will both work by adding exceptions. Use Firefox or Safari to load these pages in a web browser.

1. create a self-signed TLS cert for _laptop.int_
    1. `openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=laptop.int/O=gatewaysvc"`
1. create an `/etc/hosts` entry for _laptop.int_
    * 192.168.64.2  laptop.int
1. add the certificate to the secrets manager in kubernetes
    1. `kubectl create secret tls tls-secret --key tls.key --cert tls.crt`
1. apply `gateway.yaml` which creates both the Gateway (with TLS termination) and the HTTPRoute
    1. look at the file: `cat gateway.yaml`
    1. `kubectl apply -f gateway.yaml`
1. verify what was created
    1. `kubectl get gateway`
    1. `kubectl get httproute`
1. test with cURL `curl -kL https://laptop.int/apple` or open in Safari/Firefox.

## Clean up

1. `kubectl delete -f gateway.yaml`
1. `kubectl delete -f apple.yaml`
1. `kubectl delete -f banana.yaml`
1. `kubectl delete secret tls-secret`
