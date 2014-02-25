# Welcome to OpenCrowbar

Welcome to the OpenCrowbar Project - the successor to the 3
year-old Crowbar project, buld on the lessons learned from the Crowbar
project.

## Motivation

We want to transition from a bare metal installer into a tool that manages ongoing
operations of large-scale deployments of complex projects like
OpenStack, Hadoop, and Ceph.

OpenCrowbar is an open reference implementation targeting reliable
deployment in large-scale, multi-site datacenters. Initially, we want
to target workloads with around ~1000 physical nodes.

## Quickstart Instructions for Developers

This is the TL;DR version; the full version is [here](doc/development-guides/dev-systems/docker/docker-admin.md).

1. Place the OS install ISOs for OSes you want to deploy on to slaves in
  `$HOME/.cache/opencrowbar/tftpboot/isos`.  We currently support:
  1. `CentOS-6.5-x86_64-bin-DVD1.iso`
  2. `RHEL6.4-20130130.0-Server-x86_64-DVD1.iso`
  3. `ubuntu-12.04.4-server-amd64.iso`
1. Prep Environment
  1. Install Docker (do once)
  2. `sudo chmod 666 /var/run/docker.sock` (to run docker without sudo)
  3. `sudo usermod -a -G docker <your-user>` (to permanently run
     Docker without sudo)
2. To build Sledgehammer:
  1. `tools/build_sledgehammer.sh`
2. To run in development mode:
  1. `tools/docker-admin centos ./development.sh`
3. To run in production mode:
  1. `tools/docker-admin centos ./production.sh admin.cluster.fqdn`
     The first time you run this, it will take awhile as caches a few
     critical files and extracts the ISOs.
  2. `tools/kvm-slave` (to launch a KVM-based compute node)

Once Crowbar is bootstrapped (or if anything goes wrong), you will get
a shell running inside the container alongside a functional admin
node.  Exiting the shell will kill
Docker.

To see how to deploy an admin node in a VM, see the [Deployment Guide](doc/deployment-guide/README.md)

For more information, see the [Developer Guide](doc/development-guides/README.md)

## OpenCrowbar Documentation
OpenCrowbar documentation is located in under the [doc/](doc/) directory
of OpenCrowbar and for each OpenCrowbar workload.

Please refer to the [doc directories](doc/Index.md) for detailed
information.  The OpenCrowbar project attempts to define and maintain
one sub-directory for each functional element.  This structure is
intended to be common across all OpenCrowbar workloads in the [Crowbar project](https://github.com/opencrowbar/)

> Please, do NOT add documentation in locations outside of the
**/doc** directory trees!  If necessary, expand this README to include
pointers to important **/doc** information.


