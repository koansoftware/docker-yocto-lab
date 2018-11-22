#
# docker-yocto-lab
# (C)2018 Marco Cavallini - KOAN - http://koansoftware.com
#

FROM ubuntu:16.04

# Avoid message debconf: delaying package configuration, since apt-utils is not installed
ENV DEBIAN_FRONTEND noninteractive

# We want to use bash
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get -y upgrade

# My selection of packages
RUN apt-get install -y apt-utils tmux xz-utils libncurses5-dev

# Required Packages for the Host Development System
# https://www.yoctoproject.org/docs/current/ref-manual/ref-manual.html#detailed-supported-distros
RUN apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib \
     build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
     xz-utils debianutils iputils-ping

# Additional host packages required by poky/scripts/wic
RUN apt-get install -y curl dosfstools mtools parted syslinux tree

# Add "repo" tool (used by many Yocto-based projects)
RUN curl http://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
RUN chmod a+x /usr/local/bin/repo

# Create a non-root user that will perform the actual build
RUN id build 2>/dev/null || useradd --uid 40000 --create-home build
RUN apt-get install -y sudo
RUN echo "build ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# Fix error "Please use a locale setting which supports utf-8."
# See https://wiki.yoctoproject.org/wiki/TipsAndTricks/ResolvingLocaleIssues
RUN apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
        echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
        dpkg-reconfigure --frontend=noninteractive locales && \
        update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

USER build
WORKDIR /home/build


# --- Yocto Project ---

# Set the Yocto release
ENV YOCTO_RELEASE "sumo"

# Install Poky
RUN git clone git://git.yoctoproject.org/poky -b ${YOCTO_RELEASE}

# First setup
WORKDIR /home/build/poky
RUN  source oe-init-build-env

# Adjust settings in local.conf
ENV POKYCONFDIR "/home/build/poky/build/conf"
RUN echo 'MACHINE = "qemuarm" ' >> ${POKYCONFDIR}/local.conf
RUN echo 'PACKAGE_CLASSES = "package_ipk" ' >> ${POKYCONFDIR}/local.conf
RUN echo 'INHERIT = "rm_work" ' >> ${POKYCONFDIR}/local.conf

RUN tail /home/build/poky/build/conf/local.conf

# ------


# EOF
