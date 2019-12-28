# This dockerfile sets up a cross-compilation environment for 
# armv7 android over local ADB. Rust 1.40.0.
#
# Copyright (C) 2019 Kutometa SPLC
# License: LGPLv3
# https://www.ka.com.kw


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

# --- Set up cargo configuration 

    RUN mkdir /home/cargo-user/.cargo
    COPY cargo-config	/home/cargo-user/.cargo/config

# --- Set up gpg keyring and import Rust keys

    COPY rust-signing-key.pub /home/cargo-user/rust-signing-key.pub
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

# --- Set up helper (to check for proper usage)

    USER root:root
    COPY runner.sh /usr/local/bin/runner.sh
    RUN chmod +x /usr/local/bin/runner.sh
    COPY android-adb-runner.sh /usr/local/bin/android-adb-runner.sh
    RUN chmod +x /usr/local/bin/android-adb-runner.sh

# --- Cleaning up

    USER root:root
    RUN rm -r rust-1.40.0-x86_64-unknown-linux-gnu.tar.gz.asc
    RUN rm -r rust-1.40.0-x86_64-unknown-linux-gnu.tar.gz
    RUN rm -r rust-std-1.40.0-armv7-linux-androideabi.tar.gz.asc
    RUN rm -r rust-std-1.40.0-armv7-linux-androideabi.tar.gz
    RUN rm -r android-ndk-r20b-linux-x86_64.zip
    RUN apt clean

# --- Entry point
    
    USER cargo-user:cargo-user
    ENTRYPOINT ["runner.sh"]
    

