require 'spec_helper'

describe Bplc do
  describe "#initialize" do
    it "can be constructed from a filename" do
      expect(Bplc.new(EX1_FNAME)).to be_a Bplc
    end

    it "raises an error on an invalid filename" do
      expect{Bplc.new(EX_FAKE_FNAME)}.to raise_error(Errno::ENOENT)
    end
  end

  describe "#compile" do
    it "assembles a valid program into an AST" do
      expect(Bplc.new(EX1_FNAME).compile).to be_a Ast
    end

    it "raises an syntax error compiling an invalid program" do
      expect_error_output("BplSyntaxError", "expected semicolon, got int", 5, "\tint y;\n") do
        Bplc.new(EX_BAD_SYNTAX_FNAME).compile
      end
    end

    it "raises an declaration error compiling an invalid program" do
      expect_error_output("BplDeclarationError", "undeclared variable x", 4, "\tx + 5;\n") do
        Bplc.new(EX_BAD_DECLARATION_FNAME).compile
      end
    end

    it "raises an type error compiling an invalid program" do
      expect_error_output("BplTypeError", "invalid lhs: cannot plus string", 5, "\tx + 5;\n") do
        Bplc.new(EX_BAD_TYPE_FNAME).compile
      end
    end
  end
end
