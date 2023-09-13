#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Process results"
baseCommand: ["/bin/bash", "helper.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/cna_pipeline_docker"
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "helper.sh"
        entry: |
             #!/bin/bash

             mkdir cnvkit-outs
             mv ${1} cnvkit-outs/
             mv ${2} cnvkit-outs/
             mv ${3} cnvkit-outs/
             mv ${4} cnvkit-outs/

             Rscript /usr/bin/process-cnvkit-results.r cnvkit-outs ${5} ${6} ${7} ${8}

inputs:
 target_coverage:
  type: File
  inputBinding:
   position: 1
 antitarget_coverage:
  type: File
  inputBinding:
   position: 2
 fixed_cnr:
  type: File
  inputBinding:
   position: 3
 segmented:
  type: File
  inputBinding:
   position: 4
 reference_cnn:
  type: File
  inputBinding:
   position: 6
 genome:
  type: string
  inputBinding:
   position: 7
 target_genes:
  type: File
  inputBinding:
   position: 8

arguments:
 - valueFrom: |
    ${
      var x = String(inputs.antitarget_coverage.basename).split('.')[0];
      return x;
    }
   position: 5 

outputs:
 out_bed:
  type: File
  outputBinding:
   glob: "*.bed"
 out_cov:
  type: File
  outputBinding:
   glob: "*.cov.tsv"
