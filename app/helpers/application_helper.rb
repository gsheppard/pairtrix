# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  FLASH_NOTICE_KEYS = [:success, :notice, :warning, :failure, :error, :invalid, :alert, :unauthenticated, :unconfirmed, :invalid_token, :timeout, :inactive, :locked]

  def flash_messages
    return unless messages = flash.keys.select { |k| FLASH_NOTICE_KEYS.include?(k) }
    formatted_messages = messages.map do |type|
      content_tag(:div, class: "alert alert-#{type}") do
        content_tag(:a, 'x', class: 'close', 'data-dismiss' => 'alert') +
        message_for_item(flash[type], flash["#{type}_item".to_sym])
      end
    end
    flash.clear
    formatted_messages.join
  end

  def message_for_item(message, item = nil)
    if item.is_a?(Array)
      message % link_to(*item)
    else
      message % item
    end
  end

  def error_messages_for(resource)
    return '' if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = "#{pluralize(resource.errors.count, "error")} prohibited this #{resource.class.name.downcase} from being saved:"

    html = content_tag(:div, class: 'error-explanation') do
      content_tag(:h3, sentence) +
        content_tag(:ul, messages.html_safe)
    end
    html.html_safe
  end

  def yes_no(bool)
    bool ? 'Yes' : 'No'
  end

  def pairing_count_warning(times_paired)
    case
    when times_paired == 3
      'pairing-count-notice'
    when times_paired > 3
      'pairing-count-warning'
    else
      ''
    end
  end

  def avatar_for(employee)
    image_url = employee.avatar? ? employee.avatar_url :
      employee.solo_employee? ? 'layout/solo.png' :
      employee.out_of_office_employee? ? 'layout/out_of_office.png' : 'layout/avatar.png'
    image_tag(image_url, title: employee.name, alt: employee.name)
  end

  def restricted?(employee)
    employee.do_not_pair ? 'do-not-pair' : ''
  end

  def membership_data(membership)
    { 'membership-id' => membership.id, 'member' => (!membership.employee.solo_or_out_of_office?).to_s }
  end

  def available_teams_navigation_dropdown
    if user_signed_in?
      teams = current_user.available_teams
      generate_teams_dropdown(teams) if teams.any?
    end
  end

  def pair_cell(pair_group)
    content_tag(:div,
                times_paired(pair_group),
                class: pair_cell_css_classes(pair_group),
                data: pair_cell_data(pair_group))
  end

  def currently_paired_membership_ids(team)
    if (current_pairing_day = team.pairing_days.today.first)
      current_pairing_day.paired_membership_ids
    else
      []
    end
  end

  def breadcrumb_link(options)
    link = link_to(options[:text],
                   options[:url],
                   class: is_active_link?(options[:url]))
    content_tag(:li, raw(link))
  end

  def badge_name_for(employee)
    (employee.first_name + ' ' + employee.last_name).html_safe
  end

  private

  def is_active_link?(url)
    "#{request.protocol}#{request.host_with_port}#{request.fullpath}" == url ? 'active' : ''
  end

  def generate_teams_dropdown(teams)
    content_tag(:li, class: 'dropdown') do
      link_to(raw('Teams' + content_tag(:b, '', class: 'caret')), '#', class: 'dropdown-toggle', data: { toggle: 'dropdown' }) +
        content_tag(:ul, class: 'dropdown-menu') do
        team_name_links(teams)
      end
    end
  end

  def team_name_links(teams)
    teams.map { |team| content_tag(:li, link_to(team.name, team)) }.join('').html_safe
  end

  def pair_cell_data(pair_group)
    data_hash = { 'pair-memberships' => pair_group.ids }
    data_hash.merge!({ 'pair-id' => pair_group.current_pair_id }) if pair_group.current_pair_id
    data_hash
  end

  def pair_cell_css_classes(pair_group)
    klasses = ['paired-count', 'matrix-cell']
    klasses << pairing_count_warning(times_paired(pair_group))
    klasses << "member-#{pair_group.left_membership.id}"
    klasses << "member-#{pair_group.top_membership.id}"
    klasses << 'no-automation' if pair_group.contains_default_membership? || pair_group.do_not_pair?
    klasses << 'created-pair' if pair_group.current_pair?
    klasses.join(' ')
  end

  def times_paired(pair_group)
    pair_group.team.times_paired(pair_group.left_membership, pair_group.top_membership)
  end
end
