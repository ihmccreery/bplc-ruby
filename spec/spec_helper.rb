require 'bplc'

def get_example(s)
  File.expand_path("../examples/#{s}.bpl", __FILE__)
end

EX1_FNAME = get_example("ex1")
EX2_FNAME = get_example("ex2")
EX3_FNAME = get_example("ex3")
EX_BAD_SYNTAX_FNAME = get_example("ex_syntax_error")
EX_BAD_DECLARATION_FNAME = get_example("ex_declaration_error")
EX_BAD_TYPE_FNAME = get_example("ex_type_error")
EX_FAKE_FNAME = get_example("ex_fake")

RSpec.configure do |config|
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end

def label(s)
  Labeler.new(type_check(s)).label
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

def expect_syntax_error_on_parse(s, message, line=1)
  expect_syntax_error(message, line) do
    parse(s)
  end
end

def expect_syntax_error_on_parse_stmts(s, message)
  expect_syntax_error_on_parse("int f(void) { #{s} }", message)
end

def expect_syntax_error(message, line=1)
  expect_error(BplSyntaxError, message, line) { yield }
end

def expect_declaration_error(message, line=1)
  expect_error(BplDeclarationError, message, line) { yield }
end

def expect_type_error(message, line=1)
  expect_error(BplTypeError, message, line) { yield }
end

def expect_error(error_klass, message, line=1)
  expect{yield}.to raise_error { |error|
    expect(error).to be_a(error_klass)
    expect(error.line).to eq(line)
    expect(error.message).to eq(message)
  }
end

def expect_error_output(klass, message, line_number, line)
  expect(STDOUT).to receive(:puts).with(formatted_error(klass, message, line_number, line))
  yield
end

def formatted_error(klass, message, line_number, line)
  return <<-message
#{klass}: #{message} on line #{line_number}:

#{line}
message
end
