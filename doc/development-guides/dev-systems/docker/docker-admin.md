## Admin Node in Docker

It is possible (and convienent) to run a OpenCrowbar admin node in a
CentOS 6.5 based Docker container.  To do so, you need to be running
in a development environment that can run Docker.  Instructions for
installing Docker on the most common Linux distributions are at
http://docs.docker.io/en/latest/installation/

### Configure Docker in your development environment

Once Docker is installed, you need to configure it to use the
devicemapper storage backend and to talk through your HTTP proxy (if
any)  We need to use the devicemapper storage backend because there
are directory permissions bugs in the AUFS driver that our CentOS
container exposes.

On Ubuntu, edit `/etc/default/docker` and make the following changes:

* Uncomment the line that starts with `DOCKER_OPTS`, and make it read
`DOCKER_OPTS="-s devicemapper"`
* If you need to have the Docker daemon talk through an http proxy,
uncomment the line that starts with `export` and change the part after
`http_proxy` to point at the http proxy you normally use.

On CentOS 6.5, edit `/etc/sysconfig/docker`, and make the following
changes:

* Change the line that starts with `other_args` to read
`other_args="-s devicemapper"`.
* Add a line that reads `export http_proxy="http://<your_http_proxy>"`
  if you need to have the Docker daemon talk through an http proxy.
* If you need a proxy to talk https, add a similar line reading
`export https_proxy="http://<your_https_proxy>"`

On OpenSuSE 13.1, Fedora 20, and other distributions that use systemd
as their init system, perform the following steps:

1. Copy `/usr/lib/systemd/system/docker.service` to
`/etc/systemd/system/docker.service`
2. Edit `/etc/systemd/system/docker.service`, and make the following
changes:

  * Change the line that starts with `ExecStart=` and append
  ` -s devicemapper` to the end of it.
  * If you need to have the Docker daemon talk through an http proxy,
  add the following line directly under the `[Service]` line:

    `Environment="http_proxy=http://<your_http_proxy>" "https_proxy=http://<your_http_proxy>"`

3. Reload the docker service configuration: `systemctl daemon-reload`

After making the above changes, restart the Docker service for them to
take effect, and then enable support for your user to run Docker
without needing to sudo to root:

1. Run `sudo chmod 666 /var/run/docker.sock` to give everyone access
   to Docker for this session.
5. Run `sudo usermod -a -G docker <your-user>` to give yourself access
   to run Docker in future sessions without needing the `chmod 666`
   hack.  You will need to log out and log back in for this to work, though.

### The docker-admin command and its environment

The `docker-admin` command (located in the `tools` directory in the
core repository) is responsible for managing the interaction between
the development environment and the Docker container.  Among other
things, it ensures that:

* The contents of the `core` repository in the development environment
is visible in the Docker container at `/opt/opencrowbar/core`.  This
makes it trivial to edit the code in your development environment and
have the changes be instantly visible in the Docker container.
* The contents of `$HOME/.cache/opencrowbar/tftpboot` is visible in
  the Docker container at `/tftpboot`.  This keeps the Docker
  container from getting too bloated when setting up parts of the
  provisioner.
* The UID and GID of the OpenCrowbar user in the container are identical
to your UID and GID in your development environment.
* Your SSH public key in your development environment is added to
`/root/.ssh/authorized_keys`
* Your `http_proxy`, `https_proxy` and `no_proxy` environment
  variables will be visible in the Docker container.  If your
  `http_proxy` and `https_proxy` environment variables refer to
  `localhost`, `127.0.0.1`, or `[::1]`, then they will be rewritten to refer
  to the IP address of the bridge that Docker is using.  In that case,
  your local proxy should be configured to allow connections from
  `172.16.0.0/12`.

### Ensuring that the admin node can deploy operating systems to slaves

When deploying an admin node in production mode, you will want to be
able to install operating systems on slave nodes.  By default, the
`provisioner-base-images` role will look for OS install ISO images in
`/tftpboot/isos`.  Currently, the provisioner knows how to install the
following operating systems from the following ISO images:

* `ubuntu-12.04`: `ubuntu-12.04.4-server-amd64.iso`
* `centos-6.5`: `CentOS-6.5-x86_64-bin-DVD1.iso`

To enable the provisioner to install from those images, place them in
`$HOME/.cache/opencrowbar/tftpboot/isos`, either directly or via a
hard link.  These images will then be available inside the Docker
container at `/tftpboot/isos`, and the provisioner will be able to use
them to install operating systems on slave nodes.

### Running a production mode OpenCrowbar admin node in Docker

Once Docker is installed, configured, and you have ISO images in
place, you are ready to run a OpenCrowbar admin node on CentOS 6.5 in
Docker.  To do that, run the following command from the core
repository:

    tools/docker-admin centos ./production.sh admin.smoke.test

This will perform the following actions:

* If needed, pull the latest opencrowbar/centos image from the public
Docker repository.
* Spawn the container with all the parameters needed to set up the
environment as described above.  The rest of the actions will take
place in the spawned container.
* Ensure that the UID and GIDs of crowbar user inside the container is
  the same as your UID and GID in the development environment.
* Append your SSH public key to root's authorized_keys file.
* Run `./bootstrap.sh`, which will ensure that ruby and chef-solo are
installed, and then run the crowbar-bootstrap cookbook to converge the
state of the container with our latest specifications.
* Bring up the OpenCrowbar webserver.
* Create a default admin network on the `192.168.124.0/24` address
range.
* Update the `provisioner-server` role template to use the passed-in
http proxy, if any.
* Update the `provisioner-os-install` role template to default to
`centos-6.5`.
* Create the admin node record.
* Extract the addresses that were allocated to the admin node, and
bind them to eth0.
* Mark the admin node as alive, and converge the default set of admin
noderoles.

You should be able to monitor the progress of the admin node
deployment at http://localhost:3000.  Once the admin node is finished
deploying (or if anything goes wrong), you will be left at a running
shell inside the container.

### Booting slave VMs from the OpenCrowbar admin node

If your development environment is running on bare metal (as opposed
to running inside a VM), you can use `tools/kvm-slave &` to spawn a
KVM virtual machine that will boot from the freshly-deployed OpenCrowbar
admin node.
