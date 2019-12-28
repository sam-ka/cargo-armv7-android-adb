This container serves as a portable cross-compilation environment for building Rust code targeting ARMv7 android. It also serves as a (relatively) detailed guide on how to setup such an environment from a fresh Debian 10 "Buster" installation.

Prerequisites:
Make sure that `adb` server is running on the host and listening on the default port. Also make sure that the server is authorized to connect to the target hardware. A good way to do this is to run `adb devices`. Another option is to try running a shell on your hardware `adb shell`.

Usage:
````
docker run --rm --net=host -ti \
    -v <CRATE-DIR>:/crate \
    kutometa/cargo-armv7-android-adb:1.40.0 \
    <CARGO-CMD> \
    --target=armv7-linux-androideabi \
    <ARGS> ...
````

Docker Hub: https://hub.docker.com/r/kutometa/cargo-armv7-android-adb
