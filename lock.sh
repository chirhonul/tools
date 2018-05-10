#!/bin/bash

set -euo pipefail
echo "Encrypting '$@'.."
gpg --armor --encrypt --recipient chinul "$@"

echo "Deleting '$@'.."
srm "$@"
