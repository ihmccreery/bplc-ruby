class BplSyntaxError < StandardError
  attr_reader :line

  def initialize(line)
    @line = line
  end
end
