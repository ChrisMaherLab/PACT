#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Clean up output bedpe file. Removes duplicates and adds header"

baseCommand: ["bash", "helper.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "helper.sh"
        entry: |
           infile=$1
           cat $infile | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21}' | sort | uniq | sed '1 i\chrom1\tstart1\tend1\tchrom2\tstart2\tend2\tname\tscore\tstrand1\tstrand2\tplasma_pe_reads\tplasma_split_reads\tplasma_pe_sr_reads\tplasma_clipped\tplasma_alt_quality_obs\tnormal_pe_reads\tnormal_split_reads\tnormal_pe_sr_reads\tnormal_clipped\tnormal_alt_quality_obs\tinfo1'

inputs:
 in_file:
  type: File
  inputBinding:
   position: 1

outputs:
 cleaned_out:
  type: stdout

stdout: aggregate.final.sv.bedpe
