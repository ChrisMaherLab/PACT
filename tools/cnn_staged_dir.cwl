#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
requirements:
 - class: InlineJavascriptRequirement

inputs:
 targets:
  type: File[]
 antitargets:
  type: File[]

outputs:
 cov_dir: Directory


expression: |
 ${
  var x = [];
  x = x.concat(inputs.targets);
  x = x.concat(inputs.antitargets);
  //for (var i = 0; i < inputs.targets.length; i++) {
  // x.push(inputs.targets[i])
  // x.push(inputs.antitargets[i])
  //}
  return {"cov_dir": {
    "class": "Directory",
    "basename": "cnn_directory",
    "listing": x
   } };
 }
