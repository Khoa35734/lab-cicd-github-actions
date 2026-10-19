CC = gcc
CFLAGS = -Wall -Wextra -O3

.PHONY: build test lint clean

build:
	$(CC) $(CFLAGS) prime_utils.c test_app.c -o validator

test: build
	./validator

lint:
	cppcheck --enable=all --error-exitcode=1 prime_utils.c test_app.c

clean:
	rm -f validator *.tar.gz
