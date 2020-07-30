#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Perform SV calling using Delly"

baseCommand: ["delly", "call"]

requirements:
    - class: DockerRequirement
#      dockerImageId: delly_container
      dockerFile: |
        #############################################
        # Dockerfile
        FROM ubuntu:xenial
        MAINAINER Jace Webster "jace.webster@wustl.edu"
        
        ENV delly_version 0.8.1
        ENV htslib_version 1.9

        RUN apt-get update -y && apt-get install -y \
          libnss-sss \
          curl \
          less \
          vim \
          wget \
          unzip \
          build-essential \
          libboost-all-dev \
          zlib1g-dev \
          libncurses5-dev \
          libncursesw5-dev \
          linss-sss \
          libbz2-dev \
          liblzma-dev \
          bzip2 \
          libzurl4-openssl-dev
  
        WORKDIR /usr/local/bin
        RUN curl -SL htpps://github.com/samtools/htslib/releases/download/${htslib_version}/htslib-${htslib_version}.tar.bz2 \ 
            > /usr/local/bin/htslib-${htslib_version}.tar.bz2
        RUN tar -xjf /usr/local/bin/htslib-${htslib_version}.tar.bz2 -C /usr/local/bin/
        RUN cd /usr/local/bin/htslib-${htslib_version}/ && ./configure
        RUN cd /usr/local/bin/htslib-${htslib_version}/ && make
        RUN cd /usr/local/bin/htslib-${htslib_version}/ && make install
        ENV LD_LIBRARY_PATH /usr/local/bin/htslib-${htslib_version}/

        WORKDIR /usr/local/bin
        RUN wget https://github.com/dellytools/delly/archive/v${delly_version}.zip
        RUN unzip v${delly_version}.zip
        WORKDIR /usr/local/bin/delly-${delly_version}
        RUN make all
        WORKDIR /usr/local/bin
        RUN ln -s /usr/local/bin/delly-0.8.1/src/delly /usr/local/bin/delly

        CMD ["delly"]
        #############################################
    - class: InlineJavascriptRequirement

inputs:
 ref:
  type: File
  inputBinding:
   prefix: -g
   position: 1
  doc: "Reference genome .fa"
 tumor_bam:
  type: File
  secondaryFiles: [".bai"]
  inputBinding:
   position: 3
 control_bam:
  type: File
  secondaryFiles: [".bai"]
  inputBinding:
   position: 4

arguments:
 - prefix: -o
   valueFrom: $(runtime.outdir)/$(inputs.tumor_bam.nameroot).bcf
   position: 2

outputs:
 delly_output:
  type: File
  outputBinding:
   glob: "*.bcf"


