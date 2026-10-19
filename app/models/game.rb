# The game locks at GAME_LOCKS_AT (e.g. "2026-10-24T23:30:00-04:00").
# After that, players can no longer kill or change statuses.
module Game
  def self.locks_at
    value = ENV["GAME_LOCKS_AT"].presence
    Time.zone.parse(value) if value
  rescue ArgumentError
    Rails.logger.error("GAME_LOCKS_AT is not a valid time: #{value.inspect}")
    nil
  end

  def self.locked?
    locks_at.present? && locks_at.past?
  end
end
