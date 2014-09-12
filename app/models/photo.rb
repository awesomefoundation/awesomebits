class Photo < ActiveRecord::Base
  MAIN_DIMENSIONS = "940x470"

  belongs_to :project
  has_attached_file :image, :default_url => "/assets/no-image-:style.png"
  validates_attachment_content_type :image, :content_type => [
    "image/jpg", "image/jpeg", "image/png", "image/gif"
  ]

  attr_accessible :image

  # Build a URL to dynamically resize application images via an external service
  # Currently using http://magickly.afeld.me/
  def url(size = nil)
    case size

    when :main
      image.present? ? cropped_image_url("#{MAIN_DIMENSIONS}#") : image.url(:main)

    when :index
      image.present? ? cropped_image_url("500x300#") : image.url(:index)

    else
      image_url
    end
  end

  protected

  def image_url
    image.url(:original, :timestamp => false)
  end

  def cropped_image_url(crop)
    [image_host, "q", image_path(crop)].join("/")
  end

  def image_host
    ENV['MAGICKLY_HOST']
  end

  def image_path(crop)
    [ "src", image_with_host(image_url), "thumb", crop ].collect { |part| CGI.escape(part) }.join("/")
  end

  def image_with_host(image_url)
    base_uri = URI(ENV['DEFAULT_URL'] || "http://localhost:3000")

    uri = URI(image_url)
    uri.scheme ||= base_uri.scheme
    uri.host   ||= base_uri.host
    uri.port   ||= base_uri.port

    uri.to_s
  end
end
