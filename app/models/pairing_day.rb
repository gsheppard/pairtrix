class PairingDay < ActiveRecord::Base

  belongs_to :team

  has_many :pairs, dependent: :destroy

  validates_presence_of :team_id, :pairing_date
  validates_uniqueness_of :pairing_date, scope: :team_id

  class << self
    def today
      where(pairing_date: Date.current)
    end
  end

  def to_param
    "#{id}-#{pairing_date.to_s(:db)}"
  end

  def available_team_memberships
    [get_out_of_office_membership, get_available_team_memberships].flatten.uniq
  end

  def available_team_memberships?
    available_team_memberships.length > 1
  end

  def paired_membership_ids
    paired_team_membership_ids.map { |id| id.to_s }
  end

  private

  def get_available_team_memberships
    team_membership_table = Arel::Table.new(:team_memberships)
    TeamMembership.
      where(team_membership_table[:id].not_in(paired_team_membership_ids)).
      where(team_membership_table[:team_id].eq(team.id)).
      joins(:employee).order('employees.last_name ASC')
  end

  def get_out_of_office_membership
    find_membership_for('Office')
  end

  def solo_membership
    find_membership_for('Solo')
  end

  def find_membership_for(name)
    TeamMembership.
      joins(:employee).
      where('employees.last_name = ?', name).
      where(team_id: team.id)
  end

  def paired_team_membership_ids
    ids = pairs.map(&:team_membership_ids).flatten
    ids.any? ? ids : [0]
  end
end
