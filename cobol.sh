#https://hub.docker.com/r/gregcoleman/docker-cobol/
#docker pull gregcoleman/docker-cobol

WORKINGDIR=/root/projects

docker run -it -v "$(pwd)":${WORKINGDIR}/ -w ${WORKINGDIR} gregcoleman/docker-cobol /bin/bash
