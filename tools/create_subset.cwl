#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
label: "Create subsets of the tumor and control arrays that excludes samples that are missing a solid tumor sample"

requirements:
 - class: InlineJavascriptRequirement

inputs:
 tumor_array:
  type: string[]
 control_array:
  type: string[]

outputs:
 tumor_subset:
  type: string[]
 control_subset:
  type: string[]

expression: >
 ${
  var tumor_subset = [];
  var control_subset = [];
  for (var i = 0; i < inputs.tumor_array.length; i++) {
   if ( inputs.tumor_array[i] != "NA" ) {
    tumor_subset.push(inputs.tumor_array[i])
    control_subset.push(inputs.control_array[i])
   }
  }
  return { 'tumor_subset' : tumor_subset,
           'control_subset' : control_subset }
 }





