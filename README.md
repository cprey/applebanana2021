# Learning Kubernetes ingress using _Apple-Banana_ 🍎 🍌

_Skim_ the [excellent article by Matthew Palmer](https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-ingress-guide-nginx-example.html) which does a good job of explaining the different ways to access resources in a :kubernetes: cluster and goes into detail on ingress.

> Kubernetes moves _fast_, to illustrate, the *apiVersion: networking.k8s.io/v1* which is shown in the referenced article has changed from _beta_.

## What is the _ingress_ resource?

Please bookmark [kubernetes.io](https://kubernetes.io/) as you will use it frequently. You may also wish to add the CNCF Slack #argoCD and #kubernetes channels.
[kubernetes.io explains ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

Ingress works at TCP/IP layer 7, ingress is a set of configuration instructions which are passed to the ingress controller. The ingress controller works much like any other proxy. There will be an ingress controller on every worker node that _listens_ for traffic. When you create the controller itself, it's typically deployed into it's own namespace (ingress-nginx on minikube). This has no effect on routing traffic to services in other pods.

## step 0 (specific for AWS EC2)

1. You will need a system with at least 2CPU and 4GB RAM. M5Large seems like a good fit. Add an SG with SSH access and access to the Internet to pull packages.
1. install yum packages
    * `sudo yum install -y docker conntrack git nc`
1. prepare docker
    * add user to docker group `sudo usermod -aG docker $USER`
    * start docker `sudo systemctl start docker`
    * log out and back in
1. install minikube `curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/`
1. install kubectl
    * `curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl`
    * `chmod +x kubectl && sudo mv kubectl /usr/local/bin/`
1. install Helm
    * `curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3`
    * `chmod +x get_helm.sh`
    * `./get_helm.sh`
1. start minikube `minikube start`

## Step 0 (local OSX Intel system)

1. install `hyperkit` and `minikube` - long boring story here about how OSX isn't Linux. Hyperkit is a hypervisor which runs a Linux VM.
    1. `brew install minikube`
    1. `brew install hyperkit`
1. run `minikube start --driver=hyperkit` to start minikube.

## Let's get started

1. install the ingress controller `minikube addons enable ingress` see other addons using `minikube addons list`
1. install the yaml files `kubectl apply -f apple.yaml -f banana.yaml -f ingress.yaml`
1. inspect what was created
    1. `kubectl get ns`
    1. `kubectl get pods`
    1. `kubectl get services`
    1. `kubectl get ingress` - this will show _ingress_ in the default namespace. Many things are not shown when you run `get all`.
    1. start logging so you can watch the action `kubectl logs -f service/ingress-nginx-controller -n ingress-nginx`
1. get the ip from minikube `minikube ip`
1. hit the apple and banana resources
    1. http:_minikube ip_/apple ex: <http://192.168.64.2/apple>
    1. http:_minikube ip_/banana ex: <http://192.168.64.2/banana>
1. now look carefully at the `ingress.yaml` file and cross-reference the apple.yaml and banana.yaml files to help you understand what's happening.
1. what do you think will happen if you visit <http://192.168.64.2/> ?. There are a ton of options for ingress including setting defaults.

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

## Layer 4 and a shortcut to a deployment

Is e-mail still 😎 Cool? It was a simpler time.

1. create a deployment from the command line
    * `k create deployment exim --image=circleci/exim:0.2`
    * `k get deployments`
1. Problem! SMTP != HTTP and it's not layer 7 - Layer 4 to the rescue
    * `k port-forward deployment/exim 8825:25`
    * open another terminal
    * `nc localhost 8825`
    * `EHLO fun.com`
    * `MAIL FROM:<chad@prey.com>`
    * `RCPT TO:<bob@test.com>`
    * `DATA`
    * type your message followed by a period (.) alone on a new line
    * `QUIT`
    * we can talk about scaling by editing the exim deployment

## Hungry for more Layer 4?

1. Add the Bitnami helm repo...and install the chart *Kafka* with defaults
    * `helm repo add bitnami https://charts.bitnami.com/bitnami`
    * `helm install kafka bitnami/kafka`
    * `k port-forward service/kafka-headless 9092:9092`
    * `nc -vz localhost 9092`

## Clean up

1. `minikube stop && minikube delete`
