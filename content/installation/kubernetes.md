# Kubernetes

The Kumbuka repository contains a reference Kubernetes deployment under [`deploy/kubernetes`](https://github.com/kumbuka-me/kumbuka/tree/main/deploy/kubernetes). The manifests use Kustomize and deploy the `kumbuka` namespace together with Kumbuka, PostgreSQL, `html2pdf`, and Mailbridge.

## Prepare the manifests

Clone the server repository:

```sh
git clone https://github.com/kumbuka-me/kumbuka.git
cd kumbuka
```

Before applying the manifests, review the example configuration and replace deployment-specific values:

- change the PostgreSQL password in [`postgres/secret.yaml`](https://github.com/kumbuka-me/kumbuka/blob/main/deploy/kubernetes/postgres/secret.yaml) and keep the password in [`kumbuka/secret.yaml`](https://github.com/kumbuka-me/kumbuka/blob/main/deploy/kubernetes/kumbuka/secret.yaml) in sync;
- generate `KUMBUKA__ENCRYPTION_KEY` with `openssl rand -base64 32` and store the complete value in `kumbuka-config`;
- change `KUMBUKA__PUBLIC_URL` in [`kumbuka/deployment.yaml`](https://github.com/kumbuka-me/kumbuka/blob/main/deploy/kubernetes/kumbuka/deployment.yaml) to the externally visible URL;
- configure the optional OIDC and Mailbridge settings when you use those services;
- review the PostgreSQL `5Gi` persistent volume claim and ensure the cluster has a suitable default `StorageClass`.

The root [`kustomization.yaml`](https://github.com/kumbuka-me/kumbuka/blob/main/deploy/kubernetes/kustomization.yaml) is the entry point. Remove optional resources there if your deployment provides its own PostgreSQL, PDF service, or mail delivery.

## Deploy

Apply the complete example deployment with:

```sh
kubectl apply -k deploy/kubernetes
```

Check the workloads:

```sh
kubectl -n kumbuka get pods
kubectl -n kumbuka get services
```

The included Kumbuka service is a `ClusterIP`. For a quick local check, forward it to your machine:

```sh
kubectl -n kumbuka port-forward service/kumbuka 8080:8080
```

Then open `http://localhost:8080`.

For a normal cluster deployment, expose the `kumbuka` service through your own Ingress, Gateway, or other cluster-specific routing and set `KUMBUKA__PUBLIC_URL` to the matching external URL.

## Manifest reference

The canonical manifests are maintained with the server repository:

- [`kustomization.yaml`](https://github.com/kumbuka-me/kumbuka/blob/main/deploy/kubernetes/kustomization.yaml)
- [`kumbuka/deployment.yaml`](https://github.com/kumbuka-me/kumbuka/blob/main/deploy/kubernetes/kumbuka/deployment.yaml)
- [`kumbuka/secret.yaml`](https://github.com/kumbuka-me/kumbuka/blob/main/deploy/kubernetes/kumbuka/secret.yaml)
- [`kumbuka/service.yaml`](https://github.com/kumbuka-me/kumbuka/blob/main/deploy/kubernetes/kumbuka/service.yaml)
- [`postgres/statefulset.yaml`](https://github.com/kumbuka-me/kumbuka/blob/main/deploy/kubernetes/postgres/statefulset.yaml)
- [`html2pdf/deployment.yaml`](https://github.com/kumbuka-me/kumbuka/blob/main/deploy/kubernetes/html2pdf/deployment.yaml)
- [`mailbridge/deployment.yaml`](https://github.com/kumbuka-me/kumbuka/blob/main/deploy/kubernetes/mailbridge/deployment.yaml)

See [Runtime configuration](../configuration/runtime.md) for Kumbuka deployment settings and secrets.
