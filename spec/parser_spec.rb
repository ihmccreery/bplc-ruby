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

  # TODO
  # it "parses ex1.bpl properly" do
  #   expect(Parser.new(Scanner.new(File.new(EX1_FNAME))).parse).to be_a Ast
  # end
end
