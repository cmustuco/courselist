# Copyright 2020 Carnegie Mellon University Student College Executive Board

# SPDX-License-Identifier: MIT
# This file is part of the CourseList project under the MIT license.

import parsecsv
import writecsv
from os import paramStr
from sequtils import any
import strutils

proc parseNewCourses(new_course_path: string, output: var CsvWriter) =
  var p: CsvParser
  p.open(new_course_path)
  p.readHeaderRow()

  # Verify that desired headers exist
  proc headerExists(s: string): bool  =
    return any(p.headers, proc(v: string): bool = return s == v)

  assert headerExists("Full Course Name")
  assert headerExists("Short Course Name (for SIO)")
  assert headerExists("An SIO description for your course")
  assert headerExists("Instructor 1 Name")
  assert headerExists("Instructor 1 Andrew ID")
  assert headerExists("Instructor 2 Name")
  assert headerExists("Instructor 2 Andrew ID")
  assert headerExists("Instructor 3 Name")
  assert headerExists("Instructor 3 Andrew ID")
  assert headerExists("Instructor 4 Name")
  assert headerExists("Instructor 4 Andrew ID")
  assert headerExists("Start Time (earliest is 6:30pm)")
  assert headerExists("End Time")
  assert headerExists("Day of week")
  assert headerExists("Fees (if any)")

  # Parse rows and append to output CSV
  while p.readRow():
    for i in @["1", "2", "3", "4"]:
      let iName = p.rowEntry("Instructor $1 Name" % [i])
      let iAndrew = p.rowEntry("Instructor $1 Andrew ID" % [i]).split('@')[0]
      if (iName.len() > 0 and iName.cmpIgnoreCase("N/A") != 0):
        output.addEntry("Long Title", p.rowEntry("Full Course Name"))
        output.addEntry("Short Title", p.rowEntry("Short Course Name (for SIO)"))
        output.addEntry("Returning Instructor?", "N")
        output.addEntry("Instructor First Name", iName.splitWhitespace()[0])
        output.addEntry("Instructor Last Name", iName.splitWhitespace()[1])
        output.addEntry("Instructor AndrewID", iAndrew)
        output.addEntry("Instructor Email", iAndrew & "@andrew.cmu.edu")
        output.addEntry("Day", p.rowEntry("Day of week"))
        output.addEntry("Start Time", p.rowEntry("Start Time (earliest is 6:30pm)"))
        output.addEntry("End Time", p.rowEntry("End Time"))
        output.addEntry("Fee", p.rowEntry("Fees (if any)"))
        output.addEntry("Course Description", p.rowEntry("An SIO description for your course"))
        output.nextRow()

proc parseReturningCourses(
  returning_course_path: string,
  output: var CsvWriter
) =
  var p: CsvParser
  p.open(returning_course_path)
  p.readHeaderRow()

  # Verify that desired headers exist
  proc headerExists(s: string): bool  =
    return any(p.headers, proc(v: string): bool = return s == v)

  assert headerExists("What course are you making the request for?")
  assert headerExists("If your course was not listed above, please fill it in below.")
  assert headerExists("Instructor 1 Name")
  assert headerExists("Instructor 1 Andrew ID")
  assert headerExists("Instructor 2 Name")
  assert headerExists("Instructor 2 Andrew ID")
  assert headerExists("Instructor 3 Name")
  assert headerExists("Instructor 3 Andrew ID")
  assert headerExists("Instructor 4 Name")
  assert headerExists("Instructor 4 Andrew ID")
  assert headerExists("Start Time (earliest is 6:30pm)")
  assert headerExists("End Time")
  assert headerExists("Day of week")
  assert headerExists("Updated course description (for SIO), if any")
  assert headerExists("Upload your most updated syllabus")

  # Parse rows and append to output CSV
  while p.readRow():
    for i in @["1", "2", "3", "4"]:
      let iName = p.rowEntry("Instructor $1 Name" % [i])
      let iAndrew = p.rowEntry("Instructor $1 Andrew ID" % [i]).split('@')[0]
      let prevTaught = p.row[p.headers.find("Instructor $1 Andrew ID" % [i]) + 1]
      if (iName.len() > 0 and iName.cmpIgnoreCase("N/A") != 0):
        var course = p.rowEntry("What course are you making the request for?")
        if (course.splitWhitespace()[0] == "Other"):
          course = p.rowEntry("If your course was not listed above, please fill it in below.")

        output.addEntry("Class Number", course.splitWhitespace()[0])
        output.addEntry("Long Title", course[7..<course.len()])
        if (prevTaught.len() > 0):
          output.addEntry("Returning Instructor?", prevTaught[0..0])
        else:
          output.addEntry("Returning Instructor?", "N")
        output.addEntry("Instructor First Name", iName.splitWhitespace()[0])
        output.addEntry("Instructor Last Name", iName.splitWhitespace()[1])
        output.addEntry("Instructor AndrewID", iAndrew)
        output.addEntry("Instructor Email", iAndrew & "@andrew.cmu.edu")
        output.addEntry("Syllabus", p.rowEntry("Upload your most updated syllabus"))
        output.addEntry("Day", p.rowEntry("Day of week"))
        output.addEntry("Start Time", p.rowEntry("Start Time (earliest is 6:30pm)"))
        output.addEntry("End Time", p.rowEntry("End Time"))
        output.addEntry("Course Description", p.rowEntry("Updated course description (for SIO), if any"))
        output.nextRow()

when isMainModule:
  # Instantiate headers
  var out_csv = initCsvWriter()
  out_csv.appendHeader("Class Number")  #
  out_csv.appendHeader("Long Title")  #
  out_csv.appendHeader("Short Title")  #
  out_csv.appendHeader("Returning Instructor?")  #
  out_csv.appendHeader("Instructor First Name")  #
  out_csv.appendHeader("Instructor Last Name")  #
  out_csv.appendHeader("English Fluency Native?")
  out_csv.appendHeader("Instructor AndrewID")  #
  out_csv.appendHeader("Instructor Email")  #
  out_csv.appendHeader("Contract")
  out_csv.appendHeader("Interviewed?")
  out_csv.appendHeader("Syllabus")  #
  out_csv.appendHeader("Advisor Approval")
  out_csv.appendHeader("Recommending Faculty Approval")
  out_csv.appendHeader("Room")
  out_csv.appendHeader("Room Type")
  out_csv.appendHeader("Max Size")
  out_csv.appendHeader("Day")  #
  out_csv.appendHeader("Start Time")  #
  out_csv.appendHeader("End Time")  #
  out_csv.appendHeader("Fee")  #
  out_csv.appendHeader("Course Description")  #
  out_csv.appendHeader("Added to S3 by Kristin")
  out_csv.appendHeader("Notes")
  out_csv.appendHeader("Audit Assignment")
  out_csv.appendHeader("Audit Completion date")

  # Parse new and returning courses
  parseNewCourses(paramStr(1), out_csv)
  parseReturningCourses(paramStr(2), out_csv)

  # Save output CSV
  out_csv.writeFile(paramStr(3))
