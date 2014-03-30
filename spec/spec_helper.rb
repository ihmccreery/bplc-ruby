Dir[File.expand_path("../../lib/*.rb", __FILE__)].each { |f| require f }

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

def get_body(s)
  Parser.new(Scanner.new("int f(void) { #{s} }")).parse.declarations[0].body
end

def get_factor(s)
  Parser.new(Scanner.new("int f(void) { #{s}; }")).parse.declarations[0].body.statements[0].expression.e.t.f.factor
end
