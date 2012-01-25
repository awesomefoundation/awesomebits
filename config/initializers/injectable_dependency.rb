module InjectableDependency
  def dependency(name, value = nil)
    cattr_accessor name
    attr_accessor name
    self.send("#{name}=", value) if value
    define_method(name) do
      instance_variable_get("@#{name}") || self.class.send(name)
    end
  end
end
ActiveRecord::Base.extend(InjectableDependency)
