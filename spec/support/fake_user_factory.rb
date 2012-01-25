class FakeUserFactory
  def initialize
    @users = []
    @return_value = true
  end

  def users
    @users
  end

  def new(attributes)
    @attributes = attributes
    self
  end

  def fail!
    @return_value = false
  end

  def create
    @users << User.new(@attributes)
    @return_value && @users.last
  end
end
