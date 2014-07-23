#!/bin/sh

# This script is designed to run the tests for a gem (via Rspec) on multiple
# versions of Rails. Simply enter the versions you wish to test (in the format
# x.y.z, space separated) into the array below.
#
# Please note that this script temporarily renames the Gemfile.lock file for
# the gem. This is necessary for two reasons - first, this file will be
# overwritten during the test run, and second, it is not possible to install
# exact versions of gems when a Gemfile.lock file already exists.
#
# (This is because bundle install uses Gemfile.lock, and bundle update doesn't
# install exact gem versions - rather, it always install the latest (highest)
# TINY version number for the specified MAJOR and MINOR version combination.)
#
# The Gemfile.lock file is restored at the end of the run. Please note that if
# you interrupt the run this restoration will not happen, so you will either
# need to rename it yourself (Gemfile.lock.backup -> Gemfile.backup) or delete
# it and regenerate the file with bundle.

versions=(4.1.4 4.1.3 4.1.2 4.1.2.rc3 4.1.2.rc2 4.1.2.rc1 4.1.1 4.1.0 4.1.0.rc2 4.1.0.rc1 4.1.0.beta2 4.1.0.beta1 4.0.8 4.0.7 4.0.6 4.0.6.rc3 4.0.6.rc2 4.0.6.rc1 4.0.5 4.0.4 4.0.4.rc1 4.0.3 4.0.2 4.0.1 4.0.1.rc4 4.0.1.rc3 4.0.1.rc2 4.0.1.rc1 4.0.0 4.0.0.rc2 4.0.0.rc1 4.0.0.beta1)

# Back up the existing Gemfile.lock file, if one exists, so that it may be
# restored after the run.
if [ -e Gemfile.lock ]
then
  mv Gemfile.lock Gemfile.lock.backup
fi

echo "Testing gem on Rails versions:"

for version in ${versions[@]}; do
  # Remove Gemfile.lock file so as to permit installation of exact gem versions.
  if [ -e Gemfile.lock ]
  then
    rm Gemfile.lock
  fi

  echo -n " - ${version}"

  # bundle install, not update, to ensure exact gem versions
  RAILS_VERSION=${version} bundle install > /dev/null 2>&1

  if [ $? != 0 ]
  then
    # bundle failure ...
    echo "	[FAIL - bundle]"
  else
    RAILS_VERSION=${version} bundle exec rspec > /dev/null 2>&1

    if [ $? != 0 ]
    then
      # Rspec failure ...
      echo "	[FAIL - Rspec]"
    else
      echo "	[PASS]"
    fi
  fi
done

# Restore the Gemfile.lock backup, if one exists
if [ -e Gemfile.lock.backup ]
then
  mv Gemfile.lock.backup Gemfile.lock
fi

exit 0
