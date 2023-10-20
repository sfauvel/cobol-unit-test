#!/bin/bash

# Launch python test into a loop.
# When no folder specified, pytest command is launch to execute all tests.
# Parameters : folder to watch (. by default)
# need package 'inotify-tools' to work
###



INOTIFY_PATH=$(type inotifywait)
if [ -z "$INOTIFY_PATH" ]; then
  echo "inotifywait not yet installed."
  apt-get install -y inotify-tools
fi

FOLDER_TO_WATCH=.

PROG_NAME=$1

if [ -z "$PROG_NAME" ]; then
    echo "You should give program to launch name as script parameter"
    echo "The name is program name without extension"
    echo "Tests are aborted"
    return
fi

. ./runTest.sh $PROG_NAME

while inotifywait -qq -r -e modify -e attrib -e move -e create -e delete $FOLDER_TO_WATCH; do
	. ./runTest.sh $PROG_NAME
done
