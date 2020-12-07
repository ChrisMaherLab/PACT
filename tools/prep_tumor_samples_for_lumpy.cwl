#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
label: "Subset arrays to ensure that the correct files are matched together for SV calling using the lumpy_caller.cwl"

requirements:
 - class: InlineJavascriptRequirement

inputs:
 tumor_bams:
  type: string[]
 control_bams:
  type: string[]
 tumor_splitters:
  type: File[]
 control_splitters:
  type: File[]
 tumor_discordant:
  type: File[]
 control_discordant:
  type: File[]

outputs:
 tumor_split_subset:
  type: File[]
 control_split_subset:
  type: File[]
 tumor_disc_subset:
  type: File[]
 control_disc_subset:
  type: File[]

expression: >
 ${
  var tumor_split_subset = []
  var control_split_subset = []
  var tumor_disc_subset = []
  var control_disc_subset = []
  for (var i = 0; i < inputs.tumor_bams.length; i++) {
   if (inputs.tumor_bams[i] != "NA") {
    tumor_split_subset.push(inputs.tumor_splitters[i])
    control_split_subset.push(inputs.control_splitters[i])
    tumor_disc_subset.push(inputs.tumor_discordant[i])
    control_disc_subset.push(inputs.control_discordant[i])
   }
  }
  return { 'tumor_split_subset' : tumor_split_subset,
           'control_split_subset' : control_split_subset,
           'tumor_disc_subset' : tumor_disc_subset,
           'control_disc_subset' : control_disc_subset }
 }
