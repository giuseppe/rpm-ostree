#!/bin/bash
#
# Copyright (C) 2014 Colin Walters <walters@verbum.org>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the
# Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

set -e

. $(dirname $0)/libtest.sh

(test "$(id -u)" = "0") || { echo 1>&2 "$0 can be run only as root"; echo "1..0" ; exit 0; }

echo "1..1"

setup_os_repository "archive-z2" "syslinux"

echo "ok setup"

# This initial deployment gets kicked off with some kernel arguments 
ostree --repo=sysroot/ostree/repo remote add --set=gpg-verify=false testos file://$(pwd)/testos-repo testos/buildmaster/x86_64-runtime
ostree --repo=sysroot/ostree/repo pull testos:testos/buildmaster/x86_64-runtime
ostree admin --sysroot=sysroot deploy --karg=root=LABEL=MOO --karg=quiet --os=testos testos:testos/buildmaster/x86_64-runtime

rpm-ostree status --sysroot=sysroot | tee OUTPUT-status.txt

assert_file_has_content OUTPUT-status.txt '1.0.10'

os_repository_new_commit
rpm-ostree upgrade --sysroot=sysroot --os=testos

ostree --repo=sysroot/ostree/repo remote add --set=gpg-verify=false otheros file://$(pwd)/testos-repo testos/buildmaster/x86_64-runtime
rpm-ostree rebase --sysroot=sysroot --os=testos otheros:

rpm-ostree status --sysroot=sysroot | tee OUTPUT-status.txt

assert_not_file_has_content OUTPUT-status.txt '1.0.10'
version=$(date "+%Y%m%d.0")
assert_file_has_content OUTPUT-status.txt $version
