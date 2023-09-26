# municipal-container-host

## Before using on a new machine

Create a non-root user
`useradd -s /bin/bash -d /home/ansible ansible`

Make that user a sudoer and enable passwordless sudo
Approach varies with OS setup

Upload your ssh key
`ssh-copy-id -i ~/.ssh/id_ed25519 ansible@HOSTNAME`