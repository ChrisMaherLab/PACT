#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

baseCommand: ["bash", "helper_script.sh"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"
    - class: InlineJavascriptRequirement
    - class: InitialWorkDirRequirement
      listing:
      - entryname: "helper_script.sh"
        entry: |
            bam=$1
            samtools view -H $bam | grep '^@RG' | sed "s/.*SM:\([^\t]*\).*/\1/g" | uniq

inputs:
 bam:
  type: File
  inputBinding:
   position: 1

outputs:
 sample_name:
  type: string
  outputBinding:
    glob: sample_name.txt
    loadContents: true
    outputEval: $(self[0].contents.replace(/\n/g, ''))

stdout: sample_name.txt
