build:
	bash build-image.sh
install:
	cp built/cargo-armv7-android-adb-local /usr/local/bin/cargo-armv7-android-adb-local
clean:
	rm built/cargo-armv7-android-adb-local
	rmdir built
	[ -d test-crate/target ] && rm -r test-crate/target

