
# cfDNA Analysis Workflows
##

Developed at [Christopher Maher Lab](http://www.maherlab.com) at [Washington University in St. Louis](http://www.wustl.edu)

##

## Overview

Standardized workflows for sensitive and reproducible detection of both small and large genomic alterations using targeted cfDNA sequencing, shared in a portable [Common Workflow Language](https://www.commonwl.org/) (CWL) pipeline. 

## Quick Start

Download the repository with `git clone https://github.com/ChrisMaherLab/LiquidScan.git`

A number of tools exist for running CWL pipelines. In our benchmarking analysis, all pipelines were run using the Cromwell CWL interpreter (v54), which can be downloaded [here](https://github.com/broadinstitute/cromwell/releases). For additional information about using Cromwell, we suggest their [user guide](https://www.commonwl.org/user_guide/) and their [configuration tutorials](https://cromwell.readthedocs.io/en/stable/tutorials/ConfigurationFiles/).

After installation and configuration of Cromwell, the pipeline(s) can be run using:

`java -Dconfig.file=<config.file> -jar <cromwell.jar> run -t cwl -i <input_yaml> pipelines/<pipeline>.cwl`

For additional information about writing, reading and using CWL files, see the [official CWL user guide](https://www.commonwl.org/user_guide/).

## Structure

This repository is organized as follows:
| Directory | Description |
| --- | --- |
| pipelines | Full workflows, which rely on subworkflows and tools |
| subworkflows | Workflows called by pipelines that combine tools to form intermediate files |
| tools | Individual steps in the workflow containing single commands or scripts |
| example_ymls | Example format for input YAML files using minimal inputs |

## File Inputs

The provided workflows accept a variety of optional and/or required input files. Each input file is described below, including how to label the file in an input .yml, the workflows the file is used in, and a brief description.

<details>
  <summary>Reference fasta and associated files</summary>
  
  | Input label | Applicable workflow(s) | Description |
  | --- | --- |
  | reference | All workflows (required) | Absolute path to a reference genome fasta file. A <reference>.fai index file made using `samtools faidx` and a <reference>.dict file made using Picard's `CreateSequenceDictionary` command should be present in the directory. |
  | ref_genome | SV workflow (required) | Name of reference genome used. Should match the name used by any applicable annotation databases (eg. hg19) |
</details>
