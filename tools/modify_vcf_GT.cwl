#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Change GT of 0/0 or ./. to 0/1 to allow merging."

baseCommand: ["bash", "mod_GT.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "mod_GT.sh"
        entry: |
            infile=$1

            cat $infile | perl -ane '$a = scalar @F; if (!($F[0] =~ /^#/)){$F[$a-1] =~ s/(^\.\/\.|0\/0)/0\/1/;} print join("\t", @F), "\n";'

inputs:
 vcf:
  type: File
  inputBinding:
   position: 1
  doc: "Genotyped vcf file"

outputs:
 modded_GT:
  type: stdout

stdout: genotyped_mod_GT.vcf


