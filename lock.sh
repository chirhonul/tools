echo "Encrypting '$@'.."
gpg --armor --encrypt --recipient chinul "$@"
