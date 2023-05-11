
# PACT: A pipeline for analysis of circulating tumor DNA
##

Developed by the [Christopher Maher Lab](http://www.maherlab.com) at [Washington University in St. Louis](http://www.wustl.edu) in collaboration with the labs of Dr. Aadel Chaudhuri and Dr. Russell Pachynski.

##

## Overview

Standardized workflows for sensitive and reproducible detection of both small and large genomic alterations using targeted ctDNA sequencing, shared in a [Common Workflow Language](https://www.commonwl.org/) (CWL) pipeline. 

## Quick Start

Download the repository with `git clone https://github.com/ChrisMaherLab/PACT.git`

A number of tools exist for running CWL pipelines. In our benchmarking analysis, all pipelines were run locally using the Cromwell CWL interpreter (v54), which can be downloaded [here](https://github.com/broadinstitute/cromwell/releases). For additional information about using Cromwell, we suggest their [user guide](https://www.commonwl.org/user_guide/) and their [configuration tutorials](https://cromwell.readthedocs.io/en/stable/tutorials/ConfigurationFiles/).

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

## Inputs

The provided workflows accept a variety of optional and/or required input files. Example input yaml files have been provided in the example_ymls directory, which contain all required inputs and a brief description of expected values. Additional inputs are available for additional customization of the pipeline(s), and can be seen in the inputs section of the corresponding CWL file in the pipelines directory.

Common/required inputs are described below, including how to label the information in an input yaml file, the workflows the file is used in, and a brief description.

<details>
  <summary>Reference Genome Inputs</summary>
  
  | Input label | Applicable workflow(s) | Description |
  | --- | --- | --- |
  | reference | All workflows (required) | Absolute path to a reference genome fasta file. A <reference>.fai index file made using `samtools faidx` and a <reference>.dict file made using Picard's `CreateSequenceDictionary` command should be present in the directory. |
  | ref_genome | SV and CNA workflows (required) | Name of reference genome used. Should match the name used by any applicable annotation databases (eg. hg19) |
  | ref_flat | CNA workflow (required) | Genome annotation file in refFlat format |
</details>
<details>
  <summary>Annotation Information</summary>

  | Input label | Applicable workflow(s) | Description |
  | --- | --- | --- |
  | snpEff_data | SV workflow (required) | Absolute path to a snpEff annotation database directory. This can be downloaded using snpEff's download command: `java -jar snpEff.jar download <database>`. |
  | vep_cache_dir | SNV workflow (required) | Absolute path to vep annotation cache information. See the ensembl website (https://useast.ensembl.org/info/docs/tools/vep/script/vep_cache.html) for information about downloading the cache. |
  | vep_ensembl_assembly | SNV workflow (required) | A string containing the name of the genome assembly associated with the provided vep cache (eg GRCh37) |
  | vep_ensembl_version | SNV workflow (required) | A string containing the version number of the provided cache (eg 106) |
  | all_genes | CNA workflow (required) | Bed file of all annotated genes. First three columns are standard bed format, 4th column has gene name, 5th column has score value (arbitrary number, is not used), 6th column has +/- strand. No headed is expcted. |
</details>
<details>
  <summary>Region and Variant Information</summary>
  
  | Input label | Applicable workflow(s) | Description |
  | --- | --- | --- |
  | target_regions | All workflows (required) | A bed file containing the genomic regions covered by the targeted panel used for sequencing |
  | neither_region | SV workflow (required) | A bed file. All SVs that contain a breakpoint within these regions will be discarded. We recommend the blacklist regions provided by 10xgenomics. Their hg19 bed file can be found here: http://cf.10xgenomics.com/supp/genome/hg19/sv_blacklist.bed. |
  | notboth_region | SV workflow (required) | A bed file. SVs with >1 breakpoint within these regions will be discarded. We recommend Heng Li's low complexity regions, found here: https://github.com/lh3/varcmp/raw/master/scripts |
  | sv_whitelist | SV workflow (optional) | A bed file. Contains regions that include expected SV breakpoint sites. This will reduce the read support requirement for SVs from these regions, which will allow the user to manually review variants of interest. |
  | whitelist_vcf | SNV workflow (required) | VCF and accompanying .tbi file (using the `tabix -p`) command. VCF represents any whitelisted SNVs/Indels. VCF file may be empty (but still properly formatted) if desired |
  | target_genes | CNA workflow (required) | Bed file describing all genes targeted by the target panel. First three columns are standard bed format, 4th column is gene name, 5th column is description. Copy number control genes should be labeled as 'CN-control' in the description, all others can use any desired description |
</details>
<details>
  <summary>Samples and Controls</summary>

  | Input label | Applicable workflow(s) | Description |
  | --- | --- | --- |
  | sample_bams | All workflows (required) | An array of paths to bam files that contain reads generated from targeted sequencing of cfDNA. Arrays can be provided in the input .yaml file as described by the (CWL user guide) or as shown in our example input .yamls |
  | matched_control_bams | All workflows (required) | An array of paths to matched control bam files. The order of the array should be the same order as the sample_bams array (eg the `nth` entry in both arrays should correspond to the `nth` patient) |
  | panel_of_normal_bams | All workflows (required) | An array of paths to bam files containing reads from healthy, normal samples. If such a panel is unavailable, this panel can instead be composed of all availabled matched control samples. |
</details>
  
  
