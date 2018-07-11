require "dnn"
require "dnn/lib/mnist"
#require "numo/linalg/autoloader"

include Numo
include DNN::Layers
include DNN::Activations
include DNN::Optimizers
Model = DNN::Model
MNIST = DNN::MNIST

x_train, y_train = MNIST.load_train
x_test, y_test = MNIST.load_test

x_train = SFloat.cast(x_train).reshape(x_train.shape[0], 784)
x_test = SFloat.cast(x_test).reshape(x_test.shape[0], 784)

x_train /= 255
x_test /= 255

y_train = DNN::Util.to_categorical(y_train, 10)
y_test = DNN::Util.to_categorical(y_test, 10)

model = Model.new

model << InputLayer.new(784)

model << Dense.new(256)
model << BatchNormalization.new
model << ReLU.new

model << Dense.new(256)
model << BatchNormalization.new
model << ReLU.new

model << Dense.new(10)
model << SoftmaxWithLoss.new

model.compile(RMSProp.new)

model.train(x_train, y_train, 10, batch_size: 100, test: [x_test, y_test])
