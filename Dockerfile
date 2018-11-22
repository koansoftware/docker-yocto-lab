#
# docker-yocto-lab
#

FROM ubuntu:16.04

# This is the anti-frontend. It never interacts with you  at  all
# and  makes  the  default answers  be used for all questions. 
# The perfect frontend for automatic installs
ENV DEBIAN_FRONTENV noninteractive

RUN apt-get update && apt-get -y upgrade

# Required Packages for the Host Development System
# https://www.yoctoproject.org/docs/current/ref-manual/ref-manual.html#detailed-supported-distros
RUN apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib \
     build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
     xz-utils debianutils iputils-ping

# My selecion of packages
RUN apt-get install -y apt-utils tmux xz-utils libncurses5-dev

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


# --- Yocto setup ---
# Set the Yocto release
ENV YOCTO_RELEASE "sumo"

# Install Poky
RUN git clone -b ${YOCTO_RELEASE} git://git.yoctoproject.org/poky
# ------


WORKDIR /home/build
CMD "/bin/bash"

# EOF
