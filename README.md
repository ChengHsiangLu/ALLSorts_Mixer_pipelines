# Build bioinformatics pipelines to improve efficiency and reduce time with Docker and Nextflow in AWS

<br>

## Author

Sam (Cheng-Hsiang) Lu 

Email: clu74108@usc.edu

## Mentor

Dr. Venkata 

Email: vyellapantula@chla.usc.edu

<br>

## Background

### What is B-cell acute lymphoblastic leukemia (B-ALL)?

B-cell acute lymphoblastic leukemia (B-ALL) is a type of cancer that affects the white blood cells. It is a type of cancer that starts in the bone marrow, where blood cells are made. In people with B-ALL, the bone marrow makes too many immature B-cells, which are a type of white blood cell. These cells are not able to function properly, and they can build up in the blood and bone marrow, crowding out healthy blood cells. B-ALL can be treated with chemotherapy and other medications, but it can be a serious and life-threatening condition. There are several subtypes of B-ALL, which are distinguished based on the specific genetic changes that are present in the cancer cells.

### Why build pipelines?

This project use ALLSorts and MiXCR to analyze B-Cell Acute Lymphoblastic Leukemia patients data on the AWS ec2 instance. However, each package has it own additional packages and depedencies to download. Plus, I have to be aware of each package's version might not be compatible to others as well. Another issue is the time. When you have multiple samples, it would take you a lot of time compare to process only one sample. Therefore, we come up with a plan to combine our packages with Docker and Nextflow. By doing so, we can not only solve the compatibility issue but also save time by processing multiple samples at the same time.

<br>


## Introduction

ALLSorts is a package that can classify B-Cell Acute Lymphoblastic Leukemia (B-ALL) subtype. In my project, I use RNA-seq data to classify B-ALL 18 know subtypes and 5 meta-subtypes. Here is the link to ALLSorts github page: [ALLSorts](https://github.com/Oshlack/ALLSorts)

MiXCR is a package that can analyze raw T or B cell receptor repertoire sequencing data. Here is the link to MiXCR github page: [MiXCR](https://github.com/milaboratory/mixcr)


With Docker, people are allowed using packages without downloading any packages and their dependencies. Plus, we can automatically run different types of codes with Nextflow by organizing each section's input and output. Therefore, by combining packages with Docker and Nextflow, people can easily generate their results with one line of code and save their time as well.

<br>

## Installation

### Install miniconda: 

```wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.11.0-Linux-x86_64.sh```

### Install Git:

You can install Git by following these steps: 

```https://cloudaffaire.com/how-to-install-git-in-aws-ec2-instance/```

<br>

## ALLSorts pipelines

### 1. Install ALLSorts and run a test (or you can jump to "Create ALLSorts docker" using Docker)

You can find the original installation steps in this link: [ALLSorts installation](https://github.com/Oshlack/ALLSorts/wiki/1.-Installation)

1. Create a folder in your terminal and use ```git clone https://github.com/Oshlack/ALLSorts.git``` to install and execute ALLSorts.
2. Find the ALLSorts where you installed and then execute ```conda env create -f env/allsorts.yml```. It will create the "allsorts" environment.
3. You can either activate "allsorts" environment with ```source activate allsorts``` or ```conda activate allsorts```.
4. Then, install ALLSorts with ```pip install .``` (Notice that you have to include the "." in this code).
5. After multiple try and errors, you have to remove your numba by ```conda uninstall numba --force``` and change numba version with ```conda install numba=0.52.0``` in order to solve further errors.
6. Before you run a test, create a folder where you store all your results. For example, ```mkdir ../test_results``` from the ALLSorts root.
7. You can now run a test with ```python ALLSorts -samples tests/counts/test_counts.csv -destination ../test_results```.

### 2. Create ALLSorts docker

Install docker on AWS ec2 instance:

```
sudo yum update -y

sudo amazon-linux-extras install docker

sudo service docker start

sudo systemctl enable docker

sudo usermod -a -G docker ec2-user

docker -v

```

1. After the docker installation, now I have to create a Dockerfile for ALLSorts. You can [Click here](https://github.com/ChengHsiangLu/Capstone/tree/main/Docker/ALLSorts_dockerfile) to check my ALLSorts Dockerfile.
2. Create the ALLSorts container and push it to your DockerHub. If you don't have a DockerHub account yet, you can have one right here: [DockerHub](https://hub.docker.com/). (Or use mine that is already built: [My DockerHub](https://hub.docker.com/r/chenghsianglu/allsorts_dockerfile_083022))

```
# Create the ALLSorts container

docker build -t allsort_dockerfile_082322 .

docker image ls

docker run -it allsort_dockerfile_082322:latest bash


# Push and pull a container

docker images

docker login ## type in your user name and password

docker tag allsorts_dockerfile_083022:latest chenghsianglu/allsorts_dockerfile_083022

docker push chenghsianglu/allsorts_dockerfile_083022

docker pull chenghsianglu/allsorts_dockerfile_083022:latest

docker rmi chenghsianglu/allsorts_dockerfile_083022  ## if your want to remove it
```

### 3. Create Nextflow script

Install nextflow:

```
curl -s https://get.nextflow.io | bash

chmod +x nextflow

./nextflow

vi .bashrc

export PATH="/home/ec2-user:$PATH"

source ~/.bashrc
```

1. Once you install nextflow, you can start writing your ALLSorts nextflow script called ```main.nf```. This is my script [Click here](https://github.com/ChengHsiangLu/Capstone/blob/main/ALLSorts_nextflow/main.nf).
2. Download ```Rscript.R```, ```gtf.txt```, and ```df.txt``` in the same location with ```main.nf```. Find them with this link: [Click here](https://github.com/ChengHsiangLu/Capstone/tree/main/ALLSorts_nextflow)
3. Also download ```gencode.v38.annotation.gtf``` as well. [Download](https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/gencode.v38.annotation.gtf.gz)
4. Use ```mkdir Files``` to make a folder which can run your files.
5. The detail in ```main.nf```, the first process ```run_R``` inputs all dragon files in the ```Files``` folder which end with ``` quant.genes.sf```. With my ```Rscript.R```, it will covert dragon files into gene expression counts file ```counts.csv```.
6. The second process ```run_Allsorts``` inputs each ```counts.csv```, activate the allsorts environment, run ALLSorts, and store all B-ALL subtype predictions in the ```Results``` folder.

<br>

## ALLSorts Combines the Nextflow script with Docker

After you install Docker and Nextflow and put all your ``` quant.genes.sf``` files in the ```Files``` folder where is as the same location as ```main.nf```, ```Rscript.R```, ```gtf.txt```, and ```df.txt```, you can just run ALLSorts pipelines with one single line of code as below.

```nextflow run main.nf -with-docker chenghsianglu/allsorts_dockerfile_083022```

<br>

## MiXCR pipelines

### 1. Install MiXCR (or jump to "Create MiXCR docker" using Docker)

You can find the original installation steps in this link: [MiXCR installation](https://github.com/milaboratory/mixcr)

1. This time, I use Homebrew to install MiXCR package: ```brew install milaboratory/all/mixcr```
2. Upgrade your MiXCR to the latest version: ```brew upgrade mixcr```

### 2. Create MiXCR docker

Install docker (you can pass this step if you have already installed it):

```
sudo yum update -y

sudo amazon-linux-extras install docker

sudo service docker start

sudo systemctl enable docker

sudo usermod -a -G docker ec2-user

docker -v

```

1. Create a Dockerfile for MiXCR. [Click here](https://github.com/ChengHsiangLu/Capstone/blob/main/Docker/Mixcr_dockerfile/Dockerfile)
2. Create the MiXCR container and push it to your DockerHub. ( Or use mine that is already built: [my Dockerhub](https://hub.docker.com/r/chenghsianglu/mixcr_dockerfile_082322)

```
# Create the MiXCR container

docker build -t mixcr_dockerfile_082322 .

docker image ls

docker run -it mixcr_dockerfile_082322:latest bash


# Push and pull a container

docker images

docker login ## type in your user name and password

docker tag mixcr_dockerfile_082322:latest chenghsianglu/mixcr_dockerfile_082322

docker push chenghsianglu/mixcr_dockerfile_082322

docker pull chenghsianglu/mixcr_dockerfile_082322:latest

docker rmi chenghsianglu/mixcr_dockerfile_082322  ## if your want to remove it
```

### 3. Create MiXCR Nextflow script

Install nextflow (you can pass this step if you have already installed it):

```
curl -s https://get.nextflow.io | bash

chmod +x nextflow

./nextflow

vi .bashrc

export PATH="/home/ec2-user:$PATH"

source ~/.bashrc
```

1. Start writing your MiXCR nextflow script ```main.nf```. This is my script [Click here](https://github.com/ChengHsiangLu/Capstone/blob/main/Mixcr_nextflow/main.nf).
2. Use ```mkdir Files``` to create a folder which can run your files. In my case, it will be pair-ended fastq files.
3. In the first process of my script ```run_mixcr_align```, it inputs one pair-ended fastq files in the ```Files``` folder which end with ```fastq.gz```. This step aligns raw sequencing data against V-, D-, J- and C- gene segment references library database for specified species and generate ```alignments.vdjca``` as its output.
4. In the second process ```run_mixcr_assemblePartial_1 ```, this step overlaps alignments coming from the same molecule which partially cover CDR3 regions.
5. In the third process performs the second process again because the author strongly recommands that sometimes the efficiency is increased if you perform two consecutive rounds of assembplePartial. Therefore, I process ```run_mixcr_assemblePartial_2``` once again.
6. In the forth process ```run_mixcr_extend```, this process is typically used as a part of non-targeted RNA-Seq analysis pipeline for T-cells, to recover some of useful TCRs. The command takes alignments (.vdjca) file as input and generate ```clones.clns``` as output.
7. Last, the process ```run_mixcr_export``` export clonotypes or raw alignments in a tabular form. I export three different outputs: ```clones.txt```, ```clones.TRB.txt```, and ```clones.IGH.txt```.

You can also find full details at [MiLaboratories](https://docs.milaboratories.com).

<br>

## MiXCR Combines the Nextflow script with Docker

After you install Docker and Nextflow and put all your pair-ended fastq files in the ```Files``` folder where is as the same location as ```main.nf```, you can just run MiXCR pipelines with one single line of code as below. (If you have only 8 cores in your AWS ec2-instance, it is suggested to run 4 pair-ended fastq files at a time.)

```nextflow run main.nf -with-docker chenghsianglu/mixcr_dockerfile_082322```

<br>


## Future works
1. Numbat pipelines

<br>

## References

[1] Arber, D. A., Orazi, A., Hasserjian, R., Thiele, J., Borowitz, M. J., Le Beau, M. M., … Vardiman, J. W. (2016). The 2016 revision to the World Health Organization classification of myeloid neoplasms and acute leukemia. Blood, 127(20), 2391–2405.

[2] Gu, Z., Churchman, M. L., Roberts, K. G., Moore, I., Zhou, X., Nakitandwe, J., … Mullighan, C. G. (2019). PAX5-driven subtypes of B-progenitor acute lymphoblastic leukemia. Nature Genetics, 51(2), 296–307.

[3] Dmitriy A. Bolotin, Stanislav Poslavsky, Igor Mitrophanov, Mikhail Shugay, Ilgar Z. Mamedov, Ekaterina V. Putintseva, and Dmitriy M. Chudakov. "MiXCR: software for comprehensive adaptive immunity profiling." Nature methods 12, no. 5 (2015): 380-381.

[4] Dmitriy A. Bolotin, Stanislav Poslavsky, Alexey N. Davydov, Felix E. Frenkel, Lorenzo Fanchi, Olga I. Zolotareva, Saskia Hemmers, Ekaterina V. Putintseva, Anna S. Obraztsova, Mikhail Shugay, Ravshan I. Ataullakhanov, Alexander Y. Rudensky, Ton N. Schumacher & Dmitriy M. Chudakov. "Antigen receptor repertoire profiling from RNA-seq data." Nature Biotechnology 35, 908–911 (2017)
