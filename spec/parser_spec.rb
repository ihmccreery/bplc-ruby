require 'spec_helper'
require 'ex1_tokens'

describe Parser do
  describe "#initialize" do
    it "can be constructed from a Scanner" do
      expect(Parser.new(Scanner.new("a"))).to be_a Parser
    end
  end

  describe "#parse" do
    it "should parse a type specificer" do
      parse = Parser.new(Scanner.new("int")).parse
      expect(parse).to be_a Parse::TypeSpecifier
    end
  end

  # TODO
  # it "parses ex1.bpl properly"
end
