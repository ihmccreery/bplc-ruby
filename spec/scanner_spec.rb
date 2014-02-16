require 'spec_helper'

SCANNER_TEST_FILENAME = "spec/scanner_test.bpl"

describe Scanner do
  describe "#initialize" do
    it "can be constructed from a String" do
      expect(Scanner.new("1")).to be_a Scanner
    end

    it "can be constructed from a File" do
      expect(Scanner.new(File.new(SCANNER_TEST_FILENAME))).to be_a Scanner
    end

    it "can be constructed from a stream" do
      expect(Scanner.new(open(SCANNER_TEST_FILENAME))).to be_a Scanner
    end
  end
end
