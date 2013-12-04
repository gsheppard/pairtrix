class RemoveStartAndEndDateFromTeamMembership < ActiveRecord::Migration
  def up
    TeamMembership.where('end_date IS NOT ?', nil).destroy_all
    remove_column :team_memberships, :start_date
    remove_column :team_memberships, :end_date
  end

  def down
    add_column :team_memberships, :start_date, :date
    add_column :team_memberships, :end_date, :date
  end
end
