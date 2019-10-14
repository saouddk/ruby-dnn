require "dnn"
require "dnn/datasets/cifar10"
# If you use numo/linalg then please uncomment out.
# require "numo/linalg/autoloader"

include DNN::Models
include DNN::Layers
include DNN::Optimizers
include DNN::Losses
CIFAR10 = DNN::CIFAR10

x_train, y_train = CIFAR10.load_train
x_test, y_test = CIFAR10.load_test

x_train = Numo::SFloat.cast(x_train)
x_test = Numo::SFloat.cast(x_test)

x_train /= 255
x_test /= 255

y_train = DNN::Utils.to_categorical(y_train, 10, Numo::SFloat)
y_test = DNN::Utils.to_categorical(y_test, 10, Numo::SFloat)

model = Sequential.new

model << InputLayer.new([32, 32, 3])

model << Conv2D.new(16, 5, padding: true)
model << BatchNormalization.new
model << ReLU.new

model << Conv2D.new(16, 5, padding: true)
model << BatchNormalization.new
model << ReLU.new

model << MaxPool2D.new(2)

model << Conv2D.new(32, 5, padding: true)
model << BatchNormalization.new
model << ReLU.new

model << Conv2D.new(32, 5, padding: true)
model << BatchNormalization.new
model << ReLU.new

model << MaxPool2D.new(2)

model << Conv2D.new(64, 5, padding: true)
model << BatchNormalization.new
model << ReLU.new

model << Conv2D.new(64, 5, padding: true)
model << BatchNormalization.new
model << ReLU.new

model << Flatten.new

model << Dense.new(512)
model << BatchNormalization.new
model << ReLU.new
model << Dropout.new(0.5)

model << Dense.new(10)

model.setup(Adam.new, SoftmaxCrossEntropy.new)

model.train(x_train, y_train, 10, batch_size: 100, test: [x_test, y_test])
