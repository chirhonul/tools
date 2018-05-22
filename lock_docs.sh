#!/bin/bash
#
# Lock the documents.
#
set -euo pipefail

cd /tmp

echo "Creating docs.tar.gz archive.."
tar czfv docs.tar.gz docs_clear/

echo "Encrypting docs.tar.gz.."
gpg --out ~/src/github.com/chirhonul/docs/docs.tar.gz.asc \
    --armor --encrypt --recipient chinul docs.tar.gz

echo "Deleting docs.tar.gz.."
srm docs.tar.gz

echo "Deleting /tmp/docs_clear.."
srm -r /tmp/docs_clear
