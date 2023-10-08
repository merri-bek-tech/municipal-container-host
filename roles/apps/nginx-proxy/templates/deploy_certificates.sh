#!/usr/bin/env bash

#########################################################################################
# deploy_certificates.sh
#
# Copyright (c) 2023 Anthony Accioly <anthony@accioly.dev>
#
# SPDX-License-Identifier: MIT
#
# Description:
# This Bash script is used to deploy HTTPS/TLS certificates from the DNSroboCert
# Let's Encrypt `live` folder to Docker's `nginx-proxy` `nginx/certs` folder,
# following specific naming conventions for the output files. After deploying
# the certificates, it restarts Nginx to apply the changes.
#
# Usage:
#   ./deploy_certificates.sh [-v|--verbose] [<input_directory>] [<output_directory>]
#
#   Arguments:
#   - -v, --verbose: Optional flag to enable verbose mode for detailed logging.
#   - <input_directory>: Cerbot's style directory containing subfolders with
#     certificate files. By default, it is '/etc/letsencrypt/live'.
#   - <output_directory>: The nginx-proxy container certs folder, where
#     certificate files will be copied. By default, it is '/etc/nginx/certs'.
#
# Example:
#   ./deploy_certificates.sh -v /etc/letsencrypt/live /etc/nginx/certs
#
# Notes:
# - The script assumes the following naming conventions for certificate files:
#   - privkey.pem -> [name of the domain].key
#   - fullchain.pem -> [name of the domain].crt
#   - chain.pem -> [name of the domain].chain.pem
#
# - The script will overwrite existing files in the output directory if they have
#   the same names as the destination files.
#
# - When verbose mode is enabled, the script provides detailed logging of actions.
#
# Last Revised: 25 September 2023
#########################################################################################

# Define colors for printing messages
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# Function to display an error message, print usage, and exit with a non-zero status code
die() {
  echo -e "${RED}Error: $1${RESET}" >&2
  if [[ "$2" == "usage" ]]; then
    print_usage
  fi
  exit 1
}

# Function to display the script's usage message
print_usage() {
  echo "Usage: $0 [-v|--verbose] [<input_directory>] [<output_directory>]"
  echo "Arguments:"
  echo "  - -v, --verbose: Optional flag to enable verbose mode for detailed logging."
  echo "  - <input_directory>: Cerbot's style directory containing subfolders with"
  echo "    certificate files. By default, it is '/etc/letsencrypt/live'."
  echo "  - <output_directory>: The nginx-proxy container certs folder, where"
  echo "    certificate files will be copied. By default, it is '/etc/nginx/certs'."
  echo "Example:"
  echo "  $0 -v /etc/letsencrypt/live /etc/nginx/certs"
}

# Function to display a success message
success() {
  echo -e "${GREEN}$1${RESET}"
}

# Function to display verbose output
verbose() {
  if [[ "$verbose_mode" == true ]]; then
    echo -e "$1"
  fi
}

# Function to copy a file and log the action
copy_file() {
  local src_file="$1"
  local dest_file="$2"
  local file_description="$3"

  verbose "Copying $file_description from '$src_file' to '$dest_file'."
  cp -f "$src_file" "$dest_file" || die "Failed to copy $file_description from '$src_file' to '$dest_file'."
  verbose "Copied $file_description to '$dest_file'."
}

# Restart Nginx
restart_nginx() {
  verbose "Restarting Nginx..."
  nginx -s reload || die "Failed to restart Nginx."
  verbose "Nginx has been restarted."
}

# Initialize variables with default values
verbose_mode=false
input_dir=""
output_dir=""

# Process command line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose)
      verbose_mode=true
      shift
      ;;
    -*)
      die "Invalid flag: $1" usage
      ;;
    *)
      if [ -z "$input_dir" ]; then
        input_dir="$1"
      elif [ -z "$output_dir" ]; then
        output_dir="$1"
      else
        die "Invalid argument: $1" usage
      fi
      shift
      ;;
  esac
done

# Use default values if input directory is not provided
if [ -z "$input_dir" ]; then
  input_dir="/etc/letsencrypt/live"
fi

# Use default values if output directory is not provided
if [ -z "$output_dir" ]; then
  output_dir="/etc/nginx/certs"
fi

# Check if the input directory exists
if [ ! -d "$input_dir" ]; then
  die "Input directory '$input_dir' does not exist." usage
fi

# Check if the output directory exists, if not, create it
if [ ! -d "$output_dir" ]; then
  mkdir -p "$output_dir" || die "Failed to create output directory '$output_dir'." usage
fi

verbose "Verbose mode is enabled."

# Loop through subfolders in the input directory
for subfolder in "$input_dir"/*; do
  if [ -d "$subfolder" ]; then
    domain_name=$(basename "$subfolder")

    verbose "Deploying HTTPS/TLS certificates for '$domain_name'."

    # Copy privkey.pem to [name of subfolder].key
    copy_file "$subfolder/privkey.pem" "$output_dir/$domain_name.key" "privkey.pem"

    # Copy fullchain.pem to [name of subfolder].crt
    copy_file "$subfolder/fullchain.pem" "$output_dir/$domain_name.crt" "fullchain.pem"

    # Copy chain.pem to [name of subfolder].chain.pem
    copy_file "$subfolder/chain.pem" "$output_dir/$domain_name.chain.pem" "chain.pem"

    success "HTTPS/TLS certificates deployed for '$domain_name'."
  fi
done

success "Deployment completed."

# Restart Nginx after deploying certificates
restart_nginx
success "Nginx restarted after certificate deployment."
