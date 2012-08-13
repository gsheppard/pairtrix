class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new # guest user (not logged in)
    if user.admin?
      can :manage, :all
    else
      can :read, :all
    end

    can :create, MembershipRequest
    can :update, MembershipRequest, company: { user_id: user.id }

    can :update, Company, user_id: user.id
    can :create, Company, user_id: user.id
    can :destroy, Company, user_id: user.id

    can :update, Employee, company: { user_id: user.id }
    can :create, Employee, company: { user_id: user.id }
    can :destroy, Employee, company: { user_id: user.id }

    can :update, Team, company: { user_id: user.id }
    can :create, Team, company: { user_id: user.id }
    can :destroy, Team, company: { user_id: user.id }

    can :update, TeamMembership, team: { company: { user_id: user.id }}
    can :create, TeamMembership, team: { company: { user_id: user.id }}
    can :destroy, TeamMembership, team: { company: { user_id: user.id }}

    can :update, PairingDay, team: { company: { user_id: user.id }}
    can :create, PairingDay, team: { company: { user_id: user.id }}
    can :destroy, PairingDay, team: { company: { user_id: user.id }}

    can :update, Pair, pairing_day: { team: { company: { user_id: user.id }}}
    can :create, Pair, pairing_day: { team: { company: { user_id: user.id }}}
    can :destroy, Pair, pairing_day: { team: { company: { user_id: user.id }}}
  end
end