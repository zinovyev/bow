#!/usr/bin/env bash

################################################
#         INSTALLS RVM & RUBY & RAKE           #
#         TO REMOVE RUN: rvm implode           #
################################################

RUBY_VERSION="2.4"

# Install rvm
which rvm &>/dev/null
if [[ 0 != $? ]]; then
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  echo ">> Installing RVM..."
  \curl -sSL https://get.rvm.io | sudo bash -s stable
  source /usr/local/rvm/scripts/rvm
  if [[ $? == 0 ]]; then echo "RVM installed!"; fi
else
  echo ">> RVM already installed!"
fi

# Install ruby
which ruby &>/dev/null
if [[ 0 != $? ]]; then
  echo ">> Installing Ruby $RUBY_VERSION..."
  source /usr/local/rvm/scripts/rvm
  rvm install $RUBY_VERSION
  rvm --default use $RUBY_VERSION
  if [[ $? == 0 ]]; then echo "Ruby $RUBY_VERSION installed!"; fi
else
  echo ">> Ruby already installed!"
fi

# Install rake
which rake &>/dev/null
if [[ 0 != $? ]]; then
  echo ">> Installing Rake..."
  gem install rake
  if [[ $? == 0 ]]; then echo "Rake installed!"; fi
else
  echo ">> Rake already installed!"
fi
