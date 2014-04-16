class BplError < StandardError
  attr_reader :line

  def initialize(line)
    @line = line
  end
end

class BplSyntaxError < BplError
end

class BplDeclarationError < BplError
end
