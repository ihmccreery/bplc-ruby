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

    describe "#is_type_specifier?" do
      it "returns true when Token is a type_specifier" do
        expect(Token.new('int', :int, 1).is_type_specifier?).to be_true
        expect(Token.new('void', :void, 1).is_type_specifier?).to be_true
        expect(Token.new('string', :string, 1).is_type_specifier?).to be_true
      end

      it "returns false when Token is not a type_specifier" do
        expect(Token.new('b', :id, 1).is_type_specifier?).to be_false
        expect(Token.new('1', :num, 1).is_type_specifier?).to be_false
      end
    end
  end
end
