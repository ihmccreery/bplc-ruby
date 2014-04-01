require 'scanner'
require 'parser'
require 'type_checker'

class Bplc
  def initialize(fname)
    @source = File.new(fname)
  end

  def compile
    Parser.new(Scanner.new(@source)).parse
  end
end
