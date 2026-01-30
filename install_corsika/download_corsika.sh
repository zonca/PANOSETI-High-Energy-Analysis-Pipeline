#!/bin/bash

# Download CORSIKA from official server
# Credentials must be set as environment variables:
# CORSIKA_USER - username (required, get from https://www.iap.kit.edu/corsika/)
# CORSIKA_PASSWORD - password (required)

USER="${CORSIKA_USER}"
PASSWORD="${CORSIKA_PASSWORD}"

if [ -z "$USER" ] || [ -z "$PASSWORD" ]; then
    echo "Error: CORSIKA_USER and CORSIKA_PASSWORD environment variables must be set"
    echo "Get credentials from https://www.iap.kit.edu/corsika/"
    exit 1
fi

wget --user="$USER" --password="$PASSWORD" https://web.iap.kit.edu/corsika/download/corsika-v7750/corsika-77550.tar.gz