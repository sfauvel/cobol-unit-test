#!/usr/bin/env bash

### Loa env ###
if [ -z "$COB_LIBRARY_PATH" ]; then
    . envvars
fi
if [ -z "$COB_LIBRARY_PATH" ]; then
    echo "envvars has not defined COB_LIBRARY_PATH"
    return 1
fi

### Config ###

PROG_TO_TEST=$1
SRC_FILE=${MAINSRC}/${PROG_TO_TEST}.CBL

TEST_FILENAME=${PROG_TO_TEST}T
TEST_FILE=${TESTSRC}/unit-tests/${TEST_FILENAME}

CONFIG_FILENAME=${PROG_TO_TEST}C
CONFIG_FILE=${TESTRSC}/${CONFIG_FILENAME}

### Function ###

function run_tests() {
  local OPTION_DEBUG=-d
  local OPTIONS=

   ./run-ut ${OPTIONS} ${CONFIG_FILENAME} ${PROG_TO_TEST} ${TEST_FILENAME}
}

function check_file_exists() {
    if [[ ! -f $1 ]]; then
        echo "File $1 does not exist !"
        return 1
    fi

    return 0
}

### Script ###

COBC_PATH=$(type cobc)
if [ -z "$COBC_PATH" ]; then
  echo "cobc not found!"
  echo "Cobol was not found on this machine"
  return;
fi

LIB_UNITTEST=ZUTZCPC
if [[ ! -f "target/$LIB_UNITTEST" ]]; then
    echo "Compile UnitTest lib"
    ./compile $LIB_UNITTEST
fi


if [ -z "$PROG_TO_TEST" ]; then
    echo "You should give program to launch name as script parameter"
    echo "The name is program name without extension"
    echo "Tests are aborted"
    return
fi

if ! check_file_exists $SRC_FILE \
    || ! check_file_exists $TEST_FILE \
    || ! check_file_exists $CONFIG_FILE \
    ; then
    echo "Could not launch tests"
    return
fi



# run a test suite
RESULT=$(run_tests)

# display result
RED='\033[1;31m'
GREEN='\033[1;32m'
WHITE='\033[1;97m'
NC='\033[0m' # No Color
BG_RED='\e[48;5;196m '
BG_BLACK='\e[48;5;0m '

# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
if [[ $RESULT == *"0 FAILED"* ]]; then
    COLOR=${BG_BLACK}${GREEN}
else
    COLOR=${BG_RED}${WHITE}
fi

DATE=$(date +"%d/%m/%y %H:%M")

printf "${COLOR}${RESULT}\nLast run at : $DATE\n${NC}\n"
