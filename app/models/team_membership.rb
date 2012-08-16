class TeamMembership < ActiveRecord::Base
  attr_accessible :team_id, :employee_id, :start_date, :end_date

  belongs_to :team
  belongs_to :employee

  validates_presence_of :team_id, :employee_id, :start_date

  delegate :name, to: :employee

  after_destroy :delete_pair_memberships_containing_membership

  class << self
    def current
      team_membership_table = Arel::Table.new(:team_memberships)
      -> { TeamMembership.where(team_membership_table[:end_date].eq(nil).or(team_membership_table[:end_date].gt(Date.current))) }.call
    end

    def sorted
      joins(:employee).order("end_date DESC, employees.last_name ASC")
    end
  end

  def current?
    end_date.nil? || end_date > Date.current
  end

  def hide?
    employee.hide?
  end

  private

  def delete_pair_memberships_containing_membership
    PairMembership.where(team_membership_id: self.id).destroy_all
  end

end
