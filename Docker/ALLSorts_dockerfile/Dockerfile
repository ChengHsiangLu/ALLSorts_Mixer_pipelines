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

RUN mamba install -c conda-forge r-base
RUN R -e "install.packages('dplyr', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('stringr', dependencies=TRUE, repos='http://cran.rstudio.com/')"

RUN git clone https://github.com/Oshlack/ALLSorts.git
WORKDIR /app/ALLSorts
RUN conda env create -f /app/ALLSorts/env/allsorts.yml
RUN echo "conda activate allsorts" >> ~/.bashrc
SHELL ["/bin/bash", "--login", "-c"]
ENV PATH /app/ALLSorts/ALLSorts:$PATH
RUN mkdir ../test_results
RUN conda uninstall -n allsorts numba
RUN conda install -n allsorts numba=0.52.0
RUN pip install .

