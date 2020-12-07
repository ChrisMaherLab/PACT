#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
label: "Merge an array of arrays with an additional array, such that one item is added to each inner array of the array of arrays."

requirements:
 - class: InlineJavascriptRequirement

inputs:
 in_array_of_arrays:
  type:
   type: array
   items:
    type: array
    items: string
 tumor_array:
  type: string[]

outputs:
 array_of_arrays:
  type:
   type: array
   items:
    type: array
    items: string

# Requires that the arrays are of the same length
expression: >
 ${
  var out_array = [];
  for (var i = 0; i < inputs.in_array_of_arrays.length; i++) {
   var item1 = inputs.in_array_of_arrays[i][0];
   var item2 = inputs.in_array_of_arrays[i][1];
   var item3 = inputs.tumor_array[i];
   var inner_array = [item1, item2, item3];
   out_array.push(inner_array);
  }
  return { 'array_of_arrays' : out_array }
 }





