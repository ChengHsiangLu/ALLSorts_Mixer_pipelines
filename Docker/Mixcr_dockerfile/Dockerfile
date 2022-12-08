FROM continuumio/miniconda3

MAINTAINER Cheng-Hsiang Lu <clu@chla.usc.edu>

WORKDIR /app

RUN apt-get update && apt-get install -y procps
RUN conda config --add channels defaults && \
    conda config --add channels bioconda && \
    conda config --add channels conda-forge
RUN conda install -c conda-forge mamba --freeze-installed
RUN conda install -c anaconda git
RUN mamba install -c conda-forge vim
RUN mamba install -c bioconda nextflow=21.10.0
RUN mamba install -c conda-forge awscli

RUN conda install -c imperial-college-research-computing mixcr
