build/script.js: build
	dart2js -m script.dart -o build/script.js

build:
	mkdir build

clean:
	rm -rf build
