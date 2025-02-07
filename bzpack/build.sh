#!/bin/sh

set -o pipefail -o errexit -o nounset

cd "$(dirname "$0")/."

cd src && g++ *.cpp -o ../bzpack
