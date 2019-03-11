class FakeUserFactory
  attr_accessor :errors

  def initialize
    @users = []
    @return_value = true
  end

  def users
    @users
  end

  def user
    @users.last
  end

  def new(attributes)
    @attributes = attributes
    @attributes.delete(:chapter)
    self
  end

  def fail!
    @return_value = false
  end

  def create
    @users << User.new(@attributes)
    @return_value
  end
end
