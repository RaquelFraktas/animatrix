class User < ApplicationRecord
  VALID_STATUSES = %w[alive killed].freeze

  validates :name, presence: true
  validates :status, inclusion: { in: VALID_STATUSES, message: "must be either 'alive' or 'killed'" }
  validates :kill_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_validation :set_defaults

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
  end
end
