# work from latest LTS ubuntu release
FROM ubuntu:18.04

# set the environment variables
ENV delly_version 0.8.1
ENV htslib_version 1.9

# run update
RUN apt-get update -y && apt-get install -y \
    libnss-sss \
    curl \
    less \
    vim  \
    wget \
    unzip \
    build-essential \
    libboost-all-dev \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libnss-sss \
    libbz2-dev \
    liblzma-dev \
    bzip2 \
    libcurl4-openssl-dev

# install htslib
WORKDIR /usr/local/bin/
RUN curl -SL https://github.com/samtools/htslib/releases/download/${htslib_version}/htslib-${htslib_version}.tar.bz2 \
    > /usr/local/bin/htslib-${htslib_version}.tar.bz2
RUN tar -xjf /usr/local/bin/htslib-${htslib_version}.tar.bz2 -C /usr/local/bin/
RUN cd /usr/local/bin/htslib-${htslib_version}/ && ./configure
RUN cd /usr/local/bin/htslib-${htslib_version}/ && make
RUN cd /usr/local/bin/htslib-${htslib_version}/ && make install
ENV LD_LIBRARY_PATH /usr/local/bin/htslib-${htslib_version}/

# install delly
WORKDIR /usr/local/bin
RUN wget https://github.com/dellytools/delly/archive/v${delly_version}.zip
RUN unzip v${delly_version}.zip
WORKDIR /usr/local/bin/delly-${delly_version}
RUN make all
WORKDIR /usr/local/bin
RUN ln -s /usr/local/bin/delly-0.8.1/src/delly /usr/local/bin/delly

# set default cmd
CMD ["delly"]
