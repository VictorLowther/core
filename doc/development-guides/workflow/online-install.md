This file documents how to install OpenCrowbar on a basic install of
Ubuntu or CentOS without needing to create a crowbar ISO first.

####Caveats:

 * Online install mode still has plenty of bugs to work out.
 * Especially where the OpenCrowbar web UI is concerned.  Doing an online
   install as described by this README will result in a broken web
   UI.  The OpenCrowbar CLI still works, though.
 * Online install mode is primarily intended as a development aid for
   now.  If you want to deploy something more production oriented,
   build the ISO using the usual build process.

####Assumptions:

 * Your primary NIC has an IP address of 192.168.124.10/24
 * You have at least 20 gigs of disk space and 4 gigs of ram.
 * You are running either as root or as crowbar.

####Instructions:

 1: Install a basic install of Ubuntu Server or CentOS.
 2: Do whatever is needed to be able to install packages from the Internet.
 3: Install git, rubygems, the ruby development packages, rpm, sudo,
    debootstrap, and the json gem. This may involve setting up sane http_proxy
    and https_proxy environment variables.
 4: Clone the OpenCrowbar repository from
    http://github.com/crowbar/crowbar.git, and cd into the
    newly-created crowbar directory.
 5: In the crowbar repository, run ./dev switch.  This will check out
    the barclamps we need.
 6: Run ./install, and wait.
 7: Profit.

####Neato things:

 * You don't need to have a direct connection to the Internet at all
   to deploy OpenCrowbar with this code.  The install process pulls
   all the packages it needs entirely over http, so all you need
   is access to an http proxy that does have access to the Internet.
   If you export an appropriate http_proxy before starting the
   install, the install process and any nodes you bring up will wind
   up using that proxy for all package fetching.
 * The current code deploys its own caching proxy before installing
   anything.  This allows us to minimize the amout of data we have to
   pull from the Internet.
 * You don't need to have ISO images of the operating systems you want
   to install as long as you have an active Internet connection.
