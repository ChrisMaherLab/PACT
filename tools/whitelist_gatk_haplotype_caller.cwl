#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "HaplotypeCaller (GATK4)"
baseCommand: ["/bin/bash", "whitelist_haplotypeCaller.sh"]
requirements:
    - class: ResourceRequirement
      ramMin: 9000
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"
    - class: InitialWorkDirRequirement
      listing:
      - entryname: 'whitelist_haplotypeCaller.sh'
        entry: |
             set -o pipefail
             set -o errexit

             # Running haplotype caller using the newly created interval list
             if [[ "$#" == 5 ]];then # If normal_bam is passed.
                 # explicitly capturing variables
                 reference=$1
                 normal_bam=$2
                 tumor_bam=$3
                 whitelist_vcf=$4
                 interval_list=$5
                 # Chaning the interval_list to a new whitelist_interval_list that spans the whitelist regions by 200bp
                 cat $interval_list | grep '^@' > whitelist.interval_list # Extracting the header from the interval_list
                 zcat $whitelist_vcf | grep -v "#" | awk '{FS = "\t";OFS = "\t";print $1,$2-100,$2+100,"+",$1"_"$2-100"_"$2+100}' >> whitelist.interval_list # Extracting the whitelist regions with a 100bp flanking region on both directions
                 gatk HaplotypeCaller --java-options "-Xmx8g" -R $reference -I $normal_bam -I $tumor_bam --alleles $whitelist_vcf -L whitelist.interval_list -O whitelist_raw_variants.vcf
             else # If normal_bam is not passed
                 reference=$1
                 tumor_bam=$2
                 whitelist_vcf=$3
                 interval_list=$4
                 # Chaning the interval_list to a new whitelist_interval_list that spans the whitelist regions by 200bp
                 cat $interval_list | grep '^@' > whitelist.interval_list # Extracting the header from the interval_list
                 zcat $whitelist_vcf | grep -v "#" | awk '{FS = "\t";OFS = "\t";print $1,$2-100,$2+100,"+",$1"_"$2-100"_"$2+100}' >> whitelist.interval_list # Extracting the whitelist regions with a 100bp flanking region on both directions
                 gatk HaplotypeCaller --java-options "-Xmx8g" -R $reference -I $tumor_bam --alleles $whitelist_vcf -L whitelist.interval_list -O whitelist_raw_variants.vcf
             fi

inputs:
    reference:
        type: File
        secondaryFiles: [.fai, ^.dict]
        inputBinding:
            position: 1
    normal_bam:
        type: File
        secondaryFiles: [.bai]
        inputBinding:
            position: 2
    bam:
        type: File
        secondaryFiles: [.bai]
        inputBinding:
            position: 3
    whitelist_vcf:
        type: File
        inputBinding:
            position: 4
        secondaryFiles: [.tbi]
    interval_list:
        type: File
        inputBinding:
            position: 5
outputs:
    whitelist_raw_variants:
        type: File
        outputBinding:
            glob: "whitelist_raw_variants.vcf"
