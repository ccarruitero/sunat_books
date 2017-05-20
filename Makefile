.PHONY: test

console:
	irb -Ilib -rsunat_books

test:
	bundle exec cutest test/*.rb test/**/*.rb
	bundle exec rubocop
