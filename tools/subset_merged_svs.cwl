#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Create a subset of a merged cohort vcf that includes only header lines and SVs found in a specific sample"

baseCommand: ["bash"]

requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"

inputs:
 helper_script:
  type: File
  inputBinding:
   position: 1
 vcf:
  type: File
  inputBinding:
   position: 2
 sample_file_of_interest:
  type: string
 sample_bams:
  type: string[]
  inputBinding:
   position: 4
   itemSeparator: ","
 tumor_bams:
  type: string[]
  inputBinding:
   position: 5
   itemSeparator: ","
 extracted_sample_names:
  type: string[]
  inputBinding:
   position: 6
   itemSeparator: ","
 extracted_tumor_names:
  type: string[]
  inputBinding:
   position: 7
   itemSeparator: ","

arguments:
 - valueFrom: $(runtime.outdir)
   position: 8
 - valueFrom: $(inputs.sample_file_of_interest.split('/').slice(-1)[0].split('.').slice(0,-1).join('.')).vcf
   position: 3

outputs:
 sv_subset:
  type: File
  outputBinding:
   glob: "$(inputs.sample_file_of_interest.split('/').slice(-1)[0].split('.').slice(0,-1).join('.')).vcf"

