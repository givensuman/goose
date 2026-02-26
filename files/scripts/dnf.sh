#!/bin/bash

# Simple script to update and clean the system using dnf5.
set -euo pipefail

dnf5 -y update
dnf5 -y upgrade
dnf5 -y autoremove
dnf5 -y clean all
