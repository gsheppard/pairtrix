require 'spec_helper'

feature 'help' do
  scenario 'displays the help page' do
    visit(help_path)
    expect(page).to have_css('h3', text: 'Help')
  end
end
