#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
label: "Merge strings into a single string"

requirements:
 - class: InlineJavascriptRequirement

inputs:
 in_strings:
  type: string[]

outputs:
 out_string:
  type: string

expression: >
 ${
  var out_string = "";
  for (var i = 0; i < inputs.in_strings.length; i++) {
   out_string = out_string + inputs.in_strings[i]
  }
  return { 'out_string' : out_string }
 }

