#!/usr/bin/env bash

set -euxo pipefail

PROJECT_ROOT=$(dirname "$0")/..
XCODEPROJ=$PROJECT_ROOT/Tablier.xcodeproj

TMPPROJ=$(mktemp -d)

XCDIFF="swift run -c release xcdiff"

echo "Changes after project generation:"
if git diff --exit-code --name-only -- $XCODEPROJ ; then
    echo "No change found."
    exit 0;
fi

rsync -a $XCODEPROJ/ $TMPPROJ/

git checkout -- $XCODEPROJ

function cleanup {
    echo "Cleaning up..."
    rsync -a $TMPPROJ/ $XCODEPROJ/
    rm -rf $TMPPROJ
}

trap cleanup EXIT

if $XCDIFF -t "Tablier" -g "settings" -p1 $XCODEPROJ -p2 $TMPPROJ ; then
    exit 0;
fi

exit 1;