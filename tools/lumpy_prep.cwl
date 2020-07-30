#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Perform various functions with samtools to get split reads and discordant reads"

baseCommand: ["bash", "perform_prep.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "biocontainers/samtools:v1.7.0_cv4"
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "perform_prep.sh"
        entry: |
            tum=$1
            con=$2
            splitReads=$3
            outdir=$4

            samtools view -b -F 1294 $tum | samtools sort > $outdir/tumor.discordant.bam
            samtools view -h $tum | $splitReads -i stdin | samtools view -Sb | samtools sort > $outdir/tumor.split.bam
            samtools index $outdir/tumor.discordant.bam
            samtools index $outdir/tumor.split.bam
            samtools flagstat $outdir/tumor.discordant.bam > $outdir/tumor.discordant.bam.flagstat
            samtools flagstat $outdir/tumor.split.bam > $outdir/tumor.split.bam.flagstat
            
            
            samtools view -b -F 1294 $con | samtools sort > $outdir/control.discordant.bam
            samtools view -h $con | $splitReads -i stdin | samtools view -Sb | samtools sort > $outdir/control.split.bam
            samtools index $outdir/control.discordant.bam
            samtools index $outdir/control.split.bam
            samtools flagstat $outdir/control.discordant.bam > $outdir/control.discordant.bam.flagstat
            samtools flagstat $outdir/control.split.bam > $outdir/control.split.bam.flagstat

inputs:
 tumor_bam:
  type: File
  inputBinding:
   position: 1
 control_bam:
  type: File
  inputBinding:
   position: 2
 extractSplitReads_script:
  type: File
  inputBinding:
   position: 3

arguments:
 - valueFrom: $(runtime.outdir)
   position: 4

outputs:
 tumor_split:
  type: File
  outputBinding:
   glob: "tumor.split.bam"
 control_split:
  type: File
  outputBinding:
   glob: "control.split.bam"
 tumor_discordant:
  type: File
  outputBinding:
   glob: "tumor.discordant.bam"
 control_discordant:
  type: File
  outputBinding:
   glob: "control.discordant.bam"


