class TeamMembership < ActiveRecord::Base

  belongs_to :team
  belongs_to :employee, inverse_of: :team_memberships

  validates_presence_of :team_id, :employee_id
  validates :employee_id, uniqueness: { unless: Proc.new { |membership| membership.employee && membership.solo_or_out_of_office? } }

  delegate :name, :solo_or_out_of_office?, :out_of_office_employee?, :do_not_pair?, to: :employee

  after_destroy :delete_pair_memberships_containing_membership

  class << self
    def sorted
      joins(:employee).order('employees.last_name ASC')
    end
  end

  private

  def delete_pair_memberships_containing_membership
    PairMembership.where(team_membership_id: id).destroy_all
  end
end
