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

  def role
    Role.new(user: user, chapter: @chapter, name: @role_name)
  end

  def new(attributes)
    @attributes = attributes

    @chapter   = @attributes.delete(:chapter)
    @role_name = @attributes.delete(:role_name)

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
