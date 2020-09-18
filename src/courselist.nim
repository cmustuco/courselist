# Copyright 2020 Carnegie Mellon University Student College Executive Board

# SPDX-License-Identifier: MIT
# This file is part of the CourseList project under the MIT license.

import parsecsv
import writecsv

from os import paramStr
import parseopt
from sequtils import any

import strutils
import tables

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
  for i in @["1", "2", "3", "4"]:
    assert headerExists("Instructor $1 Name" % [i])
    assert headerExists("Instructor $1 Andrew ID" % [i])
    assert headerExists("Instructor $1 Academic Advisor Name" % [i])
    assert headerExists("Instructor $1 Academic Advisor Email" % [i])
    assert headerExists("Instructor $1 Recommending Faculty Member Name" % [i])
    assert headerExists("Instructor $1 Recommending Faculty Member Email" % [i])
  assert headerExists("Start Time (earliest is 6:30pm)")
  assert headerExists("End Time")
  assert headerExists("Day of week")
  assert headerExists("What type of room would you need?")
  assert headerExists("Fees (if any)")
  assert headerExists("As of September 1st, 2020, we are unsure as to what teaching modalities will be available for the spring 2021 semester. If modality options were to remain the same as they are for the current fall 2020 semester, what would be your current teaching modality preference for spring 2021?")

  # Parse rows and append to output CSV
  while p.readRow():
    for i in @["1", "2", "3", "4"]:
      let iName = p.rowEntry("Instructor $1 Name" % [i])
      let iAndrew = p.rowEntry("Instructor $1 Andrew ID" % [i]).split('@')[0]
      let iAdvisorName = p.rowEntry("Instructor $1 Academic Advisor Name" % [i])
      let iAdvisor = p.rowEntry("Instructor $1 Academic Advisor Email" % [i])
      let iFacultyName = p.rowEntry("Instructor $1 Recommending Faculty Member Name" % [i])
      let iFaculty = p.rowEntry("Instructor $1 Recommending Faculty Member Email" % [i])
      if (iName.len() > 0 and iName.cmpIgnoreCase("N/A") != 0):
        output.addEntry("Class Number", "98-XXX")
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
        output.addEntry("Room Type", p.rowEntry("What type of room would you need?"))
        output.addEntry("Fee", p.rowEntry("Fees (if any)"))
        output.addEntry("Course Description", p.rowEntry("An SIO description for your course"))
        output.addEntry("Advisor Name", iAdvisorName)
        output.addEntry("Advisor Email", iAdvisor)
        output.addEntry("Recommending Faculty Name", iFacultyName)
        output.addEntry("Recommending Faculty Email", iFaculty)
        output.addEntry("Modality", p.rowEntry("As of September 1st, 2020, we are unsure as to what teaching modalities will be available for the spring 2021 semester. If modality options were to remain the same as they are for the current fall 2020 semester, what would be your current teaching modality preference for spring 2021?"))
        output.nextRow()

proc parseReturningCourses(
  returning_course_path: string,
  previous_courselist_path: string = "",
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
  for i in @["1", "2", "3", "4"]:
    assert headerExists("Instructor $1 Name" % [i])
    assert headerExists("Instructor $1 Andrew ID" % [i])
    assert headerExists("Instructor $1 Academic Advisor Name" % [i])
    assert headerExists("Instructor $1 Academic Advisor Email" % [i])
    assert headerExists("Instructor $1 Recommending Faculty Name" % [i])
    assert headerExists("Instructor $1 Recommending Faculty Email" % [i])
  assert headerExists("Start Time (earliest is 6:30pm)")
  assert headerExists("End Time")
  assert headerExists("Day of week")
  assert headerExists("What type of room do you need?")
  assert headerExists("As of September 1st, 2020, we are unsure as to what teaching modalities will be available for the spring 2021 semester. If modality options were to remain the same as they are for the current fall 2020 semester, what would be your current teaching modality preference for spring 2021? ")
  assert headerExists("Updated course description (for SIO), if any")
  assert headerExists("Upload your most updated syllabus")

  var prevCSV = initTable[string, seq[string]]()
  if previous_courselist_path != "":
    var p_prev: CsvParser
    p_prev.open(previous_courselist_path)
    p_prev.readHeaderRow()

    proc prevHeaderExists(s: string): bool =
      return any(p_prev.headers, proc(v: string): bool = return s == v)

    assert prevHeaderExists("Class Number")
    assert prevHeaderExists("Short Title")
    assert prevHeaderExists("Course Description (no change or paste the new one here)")

    while p_prev.readRow():
      prevCSV[p_prev.rowEntry("Class Number")] = @[
        p_prev.rowEntry("Short Title"),
        p_prev.rowEntry("Course Description (no change or paste the new one here)")
      ]

  # Parse rows and append to output CSV
  while p.readRow():
    for i in @["1", "2", "3", "4"]:
      let iName = p.rowEntry("Instructor $1 Name" % [i])
      let iAndrew = p.rowEntry("Instructor $1 Andrew ID" % [i]).split('@')[0]
      let iAdvisorName = p.rowEntry("Instructor $1 Academic Advisor Name" % [i])
      let iAdvisor = p.rowEntry("Instructor $1 Academic Advisor Email" % [i])
      let iFacultyName = p.rowEntry("Instructor $1 Recommending Faculty Name" % [i])
      let iFaculty = p.rowEntry("Instructor $1 Recommending Faculty Email" % [i])
      let prevTaught = p.row[p.headers.find("Instructor $1 Andrew ID" % [i]) + 1]
      if (iName.len() > 0 and iName.cmpIgnoreCase("N/A") != 0):
        var course = p.rowEntry("What course are you making the request for?")
        var course_num = course.splitWhitespace()[0]
        if (course_num == "Other"):
          course = p.rowEntry("If your course was not listed above, please fill it in below.")
          course_num = course.splitWhitespace()[0]

        output.addEntry("Class Number", course_num)
        output.addEntry("Long Title", course[7..<course.len()])
        output.addEntry("Short Title", prevCSV.getOrDefault(course_num, @[""])[0])
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
        output.addEntry("Room Type", p.rowEntry("What type of room do you need?"))
        var course_desc = p.rowEntry("Updated course description (for SIO), if any")
        if course_desc == "" or
          course_desc.cmpIgnoreCase("(no updates)") == 0 or
          course_desc.cmpIgnoreCase("no updates") == 0 or
          course_desc.cmpIgnoreCase("no update") == 0 or
          course_desc.cmpIgnoreCase("(same course description as before)") == 0:
          course_desc = prevCSV.getOrDefault(course_num, @["", ""])[1]
        output.addEntry("Course Description", course_desc)
        output.addEntry("Advisor Name", iAdvisorName)
        output.addEntry("Advisor Email", iAdvisor)
        output.addEntry("Recommending Faculty Name", iFacultyName)
        output.addEntry("Recommending Faculty Email", iFaculty)
        output.addEntry("Modality", p.rowEntry("As of September 1st, 2020, we are unsure as to what teaching modalities will be available for the spring 2021 semester. If modality options were to remain the same as they are for the current fall 2020 semester, what would be your current teaching modality preference for spring 2021? "))
        output.nextRow()

when isMainModule:
  # Parse command line arguments

  var newCoursesPath = ""
  var returningCoursesPath = ""
  var outputCourselistPath = ""
  var prevCourselistPath = ""

  var p = initOptParser()
  while true:
    p.next()
    case p.kind
    of cmdEnd: break
    of cmdShortOption:
      if p.key == "N":
        newCoursesPath = p.val
      elif p.key == "R":
        returningCoursesPath = p.val
      elif p.key == "P":
        prevCourselistPath = p.val
    of cmdLongOption:
      if p.key == "NewCourses":
        newCoursesPath = p.val
      elif p.key == "ReturningCourses":
        returningCoursesPath = p.val
      elif p.key == "PreviousCourselist":
        prevCourselistPath = p.val
    of cmdArgument:
      outputCourselistPath = p.key

  if (outputCourselistPath == ""):
    quit("An output CSV file path must be specified.")
  if (prevCourselistPath != "" and returningCoursesPath == ""):
    quit("Please specify a returning courses CSV file path to make " &
          "use of the previous course list CSV.")

  # Instantiate output headers
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
  out_csv.appendHeader("Advisor Name")
  out_csv.appendHeader("Advisor Email")
  out_csv.appendHeader("Advisor Approval")
  out_csv.appendHeader("Recommending Faculty Name")
  out_csv.appendHeader("Recommending Faculty Email")
  out_csv.appendHeader("Recommending Faculty Approval")
  out_csv.appendHeader("Room")
  out_csv.appendHeader("Room Type")  #
  out_csv.appendHeader("Max Size")
  out_csv.appendHeader("Day")  #
  out_csv.appendHeader("Start Time")  #
  out_csv.appendHeader("End Time")  #
  out_csv.appendHeader("Fee")  #
  out_csv.appendHeader("Modality")
  out_csv.appendHeader("Course Description")  #
  out_csv.appendHeader("Added to S3 by Kristin")
  out_csv.appendHeader("Notes")
  out_csv.appendHeader("Audit Assignment")
  out_csv.appendHeader("Audit Completion date")

  # Parse new and returning courses
  parseNewCourses(newCoursesPath, out_csv)
  parseReturningCourses(returningCoursesPath, prevCourselistPath, out_csv)

  out_csv.sortRows("Class Number")

  # Save output CSV
  out_csv.writeFile(outputCourselistPath)
