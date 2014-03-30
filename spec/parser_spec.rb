require 'spec_helper'

describe Parser do
  let(:p) { Parser.new(Scanner.new("int x;")) }

  describe "#initialize" do
    it "can be constructed from a Scanner" do
      expect(p).to be_a Parser
    end
  end

  describe "#parse" do
    it "returns an Ast" do
      expect(p.parse).to be_a Ast
    end

    it "can be called multiple times" do
      expect(p.parse).to eq(p.parse)
    end
  end

  describe "building AssignmentExps" do
    it "properly forms AssignmentExps"
    it "chains AssignmentExps"
    it "raises SyntaxErrors on bad lhss"
  end

  describe "order of operations" do
    it "properly nests AssignmentExps"
    it "properly nests RelExps"
    it "properly nests AddExps and MulExps"
    it "properly nests NegExps"
    it "properly nests VarExps"
    it "raises errors on improperly nested variable expressions"
    it "properly nests LitExps"
    it "properly nests parenthesized Exps"
  end

  it "parses ex1.bpl properly" do
    expect(Parser.new(Scanner.new(File.new(EX1_FNAME))).parse).to be_a Ast
  end
end
