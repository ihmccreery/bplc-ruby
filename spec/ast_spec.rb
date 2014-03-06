require 'spec_helper'

describe Ast::Token do
  describe "#==" do
    it "correctly identifies equal Ast::Tokens" do
      expect(Ast::Token.new('a', :id, 1)).to eq(Ast::Token.new('a', :id, 1))
    end

    it "correctly identifies unequal Ast::Tokens" do
      expect(Ast::Token.new('b', :id, 1)).not_to eq(Ast::Token.new('a', :id, 1))
      expect(Ast::Token.new('1', :num, 1)).not_to eq(Ast::Token.new('a', :id, 1))
      expect(Ast::Token.new('a', :id, 2)).not_to eq(Ast::Token.new('a', :id, 1))
    end
  end
end
