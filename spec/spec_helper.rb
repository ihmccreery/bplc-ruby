Dir[File.expand_path("../../lib/*.rb", __FILE__)].each { |f| require f }

EX1_FNAME = File.expand_path("../ex1.bpl", __FILE__)

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
