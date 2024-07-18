# Use an official Nvidia runtime as a parent image
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

# Set noninteractive installation to avoid some prompts
ARG DEBIAN_FRONTEND=noninteractive

# Install necessary basic tools
RUN apt-get update && apt-get install -y \
    wget \
    git \
    vim \
    curl \
    ca-certificates \
    libjpeg-dev \
    libpng-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda and create an environment
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy

# Set path to conda
ENV PATH /opt/conda/bin:$PATH

# Create a Python 3.9 environment
RUN conda create -n real3dportrait python=3.9 -y && \
    conda init bash

# Activate the conda environment
SHELL ["conda", "run", "-n", "real3dportrait", "/bin/bash", "-c"]

# Install PyTorch with specific version and CUDA support
RUN conda install pytorch==2.0.1 torchvision==0.15.2 torchaudio==2.0.2 pytorch-cuda=11.7 -c pytorch -c nvidia

# Install PyTorch3D
RUN pip install "git+https://github.com/facebookresearch/pytorch3d.git@stable"

# Install MMCV
RUN pip install cython && \
    pip install openmim==0.3.9 && \
    mim install mmcv==2.1.0

# Install other dependencies from a requirements file
COPY requirements.txt /tmp/
RUN pip install -r /tmp/requirements.txt -v --use-deprecated=legacy-resolver

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Make RUN commands use the new environment
SHELL ["conda", "run", "-n", "real3dportrait", "/bin/bash", "-c"]

# Command to run on container start
CMD ["python", "your_script.py"]
