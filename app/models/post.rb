class Post < ActiveRecord::Base
  belongs_to :user
  belongs_to :club
  
  before_save :format_website_url
  before_save :scrape_with_grabbit

  default_scope -> { order(created_at: :desc) }
  #mount_uploader :picture, PictureUploader
  #validates :url, :format => URI::regexp(%w(http https)), presence: false
  validates :context,  presence: true, length: { maximum: 5000 }
  validates :title,  presence: true, length: { maximum: 100 }
  validates :user_id, presence: true
  validates :club_id, presence: true

  has_attached_file :image, styles: { medium: "300x300>" }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
  
  private 
  
  def format_website_url
    unless url.blank?
      return if url.include?('http://') || url.include?('https://')
      self.url = "http://#{url}"
    end
  end
  
  def scrape_with_grabbit
    unless url.blank?
      data = Grabbit.url(url)
      self.context = data.description 
      self.picture = data.images.first
    end
  end
  
end
