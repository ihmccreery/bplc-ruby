require 'spec_helper'

describe Parser do
  describe "#initialize" do
    it "can be constructed from a Scanner" do
      expect(Parser.new(Scanner.new("int x;"))).to be_a Parser
    end
  end

  describe "#parse" do
    it "returns a Program that is also an Ast" do
      p = Parser.new(Scanner.new("int x;")).parse
      expect(p).to be_a Program
      expect(p).to be_a Ast
    end

    it "can be called multiple times" do
      p = Parser.new(Scanner.new("int x;"))
      expect(p.parse).to be_a Ast
      expect(p.parse).to be_a Ast
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

    expect(y_times_z.mul_op.token.type).to eq(:asterisk)
    expect(w_over_v.mul_op.token.type).to eq(:slash)
    expect(x_plus_y_z.add_op.token.type).to eq(:plus)
    expect(minus.add_op.token.type).to eq(:minus)

    x = p.e.e.t.f
    y = p.e.t.t.f
    z = p.e.t.f
    w = p.t.t.f
    v = p.t.f

    # TODO F shouldn't actually act this way
    expect(x.factor.token.value).to eq("x")
    # TODO F shouldn't actually act this way
    expect(y.factor.token.value).to eq("y")
    # TODO F shouldn't actually act this way
    expect(z.factor.token.value).to eq("z")
    # TODO F shouldn't actually act this way
    expect(w.factor.token.value).to eq("w")
    # TODO F shouldn't actually act this way
    expect(v.factor.token.value).to eq("v")
  end
end
