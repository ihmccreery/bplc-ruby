require 'scanner'
require 'parser'

class Bplc
  def initialize(fname)
    @source = File.new(fname)
  end

  def compile
    Parser.new(Scanner.new(@source)).parse
  end
end
