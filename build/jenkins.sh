#!/bin/bash

# Ensure abort if any command fails (returns non zero status code $?)
set -e +x

# Parameters
if [ "$1" = "pull-request" ] ; then
  IS_PULL_REQUEST='1'
fi

if [ -z "$GIT_POINTER" ]; then
  export GIT_POINTER=$GIT_COMMIT
fi

function notify_github {
  # We only annotate pull requests with the build state, so skip this in other cases
  if [ -n "$IS_PULL_REQUEST" ]; then
    curl -s --data "{\"state\": \"${1}\", \"target_url\": \"${BUILD_URL}console\", \"description\": \"${2}\"}" \
      https://api.github.com/repos/bbc/kandl-migration-script/statuses/$GIT_POINTER?access_token=$GITHUB_ACCESS_TOKEN >/dev/null
  fi
}

function run_cmd {
  notify_github "pending" "$2"
  $(echo "$1") || error_exit "$2"
}

function error_exit {
  notify_github "failure" "$1"
  echo "$1" >&2   ## Send message to stderr. Exclude >&2 if you don't want it that way.
  exit "${2:-1}"  ## Return a code specified by $2 or 1 by default.
}

notify_github 'pending' 'Starting build'

# Install Bundler
run_cmd 'gem install bundler' 'Installing bundler'
run_cmd 'bundle install' 'Installing gems'

# Run the Tests
run_cmd 'rspec' 'Running tests'

# Finished
notify_github 'success' 'Build completed'
