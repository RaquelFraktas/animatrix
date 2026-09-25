class User < ApplicationRecord
  has_many :kills_as_killer,
           class_name: "Kill",
           foreign_key: :killer_id

  has_one :kill_record,
          class_name: "Kill",
          foreign_key: :victim_id

  VALID_STATUSES = %w[alive killed].freeze

  validates :name, uniqueness: true, allow_nil: true
  validates :kill_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :qr_code, uniqueness: true, allow_blank: true

  before_validation :set_defaults

  def self.find_or_initialize_by_qr_code(qr_code)
    normalized = qr_code.to_s.strip
    return new if normalized.blank?

    user = find_by(qr_code: normalized)
    return user if user.present?

    create!(
      qr_code: normalized,
      status: "alive"
    )
  end

  def scan_url
    return if qr_code.blank?

    Rails.application.routes.url_helpers.scan_url(
      qr_code: qr_code,
      host: ENV.fetch("APP_HOST"),
      protocol: "http"
    )
  end

  def qr_code_png_data_uri
    return if qr_code.blank?

    qrcode = RQRCode::QRCode.new(scan_url)
    png = qrcode.as_png(size: 196, border_modules: 0).to_blob

    "data:image/png;base64,#{Base64.strict_encode64(png)}"
  end

  def kill!(victim)
    return false if victim == self || !victim.alive?
    return false if kills_as_killer.exists?(victim_id: victim.id)

    victim.update!(status: "killed")
    save!
  end

  def alive?
    status == "alive"
  end

  def killed?
    status == "killed"
  end

  private

  def set_defaults
    self.status ||= "alive"
    self.kill_count ||= 0
    self.killed_user_ids ||= []

    self.qr_code ||= "user-#{SecureRandom.uuid}"
  end
end
