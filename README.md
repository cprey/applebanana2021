# Learning Kubernetes using _Apple-Banana_ 🍎 🍌

_Skim_ the [excellent article by Matthew Palmer](https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-ingress-guide-nginx-example.html) which does a good job of explaining the different ways to access resources in a :kubernetes: cluster and goes into detail on ingress.

> Kubernetes moves _fast_, to illustrate, the _apiVersion: networking.k8s.io/v1_ which is shown in the referenced article has changed from _beta_.

## Prerequisites

Some tool to view, edit, and interact with your K8s objects. Can be...See [https://handbook.gfm-ops.com/K8s%20Tools/tools/](handbook) for installation instructions

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


## What is the _ingress_ resource?

Please bookmark [kubernetes.io](https://kubernetes.io/) as you will use it frequently. You may also wish to add the CNCF Slack #argoCD and #kubernetes channels.
[kubernetes.io explains ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

Ingress works at TCP/IP layer 7, ingress is a set of configuration instructions which are passed to the ingress controller. The ingress controller works much like any other proxy. There will be an ingress controller on every worker node that _listens_ for traffic. When you create the controller itself, it's typically deployed into it's own namespace (ingress-nginx on minikube). This has no effect on routing traffic to services in other pods.

## Let's add some TLS to the mix

> NOTE: Google Chrome went a little 🙀 and won't allow self-signed certificates any longer. As of writing, Firefox and Safari will both work by adding exceptions. Use Firefox or Safari to load these pages in a web browser.

1. create a self-signed TLS cert for _laptop.int_
    1. `openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=laptop.int/O=nginxsvc"`
1. create an `/etc/hosts` entry for _laptop.int_
    * 192.168.64.2  laptop.int
1. add the certificate to the secrets manager in kubernetes
    1. `kubectl create secret tls tls-secret --key tls.key --cert tls.crt`
1. reapply the ingress.yaml with tls added.
    1. look at the changes `diff ingress.yaml ingresswtls.yaml`
    1. `kubectl apply -f ingresswtls.yaml`
1. test with cURL `curl -kL http:_minikube ip_/apple` or run in Safari/Firefox.

## Clean up

1. `minikube stop && minikube delete`
