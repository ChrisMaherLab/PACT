#!/usr/bin/cwl-runnner

cwlVersion: v1.0
class: CommandLineTool
label: "CNVkit fix"

baseCommand: ["cnvkit.py", "fix",]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/cna_pipeline_docker" 
    - class: ResourceRequirement
      coresMin: 4
      ramMin: 15000

inputs:
 target_coverage:
  type: File
  inputBinding:
   position: 2
 antitarget_coverage:
  type: File
  inputBinding:
   position: 3
 reference_coverage:
  type: File
  inputBinding:
   position: 4 

arguments:
 - valueFrom: "--no-edge"
   position: 1
 - valueFrom:
    ${
      var x = String(inputs.target_coverage.nameroot).split('.')[0];
      var xx = x + ".cnr" ;
      return xx;
    }
   position: 5
   prefix: "-o"

outputs:
 ratios:
  type: File
  outputBinding:
   glob: "*.cnr"
