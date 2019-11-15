module DNN
  module Layers

    class Sigmoid < Layer
      def forward(x)
        @y = 1 / (1 + Xumo::NMath.exp(-x))
      end

      def backward(dy)
        dy * (1 - @y) * @y
      end
    end

    class Tanh < Layer
      def forward(x)
        @y = Xumo::NMath.tanh(x)
      end

      def backward(dy)
        dy * (1 - @y**2)
      end
    end

    class Softsign < Layer
      def forward(x)
        @x = x
        x / (1 + x.abs)
      end

      def backward(dy)
        dy * (1 / (1 + @x.abs)**2)
      end
    end

    class Softplus < Layer
      def forward(x)
        @x = x
        Xumo::NMath.log(1 + Xumo::NMath.exp(x))
      end

      def backward(dy)
        dy * (1 / (1 + Xumo::NMath.exp(-@x)))
      end
    end

    class Swish < Layer
      def forward(x)
        @x = x
        @y = x * (1 / (1 + Xumo::NMath.exp(-x)))
      end

      def backward(dy)
        dy * (@y + (1 / (1 + Xumo::NMath.exp(-@x))) * (1 - @y))
      end
    end

    class ReLU < Layer
      def forward(x)
        @x = x
        Xumo::SFloat.maximum(0, x)
      end

      def backward(dy)
        dy * Xumo::SFloat.cast(@x > 0)
      end
    end

    class LeakyReLU < Layer
      attr_reader :alpha

      # @param [Float] alpha The slope when the output value is negative.
      def initialize(alpha = 0.3)
        super()
        @alpha = alpha
      end

      def forward(x)
        @x = x
        a = Xumo::SFloat.ones(x.shape)
        a[x <= 0] = @alpha
        x * a
      end

      def backward(dy)
        dx = Xumo::SFloat.ones(@x.shape)
        dx[@x <= 0] = @alpha
        dy * dx
      end

      def to_hash
        super(alpha: @alpha)
      end

      def load_hash(hash)
        initialize(hash[:alpha])
      end
    end

    class ELU < Layer
      attr_reader :alpha

      # @param [Float] alpha The slope when the output value is negative.
      def initialize(alpha = 1.0)
        super()
        @alpha = alpha
      end

      def forward(x)
        @x = x
        x1 = Xumo::SFloat.zeros(x.shape)
        x1[x >= 0] = 1
        x1 *= x
        x2 = Xumo::SFloat.zeros(x.shape)
        x2[x < 0] = 1
        x2 *= @alpha * Xumo::NMath.exp(x) - @alpha
        x1 + x2
      end

      def backward(dy)
        dx = Xumo::SFloat.ones(@x.shape)
        dx[@x < 0] = 0
        dx2 = Xumo::SFloat.zeros(@x.shape)
        dx2[@x < 0] = 1
        dx2 *= @alpha * Xumo::NMath.exp(@x)
        dy * (dx + dx2)
      end

      def to_hash
        super(alpha: @alpha)
      end

      def load_hash(hash)
        initialize(hash[:alpha])
      end
    end

  end
end