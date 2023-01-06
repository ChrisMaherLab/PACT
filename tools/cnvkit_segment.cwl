#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "CNVkit segment"

baseCommand: ["cnvkit.py", "segment"]

requirements:
    - class: ResourceRequirement
      coresMin: 4
      ramMin: 64000
    - class: DockerRequirement
      dockerPull: "jbwebster/cna_pipeline_docker"

inputs:
 coverage:
  type: File
  inputBinding:
   position: 1

arguments:
 - valueFrom: |
    ${
      var x = String(inputs.coverage.basename).split('.')[0];
      var xx = x + ".cns";
      return xx;
    }
   position: 2
   prefix: "-o"

outputs:
 cna_segmented:
  type: File
  outputBinding:
   glob: "*.cns"
