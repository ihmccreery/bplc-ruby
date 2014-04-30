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
    it "compiles a valid program" do
      expect{Bplc.new(EX1_FNAME).compile(StringIO.new)}.not_to raise_error
      expect{Bplc.new(EX2_FNAME).compile(StringIO.new)}.not_to raise_error
      expect{Bplc.new(EX3_FNAME).compile(StringIO.new)}.not_to raise_error
    end

    # TODO there's got to be a better way to do this
    it "properly compiles a program to print integers and strings" do
      expect(compile_and_run("printing.bpl")).to eq("34 72 Hello, world! Argh! \n")
    end

    it "properly compiles a program with arithmetic" do
      expect(compile_and_run("arithmetic.bpl")).to eq("10 20 30 40 50 -10 -20 -30 -40 -50 ")
    end

    it "raises an syntax error compiling an invalid program" do
      expect_error_output("BplSyntaxError", "expected semicolon, got int", 5, "\tint y;\n") do
        Bplc.new(EX_BAD_SYNTAX_FNAME).compile(StringIO.new)
      end
    end

    it "raises an declaration error compiling an invalid program" do
      expect_error_output("BplDeclarationError", "undeclared variable x", 4, "\tx + 5;\n") do
        Bplc.new(EX_BAD_DECLARATION_FNAME).compile(StringIO.new)
      end
    end

    it "raises an type error compiling an invalid program" do
      expect_error_output("BplTypeError", "invalid lhs: cannot plus string", 5, "\tx + 5;\n") do
        Bplc.new(EX_BAD_TYPE_FNAME).compile(StringIO.new)
      end
    end
  end
end
