# Check if we have x-www-browser (on Debian/Ubuntu), open (on Mac), or just
# display instructions otherwise.
URLOPENER=$(shell which x-www-browser || which open || echo "\#Please open this URL:")

IMAGE=training/docker-fundamentals-image
CONTAINER=showoff

showoff:
	docker build -t $(IMAGE) .
	# Remove the old image (if there is one)
	docker inspect $(CONTAINER) >/dev/null 2>&1 && docker rm -f $(CONTAINER) || true
	docker run -d --name $(CONTAINER) -p 9090:9090 $(IMAGE)
	$(URLOPENER) http://localhost:9090/

pdf:
	docker run --net container:$(CONTAINER) $(IMAGE) \
		prince http://localhost:9090/print -o - > DockerSlides.pdf
	docker run --net container:$(CONTAINER) $(IMAGE) \
		prince http://localhost:9090/supplemental/exercises/print -o - > DockerExercises.pdf

