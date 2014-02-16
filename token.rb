class Token

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

  attr_accessor :value, :type, :line_number

  def initialize(value, type, line_number)
    @value = value
    @type = type
    @line_number = line_number
  end

  def ==(t)
    (t.class == self.class) && (t.state == self.state)
  end
  alias_method :eql?, :==

  protected

  def state
    [@value, @type, @line_number]
  end
end
