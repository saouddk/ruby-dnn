include DNN::Models
include DNN::Layers

class Generator < Model
  def initialize
    super
    @l1 = Dense.new(1024)
    @l2 = Dense.new(7 * 7 * 64)
    @l3 = Conv2DTranspose.new(64, 4, strides: 2, padding: true)
    @l4 = Conv2D.new(64, 4, padding: true)
    @l5 = Conv2DTranspose.new(32, 4, strides: 2, padding: true)
    @l6 = Conv2D.new(32, 4, padding: true)
    @l7 = Conv2D.new(1, 4, padding: true)
    @bn1 = BatchNormalization.new
    @bn2 = BatchNormalization.new
    @bn3 = BatchNormalization.new
    @bn4 = BatchNormalization.new
    @bn5 = BatchNormalization.new
    @bn6 = BatchNormalization.new
  end

  def forward(x)
    x = InputLayer.new(20).(x)
    x = @l1.(x)
    x = @bn1.(x)
    x = ReLU.(x)

    x = @l2.(x)
    x = @bn2.(x)
    x = ReLU.(x)

    x = Reshape.(x, [7, 7, 64])
    x = @l3.(x)
    x = @bn3.(x)
    x = ReLU.(x)

    x = @l4.(x)
    x = @bn4.(x)
    x = ReLU.(x)

    x = @l5.(x)
    x = @bn5.(x)
    x = ReLU.(x)

    x = @l6.(x)
    x = @bn6.(x)
    x = ReLU.(x)

    x = @l7.(x)
    x = Tanh.(x)
    x
  end
end

class Discriminator < Model
  def initialize
    super
    @l1 = Conv2D.new(32, 4, strides: 2, padding: true)
    @l2 = Conv2D.new(32, 4, padding: true)
    @l3 = Conv2D.new(64, 4, strides: 2, padding: true)
    @l4 = Conv2D.new(64, 4, padding: true)
    @l5 = Dense.new(1024)
    @l6 = Dense.new(1)
    @bn1 = BatchNormalization.new
    @bn2 = BatchNormalization.new
    @bn3 = BatchNormalization.new
  end

  def forward(x)
    x = InputLayer.new([28, 28, 1]).(x)
    x = @l1.(x)
    x = LeakyReLU.(x, 0.2)

    x = @l2.(x)
    x = @bn1.(x)
    x = LeakyReLU.(x, 0.2)

    x = @l3.(x)
    x = @bn2.(x)
    x = LeakyReLU.(x, 0.2)

    x = @l4.(x)
    x = @bn3.(x)
    x = LeakyReLU.(x, 0.2)

    x = Flatten.(x)
    x = @l5.(x)
    x = LeakyReLU.(x, 0.2)

    x = @l6.(x)
    x
  end

  def enable_training
    trainable_layers.each do |layer|
      layer.trainable = true
    end
  end
  
  def disable_training
    trainable_layers.each do |layer|
      layer.trainable = false
    end
  end
end

class DCGAN < Model
  attr_accessor :gen
  attr_accessor :dis

  def initialize(gen = nil, dis = nil)
    super()
    @gen = gen
    @dis = dis
  end

  def forward(x)
    x = @gen.(x)
    @dis.disable_training
    x = @dis.(x)
    x
  end

  def train_step(x_batch, y_batch)
    batch_size = x_batch.shape[0]
    noise = Numo::SFloat.new(batch_size, 20).rand(-1, 1)
    images = @gen.predict(noise)
    y_real = Numo::SFloat.ones(batch_size, 1)
    y_fake = Numo::SFloat.zeros(batch_size, 1)
    @dis.enable_training
    dis_loss = @dis.train_on_batch(x_batch, y_real)
    dis_loss + @dis.train_on_batch(images, y_fake)

    noise = Numo::SFloat.new(batch_size, 20).rand(-1, 1)
    label = Numo::SFloat.cast([1] * batch_size).reshape(batch_size, 1)
    dcgan_loss = train_on_batch(noise, label)

    { dis_loss: dis_loss, dcgan_loss: dcgan_loss }
  end
end
