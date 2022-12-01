docker: image run

image:
	docker build . -t elixir:1.14-echo

run:
	docker run -itp 400:6000 --rm --name echo elixir:1.14-echo

run-detached:
	docker run -dp 400:6000 --rm --name echo elixir:1.14-echo

stop:
	docker stop echo
