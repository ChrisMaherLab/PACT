#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Add FILTER column info to INFO column"
baseCommand: ["bash", "add_filter_to_info.sh"]
requirements:
    - class: DockerRequirement
      dockerPull: "ubuntu:xenial"
    - class: ResourceRequirement
      ramMin: 4000
    - class: StepInputExpressionRequirement
    - class: InitialWorkDirRequirement
      listing:
      - entryname: 'add_filter_to_info.sh'
        entry: |
            #!/usr/bin/bash
            vcf=$1
            outfile=$2

            zgrep "^#" $vcf > $outfile
            zgrep -v "^#" $vcf | awk 'BEGIN{FS=OFS="\t"}{gsub(";", "-", $7)}{$8=$8";FILTER="$7}{gsub("-", ";", $7)}{print $0}' >> $outfile


arguments:
 - valueFrom: $(runtime.outdir)/filter_in_info.vcf
   position: 2

inputs:
    vcf:
      type: File
      inputBinding:
       position: 1

outputs:
    prepared_vcf:
        type: File
        outputBinding:
            glob: "filter_in_info.vcf"

