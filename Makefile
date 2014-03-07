# Makefile for a generic ruby project

test: spec/
	rspec

doc: lib
	rdoc lib
