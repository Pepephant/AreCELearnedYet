FROM ubuntu:18.04
RUN apt-get update && apt-get install -y libxml2 && apt-get install -y build-essential && apt-get install -y curl && apt-get install -y wget
RUN apt-get update && apt-get -y upgrade && apt-get install -y vim && apt-get install -y git
RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y

RUN apt-get update && apt-get install -y python3.7 python3.7-dev python3-pip && \
    ln -s /usr/bin/python3.7 /usr/bin/python && python3.7 -m pip install --upgrade pip

RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin
RUN pip install poetry

# install cuda
# SHELL ["/bin/bash", "-c"]
CMD ["bash"]
ENV NVARCH=ppc64el
ENV NVIDIA_REQUIRE_CUDA=cuda>=10.2
ENV NV_CUDA_CUDART_VERSION=10.2.89-1
ARG TARGETARCH
# LABEL maintainer=NVIDIA CORPORATION <cudatools@nvidia.com>
RUN TARGETARCH=ppc64le apt-get update
RUN apt-get install -y --no-install-recommends     gnupg2 curl ca-certificates
RUN curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/${NVARCH}/3bf863cc.pub | apt-key add - 
RUN echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/${NVARCH} /" > /etc/apt/sources.list.d/cuda.list 
RUN apt-get purge --autoremove -y curl     && rm -rf /var/lib/apt/lists/*
ENV CUDA_VERSION=10.2.89
RUN TARGETARCH=ppc64le apt-get update
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-license-10-2_10.2.89-1_amd64.deb
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-cudart-10-2_10.2.89-1_amd64.deb
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-compat-10-2_440.33.01-1_amd64.deb
RUN dpkg -i cuda-license-10-2_10.2.89-1_amd64.deb
RUN dpkg -i cuda-cudart-10-2_10.2.89-1_amd64.deb
RUN dpkg -i cuda-compat-10-2_440.33.01-1_amd64.deb
# RUN apt-get install -y --no-install-recommends     cuda-cudart-10-2=10.2.89-1   cuda-compat-10-2  
RUN ln -s cuda-10.2 /usr/local/cuda 
RUN  rm -rf /var/lib/apt/lists/*
RUN TARGETARCH=ppc64le echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf &&     echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64
# COPY NGC-DL-CONTAINER-LICENSE / # buildkit
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVARCH=x86_64
ENV NVIDIA_REQUIRE_CUDA=cuda>=10.2 brand=tesla
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin
RUN mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
RUN wget https://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda-repo-ubuntu1804-10-2-local-10.2.89-440.33.01_1.0-1_amd64.deb
RUN dpkg -i cuda-repo-ubuntu1804-10-2-local-10.2.89-440.33.01_1.0-1_amd64.deb
RUN apt-key add /var/cuda-repo-10-2-local-10.2.89-440.33.01/7fa2af80.pub 

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install cuda
#,driver>=418,driver<419
COPY . /app
WORKDIR /app
# COPY requirements.txt /app/requirements.txt

ENV SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True

ENV DATA_ROOT=data
ENV OUTPUT_ROOT=output
ENV DATABASE_URL=postgres://card:card@localhost:6667/card
ENV KDE_DATABASE_URL=postgres://card:card@localhost:5432/card

ENV CPU_NUM_THREADS=16
ENV OMP_NUM_THREADS=16
ENV OPENBLAS_NUM_THREADS=16
ENV MKL_NUM_THREADS=16
ENV VECLIB_MAXIMUM_THREADS=16
ENV NUMEXPR_NUM_THREADS=16

ENV PSQL=/usr/bin/psql
ENV KDE_PSQL=/usr/local/pgsql/bin/psql
ENV KDE_POSTGRES=/usr/local/pgsql/bin/postgres
ENV KDE_PG_DATA=/home/ubuntu/feedback-kde/data

ENV MYSQL=mysql
ENV MYSQL_HOST=localhost
ENV MYSQL_DB=card
ENV MYSQL_USER=root
ENV MYSQL_PSWD=card
ENV MYSQL_PORT=10235