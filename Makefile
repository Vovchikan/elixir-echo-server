HOST_PORT=400
DOCKER_PORT=6000

docker: image run

image:
	docker build . -t elixir:1.14-echo

run:
	docker run -itp $(HOST_PORT):$(DOCKER_PORT) --rm --name echo elixir:1.14-echo

run-detached:
	docker run -dp $(HOST_PORT):$(DOCKER_PORT) --rm --name echo elixir:1.14-echo

stop:
	docker stop echo

telnet:
	telnet localhost $(HOST_PORT)