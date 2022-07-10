class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books
  has_many :favorites, dependent: :destroy
  has_many :book_comments, dependent: :destroy
  has_one_attached :profile_image

# # フォローする側から中間テーブルへのアソシエーション
#   has_many :relationships, foreign_key: :followed_id
#   # フォローする側からフォローされたユーザを取得する
#   has_many :followings, through: :relationships, source: :follower

#   # フォローされる側から中間テーブルへのアソシエーション
#   has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: :follower_id
#   # フォローされる側からフォローしているユーザを取得する
#   has_many :followers, through: :reverse_of_relationships, source: :following
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

  # 一覧画面で使う
  has_many :followings, through: :relationships, source: :followed
  has_many :followers, through: :reverse_of_relationships, source: :follower


  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: {maximum: 50}


  def already_favorited?(book)
    self.favorites.exists?(book_id: book.id)
  end

  def get_profile_image
    (profile_image.attached?) ? profile_image : 'no_image.jpg'
  end

  def is_followed_by?(user)
    reverse_of_relationships.find_by(follower_id: user.id).present?
  end
end
