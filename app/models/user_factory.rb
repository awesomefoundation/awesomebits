class UserFactory
  def initialize(attributes)
    @attributes = attributes
  end

  def create
    User.transaction do
      user.save && chapter.save && role.save && user
    end
  end

  private

  def user
    if @user.nil?
      @user = User.new(@attributes)
      @user.update_password(password)
    end
    @user
  end

  def password
    @password ||= @attributes.delete(:password)
  end

  def chapter
    @chapter ||= @attributes.delete(:chapter)
  end

  def role
    if @role.nil?
      @role = Role.new(:name => "trustee")
      @role.user = user
      @role.chapter = chapter
    end
    @role
  end
end
