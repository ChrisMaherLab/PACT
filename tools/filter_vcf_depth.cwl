#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "filter variants at sites below a given sequence depth in each sample"
requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"
    - class: ResourceRequirement
      ramMin: 4000
baseCommand: ["/usr/bin/python3", "/usr/bin/depth_filter.py"]

arguments: 
    [{valueFrom: "$(runtime.outdir)/depth_filtered.vcf"}]

inputs:
    vcf:
        type: File
        inputBinding:
            position: -2
    minimum_depth: 
        type: int
        inputBinding:
            prefix: "--minimum_depth"
            position: -3
    sample_names:
        type: string[]
        inputBinding:
            itemSeparator: ","
            position: -1
outputs:
     depth_filtered_vcf:
         type: File
         outputBinding:
             glob: "depth_filtered.vcf"
