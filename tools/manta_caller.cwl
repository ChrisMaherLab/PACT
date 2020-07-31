#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "Set up and run manta for SV calling"

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/manta_docker"
    - class: InlineJavascriptRequirement
    - class: ShellCommandRequirement
    - class: ResourceRequirement
      coresMin: 12
      ramMin: 24000
      tmpdirMin: 10000

baseCommand: ["/usr/bin/python", "/usr/bin/manta/bin/configManta.py"]

inputs:
    normal_bam:
        type: File
        inputBinding:
            position: -2
            prefix: "--normalBam"
        secondaryFiles: [".bai"]
    tumor_bam:
        type: File
        inputBinding:
            position: -3
            prefix: "--tumorBam"
        secondaryFiles: [".bai"]
    ref:
        type: File
        secondaryFiles: [.fai]
        inputBinding:
            position: -4
            prefix: "--referenceFasta"

arguments:
 - valueFrom: $(runtime.outdir)
   prefix: "--runDir"
   position: -1
 - valueFrom: "--exome"
   position: -5
 - shellQuote: false
   valueFrom: "&&"
 - "/usr/bin/python"
 - "runWorkflow.py"
 - "-m"
 - "local"
 - valueFrom: $(runtime.cores)
   prefix: "-j"
   position: 1

outputs:
    diploid_variants:
        type: File?
        outputBinding:
            glob: results/variants/diploidSV.vcf.gz
        secondaryFiles: [.tbi]
    somatic_variants:
        type: File?
        outputBinding:
            glob: results/variants/somaticSV.vcf.gz
        secondaryFiles: [.tbi]
    all_candidates:
        type: File
        outputBinding:
            glob: results/variants/candidateSV.vcf.gz
        secondaryFiles: [.tbi]
    small_candidates:
        type: File
        outputBinding:
            glob: results/variants/candidateSmallIndels.vcf.gz
        secondaryFiles: [.tbi]
    tumor_only_variants:
        type: File?
        outputBinding:
            glob: results/variants/tumorSV.vcf.gz
        secondaryFiles: [.tbi]
