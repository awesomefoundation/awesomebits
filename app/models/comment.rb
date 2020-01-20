class Comment < ApplicationRecord
  VIEWABLE_OPTIONS = [
    VIEWABLE_BY_ANYONE  = "anyone".freeze,
    VIEWABLE_BY_MYSELF  = "myself".freeze
  ]

  VIEWABLE_BY_CHAPTER = "chapter".freeze

  attribute :viewable_by, :string, default: "anyone"

  belongs_to :user
  belongs_to :project
  belongs_to :viewable_chapter, optional: true

  validates :viewable_by, inclusion: { in: VIEWABLE_OPTIONS }
  validates :body, presence: true
end
