class Integer
  
  def +(other)
    if other.is_a?(DNN::Tensor) || other.is_a?(DNN::Param)
      DNN::Layers::Add.(DNN::Tensor.convert(self), other)
    else
      dnn__add(other)
    end
  end
  
  def -(other)
    if other.is_a?(DNN::Tensor) || other.is_a?(DNN::Param)
      DNN::Layers::Sub.(DNN::Tensor.convert(self), other)
    else
      dnn__sub(other)
    end
  end
  
  def *(other)
    if other.is_a?(DNN::Tensor) || other.is_a?(DNN::Param)
      DNN::Layers::Mul.(DNN::Tensor.convert(self), other)
    else
      dnn__mul(other)
    end
  end

  def /(other)
    if other.is_a?(DNN::Tensor) || other.is_a?(DNN::Param)
      DNN::Layers::Div.(DNN::Tensor.convert(self), other)
    else
      dnn__div(other)
    end
  end
  
  alias dnn__add +
  alias dnn__sub -
  alias dnn__mul *
  alias dnn__div /
end

class Float

  def +(other)
    if other.is_a?(DNN::Tensor) || other.is_a?(DNN::Param)
      DNN::Layers::Add.(DNN::Tensor.convert(self), other)
    else
      dnn__add(other)
    end
  end

  def -(other)
    if other.is_a?(DNN::Tensor) || other.is_a?(DNN::Param)
      DNN::Layers::Sub.(DNN::Tensor.convert(self), other)
    else
      dnn__sub(other)
    end
  end

  def *(other)
    if other.is_a?(DNN::Tensor) || other.is_a?(DNN::Param)
      DNN::Layers::Mul.(DNN::Tensor.convert(self), other)
    else
      dnn__mul(other)
    end
  end

  def /(other)
    if other.is_a?(DNN::Tensor) || other.is_a?(DNN::Param)
      DNN::Layers::Div.(DNN::Tensor.convert(self), other)
    else
      dnn__div(other)
    end
  end
  
  alias dnn__add +
  alias dnn__sub -
  alias dnn__mul *
  alias dnn__div /
end

if RUBY_VERSION < "2.6.0"
  class Hash
    alias dnn__to_h to_h
    def to_h(&block)
      dnn__to_h unless block
      map(&block).to_h
    end
  end
end
