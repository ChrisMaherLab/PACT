#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Get gene overlaps"

baseCommand: ["/bin/bash", "helper.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/cna_pipeline_docker"
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "helper.sh"
        entry: |
             #!/bin/bash

             echo -e "gene\tseg\tlog2r\toverlap" > genes-overlap-cna-segments.tsv
             
             IFS=',' read -ra ARR <<< ${2}
             for i in "${ARR[@]}"; do
               >&2 echo "$i"
               intersectBed -wo -a ${1} -b "$i" | cut -f4,10,11,12 >> genes-overlap-cna-segments.tsv
             done

inputs:
 all_genes:
  type:
      - string
      - File
  inputBinding:
   position: 1
 segmented_bed:
  type: File[]
  inputBinding:
   position: 2
   itemSeparator: ","

outputs:
 gene_overlaps:
  type: File
  outputBinding:
   glob: "genes-overlap-cna-segments.tsv"
