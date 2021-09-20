#! /bin/bash

set -eu

set -o pipefail


SOURCES_DIR=/tmp/artifacts

tar  -C /usr/local/bin  -zxf "${SOURCES_DIR}/camel-k-client.tar.gz"
chmod +x  /usr/local/bin/kamel
