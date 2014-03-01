class Token

  # a hash of strings representing every symbol in BPL
  # keyed to its respective #type.
  SYMBOLS = {';' => :semicolon,
             ',' => :comma,
             '[' => :l_bracket,
             ']' => :r_bracket,
             '{' => :l_brace,
             '}' => :r_brace,
             '(' => :l_paren,
             ')' => :r_paren,
             '+' => :plus,
             '-' => :minus,
             '*' => :asterisk,
             '/' => :slash,
             '=' => :gets,
             '<' => :lt,
             '<=' => :leq,
             '==' => :eq,
             '!=' => :neq,
             '>=' => :geq,
             '>' => :gt,
             '%' => :percent,
             '&' => :ampersand}.freeze

  # a hash of strings representing every keyword in BPL
  # keyed to its respective #type.
  KEYWORDS = {'int' => :int,
              'void' => :void,
              'string' => :string,
              'if' => :if,
              'else' => :else,
              'while' => :while,
              'return' => :return,
              'write' => :write,
              'writeln' => :writeln,
              'read' => :read}

  TYPE_SPECIFIERS = [:int, :void, :string]

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

  def is_type_specifier?
    return TYPE_SPECIFIERS.include? type
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
