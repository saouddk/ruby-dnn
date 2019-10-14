require "test_helper"

include DNN::Layers
include DNN::Optimizers
include DNN::Losses
include DNN::Regularizers

class TestRNN < MiniTest::Unit::TestCase
  def test_initialize
    rnn = RNN.new(64, stateful: true, return_sequences: false,
                  weight_initializer: RandomUniform.new,
                  recurrent_weight_initializer: RandomUniform.new,
                  bias_initializer: RandomUniform.new,
                  weight_regularizer: L1.new,
                  recurrent_weight_regularizer: L2.new,
                  bias_regularizer: L1L2.new)
    assert_equal 64, rnn.num_nodes
    assert_equal true, rnn.stateful
    assert_equal false, rnn.return_sequences
  end

  def test_build
    rnn = RNN.new(64, return_sequences: false)
    rnn.build([16, 64])
    assert_equal 16, rnn.instance_variable_get(:@time_length)
  end

  def test_output_shape
    rnn = RNN.new(64)
    rnn.build([16, 64])
    assert_equal [16, 64], rnn.output_shape
  end

  def test_output_shape2
    rnn = RNN.new(64, return_sequences: false)
    rnn.build([16, 64])
    assert_equal [64], rnn.output_shape
  end

  def test_reset_state
    rnn = RNN.new(64)
    rnn.build([16, 64])
    rnn.hidden.data = Numo::SFloat.ones(16, 64)
    rnn.reset_state
    assert_equal Numo::SFloat.zeros(16, 64), rnn.hidden.data
  end

  def test_to_hash
    rnn = RNN.new(64, stateful: true, return_sequences: false, use_bias: false,
                  weight_regularizer: L1.new, recurrent_weight_regularizer: L2.new, bias_regularizer: L1L2.new)
    expected_hash = {
      class: "DNN::Layers::RNN",
      name: nil,
      num_nodes: 64,
      weight_initializer: rnn.weight_initializer.to_hash,
      recurrent_weight_initializer: rnn.recurrent_weight_initializer.to_hash,
      bias_initializer: rnn.bias_initializer.to_hash,
      weight_regularizer: rnn.weight_regularizer.to_hash,
      recurrent_weight_regularizer: rnn.recurrent_weight_regularizer.to_hash,
      bias_regularizer: rnn.bias_regularizer.to_hash,
      use_bias: false,
      stateful: true,
      return_sequences: false,
    }
    assert_equal expected_hash, rnn.to_hash
  end

  def test_regularizers
    rnn = RNN.new(1, weight_regularizer: L1.new,
                       recurrent_weight_regularizer: L2.new,
                       bias_regularizer: L1L2.new)
    rnn.build([1, 10])
    assert_kind_of L1, rnn.regularizers[0]
    assert_kind_of L2, rnn.regularizers[1]
    assert_kind_of L1L2, rnn.regularizers[2]
  end

  def test_regularizers2
    rnn = RNN.new(1)
    rnn.build([1, 10])
    assert_equal [], rnn.regularizers
  end

  def test_get_params
    rnn = RNN.new(1)
    rnn.build([1, 10])
    expected_hash = {
      weight: rnn.weight,
      recurrent_weight: rnn.recurrent_weight,
      bias: rnn.bias,
      hidden: rnn.hidden,
    }
    assert_equal expected_hash, rnn.get_params
  end
end



class TestSimpleRNNDense < MiniTest::Unit::TestCase
  def test_forward
    x = Numo::SFloat.new(1, 64).seq
    h = Numo::SFloat.new(1, 16).seq
    w = DNN::Param.new
    w.data = Numo::SFloat.new(64, 16).fill(1)
    w2 = DNN::Param.new
    w2.data = Numo::SFloat.new(16, 16).fill(1)
    b = DNN::Param.new
    b.data = Numo::SFloat.new(16).fill(0)

    dense = SimpleRNNDense.new(w, w2, b, Tanh.new)
    assert_equal [1, 16], dense.forward(x, h).shape
  end

  def test_backward
    x = Numo::SFloat.new(1, 64).seq
    h = Numo::SFloat.new(1, 16).seq
    dh2 = Numo::SFloat.new(2, 16).seq[1, false].reshape(1, 16)
    w = DNN::Param.new
    w.data = Numo::SFloat.new(64, 16).fill(1)
    w.grad = 0
    w2 = DNN::Param.new
    w2.data = Numo::SFloat.new(16, 16).fill(1)
    w2.grad = 0
    b = DNN::Param.new
    b.data = Numo::SFloat.new(16).fill(0)
    b.grad = 0

    dense = SimpleRNNDense.new(w, w2, b, Tanh.new)
    dense.forward(x, h)
    dx, dh = dense.backward(dh2)
    assert_equal [1, 64], dx.shape
    assert_equal [1, 16], dh.shape
  end

  def test_backward2
    x = Numo::SFloat.new(1, 64).seq
    h = Numo::SFloat.new(1, 16).seq
    dh2 = Numo::SFloat.new(2, 16).seq[1, false].reshape(1, 16)
    w = DNN::Param.new
    w.data = Numo::SFloat.new(64, 16).fill(1)
    w.grad = 0
    w2 = DNN::Param.new
    w2.data = Numo::SFloat.new(16, 16).fill(1)
    w2.grad = 0

    dense = SimpleRNNDense.new(w, w2, nil, Tanh.new)
    dense.forward(x, h)
    dense.backward(dh2)
    assert_nil dense.instance_variable_get(:@bias)
  end

  def test_backward3
    x = Numo::SFloat.new(1, 64).seq
    h = Numo::SFloat.new(1, 16).seq
    dh2 = Numo::SFloat.new(2, 16).seq[1, false].reshape(1, 16)
    w = DNN::Param.new
    w.data = Numo::SFloat.new(64, 16).fill(1)
    w.grad = 0
    w2 = DNN::Param.new
    w2.data = Numo::SFloat.new(16, 16).fill(1)
    w2.grad = 0
    b = DNN::Param.new
    b.data = Numo::SFloat.new(16).fill(0)
    b.grad = 0

    dense = SimpleRNNDense.new(w, w2, b, Tanh.new)
    dense.trainable = false
    dense.forward(x, h)
    dense.backward(dh2)
    assert_equal 0, dense.instance_variable_get(:@weight).grad
    assert_equal 0, dense.instance_variable_get(:@recurrent_weight).grad
    assert_equal 0, dense.instance_variable_get(:@bias).grad
  end
end


class TestSimpleRNN < MiniTest::Unit::TestCase
  
  def test_from_hash
    hash = {
      class: "DNN::Layers::SimpleRNN",
      num_nodes: 64,
      weight_initializer: RandomUniform.new.to_hash,
      recurrent_weight_initializer: RandomUniform.new.to_hash,
      bias_initializer: RandomUniform.new.to_hash,
      weight_regularizer: L1.new.to_hash,
      recurrent_weight_regularizer: L2.new.to_hash,
      bias_regularizer: L1L2.new.to_hash,
      use_bias: false,
      stateful: true,
      return_sequences: false,
      activation: ReLU.new.to_hash,
    }
    rnn = SimpleRNN.from_hash(hash)
    assert_equal 64, rnn.num_nodes
    assert_kind_of RandomUniform, rnn.weight_initializer
    assert_kind_of RandomUniform, rnn.recurrent_weight_initializer
    assert_kind_of RandomUniform, rnn.bias_initializer
    assert_kind_of L1, rnn.weight_regularizer
    assert_kind_of L2, rnn.recurrent_weight_regularizer
    assert_kind_of L1L2, rnn.bias_regularizer
    assert_equal false, rnn.use_bias
    assert_equal true, rnn.stateful
    assert_equal false, rnn.return_sequences
    assert_kind_of ReLU, rnn.activation
  end

  def test_forward
    x = Numo::SFloat.new(1, 16, 64).seq
    rnn = SimpleRNN.new(64)
    rnn.build([16, 64])
    assert_equal [1, 16, 64], rnn.forward(x).shape
  end

  def test_forward2
    x = Numo::SFloat.new(1, 16, 64).seq
    rnn = SimpleRNN.new(64, stateful: true)
    rnn.build([16, 64])
    rnn.forward(x)
    assert_equal [1, 16, 64], rnn.forward(x).shape
  end

  def test_backward
    x = Numo::SFloat.new(1, 16, 64).seq
    y = Numo::SFloat.new(1, 16, 64).seq
    rnn = SimpleRNN.new(64)
    rnn.build([16, 64])
    rnn.forward(x)
    assert_equal [1, 16, 64], rnn.backward(y).shape
  end

  def test_backward2
    x = Numo::SFloat.new(1, 16, 64).seq
    y = Numo::SFloat.new(1, 16, 64).seq
    rnn = SimpleRNN.new(64, use_bias: false)
    rnn.build([16, 64])
    rnn.forward(x)
    rnn.backward(y)
    assert_nil rnn.bias
  end

  def test_backward3
    x = Numo::SFloat.new(1, 16, 64).seq
    y = Numo::SFloat.new(1, 16, 64).seq
    rnn = SimpleRNN.new(64)
    rnn.trainable = false
    rnn.build([16, 64])
    rnn.forward(x)
    rnn.backward(y)
    assert_equal Numo::SFloat[0], rnn.weight.grad
    assert_equal Numo::SFloat[0], rnn.recurrent_weight.grad
    assert_equal Numo::SFloat[0], rnn.bias.grad
  end

  def test_backward4
    x = Numo::SFloat.new(1, 16, 64).seq
    y = Numo::SFloat.new(1, 16, 64).seq
    rnn = SimpleRNN.new(64, stateful: true)
    rnn.build([16, 64])
    rnn.forward(x)
    rnn.backward(y)
    rnn.forward(x)
    assert_equal [1, 16, 64], rnn.backward(y).shape
  end

  def test_to_hash
    rnn = SimpleRNN.new(64, stateful: true, return_sequences: false, use_bias: false, activation: ReLU.new,
                        weight_regularizer: L1.new, recurrent_weight_regularizer: L2.new, bias_regularizer: L1L2.new)
    expected_hash = {
      class: "DNN::Layers::SimpleRNN",
      name: nil,
      num_nodes: 64,
      weight_initializer: rnn.weight_initializer.to_hash,
      recurrent_weight_initializer: rnn.recurrent_weight_initializer.to_hash,
      bias_initializer: rnn.bias_initializer.to_hash,
      weight_regularizer: rnn.weight_regularizer.to_hash,
      recurrent_weight_regularizer: rnn.recurrent_weight_regularizer.to_hash,
      bias_regularizer: rnn.bias_regularizer.to_hash,
      use_bias: false,
      stateful: true,
      return_sequences: false,
      activation: rnn.activation.to_hash,
    }
    assert_equal expected_hash, rnn.to_hash
  end

  def test_build
    rnn = SimpleRNN.new(64, weight_initializer: Const.new(2),
                            recurrent_weight_initializer: Const.new(2),
                            bias_initializer: Const.new(2))
    rnn.build([16, 32])
    assert_equal Numo::SFloat.new(32, 64).fill(2), rnn.weight.data
    assert_equal Numo::SFloat.new(64, 64).fill(2), rnn.recurrent_weight.data
    assert_equal Numo::SFloat.new(64).fill(2), rnn.bias.data
    assert_kind_of SimpleRNNDense, rnn.instance_variable_get(:@layers)[15]
  end
end


class TestLSTMDense < MiniTest::Unit::TestCase
  def test_forward
    x = Numo::SFloat.new(1, 64).seq
    h = Numo::SFloat.new(1, 16).seq
    c = Numo::SFloat.new(1, 16).seq
    w = DNN::Param.new
    w.data = Numo::SFloat.new(64, 16 * 4).fill(1)
    w2 = DNN::Param.new
    w2.data = Numo::SFloat.new(16, 16 * 4).fill(1)
    b = DNN::Param.new
    b.data = Numo::SFloat.new(16 * 4).fill(0)

    dense = LSTMDense.new(w, w2, b)
    h2, c2 = dense.forward(x, h, c)
    assert_equal [1, 16], h2.shape
    assert_equal [1, 16], c2.shape
  end

  def test_backward
    x = Numo::SFloat.new(1, 64).seq
    h = Numo::SFloat.new(1, 16).seq
    dh2 = Numo::SFloat.new(1, 16).seq
    c = Numo::SFloat.new(1, 16).seq
    dc2 = Numo::SFloat.new(1, 16).seq
    w = DNN::Param.new
    w.data = Numo::SFloat.new(64, 16 * 4).fill(1)
    w.grad = 0
    w2 = DNN::Param.new
    w2.data = Numo::SFloat.new(16, 16 * 4).fill(1)
    w2.grad = 0
    b = DNN::Param.new
    b.data = Numo::SFloat.new(16 * 4).fill(0)
    b.grad = 0

    dense = LSTMDense.new(w, w2, b)
    dense.forward(x, h, c)
    dx, dh, dc = dense.backward(dh2, dc2)
    assert_equal [1, 64], dx.shape
    assert_equal [1, 16], dh.shape
    assert_equal [1, 16], dc.shape
  end

  def test_backward2
    x = Numo::SFloat.new(1, 64).seq
    h = Numo::SFloat.new(1, 16).seq
    dh2 = Numo::SFloat.new(1, 16).seq
    c = Numo::SFloat.new(1, 16).seq
    dc2 = Numo::SFloat.new(1, 16).seq
    w = DNN::Param.new
    w.data = Numo::SFloat.new(64, 16 * 4).fill(1)
    w.grad = 0
    w2 = DNN::Param.new
    w2.data = Numo::SFloat.new(16, 16 * 4).fill(1)
    w2.grad = 0

    dense = LSTMDense.new(w, w2, nil)
    dense.forward(x, h, c)
    dense.backward(dh2, dc2)
    assert_nil dense.instance_variable_get(:@bias)
  end

  def test_backward3
    x = Numo::SFloat.new(1, 64).seq
    h = Numo::SFloat.new(1, 16).seq
    dh2 = Numo::SFloat.new(1, 16).seq
    c = Numo::SFloat.new(1, 16).seq
    dc2 = Numo::SFloat.new(1, 16).seq
    w = DNN::Param.new
    w.data = Numo::SFloat.new(64, 16 * 4).fill(1)
    w.grad = 0
    w2 = DNN::Param.new
    w2.data = Numo::SFloat.new(16, 16 * 4).fill(1)
    w2.grad = 0
    b = DNN::Param.new
    b.data = Numo::SFloat.new(16 * 4).fill(0)
    b.grad = 0

    dense = LSTMDense.new(w, w2, b)
    dense.trainable = false
    dense.forward(x, h, c)
    dense.backward(dh2, dc2)
    assert_equal 0, dense.instance_variable_get(:@weight).grad
    assert_equal 0, dense.instance_variable_get(:@recurrent_weight).grad
    assert_equal 0, dense.instance_variable_get(:@bias).grad
  end
end


class TestLSTM < MiniTest::Unit::TestCase
  
  def test_from_hash
    hash = {
      class: "DNN::Layers::LSTM",
      num_nodes: 64,
      weight_initializer: RandomUniform.new.to_hash,
      recurrent_weight_initializer: RandomUniform.new.to_hash,
      bias_initializer: RandomUniform.new.to_hash,
      weight_regularizer: L1.new.to_hash,
      recurrent_weight_regularizer: L2.new.to_hash,
      bias_regularizer: L1L2.new.to_hash,
      use_bias: false,
      stateful: true,
      return_sequences: false,
    }
    lstm = LSTM.from_hash(hash)
    assert_equal 64, lstm.num_nodes
    assert_kind_of RandomUniform, lstm.weight_initializer
    assert_kind_of RandomUniform, lstm.recurrent_weight_initializer
    assert_kind_of RandomUniform, lstm.bias_initializer
    assert_kind_of L1, lstm.weight_regularizer
    assert_kind_of L2, lstm.recurrent_weight_regularizer
    assert_kind_of L1L2, lstm.bias_regularizer
    assert_equal false, lstm.use_bias
    assert_equal true, lstm.stateful
    assert_equal false, lstm.return_sequences
  end

  def test_forward
    x = Numo::SFloat.new(1, 16, 64).seq
    lstm = LSTM.new(64)
    lstm.build([16, 64])
    assert_equal [1, 16, 64], lstm.forward(x).shape
  end

  def test_forward2
    x = Numo::SFloat.new(1, 16, 64).seq
    lstm = LSTM.new(64, stateful: true)
    lstm.build([16, 64])
    lstm.forward(x)
    assert_equal [1, 16, 64], lstm.forward(x).shape
  end

  def test_backward
    x = Numo::SFloat.new(1, 16, 64).seq
    y = Numo::SFloat.new(1, 16, 64).seq
    lstm = LSTM.new(64)
    lstm.build([16, 64])
    lstm.forward(x)
    assert_equal [1, 16, 64], lstm.backward(y).shape
  end

  def test_backward2
    x = Numo::SFloat.new(1, 16, 64).seq
    y = Numo::SFloat.new(1, 16, 64).seq
    lstm = LSTM.new(64, use_bias: false)
    lstm.build([16, 64])
    lstm.forward(x)
    lstm.backward(y)
    assert_nil lstm.bias
  end

  def test_backward3
    x = Numo::SFloat.new(1, 16, 64).seq
    y = Numo::SFloat.new(1, 16, 64).seq
    lstm = LSTM.new(64)
    lstm.trainable = false
    lstm.build([16, 64])
    lstm.forward(x)
    lstm.backward(y)
    assert_equal Numo::SFloat[0], lstm.weight.grad
    assert_equal Numo::SFloat[0], lstm.recurrent_weight.grad
    assert_equal Numo::SFloat[0], lstm.bias.grad
  end

  def test_backward4
    x = Numo::SFloat.new(1, 16, 64).seq
    y = Numo::SFloat.new(1, 16, 64).seq
    lstm = LSTM.new(64, stateful: true)
    lstm.build([16, 64])
    lstm.forward(x)
    lstm.backward(y)
    lstm.forward(x)
    assert_equal [1, 16, 64], lstm.backward(y).shape
  end

  def test_reset_state
    lstm = LSTM.new(64)
    lstm.build([16, 64])
    lstm.hidden.data = Numo::SFloat.ones(16, 64)
    lstm.cell.data = Numo::SFloat.ones(16, 64)
    lstm.reset_state
    assert_equal Numo::SFloat.zeros(16, 64), lstm.hidden.data
    assert_equal Numo::SFloat.zeros(16, 64), lstm.cell.data
  end

  def test_build
    lstm = LSTM.new(64, weight_initializer: Const.new(2),
                    recurrent_weight_initializer: Const.new(2),
                    bias_initializer: Const.new(2))
    lstm.build([16, 32])
    assert_equal Numo::SFloat.new(32, 256).fill(2), lstm.weight.data
    assert_equal Numo::SFloat.new(64, 256).fill(2), lstm.recurrent_weight.data
    assert_equal Numo::SFloat.new(256).fill(2), lstm.bias.data
    assert_kind_of LSTMDense, lstm.instance_variable_get(:@layers)[15]
  end

  def test_to_hash
    lstm = LSTM.new(64, stateful: true, return_sequences: false, use_bias: false,
                    weight_regularizer: L1.new, recurrent_weight_regularizer: L2.new, bias_regularizer: L1L2.new)
    expected_hash = {
      class: "DNN::Layers::LSTM",
      name: nil,
      num_nodes: 64,
      weight_initializer: lstm.weight_initializer.to_hash,
      recurrent_weight_initializer: lstm.recurrent_weight_initializer.to_hash,
      bias_initializer: lstm.bias_initializer.to_hash,
      weight_regularizer: lstm.weight_regularizer.to_hash,
      recurrent_weight_regularizer: lstm.recurrent_weight_regularizer.to_hash,
      bias_regularizer: lstm.bias_regularizer.to_hash,
      use_bias: false,
      stateful: true,
      return_sequences: false,
    }
    assert_equal expected_hash, lstm.to_hash
  end

  def test_get_params
    lstm = LSTM.new(1)
    lstm.build([1, 10])
    expected_hash = {
      weight: lstm.weight,
      recurrent_weight: lstm.recurrent_weight,
      bias: lstm.bias,
      hidden: lstm.hidden,
      cell: lstm.cell,
    }
    assert_equal expected_hash, lstm.get_params
  end
end


class TestGRUDense < MiniTest::Unit::TestCase
  def test_forward
    x = Numo::SFloat.new(1, 64).seq
    h = Numo::SFloat.new(1, 16).seq
    w = DNN::Param.new
    w.data = Numo::SFloat.new(64, 16 * 3).fill(1)
    w2 = DNN::Param.new
    w2.data = Numo::SFloat.new(16, 16 * 3).fill(1)
    b = DNN::Param.new
    b.data = Numo::SFloat.new(16 * 3).fill(0)

    dense = GRUDense.new(w, w2, b)
    assert_equal [1, 16], dense.forward(x, h).shape
  end

  def test_backward
    x = Numo::SFloat.new(1, 64).seq
    h = Numo::SFloat.new(1, 16).seq
    dh2 = Numo::SFloat.new(2, 16).seq[1, false].reshape(1, 16)
    w = DNN::Param.new
    w.data = Numo::SFloat.new(64, 16 * 3).fill(1)
    w.grad = 0
    w2 = DNN::Param.new
    w2.data = Numo::SFloat.new(16, 16 * 3).fill(1)
    w2.grad = 0
    b = DNN::Param.new
    b.data = Numo::SFloat.new(16 * 3).fill(0)
    b.grad = 0
    dense = GRUDense.new(w, w2, b)
    dense.forward(x, h)
    dx, dh = dense.backward(dh2)
    assert_equal [1, 64], dx.shape
    assert_equal [1, 16], dh.shape
  end

  def test_backward2
    x = Numo::SFloat.new(1, 64).seq
    h = Numo::SFloat.new(1, 16).seq
    dh2 = Numo::SFloat.new(2, 16).seq[1, false].reshape(1, 16)
    w = DNN::Param.new
    w.data = Numo::SFloat.new(64, 16 * 3).fill(1)
    w.grad = 0
    w2 = DNN::Param.new
    w2.data = Numo::SFloat.new(16, 16 * 3).fill(1)
    w2.grad = 0
    b = DNN::Param.new
    b.data = Numo::SFloat.new(16 * 3).fill(0)
    b.grad = 0

    dense = GRUDense.new(w, w2, nil)
    dense.forward(x, h)
    dense.backward(dh2)
    assert_nil dense.instance_variable_get(:@bias)
  end

  def test_backward3
    x = Numo::SFloat.new(1, 64).seq
    h = Numo::SFloat.new(1, 16).seq
    dh2 = Numo::SFloat.new(2, 16).seq[1, false].reshape(1, 16)
    w = DNN::Param.new
    w.data = Numo::SFloat.new(64, 16 * 3).fill(1)
    w.grad = 0
    w2 = DNN::Param.new
    w2.data = Numo::SFloat.new(16, 16 * 3).fill(1)
    w2.grad = 0
    b = DNN::Param.new
    b.data = Numo::SFloat.new(16 * 3).fill(0)
    b.grad = 0
    dense = GRUDense.new(w, w2, b)
    dense.trainable = false
    dense.forward(x, h)
    dense.backward(dh2)
    assert_equal 0, dense.instance_variable_get(:@weight).grad
    assert_equal 0, dense.instance_variable_get(:@recurrent_weight).grad
    assert_equal 0, dense.instance_variable_get(:@bias).grad
  end
end


class TestGRU < MiniTest::Unit::TestCase
  def test_to_hash
    gru = GRU.new(64, stateful: true, return_sequences: false, use_bias: false,
                  weight_regularizer: L1.new, recurrent_weight_regularizer: L2.new, bias_regularizer: L1L2.new)
    expected_hash = {
      class: "DNN::Layers::GRU",
      name: nil,
      num_nodes: 64,
      weight_initializer: gru.weight_initializer.to_hash,
      recurrent_weight_initializer: gru.recurrent_weight_initializer.to_hash,
      bias_initializer: gru.bias_initializer.to_hash,
      weight_regularizer: gru.weight_regularizer.to_hash,
      recurrent_weight_regularizer: gru.recurrent_weight_regularizer.to_hash,
      bias_regularizer: gru.bias_regularizer.to_hash,
      use_bias: false,
      stateful: true,
      return_sequences: false,
    }
    assert_equal expected_hash, gru.to_hash
  end

  def test_build
    gru = GRU.new(64, weight_initializer: Const.new(2),
                  recurrent_weight_initializer: Const.new(2),
                  bias_initializer: Const.new(2))
    gru.build([16, 32])
    assert_equal Numo::SFloat.new(32, 192).fill(2), gru.weight.data
    assert_equal Numo::SFloat.new(64, 192).fill(2), gru.recurrent_weight.data
    assert_equal Numo::SFloat.new(192).fill(2), gru.bias.data
    assert_kind_of GRUDense, gru.instance_variable_get(:@layers)[15]
  end
end
