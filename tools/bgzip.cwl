#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "bgzip VCF"
baseCommand: ["/usr/local/bin/bgzip"]
requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/snv_pipeline_docker"
    - class: ResourceRequirement
      ramMin: 4000
stdout: $(inputs.file.basename).gz
arguments:
    ["-c"]
inputs:
    file:
        type: File
        inputBinding:
            position: 1
outputs:
    bgzipped_file:
        type: stdout

