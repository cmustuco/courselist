# CourseList

This single-binary Google Sheets utility takes returning/new course application
response sheets and parses them to fill a desired course list sheet.

## Usage

Call the executable file with the new course application CSV, returning course
application CSV, and the output CSV paths as arguments. Optionally, also
provide the previous semester's course list CSV to fill in missing information
from the returning course application CSV.

```
./courselist[.exe] output_here.csv -N:new_course_sheet.csv -R:returning_course_sheet.csv -P:previous_course_sheet.csv
```

OR

```
./courselist[.exe] output_here.csv --NewCourses=new_course_sheet.csv -ReturningCourses=returning_course_sheet.csv -PreviousCourselist=previous_course_sheet.csv
```
