class Micropost < ApplicationRecord
  belongs_to :user

  scope :order_microposts, ->{order created_at: :desc}

  scope :feed, (lambda do |id|
    following_ids = "SELECT followed_id FROM relationships
      WHERE follower_id = :user_id"
    where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
  end)

  mount_uploader :picture, PictureUploader

  validates :content, presence: true,
                      length: {maximum: Settings.microposts.content.maximum}
  validate :picture_size

  private

  def picture_size
    errors.add :picture, I18n.t("less") if picture.size > Settings.picture.megabytes
  end
end
