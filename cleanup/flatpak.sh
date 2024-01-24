#!/bin/bash

# Error status variables
STATUS_OK=0
STATUS_ERROR=1

# Definitions
USER_NAME="${SUDO_USER:-${USER}}"
USER_DIR="/home/${USER_NAME}"

if [ "${USER}" != root ]; then
  echo "Error: Must be running as root"

  exit "${STATUS_ERROR}"
fi

USED_BEFORE="$(df -k / | awk 'NR>1 {print $3}')"

if [ -n "$(command -v flatpak)" ]; then
  flatpak repair --verbose

  # cache
  rm -rfv /var/tmp/flatpak-cache-*
  sudo -u "${USER_NAME}" rm -rfv "${USER_DIR}"/.cache/flatpak/*

  flatpak uninstall --unused --verbose
fi

USED_AFTER="$(df -k / | awk 'NR>1 {print $3}')"

# Summary
echo "Freed up space: $(( (USED_BEFORE - USED_AFTER)/1024 )) MB"
exit "${STATUS_OK}"
