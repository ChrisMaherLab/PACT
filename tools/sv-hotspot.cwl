#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
description: "Create basic visualization using default values from SV-HotSpot"

baseCommand: ["bash", "run_sv_hotspot.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "chrismaherlab/sv-hotspot"
    - class: ResourceRequirement
      ramMin: 12000
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "run_sv_hotspot.sh"
        entry: |
           cd /usr/bin
           sv-hotspot -g $1 --sv $2 -o $3

inputs:
 genome:
  type: string
  inputBinding:
   position: 1
 bedpe:
  type: File
  inputBinding:
   position: 2

arguments:
 - valueFrom: $(runtime.outdir)/OUTPUT_VIS
   position: 3

outputs:
 vis:
  type: Directory
  outputBinding:
   glob: "OUTPUT_VIS"
 annotated_peaks:
  type: File
  outputBinding:
   glob: "OUTPUT_VIS/sv-hotspot-output/annotated_peaks_summary.tsv"


