require "dnn"

include DNN::Layers
include DNN::Activations
include DNN::Optimizers
include DNN::Losses
Model = DNN::Model
Utils = DNN::Utils

x = Numo::SFloat[[0, 0], [1, 0], [0, 1], [1, 1]]
y = Numo::SFloat[[0], [1], [1], [0]]

model = Model.new

model << InputLayer.new(2)
model << Dense.new(16)
model << ReLU.new
model << Dense.new(1)

model.compile(SGD.new, SigmoidCrossEntropy.new)

model.train(x, y, 20000, batch_size: 4, verbose: false)

p Utils.sigmoid(model.predict(x))
