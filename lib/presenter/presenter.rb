# Created by IntelliJ IDEA.
# User: yeameen
# Date: May 8, 2008
# Time: 9:55:21 AM
# To change this template use File | Settings | File Templates.

class Presenter
  extend Forwardable

  def initialize(p_params)
    p_params.each_pair do |attribute, value|
      self.send :"#{attribute}=", value
    end unless p_params.nil?
  end

  def attributes=(p_params)
    p_params.each_pair do |attribute, value|
      self.send :"#{attribute}=", value
    end unless p_params.nil?
  end
end