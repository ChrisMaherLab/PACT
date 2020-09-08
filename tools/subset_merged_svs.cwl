#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Create a subset of a merged cohort vcf that includes only header lines and SVs found in a specific sample"

baseCommand: ["bash", "create_subset.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "create_subset.sh"
        entry: |
            filepath=$1
            vcf=$2
            outdir=$3
            base=${filepath##*/}
            rootname=${base%.*}
            grep "#" $vcf > $outdir/$rootname.vcf
            grep -v "#" $vcf | grep $rootname >> $outdir/$rootname.vcf

inputs:
 sample_of_interest:
  type: string[]
 vcf:
  type: File
  inputBinding:
   position: 2

arguments:
 - valueFrom: $(inputs.sample_of_interest[1])
   position: 1
 - valueFrom: $(runtime.outdir)
   position: 3

outputs:
 sv_subset:
  type: File
  outputBinding:
   glob: "$(inputs.sample_of_interest[1].split('/').slice(-1)[0].split('.').slice(0,-1).join('.')).vcf"

