class UserFactory
  attr_accessor :errors

  def initialize(attributes)
    @attributes = attributes
  end

  def create
    begin
      User.transaction do
        user.save! && chapter.save! && role.save! && user
      end
    rescue ActiveRecord::ActiveRecordError => e
      self.errors = e.record.errors
      Rails.logger.error("Cannot accept invitation: #{e.message}")
      Rails.logger.error("User: #{user.errors.full_messages.to_sentence}") unless user.valid?
      Rails.logger.error("Chapter: #{chapter.errors.full_messages.to_sentence}") unless chapter.valid?
      Rails.logger.error("Role: #{role.errors.full_messages.to_sentence}") unless role.valid?
      false
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
    @role ||= Role.where(user_id: user).where(chapter_id: chapter).first
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

