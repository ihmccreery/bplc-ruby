require 'bplc'

def get_example(s)
  File.expand_path("../examples/#{s}.bpl", __FILE__)
end

EX1_FNAME = get_example("ex1")
EX_BAD_SYNTAX_FNAME = get_example("ex_bad_syntax")
EX_FAKE_FNAME = get_example("ex_fake")

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end

def resolve(s)
  a = parse_program(s)
  Resolver.new(a).resolve
  return a
end

def parse_program(s)
  parse(s)
end

def parse_declaration(s)
  parse(s).declarations[0]
end

def parse_param(s)
  parse("int f(#{s}) { }").declarations[0].params[0]
end

def parse_stmt(s)
  parse("int f(void) { #{s} }").declarations[0].body.stmts[0]
end

def parse_exp(s)
  parse("int f(void) { #{s}; }").declarations[0].body.stmts[0].exp
end

def parse(s)
  Parser.new(Scanner.new(s)).parse
end

def expect_syntax_error(s, message)
  p = Parser.new(Scanner.new(s))
  expect{p.parse}.to raise_error(SyntaxError, message)
end

def expect_syntax_error_on_stmts(s, message)
  expect_syntax_error("int f(void) { #{s} }", message)
end
