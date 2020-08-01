#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
label: "Merge three arrays into an array of arrays, where position i of the output = [array1[i], array2[i], array3[i]"

requirements:
 - class: InlineJavascriptRequirement

inputs:
 array1:
  type: File[]
 array2:
  type: File[]
 array3:
  type: File[]

outputs:
 merged_array:
  type: 
   type: array
   items:
    type: array
    items: File

# Requires that input arrays are of the same length
expression: >
 ${
  var out_array = [];
  for (var i = 0; i < inputs.array1.length; i++) {
   inner = [inputs.array1[i], inputs.array2[i], inputs.array3[i]];
   out_array.push(inner);
  }
  return { 'merged_array' : out_array }
 }

