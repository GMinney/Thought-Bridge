
build:
	docker build -t thought-bridge:latest https://github.com/GMinney/Thought-Bridge.git

build-local:
	docker build -t thought-bridge:latest .

run:
	docker run -it -e "PORT=8080" -p 8080:8080 thought-bridge:latest