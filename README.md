# Pier

Pier is an alternative Docker client, which uses the Ruby [docker-api](https://github.com/swipely/docker-api) gem to access the Docker Remote API. Pier is focused on the use-case of managing one or more clusters of machines which are entirely dedicated to running a Docker swarm.

Pier uses [fog](http://fog.io/) for its instance management. For now, only the [fog-libvirt](https://github.com/fog/fog-libvirt) backend is supported.

Pier assumes that each cluster has a cluster-manager endpoint, called a "pier." The pier is a running instance that must:

* be accessible via SSH;
* be a manager in your Docker swarm; and
* have `easy-rsa` installed and set up to generate both server and client certificates.

A pier need not be a member of the cluster itself. Pier does not manage the pier, only the cluster visible through the pier.

By default, Pier also assumes that each pier is the _libvirt hypervisor_ for its cluster—i.e. that libvirt's endpoint is accessible as `qemu+ssh://[your-pier-endpoint]/system`.
