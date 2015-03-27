#!/bin/bash
#
# Copyright (C) 2015 Red Hat Inc.
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

(uname -r | grep -q x86_64) || { echo 1>&2 "$0 can be run only on x86_64"; echo "1..0" ; exit 0; }

echo "1..1"

mkdir repo
ostree --repo=repo init --mode=archive-z2

echo "ok setup"

LD_PRELOAD=$(dirname $0)/compose/libshadow.so $(dirname $0)/compose/pseudo/bin/pseudo -P $(dirname $0)/compose/pseudo rpm-ostree --repo=repo compose tree $(dirname $0)/compose/test-repo.json
