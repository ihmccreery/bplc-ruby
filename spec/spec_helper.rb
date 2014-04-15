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

def type_check(s)
  TypeChecker.new(resolve(s)).type_check
end

def resolve(s)
  Resolver.new(parse(s)).resolve
end

def parse(s)
  Parser.new(Scanner.new(s)).parse
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

def expect_syntax_error_on_parse(s, message)
  p = Parser.new(Scanner.new(s))
  expect{p.parse}.to raise_error(SyntaxError, message)
end

def expect_syntax_error_on_parse_stmts(s, message)
  expect_syntax_error_on_parse("int f(void) { #{s} }", message)
end

def expect_syntax_error(message, line, column)
  expect{yield}.to raise_error { |error|
    expect(error).to be_a(BplSyntaxError)
    expect(error.line).to eq(line)
    expect(error.column).to eq(column)
    expect(error.message).to eq(message)
  }
end
