require 'stringio'

# a simple scanner that takes in a String, File, or other IO object
# and yields successive tokens with #next_token and #current_token
class Scanner

  # the current Token in the source
  attr_accessor :current_token

  def initialize(source)
    configure_source(source)
    @line_number = 1
  end

  # gets the next Token in the source and returns it, progressing
  # #current_token as well
  def next_token
    consume_whitespace_and_comments
    p = peek

    if p =~ /[A-Za-z_]/
      return get_identifier_or_keyword

    elsif p =~ /[0-9]/
      return get_numeric

    elsif p == '"'
      return get_string

    # NOTE we've already checked for comments, so we can consume '/'
    elsif %w[; , [ ] { } ( ) + - * / % &].include? p
      return get_single_character_symbol

    elsif %w[= < > !].include? p
      return get_ambiguous_symbol

    elsif p.nil?
      return get_eof

    else
      raise SyntaxError, "invalid symbol '#{getc}' on line #{@line_number}"
    end
  end

  private

  ###############
  # get methods #
  ###############

  def get_identifier_or_keyword
    s = getc
    c = getc
    while(c =~ /[0-9A-Za-z_]/)
      s << c
      c = getc
    end
    ungetc(c)
    if Token::KEYWORDS[s]
      return @current_token = Token.new(s, Token::KEYWORDS[s], @line_number)
    else
      return @current_token = Token.new(s, :id, @line_number)
    end
  end

  def get_numeric
    s = getc
    c = getc
    while(c =~ /[0-9]/)
      s << c
      c = getc
    end
    ungetc(c)
    return @current_token = Token.new(s, :num, @line_number)
  end

  def get_string
    # don't want the quotes
    getc
    s = ''
    c = getc
    while(c != '"')
      if ["\n", nil].include? c
        ungetc(c)
        raise SyntaxError, "unterminated string \"#{s}\" on line #{@line_number}"
      end
      s << c
      c = getc
    end
    return @current_token = Token.new(s, :str, @line_number)
  end

  def get_single_character_symbol
    c = getc
    return @current_token = Token.new(c, Token::SYMBOLS[c], @line_number)
  end

  def get_ambiguous_symbol
    s = getc
    if s == '!'
      c = getc
      if c == '='
        s << c
        return @current_token = Token.new(s, Token::SYMBOLS[s], @line_number)
      else
        ungetc(c)
        raise SyntaxError, "invalid symbol '#{s}' on line #{@line_number}"
      end
    else
      c = getc
      if c == '='
        s << c
        return @current_token = Token.new(s, Token::SYMBOLS[s], @line_number)
      else
        ungetc(c)
        return @current_token = Token.new(s, Token::SYMBOLS[s], @line_number)
      end
    end
  end

  def get_eof
    return @current_token = Token.new(getc, :eof, @line_number)
  end

  ###################
  # support methods #
  ###################

  # source must either
  #   be a String (in which case we construct a StringIO object)
  #   be a File (in which case we construct an IO object)
  #   respond to #getc
  def configure_source(source)
    if source.is_a? String
      @source = StringIO.new(source)
    elsif source.is_a? File
      @source = open(source)
    else
      @source = source
    end
  end

  def consume_whitespace_and_comments
    # consume whitespace
    c = getc
    while c =~ /\s/
      c = getc
    end

    # consume comment
    if c == '/'
      d = getc
      if d == '*'
        consume_until_end_of_comment
        # recurse to consume more whitespace and comments
        consume_whitespace_and_comments
      else
        ungetc(d)
        ungetc(c)
      end
    else
      ungetc(c)
    end
  end

  def consume_until_end_of_comment
    beginning_line_number = @line_number
    s = getc
    until s =~ /.*\*\//
      c = getc
      if c.nil?
        ungetc(c)
        raise SyntaxError, "unterminated comment beginning on line #{beginning_line_number}"
      else
        s << c
      end
    end
  end

  def peek
    c = getc
    ungetc(c)
    return c
  end

  def getc
    c = @source.getc
    if c == "\n"
      @line_number += 1
    end
    return c
  end

  def ungetc(c)
    if c == "\n"
      @line_number -= 1
    end
    @source.ungetc(c)
  end
end
