# Copyright 2020 Carnegie Mellon University Student College Executive Board

# SPDX-License-Identifier: MIT
# This file is part of the CourseList project under the MIT license.

import tables
import sequtils
import strutils

type
  CsvWriter* = object
    headers*: OrderedTable[string, int]
    rows*: seq[OrderedTable[string, string]]
    sep: char


proc initCsvWriter*(): CsvWriter =
  return CsvWriter(
    headers: initOrderedTable[string, int](),
    rows: @[initOrderedTable[string, string]()],
    sep: ','
  )

proc appendHeader*(self: var CsvWriter, header: string) =
  ## Adds a header to CSV table, if it does not already exist. Insertion order
  ## is preserved.
  discard self.headers.hasKeyOrPut(header, self.headers.len())

proc addEntry*(self: var CsvWriter, header: string, value: string) =
  if (header in self.headers):
    self.rows[self.rows.len() - 1][header] = value

proc nextRow*(self: var CsvWriter) =
  self.rows = concat(self.rows, @[initOrderedTable[string, string]()])

proc writeFile*(self: CsvWriter, out_file_path: string) =
  var out_string = ""

  # Write headers
  for header in self.headers.keys:
    out_string.add(header)
    out_string.add(self.sep)
  out_string.add('\n')

  # Write rows
  for row in self.rows:
    for header in self.headers.keys:
      var val = row.getOrDefault(header, "")
      val = val.replace("\"", "\"\"")
      val = "\"" & val & "\""
      out_string.add(val)
      out_string.add(self.sep)
    out_string.add('\n')

  writeFile(out_file_path, out_string)
