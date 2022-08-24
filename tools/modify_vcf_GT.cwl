#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Drop germline SVs. Change GT of 0/0 or ./. to 0/1 for remaining calls to allow merging."

baseCommand: ["bash", "mod_GT.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "mod_GT.sh"
        entry: |
            infile=$1
            #cat $infile | perl -ane 'if ($F[0] =~ /^#/){print $_;} else {$F[$a-1] =~ s/(^\.\/\.|0\/0)/0\/1/; @tt=split(/:/, $F[9]); @nn=split(/:/, $F[-1]); $tpe=$tt[23]; $tsr=@tt[20]; $npe=@nn[23]; $nsr=@nn[20]; $tr=$tpe+$tsr; $nr=$npe+$nsr; if ($tr> 0 && $nr==0) {print join("\t", @F), "\n";}}'
            cat $infile | perl -ane 'if ($F[0] =~ /^#/){print $_;} else {$F[$a-1] =~ s/(^\.\/\.|0\/0)/0\/1/; @tt=split(/:/, $F[9]); @nn=split(/:/, $F[-1]); $npe=@nn[23]; $nsr=@nn[20]; $nr=$npe+$nsr; if ($nr==0) {print join("\t", @F), "\n";}}'

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


