require "test_helper"

Utils = DNN::Utils

class TestUtils < MiniTest::Unit::TestCase
  def test_to_categorical
    y = Numo::NArray[0, 3]
    y2 = Utils.to_categorical(y, 5)
    assert_equal Numo::NArray[[1, 0, 0, 0, 0], [0, 0, 0, 1, 0]], y2
  end

  def test_to_categorical2
    y = Numo::NArray[0, 3]
    y2 = Utils.to_categorical(y, 5, Numo::SFloat)
    assert_kind_of Numo::SFloat, y2
  end

  def test_broadcast_to
    y = Numo::SFloat.new(1, 2, 3, 4).seq
    x = y.sum(axis: 2)
    x = DNN::Utils.broadcast_to(x, y.shape)
    assert_equal y.shape, x.shape
  end

  def test_hash_to_obj
    relu = Utils.hash_to_obj({class: "DNN::Layers::ReLU"})
    assert_kind_of ReLU, relu
  end

  def test_hash_to_obj2
    lrelu = Utils.hash_to_obj({class: "DNN::Layers::LeakyReLU", alpha: 0.2})
    assert_equal 0.2, lrelu.alpha
  end

  def test_sigmoid
    out = Utils.sigmoid(Numo::SFloat[0, 1])
    assert_equal Numo::SFloat[0.5, 0.7311], out.round(4)
  end

  def test_softmax
    out = Utils.softmax(Numo::SFloat[[0, 1, 2]])
    assert_equal Numo::SFloat[[0.09, 0.2447, 0.6652]], out.round(4)
  end
end
