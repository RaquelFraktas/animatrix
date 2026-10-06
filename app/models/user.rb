class User < ApplicationRecord
  has_many :kills_as_killer,
           class_name: "Kill",
           foreign_key: :killer_id

  has_one :kill_record,
          class_name: "Kill",
          foreign_key: :victim_id

  VALID_STATUSES = %w[alive killed].freeze

  validates :name, uniqueness: true, allow_nil: true
  validates :qr_code, uniqueness: true, allow_blank: true

  before_validation :set_defaults

  def self.highscores
    left_joins(:kills_as_killer)
      .select("users.*, COUNT(kills.id) AS kills_count")
      .group("users.id")
      .order(Arel.sql("COUNT(kills.id) DESC, users.name ASC, users.id ASC"))
      .limit(5)
  end

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

    self.class.transaction do
      victim.lock!
      return false unless victim.alive?
      return false if kills_as_killer.exists?(victim_id: victim.id)

      kills_as_killer.create!(victim: victim)
      victim.update!(status: "killed")
    end

    true
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
    self.qr_code ||= "user-#{SecureRandom.uuid}"
  end
end
