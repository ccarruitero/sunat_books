.PHONY: test

console:
	irb -Ilib -rsunat_books

test:
	cutest test/*.rb
	rubocop
