#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "CNVkit reference"

baseCommand: ["python3", "helper.py"]

requirements:
    - class: DockerRequirement
      dockerPull: "jbwebster/cna_pipeline_docker"
    - class: InlineJavascriptRequirement
    - class: InitialWorkDirRequirement
      listing:
      - entryname: 'helper.py'
        entry: |
            #!/usr/bin/python3

            import os
            import sys
            import subprocess

            cmd = 'cnvkit.py reference'

            fasta = sys.argv[1]
            cmd += ' --fasta ' + fasta

            cmd += ' -y --no-edge'

            outf = sys.argv[2]
            cmd += ' -o ' + outf

            targs = sys.argv[3]
            targ_str = targs.split(',')
            for x in targ_str:
                cmd += ' ' + x
            
            antitargs = sys.argv[4]
            antitargs_str = antitargs.split(',')
            for x in antitargs_str:
                cmd += ' ' + x

            process = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
            output, error = process.communicate()


    - class: ResourceRequirement
      coresMin: 12
      ramMin: 28000

inputs:
 reference:
  type:
   - string
   - File
  inputBinding:
   position: 3
 target_cnn:
  type: File[]
  inputBinding:
   position: 5
   itemSeparator: ","
 antitarget_cnn:
  type: File[]
  inputBinding:
   position: 6
   itemSeparator: ","

arguments:
 - valueFrom: $(runtime.outdir)/reference.cnn
   position: 4

outputs:
 reference_coverage:
  type: File
  outputBinding:
   glob: "reference.cnn"
