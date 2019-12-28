This container serves as a portable cross-compilation environment for building ARMv7 android software that's written in Rust. It also serves as a (relatively) detailed guide on how to setup such an environment.

Prerequisites:
Make sure that `adb` server is already running and listening on the default before running this container. Also make sure that the server is authorized to connect to `adbd` running on the target hardware. A good way to do this is to run `adb devices`. Another option is to try running a shell on your hardware `adb shell`.

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
