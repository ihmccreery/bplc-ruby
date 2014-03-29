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

  it "properly nests arithmetic expressions" do
    p = get_body("x + y * z - w / v;").statements[0].expression.e

    # p:
    #   add_op: -
    #   e:
    #     add_op: +
    #     e:
    #       add_op: nil
    #       e: nil
    #       t:
    #         mul_op: nil
    #         t: nil
    #         f: x
    #     t:
    #       mul_op: *
    #       t:
    #         mul_op: nil
    #         t: nil
    #         f: y
    #       f: z
    #   t:
    #     mul_op: /
    #     t:
    #       mul_op: nil
    #       t: nil
    #       f: w
    #     f: v
    y_times_z = p.e.t
    w_over_v = p.t
    x_plus_y_z = p.e
    minus = p

    expect(y_times_z.mul_op.type).to eq(:asterisk)
    expect(w_over_v.mul_op.type).to eq(:slash)
    expect(x_plus_y_z.add_op.type).to eq(:plus)
    expect(minus.add_op.type).to eq(:minus)

    x = p.e.e.t.f
    y = p.e.t.t.f
    z = p.e.t.f
    w = p.t.t.f
    v = p.t.f

    expect(x.factor.id.value).to eq("x")
    expect(y.factor.id.value).to eq("y")
    expect(z.factor.id.value).to eq("z")
    expect(w.factor.id.value).to eq("w")
    expect(v.factor.id.value).to eq("v")
  end

  it "parses ex1.bpl properly" do
    expect(Parser.new(Scanner.new(File.new(EX1_FNAME))).parse).to be_a Ast
  end
end
