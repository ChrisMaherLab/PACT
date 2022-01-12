# Jacesbestrepoever
(WIP)

Standardized workflow, written in the Common Workflow Language (CWL), for the identification of somatic variants using cfDNA. Uses a variety of open-source tools to identify variants that are detected in cfDNA plasma samples. The workflow applies best-practice protocols for calling mutations of multiple classes across a cohort of samples (though it can be used on single samples as well).


CWL is meant to be a language for creating standardized scientific workflows and can be run using a variety of methods. We have tested the workflows here using Cromwell's CWL interpreter, configured to work with the IBM's Load Sharing Facility (LSF) for high-performance computing environments.


If using Cromwell to run the CWL pipeline, download the latest version of Cromwell from their [release page](https://github.com/broadinstitute/cromwell/releases), and then run the workflow using the command:

```
java -jar /path/to/cromwell.jar run -t cwl -i example/example.yml pipelines/sv_pipeline.cwl
```

We would highly recommend following Cromwell's [Configuration file tutorial](https://cromwell.readthedocs.io/en/stable/tutorials/ConfigurationFiles/) to further customize how Cromwell runs the workflow, by specifying where Cromwell should save log files, output files, how it should integrate with your HPC platform (if used), to prioritize using copies/soft-links instead of hard-links, etc. A non-exhaustive list of other tools that can run CWL workflows is described [here](https://www.commonwl.org/).

---

