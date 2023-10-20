#https://hub.docker.com/r/gregcoleman/docker-cobol/
#docker pull gregcoleman/docker-cobol

WORKINGDIR=/root/projects

if [ -z "$1" ]; then
    echo "Please add the program name as first parameter."
    return 1
fi
PROG_TO_TEST=$1

docker run -it -v "$(pwd)":${WORKINGDIR}/ -w ${WORKINGDIR} gregcoleman/docker-cobol /bin/bash ./runTestLoop.sh $PROG_TO_TEST
