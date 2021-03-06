#!/bin/bash

set -e

module=promoe
snaproot="git://git.xmms.se/xmms2/${module}.git/"

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
  git clone ${snaproot} ${module}-${snap}
  pushd ${module}-${snap}
    find . -type d -name .git -print0 | xargs -0r rm -rf
    find . -type d -name .gitignore -print0 | xargs -0r rm -rf
  popd
  tar jcf "${pwd}"/${module}-${snap}.tar.bz2 ${module}-${snap}
popd >/dev/null
