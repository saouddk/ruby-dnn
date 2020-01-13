require "dnn"
require "dnn/datasets/mnist"
# If you use numo/linalg then please uncomment out.
# require "numo/linalg/autoloader"

include DNN::Models
include DNN::Layers
include DNN::Optimizers
include DNN::Losses
include DNN::Callbacks

EPOCHS = 3
BATCH_SIZE = 128

x_train, y_train = DNN::MNIST.load_train
x_test, y_test = DNN::MNIST.load_test

x_train = x_train.reshape(x_train.shape[0], 784)
x_test = x_test.reshape(x_test.shape[0], 784)

x_train = Numo::SFloat.cast(x_train) / 255
x_test = Numo::SFloat.cast(x_test) / 255

y_train = DNN::Utils.to_categorical(y_train, 10, Numo::SFloat)
y_test = DNN::Utils.to_categorical(y_test, 10, Numo::SFloat)

class MLP < Model
  def initialize
    super
    @l1 = Dense.new(256)
    @l2 = Dense.new(256)
    @l3 = Dense.new(10)
    @bn1 = BatchNormalization.new
    @bn2 = BatchNormalization.new
  end

  def forward(x)
    x = InputLayer.new(784).(x)
    x = @l1.(x)
    x = @bn1.(x)
    x = ReLU.(x)
    x = @l2.(x)
    x = @bn2.(x)
    x = ReLU.(x)
    x = @l3.(x)
    x
  end
end

model = MLP.new
model.setup(Adam.new, SoftmaxCrossEntropy.new)

# Add EarlyStopping callback for model.
# This callback is stop the training when test accuracy is over 0.9.
model.add_callback(EarlyStopping.new(:test_accuracy, 0.9))

model.train(x_train, y_train, EPOCHS, batch_size: BATCH_SIZE, test: [x_test, y_test])
