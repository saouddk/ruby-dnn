require "test_helper"

include DNN
include MergeLayers
include Activations
include Optimizers
include Initializers
include Regularizers

class TestAdd < MiniTest::Unit::TestCase
  def test_forward
    add = Add.new
    y = add.forward(Numo::SFloat[1, 2], Numo::SFloat[3, 4])
    assert_equal Numo::SFloat[4, 6], y.round(4)
  end

  def test_backward
    add = Add.new
    add.forward(Numo::SFloat[1, 2], Numo::SFloat[3, 4])
    dx1, dx2 = add.backward(Numo::SFloat[1, 2])
    assert_equal Numo::SFloat[1, 2], dx1
    assert_equal Numo::SFloat[1, 2], dx2
  end
end


class TestMul < MiniTest::Unit::TestCase
  def test_forward
    mul = Mul.new
    y = mul.forward(Numo::SFloat[1, 2], Numo::SFloat[3, 4])
    assert_equal Numo::SFloat[3, 8], y.round(4)
  end

  def test_backward
    mul = Mul.new
    mul.forward(Numo::SFloat[1, 2], Numo::SFloat[3, 4])
    dx1, dx2 = mul.backward(Numo::SFloat[1, 2])
    assert_equal Numo::SFloat[3, 8], dx1
    assert_equal Numo::SFloat[1, 4], dx2
  end
end


class TestConcatenate < MiniTest::Unit::TestCase
  def test_forward
    con = Concatenate.new
    y = con.forward(Numo::SFloat[[1, 2]], Numo::SFloat[[3, 4]])
    assert_equal Numo::SFloat[[1, 2, 3, 4]], y.round(4)
  end

  def test_backward
    con = Concatenate.new
    con.forward(Numo::SFloat[[1, 2]], Numo::SFloat[[3, 4]])
    dx1, dx2 = con.backward(Numo::SFloat[[5, 6, 7, 8]])
    assert_equal Numo::SFloat[[5, 6]], dx1
    assert_equal Numo::SFloat[[7, 8]], dx2
  end
end