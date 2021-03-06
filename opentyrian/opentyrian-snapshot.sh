#!/bin/bash

set -e

module=opentyrian
snaproot="http://opentyrian.googlecode.com/svn/classic/trunk"

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
  svn checkout -r {$snap} ${snaproot} ${module}-${snap}
  pushd ${module}-${snap}
    SVNREV=$(svnversion src -n)
    sed -i -e "/^SVN_REV/s|:=.*|:= ${SVNREV}|g" Makefile
    find . -type d -name .svn -print0 | xargs -0r rm -rf
  popd
  tar -jcf "${pwd}"/${module}-${snap}.tar.bz2 ${module}-${snap}
popd >/dev/null
