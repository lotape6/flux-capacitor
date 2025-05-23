# GitHub Workflows

This directory contains GitHub Actions workflows for automating various tasks in the flux-capacitor repository.

## Workflows

### CI (ci.yml)
Runs continuous integration tests when code is pushed to the master branch or pull requests are created.

### Auto Issue Assignment (issue-assignment.yml)
Automatically assigns new GitHub issues to the user 'copilot' if they remain unassigned for 30 seconds after creation.

### Assign Current Issue (assign-current-issue.yml)
A one-time workflow to assign a specific issue (#9) to the user 'copilot'. This was created to fulfill the requirements of issue #9.