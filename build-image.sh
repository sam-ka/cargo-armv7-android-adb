#!/bin/bash
#
# Copyright (C) 2020 Kutometa SPLC, Kuwait
# License: LGPLv3 
# www.ka.com.kw

OWNER="kutometa"
IMAGENAME="cargo-armv7-android-adb"
BUILD_FLAGS="--squash"
#BUILD_FLAGS=""
RUST_TARGET_TRIPLE="armv7-linux-androideabi"



#-------------------------------------------------------------

# Make sure that a tag is supplied
if ! [[ "$1" ]]; then 
    TAG="local"
    echo "A tag was not supplied. Assuming a local build ('$OWNER/$IMAGENAME:$TAG')" 1>&2
else 
    TAG="$1"
fi

set -euH

# If not a local build, make sure that a tag given does not exist
if [[ "$TAG" != "local" ]]; then 
    if docker image inspect "$OWNER/$IMAGENAME:$TAG" >/dev/null 2>&1; then
        echo "Warning! '$TAG' already exists for '$OWNER/$IMAGENAME'"
        echo "Do you want to continue? (press Ctrl+C to cancel)"
        read ignored
    fi
fi

# Build new image
echo "Building image..."
docker build $BUILD_FLAGS -t "$OWNER/$IMAGENAME:$TAG" .
echo "Image built successfully."

echo "Testing built image..."
# Test new image
RESULT=$(docker run --rm --net=host -v "$(realpath .)/test-crate":/crate "$OWNER/$IMAGENAME:$TAG" run -q) || {
    echo "$RESULT" 1>&2
    exit 1
}


if ! [[ "$RESULT" == "ok" ]]; then
    echo "Unexpected result: $RESULT" 1>&2
    exit 1
else 
    echo "Test successful."
fi

mkdir -p "built"

echo "#!/bin/bash"'
docker run --rm --net=host -v "$(realpath .)":/crate "'"$OWNER/$IMAGENAME:$TAG"'" "$@"
' > "built/$IMAGENAME-$TAG"

chmod -w "built/$IMAGENAME-$TAG"
chmod +x "built/$IMAGENAME-$TAG"

echo "BUILD AND TEST OK. New image is '$OWNER/$IMAGENAME:$TAG'"
exit 0
