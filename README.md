# 💾 Homelab

## Introduction

This repository contains the configuration and documentation of my homelab.

The goals are learning and enjoyment. As a DevOps engineer I work with Kubernetes daily, and this homelab is where I explore new ideas. Self-hosting selected applications keeps me accountable for the entire lifecycle from deployment to operations, which encourages clear thinking around backups, security, scalability and maintainability.

## At a glance

* Kubernetes with GitOps driven operations
* Cloudflare Tunnels for secure remote access
* TrueNAS backed storage with NFS CSI for dynamic provisioning
* Prometheus and Grafana for metrics and dashboards

## Cluster provisioning and architecture

| Number | Name   | Description                                                                                                   |
|-------:|--------|---------------------------------------------------------------------------------------------------------------|
| 1      | Noia   | End user applications. Stateless by design and provisioned from code. Reprovisionable in minutes.             |
| 2      | Data   | Databases and stateful workloads. Multi node. Restorable from object storage snapshots.                        |
| 3      | Zurich | Private cluster provisioned from a private repository.                                                         |

## 🚀 Installed apps and tools

### End user applications

| Name | Description |
|------|-------------|
| [Linkding](https://linkding.link) | Bookmark Manager |
| [Homarr](https://homarr.dev) | Personal start page for my homelab and the web |
| [Wallabag](https://wallabag.org/) | Save and read content later |
| [n8n](https://n8n.io/) | Secure and AI aware workflow automation |


### Platform and operations

| Name | Description |
|------|-------------|
| [Flux CD](https://fluxcd.io/) | GitOps engine that fits my workflows |
| [Cilium](https://cilium.io/) | eBPF networking, observability and security |
| [Grafana](https://grafana.com/) | Observability dashboards |
| [Prometheus](https://prometheus.io/) | Metrics and alerting backend |
| [Cloudflare Zero Trust](https://developers.cloudflare.com/cloudflare-one/) | Private tunnels for selected services |
| [NFS CSI Driver](https://github.com/kubernetes-csi/csi-driver-nfs) | Dynamic NFS provisioning backed by TrueNAS exports |

## Networking

Kubernetes runs Cilium as the CNI. Service addresses are allocated with Cilium LoadBalancer IPAM. The ingress layer uses the Cilium Gateway API, which avoids operating a separate ingress controller. At the edge I use a UniFi Cloud Gateway Fiber with VLANs and strict traffic rules.

## Storage

Primary NAS is a TrueNAS system.

* Kubernetes dynamic provisioning uses the NFS CSI driver backed by TrueNAS exports.
* A separate NFS share serves data that must be shared across clusters.

## Operations

### GitOps and environments

* Flux manages all clusters from this repository.
* Changes land through pull requests, then Flux reconciles them.

