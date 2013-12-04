require 'spec_helper'

feature 'homepage' do
  scenario 'displays the home page' do
    visit(root_path)

    within('.navbar.navbar-fixed-top') do
      expect(page).to have_css('a', text: 'Sign in')
    end
  end
end
