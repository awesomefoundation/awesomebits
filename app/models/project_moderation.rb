class ProjectModeration < ApplicationRecord
  belongs_to :project
  belongs_to :reviewed_by, class_name: "User", optional: true

  validates :project_id, uniqueness: true

  enum :status, %w[unreviewed suspected confirmed_spam confirmed_legit].index_by(&:itself)
  enum :moderation_type, %w[spam missing_metadata other].index_by(&:itself)

  store_accessor :signals, :score, :triggered

  scope :pending, -> { where(status: %w[unreviewed suspected]) }
  scope :approved, -> { where(status: %w[confirmed_legit]) }

  def mark_confirmed_spam!(user)
    update!(
      status: :confirmed_spam,
      reviewed_by: user,
      reviewed_at: Time.current
    )
  end

  def mark_confirmed_legit!(user)
    update!(
      status: :confirmed_legit,
      reviewed_by: user,
      reviewed_at: Time.current
    )
  end

  def reviewed?
    reviewed_by.present?
  end
end
