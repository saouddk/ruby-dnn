module DNN
  module Layers
    module MathUtils
      def self.align_ndim(shape1, shape2)
        if shape1.length < shape2.length
          shape2.length.times do |axis|
            unless shape1[axis] == shape2[axis]
              shape1.insert(axis, 1)
            end
          end
        elsif shape1.length > shape2.length
          shape1.length.times do |axis|
            unless shape1[axis] == shape2[axis]
              shape2.insert(axis, 1)
            end
          end
        end
        [shape1, shape2]
      end

      def self.broadcast_to(x, target_shape)
        return x if x.shape == target_shape
        x_shape, target_shape = align_ndim(x.shape, target_shape)
        x = x.reshape(*x_shape)
        x_shape.length.times do |axis|
          unless x.shape[axis] == target_shape[axis]
            tmp = x
            (target_shape[axis] - 1).times do
              x = x.concatenate(tmp, axis: axis)
            end
          end
        end
        x
      end

      def self.sum_to(x, target_shape)
        return x if x.shape == target_shape
        x_shape, target_shape = align_ndim(x.shape, target_shape)
        x = x.reshape(*x_shape)
        x_shape.length.times do |axis|
          unless x.shape[axis] == target_shape[axis]
            x = x.sum(axis: axis, keepdims: true)
          end
        end
        x
      end
    end

    class Neg < Layer
      include LayerNode

      def forward_node(x)
        -x
      end

      def backward_node(dy)
        -dy
      end
    end

    class Add < MergeLayer
      include MergeLayerNode

      def forward_node(x1, x2)
        @x1_shape = x1.shape
        @x2_shape = x2.shape
        x1 + x2
      end

      def backward_node(dy)
        dx1 = MathUtils.sum_to(dy, @x1_shape)
        dx2 = MathUtils.sum_to(dy, @x2_shape)
        [dx1, dx2]
      end
    end

    class Sub < MergeLayer
      include MergeLayerNode

      def forward_node(x1, x2)
        @x1_shape = x1.shape
        @x2_shape = x2.shape
        x1 - x2
      end

      def backward_node(dy)
        dx1 = MathUtils.sum_to(dy, @x1_shape)
        dx2 = MathUtils.sum_to(-dy, @x2_shape)
        [dx1, dx2]
      end
    end

    class Mul < MergeLayer
      include MergeLayerNode

      def forward_node(x1, x2)
        @x1, @x2 = x1, x2
        x1 * x2
      end

      def backward_node(dy)
        dx1 = MathUtils.sum_to(dy * @x2, @x1.shape)
        dx2 = MathUtils.sum_to(dy * @x1, @x2.shape)
        [dx1, dx2]
      end
    end

    class Div < MergeLayer
      include MergeLayerNode

      def forward_node(x1, x2)
        @x1, @x2 = x1, x2
        x1 / x2
      end

      def backward_node(dy)
        dx1 = MathUtils.sum_to(dy / @x2, @x1.shape)
        dx2 = MathUtils.sum_to(dy * -(@x1 / @x2**2), @x2.shape)
        [dx1, dx2]
      end
    end

    class Dot < MergeLayer
      include MergeLayerNode

      def forward_node(x1, x2)
        @x1, @x2 = x1, x2
        x1.dot(x2)
      end

      def backward_node(dy)
        [dy.dot(@x2.transpose), @x1.transpose.dot(dy)]
      end
    end

    class Exp < Layer
      include LayerNode

      def forward_node(x)
        @y = Xumo::NMath.exp(x)
      end

      def backward_node(dy)
        dy * @y
      end
    end

    class Log < Layer
      include LayerNode

      def forward_node(x)
        @x = x
        Xumo::NMath.log(x)
      end

      def backward_node(dy)
        dy / @x
      end
    end

    class Pow < Layer
      include LayerNode

      def initialize(index)
        super()
        @index = index
      end

      def forward_node(x)
        @x = x
        x**@index
      end

      def backward_node(dy)
        dy * @index * @x**(@index - 1)
      end
    end

    class Sqrt < Layer
      include LayerNode

      def forward_node(x)
        @x = x
        Xumo::NMath.sqrt(x)
      end

      def backward_node(dy)
        dy * (1.0 / 2 * Xumo::NMath.sqrt(@x))
      end
    end

    class Sum < Layer
      include LayerNode

      def initialize(axis: 0)
        super()
        @axis = axis
      end

      def forward_node(x)
        @x_shape = x.shape
        @dim = x.shape[@axis]
        x.sum(axis: @axis, keepdims: true)
      end

      def backward_node(dy)
        return dy if @x_shape == dy.shape
        dx = dy
        (@dim - 1).times do
          dx = dx.concatenate(dy, axis: @axis)
        end
        dx
      end
    end

    class Mean < Layer
      include LayerNode

      def initialize(axis: 0)
        super()
        @axis = axis
      end

      def forward_node(x)
        @x_shape = x.shape
        @dim = x.shape[@axis]
        x.mean(axis: @axis, keepdims: true)
      end

      def backward_node(dy)
        return dy / @dim if @x_shape == dy.shape
        dx = dy
        (@dim - 1).times do
          dx = dx.concatenate(dy, axis: @axis)
        end
        dx / @dim
      end
    end

  end
end
