#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
label: "Merge two arrays into an array of arrays, where position i of the output = [array1[i], array2[i]]"

requirements:
 - class: InlineJavascriptRequirement

inputs:
 array1:
  type: File[]
 array2:
  type: File[]

outputs:
 array_of_arrays:
  type: 
   type: array
   items:
    type: array
    items: File

# Requires that both input arrays are of the same length
expression: >
 ${
  var out_array = [];
  for (var i = 0; i < inputs.array1.length; i++) {
   tuple = [inputs.array1[i], inputs.array2[i]];
   out_array.push(tuple);
  }
  return { 'array_of_arrays' : out_array }
 }

