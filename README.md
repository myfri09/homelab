# 🏠 Homelab

## Introduction

This repo contains all of the configuration and documentation of my homelab.

The purpose of my homelab is to learn and to have fun. Being a Cloud Native Engineer by trade, I work with Kubernetes every day, and my homelab is the place where I can try out and learn new things. On the other hand, by self-hosting some applications, it makes me feel responsible for the entire process of deploying and maintaining an application from A to Z. It forces me to think about backup strategies, security, scalability and the ease of deployment and maintenance.

## Cluster Provisioning & Architecture

<table>
    <tr>
        <th>Number</th>
        <th>Name</th>
        <th>Description</th>
    </tr>
    <tr>
    <td>1</td>
    <td>Noia</td>
        <td>Contains all end-user applications. Stateless, fully provisioned from code. Can be torn down and spun up within minutes on different hardware.</td>
    </tr>
    <tr>
        <td>2</td>
    <td>Data</td>
        <td>Contains all my databases & state. Multi-node. Can be fully restored from Blob storage.</td>
    </tr>
    <tr>
        <td>3</td>
    <td>Zurich</td>
        <td>Private cluster provisioned from private repository.</td>
    </tr>
</table>
