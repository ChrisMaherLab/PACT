#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
label: "Append array to end of other array"

requirements:
 - class: InlineJavascriptRequirement

inputs:
 array1:
  type: File[]
 array2:
  type: File[]

outputs:
 out_array:
  type: File[]

expression: >
 ${
  var out_array = inputs.array1
  out_array = out_array.concat(inputs.array2)
  return { 'out_array' : out_array }
 }





