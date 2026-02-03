class Comment < ApplicationRecord
  VIEWABLE_OPTIONS = [
    VIEWABLE_BY_ANYONE  = "anyone".freeze,
    VIEWABLE_BY_MYSELF  = "myself".freeze
  ]

  VIEWABLE_BY_CHAPTER = "chapter".freeze

  attribute :viewable_by, :string, default: "anyone"

  belongs_to :user
  belongs_to :project
  belongs_to :viewable_chapter, class_name: "Chapter", optional: true

  validates :viewable_by, inclusion: { in: VIEWABLE_OPTIONS }
  validates :body, presence: true

  before_save :sanitize_fields

  scope :by_date, -> { order(created_at: :asc) }

  def self.viewable_by(user: nil, chapter: nil)
    scope = where(viewable_by: "anyone")
    scope = scope.or(where(viewable_by: "myself", user: user)) if user.present?
    scope = scope.or(where(viewable_by: "chapter").where(viewable_chapter: chapter)) if chapter.present?
    scope
  end

  def as_json(options = {})
    super(options).merge({
      body: ApplicationController.helpers.markdown(body),
      user_gravatar_url: user.gravatar_url,
      user_name: user.name,
      created_at_human: created_at.in_time_zone(project.chapter.time_zone).to_fs(:long_with_zone),
      visibility_class: ApplicationController.helpers.comment_visibility_class(self)
    })
  end

  private

  def sanitize_fields
    self.body = ApplicationController.helpers.strip_tags(body)
  end
end
