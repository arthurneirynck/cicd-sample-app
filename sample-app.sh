#!/bin/bash
set -euo pipefail

# Check if tempdir exists; if not, create it.
if [ ! -d "tempdir" ]; then
    mkdir tempdir
fi

# Check if tempdir/templates exists; if not, create it.
if [ ! -d "tempdir/templates" ]; then
    mkdir -p tempdir/templates
fi

# Check if tempdir/static exists; if not, create it.
if [ ! -d "tempdir/static" ]; then
    mkdir -p tempdir/static
fi

# Copy application files into the tempdir
cp sample_app.py tempdir/.
cp -r templates/* tempdir/templates/.
cp -r static/* tempdir/static/.

# Create the Dockerfile
cat > tempdir/Dockerfile << _EOF_
FROM python
RUN pip install flask
COPY  ./static /home/myapp/static/
COPY  ./templates /home/myapp/templates/
COPY  sample_app.py /home/myapp/
EXPOSE 5050
CMD python /home/myapp/sample_app.py
_EOF_

# Navigate into tempdir and build the Docker image
cd tempdir || exit
docker build -t sampleapp .
docker run -t -d -p 5050:5050 --name samplerunning sampleapp
docker ps -a
