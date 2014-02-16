# Makefile for a generic ruby project

test: spec/
	rspec

doc: scanner.rb token.rb
	rdoc scanner.rb token.rb
