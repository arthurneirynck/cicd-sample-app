#!/bin/bash
set -euo pipefail

DOCKER_CONTAINER_NAME="samplerunning"
SERVER_ADDRESS="172.17.0.3"
SERVER_PORT="5050"

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

echo "Running acceptance test..."
RESPONSE=$(curl -s "http://${SERVER_ADDRESS}:${SERVER_PORT}/")
echo "Server Response: $RESPONSE"

if echo "$RESPONSE" | grep -q "You are calling me from 172.17.0.2:8080"; then
    echo "Test Passed: Expected response found."
else
    echo "Test Failed: Expected response not found."
    exit 1  
fi