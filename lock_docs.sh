#!/bin/bash
set -euo pipefail

cd

echo "Creating docs.tar.gz archive.."
tar czfv docs.tar.gz ~/docs/

echo "Encrypting docs.tar.gz.."
gpg --out ~/src/github.com/chirhonul/docs/docs.tar.gz.asc \
    --armor --encrypt --recipient chinul ~/docs.tar.gz

echo "Deleting docs.tar.gz.."
srm ~/docs.tar.gz
