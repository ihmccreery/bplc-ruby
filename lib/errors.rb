class BplSyntaxError < StandardError
  attr_reader :line, :column

  def initialize(line, column)
    @line = line
    @column = column
  end
end
