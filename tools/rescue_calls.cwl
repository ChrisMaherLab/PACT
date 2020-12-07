#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Rescue non-consensus calls based on evidence of recurrence across multiple samples"

baseCommand: ["python"]

requirements:
    - class: DockerRequirement
      dockerPull: "python"
    - class: ResourceRequirement
      ramMin: 12000

inputs:
 helper_script:
  type: File
  inputBinding:
   position: 1
 peaks:
  type: File
  inputBinding:
   position: 2
   prefix: -p
 consensus_calls:
  type: File
  inputBinding:
   position: 3
   prefix: -c
 sample_vcfs: 
  type: File[]
  inputBinding:
   position: 4
   prefix: -v
   itemSeparator: ","
 threshold:
  type: int
  inputBinding:
   position: 5
   prefix: -n

arguments:
 - valueFrom: $(runtime.outdir)
   position: 6
   prefix: -o

outputs:
 delly_rescue:
  type: File
  outputBinding:
   glob: "delly_rescue*"
 manta_rescue:
  type: File
  outputBinding:
   glob: "manta_rescue*"
 lumpy_rescue:
  type: File
  outputBinding:
   glob: "lumpy_rescue*"


