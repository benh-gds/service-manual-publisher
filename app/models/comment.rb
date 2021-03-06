class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  scope :for_rendering, -> { order(created_at: :desc).includes(:user) }
  scope :oldest_first, -> { order('created_at, id') }

  validates :comment, presence: true

  def html_id
    "comment-#{id}"
  end
end
