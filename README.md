
# cfDNA Analysis Workflows
##

Developed at [Christopher Maher Lab](http://www.maherlab.com) at [Washington University in St. Louis](http://www.wustl.edu)

##

## Overview

Standardized workflows for sensitive and reproducible detection of both small and large genomic alterations using targeted cfDNA sequencing, shared in a portable [Common Workflow Language](https://www.commonwl.org/) (CWL) pipeline. 

## Quick Start

Download the repository with `git clone https://github.com/ChrisMaherLab/Jacesbestrepoever.git`

A number of tools exist for running CWL pipelines. In our benchmarking analysis, all pipelines were run using the Cromwell CWL interpreter (v54), which can be downloaded [here](https://github.com/broadinstitute/cromwell/releases). For additional information about using Cromwell, we suggest their [user guide](https://www.commonwl.org/user_guide/) and their [configuration tutorials](https://cromwell.readthedocs.io/en/stable/tutorials/ConfigurationFiles/).

After installation and configuration of Cromwell, the pipeline(s) can be run using:

`java -Dconfig.file=<config.file> -jar <cromwell.jar> run -t cwl -i <input_yaml> pipelines/<pipeline>.cwl`

## Structure

This repo is organized as follows:
| Directory | Description |
| --- | --- |
| pipelines | Full workflows, which rely on subworkflows and tools |
| subworkflows | Workflows called by pipelines that combine tools to form intermediate files |
| tools | Individual steps in the workflow containing single commands or scripts |
| example_ymls | Example format for input YAML files using minimal inputs |
