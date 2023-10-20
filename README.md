# Cobol unit testing framework for mainframe programs

The goal of the project is to enable isolated unit testing of individual paragraphs in Cobol programs in a standalone environment with no connection to a zOS system. 

Please see [the wiki](https://github.com/neopragma/cobol-unit-test/wiki/) for more information.

## Update October 2023

Add a script to run a test in a docker and rerun it when the file is modified.
```
. ./cobolTestRun.sh SAMPLE
```

`cobol.sh` just run the docker to work within it.

`cobolRunTest.sh PROG_TO_RUN` run the docker, launch the test and wait a change to rerun it.

The `envvars` is committed to specify folder to use.

`runTest.sh PROG_TO_RUN` checks variables before running test and add color on result.

`runTestLoop.sh PROG_TO_RUN` run the test and waiting any file change to rerun it automatically.

You could try :
`cobolRunTest.sh SAMPLE`

The test fails. 

In `src/test/cobol/unit-tests/SAMPLET` file, change `'GOODBYE, CRUEL WORLD!'` by `'SEE YOU LATER, ALLIGATOR!'`.

Save the file and the test should be rerun and it should passed.

## Update December 2020 

Having ignored this project for some time, I recently learned there were several pull requests that had been languishing for months. Sorry about that! 

When I merged the changes, I discovered they broke the tool on Linux with Gnu COBOL. There is a set of sample test cases that should be executed to ensure functionality that worked before still works after applying changes to the code. 

The modified version with changes by Rune Christensen and his team is available here: https://github.com/Rune-Christensen/cobol-unit-test. I think that version works on zOS. The present version here does not. 

Beyond that, however, I think that it would be useful to rewrite this tool using a language better suited to text processing. This is a proof-of-concept project, and was never polished. It is somewhat useful, but there are many holes in it. 

My original idea to write the tool in Cobol was to try and achieve cross-platform support. That didn't work out. I would like the tool to work on Linux, Unix, Windows, and zOS, and possibly OS X if there's a way to set it up so that it's hassle-free for developers. Gnu Cobol on OS X isn't hassle-free IMO. To that end, I'm thinking of Java for the rewrite, even though I can think of half a dozen other languages better suited to text processing. Java is a first-class citizens on all the platforms of interest.

Let me know if you're interested in contributing to such a rewrite.

## Description

The unit test precompiler copies the program under test and inserts test code into the WORKING-STORAGE SECTION and PROCEDURE DIVISION. You can then run the copy of the program, which executes the isolated unit test cases without running the program from start to finish.

## A brief sample

```
           TESTSUITE 'CONVERT COMMA-DELIMITED FILE TO FIXED FORMAT' 

      *****************************************************************
      * COBOL COMMENTS ARE IGNORED SO YOU CAN DO THIS SORT OF THING IF
      * YOU PLEASE.
      *****************************************************************  

           BEFORE-EACH
               MOVE FOO TO BAR
               MOVE ZERO TO WS-COUNT
           END-BEFORE

           AFTER-EACH
               INITIALIZE WS-RESULTS-TABLE
           END-AFTER

           TESTCASE 'IT CONVERTS TEXT FIELD 1 TO UPPER CASE' 
               MOVE 'something' TO TEXT-VALUE-1
               PERFORM 2100-CONVERT-TEXT-FIELD-1
               EXPECT TEXT-OUT-1 TO BE 'SOMETHING'

           TESTCASE 'IT HANDLES FILE NOT FOUND GRACEFULLY'
               MOCK
                   FILE INPUT-FILE 
                   ON OPEN STATUS FILE-NOT-FOUND
               END-MOCK    
               PERFORM 0100-OPEN-INPUT
               EXPECT WS-INPUT-FILE-STATUS TO BE '35'
               EXPECT WS-FRIENDLY-MESSAGE TO BE 'SORRY, COULDN''T FIND INPUT-FILE'
```

### Notes

The precompiler recognizes certain keywords and substitutes test code, so that you need not code a lot of boilerplate code manually. Please see [the wiki](https://github.com/neopragma/cobol-unit-test/wiki/01.%20Syntax) for syntax details.

TESTSUITE - Provides a description for a series of test cases. The description is echoed in the output from the test run.

MOCK - declares a mock. Current version has support for mocking EXEC CICS commands and rudimentary support for mocking batch file I/O. This feature is currently under active development.

BEFORE-EACH, AFTER-EACH - the precompiler copies these statements into paragraphs that are performed at the start and end of each test case.

TESTCASE - identifies a test case. The description is echoed in the output of the test run.

EXPECT - asserts an expected result. Current version supports PIC X, numeric, and 88-level compares. 

VERIFY - verifies that a mock was accessed the expected number of times.

The precompiler ignores Cobol-style comment lines.


### Examples

Copy the `envvars` file and update the `PROJECT` variable: `cp envvars.example envvars`

Compile the program ```SAMPLE```, located at ```src/main/cobol/SAMPLE.CBL```

```sh
./compile SAMPLE
```

Run the unit tests for ```SAMPLE```. Configuration file is ```src/test/resources/SAMPLEC``` and unit tests are in ```src/test/cobol/unit-tests/SAMPLET```.

```sh
./run-ut SAMPLEC SAMPLE SAMPLET
```

Run all the provided examples.

```sh
./run-examples
```

The sample programs are:

* CALLDEMO - demonstration of testing a called subprogram.
* CICSDEMO - demonstration of testing a CICS program.
* CONVERT - convert a CSV file into a fixed-format file.
* FILEDEMO - demonstration of batch file mocks.
* FIZZBUZZ - the classic FizzBuzz exercise.
* INVDATE - calculate the date of the last day of the month.
* PARADEMO - demonstration of mocking paragraphs.
* SAMPLE - minimal unit test code for a "Hello, World!" program.
* SUBPROG - demonstration of testing a called subprogram.

The unit test framework comprises:

* ZUTZCPC - the precompiler that inserts test code into a copy of the program under test.
* ZUTZCPD - PROCEDURE DIVISION copybook containing common test code.
* ZUTZCWS - WORKING-STORAGE SECTION copybook containing common test code.

### Why the funky names?

We want the unit test framework to be usable on zOS, *nix, and Windows systems. Most objects on zOS systems are limited to 8-character names, and IBM product names follow a certain pattern. We followed the same pattern in an informal way. Referring to [this document](http://www-01.ibm.com/support/knowledgecenter/SSLTBW_1.13.0/com.ibm.zos.r13.bpxa800/bpxza8c008.htm), we did not find an existing product with the prefix ZUT. So, the names of the components in the unit testing framework mean:

* ZUT - zOS Unit Test
* ZC - zOS Cobol
* PC - precompiler
* PD - PROCEDURE DIVISION
* WS - WORKING-STORAGE
