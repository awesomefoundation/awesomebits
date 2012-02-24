class UserFactory
  def initialize(attributes)
    @attributes = attributes
  end

  def create
    User.transaction do
      user.save && chapter.save && role.save && user
    end
  end

  def user
    if @user.nil?
      @user = User.find_by_email(@attributes[:email]) || User.new(@attributes)
      @user.update_password(password)
    end
    @user
  end

  def chapter
    @chapter ||= @attributes.delete(:chapter)
  end

  def role
    if @role.nil?
      @role = Role.new
      @role.name = "trustee"
      @role.user = user
      @role.chapter = chapter
    end
    @role
  end

  private

  def password
    @password ||= @attributes.delete(:password)
  end

end

