# municipal-container-host

## Before using on a new machine

Create a non-root user
`useradd -s /bin/bash -d /home/ansible ansible`

Make that user a sudoer and enable passwordless sudo
Approach varies with OS setup

Upload your ssh key
`ssh-copy-id -i ~/.ssh/id_ed25519 ansible@HOSTNAME`

## TODO

* Does not currently support wildcard SSL certificates
Consider using https://dnsrobocert.readthedocs.io/en/latest/user_guide.html instead

https://gist.github.com/aaccioly/409205f5b87228cae7a69aafa31a0924?permalink_comment_id=4702163
