class PairGroup

  attr_reader :left_membership, :top_membership

  def initialize(left_membership, top_membership)
    @left_membership = left_membership
    @top_membership = top_membership
  end

  def team
    @left_membership.team
  end

  def ids
    [@left_membership.id, @top_membership.id].sort.join(',')
  end

  def current_pair?
    current_pair
  end

  def current_pair_id
    current_pair.try(:id)
  end

  def contains_default_membership?
    @left_membership.solo_or_out_of_office? || @top_membership.solo_or_out_of_office?
  end

  def do_not_pair?
    @left_membership.do_not_pair? && @top_membership.do_not_pair?
  end

  private

  def current_pair
    if (pairing_day = team.pairing_days.today.first)
      pairing_day.pairs.find do |pair|
        pair.has_membership?(@left_membership) && pair.has_membership?(@top_membership)
      end
    end
  end
end
