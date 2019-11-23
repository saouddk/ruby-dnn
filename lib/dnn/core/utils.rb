module DNN
  # This module provides utility functions.
  module Utils
    # Categorize labels into "num_classes" classes.
    # @param [Numo::SFloat] y Label data.
    # @param [Numo::SFloat] num_classes Number of classes to classify.
    # @param [Class] narray_type Type of Numo::Narray data after classification.
    def self.to_categorical(y, num_classes, narray_type = nil)
      narray_type ||= y.class
      y2 = narray_type.zeros(y.shape[0], num_classes)
      y.shape[0].times do |i|
        y2[i, y[i]] = 1
      end
      y2
    end

    # Convert hash to an object.
    def self.hash_to_obj(hash)
      return nil if hash == nil
      dnn_class = DNN.const_get(hash[:class])
      dnn_class.from_hash(hash)
    end

    # Return the result of the sigmoid function.
    def self.sigmoid(x)
      Layers::Sigmoid.new.forward(x)
    end

    # Return the result of the softmax function.
    def self.softmax(x)
      Losses::SoftmaxCrossEntropy.softmax(x)
    end

    # Perform numerical differentiation.
    def self.numerical_grad(x, func)
      (func.(x + 1e-7) - func.(x)) / 1e-7
    end
  end
end
