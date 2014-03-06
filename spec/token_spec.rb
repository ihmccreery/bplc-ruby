require 'spec_helper'

describe Token do
  describe "#==" do
    it "correctly identifies equal Tokens" do
      expect(Token.new('a', :id, 1)).to eq(Token.new('a', :id, 1))
    end

    it "correctly identifies unequal Tokens" do
      expect(Token.new('b', :id, 1)).not_to eq(Token.new('a', :id, 1))
      expect(Token.new('1', :num, 1)).not_to eq(Token.new('a', :id, 1))
      expect(Token.new('a', :id, 2)).not_to eq(Token.new('a', :id, 1))
    end
  end
end
