#!/bin/bash
set -e

if [[ ! -x "${RUBIES_PATH}/${RUBY_VERSION}/bin/ruby" ]]; then
  echo "Installing Ruby ${RUBY_VERSION}"

  # We need somewhere local to put our new rubies/gems
  mkdir -p ${GEM_HOME}
  mkdir -p ${RUBIES_PATH}

  # Download pre-compiled Ruby
  curl -s -L "https://repoav.dev.bbc.co.uk/projects/VOSBOX/ruby/ruby-${RUBY_VERSION}.tar.gz" -o ${WORKSPACE}/${RUBY_VERSION}.tar.gz --cert /etc/pki/tviplayer.pem --insecure

  # unzip Ruby to our workspace
  tar zxf ${WORKSPACE}/${RUBY_VERSION}.tar.gz -C ${RUBIES_PATH}

  # Install Bundler
  gem install bundler
fi
