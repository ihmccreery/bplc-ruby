require 'stringio'

class Scanner
  def initialize(source)
    configure_source(source)
    @line_number = 1
  end

  def next_token
    consume_whitespace_and_comments
    s = getc

    # identifiers & keywords
    if s =~ /[A-Za-z_]/
      c = getc
      while(c =~ /[0-9A-Za-z_]/)
        s << c
        c = getc
      end
      ungetc(c)
      if Token::KEYWORDS[s]
        return Token.new(s, Token::KEYWORDS[s], @line_number)
      else
        return Token.new(s, :id, @line_number)
      end

    # numerics
    elsif s =~ /[0-9]/
      c = getc
      while(c =~ /[0-9]/)
        s << c
        c = getc
      end
      ungetc(c)
      return Token.new(s, :num, @line_number)

    # strings
    elsif s == '"'
      # don't want the quotes
      s = ''
      c = getc
      while(c != '"')
        if ["\n", nil].include? c
          raise SyntaxError, "unterminated string \"#{s}\" on line #{@line_number}"
        end
        s << c
        c = getc
      end
      return Token.new(s, :str, @line_number)

    # single-character symbols
    # NOTE we've already checked for comments, so we can consume '/'
    elsif %w[; , [ ] { } ( ) + - * / % &].include? s
      return Token.new(s, Token::SYMBOLS[s], @line_number)

    # ambiguous symbols
    elsif %w[= < >].include? s
      c = getc
      if c == '='
        s << c
        return Token.new(s, Token::SYMBOLS[s], @line_number)
      else
        ungetc(c)
        return Token.new(s, Token::SYMBOLS[s], @line_number)
      end
    elsif s == '!'
      c = getc
      if c == '='
        s << c
        return Token.new(s, Token::SYMBOLS[s], @line_number)
      else
        ungetc(c)
        raise SyntaxError, "invalid symbol '#{s}' on line #{@line_number}"
      end

    # end-of-file
    elsif s.nil?
      return Token.new(s, :eof, @line_number)

    # syntax error
    else
      raise SyntaxError, "invalid symbol '#{s}' on line #{@line_number}"
    end
  end

  private

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

  # NOTE increments line numbers as it consumes
  def consume_whitespace_and_comments
    # consume whitespace
    c = getc
    while c =~ /\s/
      if c == "\n"
        @line_number += 1
      end
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
    s = getc
    beginning_line = @line_number
    until s =~ /.*\*\//
      c = getc
      if c == "\n"
        @line_number += 1
      end
      if c.nil?
        raise SyntaxError, "unterminated comment beginning on line #{beginning_line}"
      else
        s << c
      end
    end
  end

  def getc
    @source.getc
  end

  def ungetc(c)
    @source.ungetc(c)
  end
end
