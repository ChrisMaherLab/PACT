#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Move all files into same dir"
baseCommand: ["/bin/bash", "helper.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/cna_pipeline_docker"
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "helper.sh"
        entry: |
             #!/bin/bash

             cat $1 > gene_overlaps.tsv
             tail -n +2 $2 >> gene_overlaps.tsv

             echo -e "sample\ttype" > samples.info.tsv
             tail -n +2 $1 | awk 'BEGIN{FS=OFS="\t"}{print $2}' | sed 's#/.*##g' | sort | uniq | awk 'BEGIN{FS=OFS="\t"}{print $1,"plasma"}' >> samples.info.tsv
             tail -n +2 $2 | awk 'BEGIN{FS=OFS="\t"}{print $2}' | sed 's#/.*##g' | sort | uniq | awk 'BEGIN{FS=OFS="\t"}{print $1,"normal"}' >> samples.info.tsv


             Rscript /usr/bin/calc-cna-for-genes.r gene_overlaps.tsv samples.info.tsv $3 $4

inputs:
 sample_gene_overlaps:
  type: File
  inputBinding:
   position: 1
 control_gene_overlaps:
  type: File
  inputBinding:
   position: 2
 target_genes:
  type:
      - string
      - File
  inputBinding:
   position: 3
 nsd:
  type: int
  inputBinding:
   position: 4

outputs:
 cna_calls:
  type: File
  outputBinding:
   glob: "cna-call-targeted-genes.tsv"

