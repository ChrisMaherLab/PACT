# Jacesbestrepoever
(WIP)

Standardized workflow, written in CWL, for the identification of somatic structural variants using cfDNA. Uses a variety of tools, including Lumpy, Manta, Delly, Survivor, svtools, and svtyper, to identify SVs that are detected in cfDNA, but that are not found in a (plasma-depleted) matched control or in any of the provided 'healthy' samples.

The workflow consists of three basic steps:
 1. Perform SV calling. Given the provided bam files, the workflow uses Lumpy, Manta, and Delly to perform SV calling.
 2. Merging and filtering. Using the output from step 1, consensus calls are identified by requiring that an SV appear in the output of at least `x` of the three SV calling tools. Consensus calls are re-formatted and then genotyped and annotated. Only SV calls that appear in a plasma sample, but not in the matched control or in any of the healthy samples are kept. Region based filters are then optionally applied, and a single, cohort-wide bedpe is produced for all SVs that meet all filtering criteria.
 3. Basic visualizations are created using default parameters using SV-HotSpot. SV-HotSpot provides many options for enhanced visualizations, but users may not know the optimal parameters until they have seen what SVs are present in their cohort. After reviewing the output of the workflow, we suggest using the output bedpe with SV-HotSpot to further customize their visualizations. 

To run, download the repository, cd into the repository, create a `.yml` file using the helper script described below, then pass the generated `.yml` file and the `workflow/sv_pipeline.cwl` to your preferred CWL runner. For example, using the command:

```
cwl-runner workflow/sv_pipeline.cwl example/example.yml
```

We recommend using Cromwell's CWL runner, if it is compatible with your system, because it is what the workflow was originally tested on and it can integrate with multiple HPC platforms. To do so, download the latest version of Cromwell from their [release page](https://github.com/broadinstitute/cromwell/releases), and then run the workflow using the command:

```
java -jar /path/to/cromwell.jar run -t cwl -i example/example.yml workflow/sv_pipeline.cwl
```

We would highly recommend following Cromwell's [Configuration file tutorial](https://cromwell.readthedocs.io/en/stable/tutorials/ConfigurationFiles/) to further customize how Cromwell runs the workflow, by specifying where Cromwell should save log files, output files, how it should integrate with your HPC platform (if used), to prioritize using copies instead of hard-links, etc. Other tools that can run CWL workflows are described [here](https://www.commonwl.org/).

Though the workflow was written to be able to handle an entire cohort as input, users may find it useful to run samples one at a time or in smaller batches, as Cromwell and other CWL tools will attempt to localize input files either as copies or hard-links (depending on the tool and configuration). We advise against hard-links as a general rule, but note that creating copies of input files may take up a large amount of space, depending on the size of the cohort, the number of samples being run at a time, and sequencing depth.

---

A helper script has been provided to help create a properly formatted yaml file containing all values that can be passed to the workflow. It is recommended that all paths be absolute paths, since multiple implemenations of CWL runners exist, and may handle paths differently. The example.yml file provided in the example directory was produced by using the helper script with the following parameters:

```
python helper/prepare_pipeline_yml.py -s example/samples.tsv -n example/healthy.tsv -r /path/to/reference_hg19.fa -g hg19 -t /path/to/target_regions.bed --neither /path/to/blacklist.bed --notboth /path/to/low_complexity_regions.bed > example/example.yml
```

The file passed using `-s` should be a tab-delimited file, where the first column is a path to a bam file, and the second column is a path a bam representing a matched control (in the case of a cfDNA analysis, this may be a plasma-depleted sample). The file passed with `-n` should contain a list of paths to bam files representing 'healthy' samples. For additional information, run `python helper/prepare_pipeline_yml.py -h`
