#!/bin/bash

set -e

module=pydesktop-effects
snaproot="http://kagesenshi-private.googlecode.com/svn/trunk/${module}"

tmp=$(mktemp -d)

trap cleanup EXIT
cleanup() {
  set +e
  [ -z "${tmp}" -o ! -d "${tmp}" ] || rm -rf "${tmp}"
}

unset CDPATH
pwd=$(pwd)
snap=${snap:-$(date +%Y%m%d)}

pushd "${tmp}"
  svn checkout -r {$snap} ${snaproot}/ ${module}-${snap}
  pushd ${module}-${snap}
    find . -type d -name .svn -print0 | xargs -0r rm -rf
  popd
  tar -jcf "${pwd}"/${module}-${snap}.tar.bz2 ${module}-${snap}
popd >/dev/null
