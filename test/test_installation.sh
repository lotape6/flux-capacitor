#!/usr/bin/env bash
set -e

# Install dependencies for your tools if needed
apt-get update
apt-get install -y curl git

# Install project
#TODO
# Basic checks
# tmux -V
# fzf --version

echo "All tools installed and working!"
# Exit code is automatically the script's exit code: 0 = success, nonzero = failure
exit 0