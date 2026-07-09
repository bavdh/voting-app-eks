# voting-app-k8s

A hands-on Kubernetes deployment of the [Docker Example Voting App](https://github.com/dockersamples/example-voting-app). This project focuses on deploying a multi-service distributed application on a local Kubernetes cluster using Minikube, covering core Kubernetes concepts such as Deployments, Services, Secrets, and inter-service communication.

---

## Architecture

![Architecture](./architecture.svg)

---

## Getting Started

### 1. Start Minikube

```bash
minikube start
```

### 2. Point Docker CLI to Minikube's daemon

This is required so images built locally are available inside the Minikube cluster:

```bash
eval $(minikube docker-env)
```

> **Note:** This only applies to your current terminal session. Run this command again if you open a new terminal.

---

## Build Images

Navigate to the root of the cloned voting app and build each service image:

```bash
# Vote frontend
docker build -t vote ./vote

# Result frontend
docker build -t result ./result

# Worker
docker build -t worker ./worker
```

---

## Deploy to Kubernetes

Apply all manifests from this repository:

```bash
# Deploy Redis
kubectl apply -f manifests/redis-deployment.yaml

# Deploy PostgreSQL
kubectl apply -f manifests/postgres-deployment.yaml

# Deploy Secrets
kubectl apply -f manifests/secrets.yaml

# Deploy Worker
kubectl apply -f manifests/worker-deployment.yaml

# Deploy Vote frontend
kubectl apply -f manifests/vote-deployment.yaml

# Deploy Result frontend
kubectl apply -f manifests/result-deployment.yaml
```

Verify all pods are running:

```bash
kubectl get pods
kubectl get services
```

You should see all five pods with status `Running`.

---

## Access the Application

Get your Minikube IP:

```bash
minikube ip
```

Then open your browser:

| Service | URL                          |
| ------- | ---------------------------- |
| Vote    | `http://<minikube-ip>:30001` |
| Result  | `http://<minikube-ip>:30002` |

Cast a vote at the Vote URL and see results update in real time at the Result URL.

---

## Cleanup

To delete all deployed resources:

```bash
kubectl delete -f manifests/
```

To stop Minikube:

```bash
minikube stop
```

---

## Reference

- Original application: [dockersamples/example-voting-app](https://github.com/dockersamples/example-voting-app)
