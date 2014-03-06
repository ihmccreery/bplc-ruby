class Token


  # the string value of the token
  attr_reader :value

  # the type of token, as a symbol
  attr_reader :type

  # the line from which the Token was generated
  attr_reader :line_number

  def initialize(value, type, line_number)
    @value = value
    @type = type
    @line_number = line_number
  end

  # checks for equality based on the attributes of the Token
  def ==(t)
    (t.class == self.class) && (t.state == self.state)
  end
  alias_method :eql?, :==

  protected

  # list of attributes used for checking equality
  def state
    [@value, @type, @line_number]
  end
end
