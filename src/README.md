# Inary source code

## libymp documentation
look **libymp.md** file

# Writing documentation

* Document line must starts with `//DOC:`
* Document type is markdown.

# source organization

* **ccode/** has C source files.
* **data/** has package, repository and other functions.
* **operations/** has install/remove and other operation functions.
* **tools/** has command line programs.
* **util/** has utility functions for libymp.
* **color.vala** has color related functions.
* **ymp.vala** is main libymp file.
* **settings.vala** has init functions and settings.
* **wslblock.vala** has wsl blocker functions.

# Exit status codes
| Number  | Meaning               |
|---------|-----------------------|
| 31      | Inary init error      |
| 3       | Archive extract error |
| 2       | File not found        |
| 1       | Operation failed      |
| 0       | Successfull           |

# How to ymp works
![ymp-work-schema](ymp-work-schema.svg)
