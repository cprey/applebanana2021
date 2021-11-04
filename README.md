# Learning Kubernetes ingress using _Apple-Banana_

_Skim_ the [excellent article by Matthew Palmer](https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-ingress-guide-nginx-example.html) which does a good job of explaining the different ways to access resources in a :kubernetes: cluster and goes into detail on ingress.

> Kubernetes moves _fast_, to illustrate, the *apiVersion: networking.k8s.io/v1* which is shown in the referenced article has changed from _beta_.

## Let's get started

1. clone this repo.
1. install `hyperkit` and `minikube` - long boring story here about how OSX isn't Linux. Hyperkit is a hypervisor which runs a Linux VM.
    1. `brew install minikube`
    1. `brew install hyperkit`
1. run `minikube start --driver=hyperkit` to start minikube.
1. install the ingress controller `minikube addons enable ingress` see other addons using `minikube addons list`
1. install the yaml files `kubectl apply -f .`
1. inspect what was created
    1. `kubectl get ns`
    1. `kubectl get all --all-namespaces`
    1. `kubectl get ingress` - this will show _ingress_ in the default namespace. Many things are not shown when you run `get all`.
    1. start logging so you can watch the action `kubectl logs -f service/ingress-nginx-controller -n ingress-nginx`
1. get the ip from minikube `minikube ip`
1. hit the apple and banana resources
    1. http:_minikube ip_/apple ex: http://192.168.64.2/apple
    1. http:_minikube ip_/banana ex: http://192.168.64.2/banana
1. now look carefully at the `ingress.yaml` file and cross-reference the apple.yaml and banana.yaml files to help you understand what's happening.
1. what do you think will happen if you visit http://192.168.64.2/ ?. There are a ton of options for ingress including setting defaults.

## What is the _ingress_ resource?

Please bookmark [kubernetes.io](https://kubernetes.io/) as you will use it frequently. You may also wish to add the CNCF Slack #argoCD and #kubernetes channels.
[kubernetes.io explains ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

Ingress works at TCP/IP layer 7, ingress is a set of configuration instructions which are passed to the ingress controller. The ingress controller works much like any other proxy. There will be an ingress controller on every worker node that _listens_ for traffic. When you create the controller itself, it's typically deployed into it's own namespace (ingress-nginx on minikube). This has no effect on routing traffic to services in other pods.
