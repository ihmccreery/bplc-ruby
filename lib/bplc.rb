require 'errors'
require 'scanner'
require 'parser'
require 'resolver'
require 'type_checker'

class Bplc
  def initialize(fname)
    @source = File.new(fname)
  end

  def compile
    begin
      a = Parser.new(Scanner.new(@source)).parse
      Resolver.new(a).resolve
      TypeChecker.new(a).type_check
    rescue BplError => error
      puts <<-message
#{error.class}: #{error.message} on line #{error.line}:

#{[*@source][error.line-1]}
message
    end
  end
end
