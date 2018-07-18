class Micropost < ApplicationRecord
  belongs_to :user

  scope :order_microposts, ->{order created_at: :desc}
  scope :feed, ->(id){where user_id: id}
  mount_uploader :picture, PictureUploader

  validates :content, presence: true,
                      length: {maximum: Settings.microposts.content.maximum}
  validate :picture_size

  private

  def picture_size
    errors.add :picture, I18n.t("less") if picture.size > Settings.picture.megabytes
  end
end
