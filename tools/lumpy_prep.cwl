#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Perform various functions with samtools to get split reads and discordant reads"

baseCommand: ["bash", "perform_prep.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/pipeline_docker"
    - class: ResourceRequirement
      coresMin: 8
      ramMin: 15000
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "perform_prep.sh"
        entry: |
            sam=$1
            con=$2
            outdir=$3

            samtools view -b -F 1294 $sam | samtools sort > $outdir/sample.discordant.bam
            samtools view -h $sam | python3 /usr/local/bin/extractSplitReads_BwaMem -i stdin | samtools view -Sb | samtools sort > $outdir/sample.split.bam
            samtools index $outdir/sample.discordant.bam
            samtools index $outdir/sample.split.bam
            samtools flagstat $outdir/sample.discordant.bam > $outdir/sample.discordant.bam.flagstat
            samtools flagstat $outdir/sample.split.bam > $outdir/sample.split.bam.flagstat
            
            
            samtools view -b -F 1294 $con | samtools sort > $outdir/normal.discordant.bam
            samtools view -h $con | python3 /usr/local/bin/extractSplitReads_BwaMem -i stdin | samtools view -Sb | samtools sort > $outdir/normal.split.bam
            samtools index $outdir/normal.discordant.bam
            samtools index $outdir/normal.split.bam
            samtools flagstat $outdir/normal.discordant.bam > $outdir/normal.discordant.bam.flagstat
            samtools flagstat $outdir/normal.split.bam > $outdir/normal.split.bam.flagstat


inputs:
 sample_bam:
  type: string
  inputBinding:
   position: 1
 normal_bam:
  type: string
  inputBinding:
   position: 2

arguments:
 - valueFrom: $(runtime.outdir)
   position: 3

outputs:
 sample_split:
  type: File
  outputBinding:
   glob: "sample.split.bam"
 normal_split:
  type: File
  outputBinding:
   glob: "normal.split.bam"
 sample_discordant:
  type: File
  outputBinding:
   glob: "sample.discordant.bam"
 normal_discordant:
  type: File
  outputBinding:
   glob: "normal.discordant.bam"


