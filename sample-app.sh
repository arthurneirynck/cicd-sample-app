#!/bin/bash
set -euo pipefail

DOCKER_CONTAINER_NAME="samplerunning"

if docker ps -a --format '{{.Names}}' | grep -q "^${DOCKER_CONTAINER_NAME}\$"; then
    docker rm -f "${DOCKER_CONTAINER_NAME}"
    echo "Removed existing container: ${DOCKER_CONTAINER_NAME}"
fi

rm -rf tempdir
mkdir -p tempdir/templates tempdir/static

cp sample_app.py tempdir/.
cp -r templates/* tempdir/templates/.
cp -r static/* tempdir/static/.

cat > tempdir/Dockerfile << _EOF_
FROM python
RUN pip install flask
COPY  ./static /home/myapp/static/
COPY  ./templates /home/myapp/templates/
COPY  sample_app.py /home/myapp/
EXPOSE 5050
CMD python /home/myapp/sample_app.py
_EOF_

cd tempdir || exit
docker build -t sampleapp .
docker run -t -d -p 5050:5050 --name "${DOCKER_CONTAINER_NAME}" sampleapp
docker ps -a