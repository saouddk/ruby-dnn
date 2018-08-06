require "test_helper"

include Numo
include DNN::Layers
include DNN::Activations
include DNN::Optimizers
include DNN::Initializers
Util = DNN::Util
Model = DNN::Model

class TestInitializer < MiniTest::Unit::TestCase
  def test_init_param
    initializer = Initializer.new
    model = Model.new
    model << InputLayer.new(10)
    dense = Dense.new(10)
    model << dense
    model << IdentityMSE.new
    model.compile(SGD.new)
    zeros = SFloat.zeros(dense.params[:weight].shape)
    initializer.init_param(dense, :weight, zeros)
    assert_equal zeros, dense.params[:weight]
  end

  def test_to_hash
    initializer = Initializer.new
    hash = initializer.to_hash({mean: 0, std: 0.05})
    expected_hash = {
      name: "DNN::Initializers::Initializer",
      mean: 0,
      std: 0.05,
    }
    assert_equal expected_hash, hash
  end
end


class TestZeros < MiniTest::Unit::TestCase
  def test_init_param
    initializer = Zeros.new
    model = Model.new
    model << InputLayer.new(10)
    dense = Dense.new(10)
    model << dense
    model << IdentityMSE.new
    model.compile(SGD.new)
    zeros = SFloat.zeros(dense.params[:weight].shape)
    initializer.init_param(dense, :weight)
    assert_equal zeros, dense.params[:weight]
  end
end


class TestRandomNorm < MiniTest::Unit::TestCase
  def test_load_hash
    hash = {mean: 0, std: 0.1}
    initializer = RandomNormal.load_hash(hash)
    assert_equal 0, initializer.mean
    assert_equal 0.1, initializer.std
  end

  def test_initialize
    initializer = RandomNormal.new
    assert_equal 0, initializer.mean
    assert_equal 0.05, initializer.std
  end

  def test_init_param
    initializer = RandomNormal.new
    model = Model.new
    model << InputLayer.new(10)
    dense = Dense.new(10)
    model << dense
    model << IdentityMSE.new
    model.compile(SGD.new)
    initializer.init_param(dense, :weight)
    assert_kind_of SFloat, dense.params[:weight]
  end

  def test_to_hash
    initializer = RandomNormal.new
    expected_hash = {
      name: "DNN::Initializers::RandomNormal",
      mean: 0,
      std: 0.05,
    }
    assert_equal expected_hash, initializer.to_hash
  end
end


class TestXavier < MiniTest::Unit::TestCase
  def test_init_param
    initializer = Xavier.new
    model = Model.new
    model << InputLayer.new(10)
    dense = Dense.new(10)
    model << dense
    model << IdentityMSE.new
    model.compile(SGD.new)
    initializer.init_param(dense, :weight)
    assert_kind_of SFloat, dense.params[:weight]
  end
end


class TestHe < MiniTest::Unit::TestCase
  def test_init_param
    initializer = He.new
    model = Model.new
    model << InputLayer.new(10)
    dense = Dense.new(10)
    model << dense
    model << IdentityMSE.new
    model.compile(SGD.new)
    initializer.init_param(dense, :weight)
    assert_kind_of SFloat, dense.params[:weight]
  end
end