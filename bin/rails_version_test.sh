#!/bin/sh

versions=(4.1.4 4.1.3 4.1.2 4.1.2.rc3 4.1.2.rc2 4.1.2.rc1 4.1.1 4.1.0 4.1.0.rc2 4.1.0.rc1 4.1.0.beta2 4.1.0.beta1 4.0.8 4.0.7 4.0.6 4.0.6.rc3 4.0.6.rc2 4.0.6.rc1 4.0.5 4.0.4 4.0.4.rc1 4.0.3 4.0.2 4.0.1 4.0.1.rc4 4.0.1.rc3 4.0.1.rc2 4.0.1.rc1 4.0.0 4.0.0.rc2 4.0.0.rc1 4.0.0.beta1)

echo "Testing gem on Rails versions:"

for v in ${versions[@]}; do
  if [ -e Gemfile.lock ]
  then
    rm Gemfile.lock
  fi

  echo -n " - ${v}"

  export RAILS_VERSION=${v}
  bundle install > /dev/null 2>&1
  bundle exec rspec > rails_${v}_tests.log 2>&1

  if [ $? != 0 ]
  then
    echo "	[FAIL]"
  else
    echo "	[PASS]"
  fi

  unset RAILS_VERSION
done

exit 0
