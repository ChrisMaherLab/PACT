# Jacesbestrepoever
(WIP)

Standardized workflow, written in the Common Workflow Language (CWL), for the identification of somatic variants using cfDNA. Uses a variety of open-source tools to identify variants that are detected in cfDNA plasma samples. The workflow applies best-practice protocols for calling mutations of multiple classes across a cohort of samples (though it can be used on single samples as well).


CWL is meant to be a language for creating standardized scientific workflows and can be run using a variety of methods. We have tested the workflows here using Cromwell's CWL interpreter, configured to work with the IBM's Load Sharing Facility (LSF) for high-performance computing environment, though other CWL interpreters exist. A non-exaustive list of other tools that can run CWL workflows is described [here](https://www.commonwl.org/).


If using Cromwell to run the CWL pipeline, the latest version of Cromwell from their [release page](https://github.com/broadinstitute/cromwell/releases). We would highly recommend following Cromwell's [Configuration file tutorial](https://cromwell.readthedocs.io/en/stable/tutorials/ConfigurationFiles/) to further customize how Cromwell runs the workflow. 


---
Output

SV pipeline output includes a cohort-wide bedpe file that includes read support and annotation information. The format is compatible with SV-HotSpot for easy visualization, as well as other standard bedpe tools.

SNV pipeline output includes a tsv files for each sample that include read suppor and annotation information.
