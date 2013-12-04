class Pair < ActiveRecord::Base

  belongs_to :pairing_day

  has_many :pair_memberships, inverse_of: :pair
  has_many :team_memberships, through: :pair_memberships

  has_many :employees, through: :team_memberships

  validates_presence_of :pairing_day

  validate :validate_team_membership_count

  def validate_team_membership_count
    errors.add(:base, 'You must include two team members.') if team_memberships.size < 2
  end

  def name
    pair_memberships.map(&:name).join('-')
  end

  def employee_one
    pair_memberships[0].name
  end

  def employee_two
    pair_memberships[1].name
  end

  def memberships_active?(active_memberships)
    team_memberships.all? { |team_membership| active_memberships.include?(team_membership) }
  end

  def has_membership?(membership)
    team_memberships.find { |team_membership| team_membership.employee_id == membership.employee_id }
  end

  def other_membership(membership)
    team_memberships.find { |team_membership| team_membership.employee_id != membership.employee_id }
  end
end
