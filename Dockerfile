# This dockerfile sets up a cross-compilation environment for 
# armv7 android over host ADB server. Rust 1.40.0.
#
# Copyright (C) 2020 Kutometa SPLC, Kuwait
# License: LGPLv3 
# www.ka.com.kw


# --- Based on debian 10

    FROM debian:buster

# --- Update and download needed tools

    RUN apt update
    RUN apt upgrade -y
    RUN apt install -y adb netcat-openbsd wget gpg tar ca-certificates

# --- Add user 'cargo-user' and set as cargo default user and home dir

    RUN adduser --disabled-password --gecos "" cargo-user
    USER cargo-user:cargo-user
    WORKDIR /home/cargo-user

# --- Download needed Rust standalone installers + pgp signatures 

    RUN wget https://static.rust-lang.org/dist/rust-1.40.0-x86_64-unknown-linux-gnu.tar.gz
    RUN wget https://static.rust-lang.org/dist/rust-1.40.0-x86_64-unknown-linux-gnu.tar.gz.asc
    RUN wget https://static.rust-lang.org/dist/rust-std-1.40.0-armv7-linux-androideabi.tar.gz
    RUN wget https://static.rust-lang.org/dist/rust-std-1.40.0-armv7-linux-androideabi.tar.gz.asc
    RUN wget https://dl.google.com/android/repository/android-ndk-r20b-linux-x86_64.zip

# --- Set up gpg keyring and import Rust keys

    COPY container-files/rust-signing-key.pub /home/cargo-user/rust-signing-key.pub
    RUN gpg --yes --always-trust --import < rust-signing-key.pub

# --- Verify pgp signatures

    RUN gpg --verify rust-1.40.0-x86_64-unknown-linux-gnu.tar.gz.asc rust-1.40.0-x86_64-unknown-linux-gnu.tar.gz
    RUN gpg --verify rust-std-1.40.0-armv7-linux-androideabi.tar.gz.asc rust-std-1.40.0-armv7-linux-androideabi.tar.gz
    RUN bash -c 'HASH=($(sha384sum android-ndk-r20b-linux-x86_64.zip)) && [ "${HASH[0]}" = f2897012a748c579302483dd315c685056a4e8ad740a929f62972f82ed65718c43e9c77367714bd9255eb30f3d2e2d75 ]'

# --- Untar standalone installers

    RUN tar -xzf rust-1.40.0-x86_64-unknown-linux-gnu.tar.gz
    RUN tar -xzf rust-std-1.40.0-armv7-linux-androideabi.tar.gz
    
# -- unzip ndk
    USER root:root
    RUN apt install -y unzip
    USER cargo-user:cargo-user
    RUN unzip android-ndk-r20b-linux-x86_64.zip
    

# --- Run standalone installers

    USER root:root
    RUN cd rust-1.40.0-x86_64-unknown-linux-gnu && ./install.sh
    RUN cd rust-std-1.40.0-armv7-linux-androideabi && ./install.sh

# --- Cleaning up

    USER root:root
    RUN apt clean
    RUN rm -r rust-1.40.0-x86_64-unknown-linux-gnu.tar.gz.asc
    RUN rm -r rust-1.40.0-x86_64-unknown-linux-gnu.tar.gz
    RUN rm -r rust-std-1.40.0-armv7-linux-androideabi.tar.gz.asc
    RUN rm -r rust-std-1.40.0-armv7-linux-androideabi.tar.gz
    RUN rm -r android-ndk-r20b-linux-x86_64.zip
    RUN rm -r rust-1.40.0-x86_64-unknown-linux-gnu
    RUN rm -r rust-std-1.40.0-armv7-linux-androideabi
    RUN mv android-ndk-r20b/toolchains/llvm/prebuilt/linux-x86_64 android-ndk-r20b-linux-x86_64
    RUN rm -r android-ndk-r20b-linux-x86_64/sysroot/usr/lib/aarch64-linux-android
    RUN rm -r android-ndk-r20b-linux-x86_64/sysroot/usr/lib/x86_64-linux-android
    RUN rm -r android-ndk-r20b-linux-x86_64/sysroot/usr/lib/i686-linux-android
    RUN rm -r android-ndk-r20b-linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/29
    RUN rm -r android-ndk-r20b-linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/28
    RUN rm -r android-ndk-r20b-linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/27
    RUN rm -r android-ndk-r20b-linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/26
    RUN rm -r android-ndk-r20b-linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/24
    RUN rm -r android-ndk-r20b-linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/23
    RUN rm -r android-ndk-r20b-linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/22
    RUN rm -r android-ndk-r20b-linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/21
    RUN rm -r android-ndk-r20b-linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/19
    RUN rm -r android-ndk-r20b-linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/18
    RUN rm -r android-ndk-r20b-linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/17
    RUN rm android-ndk-r20b-linux-x86_64/bin/aarch64-*
    RUN rm android-ndk-r20b-linux-x86_64/bin/i686-*
    RUN rm android-ndk-r20b-linux-x86_64/bin/x86_64-*
    RUN rm android-ndk-r20b-linux-x86_64/bin/arm-*
    
# --- Set up cargo configuration 

    USER cargo-user:cargo-user
    RUN mkdir /home/cargo-user/.cargo
    COPY container-files/cargo-config /home/cargo-user/.cargo/config    

# --- Set up helper (to check for proper usage)

    USER root:root
    COPY container-files/docker-launcher.sh /usr/local/bin/launcher.sh
    RUN chmod +x /usr/local/bin/launcher.sh
    COPY container-files/android-adb-runner.sh /usr/local/bin/android-adb-runner.sh
    RUN chmod +x /usr/local/bin/android-adb-runner.sh
    
# --- Entry point
    
    USER cargo-user:cargo-user
    ENTRYPOINT ["launcher.sh"]
    

