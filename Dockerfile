FROM ubuntu:18.04

LABEL maintainer="duanjun1981@gmail.com"

ARG AIV_VER="0.1"
ARG PATH="/opt/conda/bin:${PATH}"

# Define PATH variable
ENV DEBIAN_FRONTEND="noninteractive"
ENV PATH="/opt/conda/bin:${PATH}"
ENV LANG="C.UTF-8" LC_ALL="C.UTF-8"

# Install apt dependencies
RUN apt-get update && \
    apt-get -y install \
      tar \
      wget \
      git && \
    mkdir /root/.conda && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    chmod -R 755 /opt/conda  && \
    rm -f Miniconda3-latest-Linux-x86_64.sh && \
    apt-get clean all && \
    apt-get purge

# Build AIV_seeker
RUN mkdir /build && \
    cd /build && \
    git clone https://github.com/duanjunhyq/AIV_seeker.git && \
    cd AIV_seeker && \
    bash install_envs.sh && \
    chmod -R 755 /opt/conda && \
    chmod -R 755 /build

# Default command to be bash
# ENTRYPOINT ["/opt/conda/bin/conda", "run", "-n", "aiv_seeker", "aiv_seeker.pl"]
#CMD ["/bin/bash"]
