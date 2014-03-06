require 'spec_helper'

describe Parser do
  describe "#initialize" do
    it "can be constructed from a Scanner" do
      expect(Parser.new(Scanner.new("a"))).to be_a Parser
    end
  end

  describe "#parse" do
    it "returns an Ast" do
      expect(Parser.new(Scanner.new("a")).parse).to be_a Ast
    end

    it "returns a Program" do
      p = Parser.new(Scanner.new("a")).parse
      expect(p).to be_a Program
    end

    context "a Program" do
      let(:p) { Parser.new(Scanner.new("a")).parse }

      it "has a DeclarationList" do
        expect(p.declaration_list).to be_a DeclarationList
      end
    end
  end
end
