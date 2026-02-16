# 🚀 COP-PILOT Cluster Integration & Automation Guide

This document helps clusters navigate the available documentation,
automation scripts, and CI/CD pipelines required to connect to the
COP-PILOT platform and use its services.

------------------------------------------------------------------------

# 🟣 SIF Layer

## 🔐 CloudZiti Access (Secure Networking)

For the COP-PILOT project, NetFoundry has deployed a CloudZiti
environment:

https://cop-pilot.cloudziti.io/

To gain access:

1.  Send an email to the NETC team.
2.  NETC will coordinate with the appropriate NetFoundry members.
3.  You will receive an invitation to join the CloudZiti network.

------------------------------------------------------------------------

## 🔗 Connecting Your VM to the Ziti Network

To allow your VM (e.g., hosting OpenSlice) to communicate securely with
the rest of the platform (e.g., Multi-Domain Orchestrator via SIF), an
automation script has been created.

Repository location:
https://github.com/cop-pilot-eu/platform-integration-pipelines/tree/main/sif-layer-pipelines/identity-script

A README file with usage instructions is included in the repository.

------------------------------------------------------------------------

# 🔵 DO Layer (Domain Orchestrator -- OpenSlice)

## 📦 OpenSlice Installation

Official documentation:
https://osl.etsi.org/documentation/2025Q4/getting_started/deployment/kubernetes/

------------------------------------------------------------------------

## 🌐 Recommended Ingress Configuration (Kubernetes Deployment)

For consistency with the secure networking setup of COP-PILOT (OpenZiti,
etc.), it is recommended to:

-   Configure the Ingress Controller as a NodePort service
-   Operate over HTTP
-   Use NGINX Ingress

Example root URL:

http://`<master-node-ip>`{=html}:`<nodeport>`{=html}

------------------------------------------------------------------------

## ⚠️ Keycloak HTTPS Issue (Kubernetes Deployment)

To disable SSL enforcement:

```bash
kubectl exec -it `<keycloak_pod_name>`{=html} -n openslice -- /bin/sh

cd /opt/jboss/keycloak/bin/

./kcadm.sh config credentials --server http://localhost:8080/auth
--realm master --user admin --password '`<YOUR_ADMIN_PASS>`{=html}'
./kcadm.sh update realms/openslice -s sslRequired=NONE ./kcadm.sh update
realms/master -s sslRequired=NONE
```

------------------------------------------------------------------------

# 🧩 Application Deployment via Domain Orchestrator

## ✅ Step 1 --- Validate CRIDGE Component

Ensure the CRIDGE component is properly configured:
https://osl.etsi.org/documentation/latest/getting_started/deployment/kubernetes/#cridge

------------------------------------------------------------------------

## 🚀 Step 2 --- Install ArgoCD

Guide:
https://osl.etsi.org/documentation/latest/service_design/kubernetes/design_helm_aas/

------------------------------------------------------------------------

## 📦 Step 3 --- Add COP-PILOT Helm Repository to ArgoCD

Guide:
https://argo-cd.readthedocs.io/en/stable/user-guide/private-repositories/#helm

Project field should be set to: default

------------------------------------------------------------------------

## 🛒 Step 4 --- Order & Deploy the Service

Navigate to: Manage Services → Service Orders

Change state from: INITIAL

To: ACKNOWLEDGED

Deployment will proceed automatically.

------------------------------------------------------------------------

# 🟡 ESO Layer (Multi-Domain Orchestrator Peering)

Pipeline documentation:

OpenSlice Service Creation:
https://github.com/cop-pilot-eu/platform-integration-pipelines/blob/main/sif-layer-pipelines/OpenSlice-service-creation.md

Peering Pipeline:
https://github.com/cop-pilot-eu/platform-integration-pipelines/blob/main/service-orchestrator-pipelines/peering/README.md

------------------------------------------------------------------------

# 🟢 Data Management Layer

## 🧠 Context Broker Deployment

Pipelines:
https://github.com/cop-pilot-eu/platform-integration-pipelines/tree/main/data-management-pipelines/orion-context-broker

------------------------------------------------------------------------

## ⚙️ Jenkins Agent Setup

Documentation:
https://github.com/cop-pilot-eu/cicd-documentation/blob/main/install-jenkins-agent-documentation.md

Once connected, Jenkins can automatically deploy the Context Broker to
your VM.

------------------------------------------------------------------------

For coordination or assistance, contact the NETC team.
