bplc-ruby
====

An implementation of a BPL language compiler in Ruby for the OCCS Compilers course.

Usage
---

    $ ./bin/bplc example.bplc

Directory system
---

### Code

All compiler code is in `lib/`.  Generally-used components like tokens and the abstract syntax tree are in top-level
files, (in `lib/token.rb` and `lib/ast.rb`, respectively).

Other components that can have multiple implementations, such as scanners and parsers, have a more complex structure.
At the top level, there are plug-and-play components like `parser.rb`:

    require 'parsers/recursive_descent_parser'

    class Parser < Parsers::RecursiveDescentParser
    end

This way, if I build different implementations, I can pull out one, plug in another, and it will (should) all run
smoothly.

### Specs

Tests (specs) are in `spec/`.  Right now, there are general specs for scanners and parsers; if/when I implement other
scanners, (like a regex-based scanner,) parsers, (like a bottom-up parser,) or other componenets, I'll have to split
tests for each implementation.
