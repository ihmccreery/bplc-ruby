require 'spec_helper'
require 'ex1_tokens'

describe Parser do
  describe "#initialize" do
    it "can be constructed from a Scanner" do
      expect(Parser.new(Scanner.new("a"))).to be_a Parser
    end
  end

  # TODO this is hideous; I need to think about how to do this OO properly
  describe "#parse" do
    it "should parse a variable declaration" do
      parse = Parser.new(Scanner.new("int x;")).parse
      expect(parse).to be_a Parse::VariableDeclaration
      expect(parse.type_specifier).to be_a Parse::TypeSpecifier
      expect(parse.id).to be_a Parse::Id
      expect(parse.semicolon).to be_a Parse::Semicolon
    end
  end

  # TODO it "parses ex1.bpl properly"
end
