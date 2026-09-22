require "rqrcode"

class User < ApplicationRecord
  VALID_STATUSES = %w[alive killed].freeze

  validates_uniqueness_of :name
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

  def qr_code_svg
    return if qr_code.blank?

    qrcode = RQRCode::QRCode.new(scan_url)
    qrcode.as_svg(
      offset: 0,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 4,
      stand_alone: true
    )
  end

  def kill!(other_user)
    return false if other_user == self || !other_user.alive?
    return false if killed_user_ids.include?(other_user.id)

    self.killed_user_ids ||= []
    self.killed_user_ids << other_user.id
    self.kill_count = killed_user_ids.count
    other_user.update!(status: "killed")
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
