#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Prepare vcf for HaplotypeCaller (GATK)"
baseCommand: ["/bin/bash", "helper.sh"]
requirements:
    - class: ResourceRequirement
      ramMin: 9000
    - class: DockerRequirement
      dockerPull: "broadinstitute/gatk:4.1.2.0"
    - class: InitialWorkDirRequirement
      listing:
      - entryname: 'helper.sh'
        entry: |
             set -o pipefail
             set -o errexit

             vcf=$1
             intervals=$2

             # Only keep PASSed calls that were not on the whitelist 
             grep "##" $vcf > prepared.vcf
             grep "CHROM" $vcf | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4, $5, $6, $7, $8}' >> prepared.vcf
             grep -v "##" $vcf | grep "PASS" | grep -v "whitelist" | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4, $5, $6, $7, $8}' >> prepared.vcf
            
             if grep -q -v "#" prepared.vcf; then 
               cat $intervals | grep '^@' > modified.interval_list
               grep -v "#" prepared.vcf | awk '{FS = "\t";OFS = "\t";print $1,$2-100,$2+100,"+",$1"_"$2-100"_"$2+100}' >> modified.interval_list
             else
               cat $intervals > modified.interval_list;
             fi 
inputs:
    vcf:
        type: File
        inputBinding:
            position: 1
    intervals:
        type: File
        inputBinding:
            position: 2 
outputs:
    prepared_vcf:
        type: File
        outputBinding:
            glob: "prepared.vcf"
    mod_interval_list:
        type: File
        outputBinding:
            glob: "modified.interval_list"
