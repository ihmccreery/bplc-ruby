require 'spec_helper'
require 'examples/ex1_tokens'

describe Scanner do
  describe "#initialize" do
    it "can be constructed from a String" do
      expect(Scanner.new("a")).to be_a Scanner
    end

    it "can be constructed from a File" do
      expect(Scanner.new(File.new(EX1_FNAME))).to be_a Scanner
    end

    it "can be constructed from a stream" do
      expect(Scanner.new(open(EX1_FNAME))).to be_a Scanner
    end
  end

  describe "#next_token" do
    it "recognizes identifiers" do
      s = Scanner.new("a bb c_c d1")
      %w[a bb c_c d1].each do |t|
        expect(s.next_token).to eq(Token.new(t, :id, 1))
      end
    end

    it "recognizes numerics" do
      s = Scanner.new("1 22")
      %w[1 22].each do |t|
        expect(s.next_token).to eq(Token.new(t, :num, 1))
      end
    end

    it "recognizes negative numerics" do
      s = Scanner.new("1 -22")
      expect(s.next_token).to eq(Token.new('1', :num, 1))
      expect(s.next_token).to eq(Token.new('-', :minus, 1))
      expect(s.next_token).to eq(Token.new('22', :num, 1))
    end

    it "splits number-identifier concatentations" do
      s = Scanner.new("1a")
      expect(s.next_token).to eq(Token.new('1', :num, 1))
      expect(s.next_token).to eq(Token.new('a', :id, 1))
    end

    it "recognizes strings" do
      s = Scanner.new('"string""another string"')
      expect(s.next_token).to eq(Token.new('string', :str, 1))
      expect(s.next_token).to eq(Token.new('another string', :str, 1))
    end

    it "raises BplSyntaxErrors on multi-line strings" do
      expect_syntax_error('unterminated string "this is a"', 1) do
        Scanner.new("\"this is a\nmulti-line string\"").next_token
      end
    end

    it "raises BplSyntaxErrors on unterminated strings" do
      expect_syntax_error('unterminated string "this is a"', 1) do
        Scanner.new("\"this is a").next_token
      end
    end

    it "recognizes single-character symbols" do
      s = Scanner.new(";,[]{}()+-*/%&")
      %w[; , [ ] { } ( ) + - * / % &].each do |t|
        expect(s.next_token).to eq(Token.new(t, Scanner::SYMBOLS[t], 1))
      end
    end

    it "recognizes ambiguous symbols" do
      s = Scanner.new("= < <= == != >= >")
      %w[= < <= == != >= >].each do |t|
        expect(s.next_token).to eq(Token.new(t, Scanner::SYMBOLS[t], 1))
      end
    end

    it "recognizes ambiguous symbols" do
      s = Scanner.new("=<<===!=>=>")
      %w[= < <= == != >= >].each do |t|
        expect(s.next_token).to eq(Token.new(t, Scanner::SYMBOLS[t], 1))
      end
    end

    it "raises BplSyntaxErrors on '!' without a following '='" do
      expect_syntax_error("invalid symbol '!'", 1) do
        Scanner.new("!").next_token
      end
    end

    it "returns nil on end-of-file" do
      s = Scanner.new("a")
      expect(s.next_token).to eq(Token.new('a', :id, 1))
      expect(s.next_token).to eq(Token.new(nil, :eof, 1))
    end

    it "raises BplSyntaxErrors on erroneous characters" do
      expect_syntax_error("invalid symbol '#'", 1) do
        Scanner.new("#").next_token
      end
    end

    it "consumes whitespace properly" do
      s = Scanner.new("a bb\tc_c\rd1\ne")
      %w[a bb c_c d1].each do |t|
        expect(s.next_token).to eq(Token.new(t, :id, 1))
      end
      expect(s.next_token).to eq(Token.new('e', :id, 2))
    end

    it "bypasses comments" do
      s = Scanner.new("a/*this is a comment*/bb/*this is another comment*/c_c")
      %w[a bb c_c].each do |t|
        expect(s.next_token).to eq(Token.new(t, :id, 1))
      end
    end

    it "bypasses multi-line comments and handles line-counting properly" do
      s = Scanner.new("a/*this is a\nmulti-line comment*/bb")
      expect(s.next_token).to eq(Token.new('a', :id, 1))
      expect(s.next_token).to eq(Token.new('bb', :id, 2))
    end

    it "bypasses pathalogical comments" do
      s = Scanner.new(" /*this is a beginning comment*/a/**** /**/bb/**/c_c/*this is the last comment*/  ")
      %w[a bb c_c].each do |t|
        expect(s.next_token).to eq(Token.new(t, :id, 1))
      end
      expect(s.next_token).to eq(Token.new(nil, :eof, 1))
    end

    it "raises BplSyntaxErrors on unterminated comments" do
      expect_syntax_error("unterminated comment", 1) do
        Scanner.new("/*").next_token
      end
    end

    it "raises BplSyntaxErrors on unterminated multi-line comments" do
      expect_syntax_error("unterminated comment", 1) do
        Scanner.new("/*\n\n").next_token
      end
    end

    it "provides line numbers" do
      s = Scanner.new("a\nbb")
      expect(s.next_token).to eq(Token.new('a', :id, 1))
      expect(s.next_token).to eq(Token.new('bb', :id, 2))
    end

    context "when raising BplSyntaxErrors" do
      it "assigns correct line" do
        expect_syntax_error("invalid symbol '#'", 3) do
          s = Scanner.new("\na\na #")
          3.times do
            s.next_token
          end
        end
      end
    end
  end

  describe "#current_token" do
    it "returns the current token" do
      s = Scanner.new("a bb c_c d1")
      %w[a bb c_c d1].each do |t|
        s.next_token
        expect(s.current_token).to eq(Token.new(t, :id, 1))
      end
    end

    it "returns nil before calling next_token" do
      s = Scanner.new("a bb c_c d1")
      expect(s.current_token).to be_nil
    end
  end

  it "scans ex1.bpl properly" do
    s = Scanner.new(File.new(EX1_FNAME))
    EX1_TOKENS.each do |t|
      expect(s.next_token).to eq(t)
      expect(s.current_token).to eq(t)
    end
  end
end
