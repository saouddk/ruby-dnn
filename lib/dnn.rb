if defined? Cumo
  Xumo = Cumo
else
  require "numo/narray"
  Xumo = Numo
end

Xumo::SFloat.srand(rand(2**64))

module DNN; end

require_relative "dnn/version"
require_relative "dnn/core/error"
require_relative "dnn/core/model"
require_relative "dnn/core/initializers"
require_relative "dnn/core/layers"
require_relative "dnn/core/activations"
require_relative "dnn/core/cnn_layers"
require_relative "dnn/core/rnn_layers"
require_relative "dnn/core/optimizers"
require_relative "dnn/core/util"
