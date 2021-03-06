require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end

module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

World(WithinHelpers)
World(WaitForAjax)

When /^I start a new game with word "(.*)"$/ do |word|
  stub_request(:post, "http://watchout4snakes.com/wo4snakes/Random/RandomWord").
    to_return(:status => 200, :headers => {}, :body => word)
  visit '/new'
  click_button "New Game"
end

When /^I guess "(.*)"(?: again)?$/ do |letter|
  letter.downcase!
  fill_in("guess", :with => letter)
  click_button("Guess!")
end

When /^I make the following guesses:(.*)$/ do |guesses|
  guesses = guesses.gsub(' ', '').split(',')
  guesses.each do |letter|
    fill_in("guess", :with => letter)
    click_button("Guess!")
  end
end

Then /^the word should read "(.*)"$/ do |word|
  page.should have_content(word)
end

Then /^the wrong guesses should include:(.*)$/ do |guesses|
  guesses = guesses.gsub(' ', '').split(',')
  guesses.each do |guess|
    with_scope("span.guesses") do
      page.should have_content(guess)
    end
  end
end

When /^I guess "(.*)" (.*) times in a row$/ do |letter, num|
  letter.downcase!
  num.to_i.times do
    fill_in("guess", :with => letter)
    click_button("Guess!")
  end
end

When /^I try to go to the URL "(.*)"$/ do |url|
  visit url
end

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

Given /^(?:|I )login and am on (.+)$/ do |page_name|
  user = FactoryBot.build(:user)
  @user = User.create(provider: user.provider,
                      uid: user.uid,
                      name: user.name,
                      oauth_token: user.oauth_token,
                      oauth_expires_at: user.oauth_expires_at)
  logon(user.provider, user.name, user.uid)
  visit path_to(page_name)
end

Given /^(?:|I )login$/ do
  user = FactoryBot.build(:user)
  @user = User.create(provider: user.provider,
                      uid: user.uid,
                      name: user.name,
                      oauth_token: user.oauth_token,
                      oauth_expires_at: user.oauth_expires_at)
  logon(user.provider, user.name, user.uid)
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  puts("current_path: #{URI.parse(current_url).path}")
  puts("should_path: #{path_to(page_name)}")
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should == path_to(page_name)
  else
    assert_equal path_to(page_name), current_path
  end
end

Then /^(?:|I )should see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_content(text)
    else
      assert page.has_content?(text)
    end
  end
end

Then /^(?:|I )should see exercise name(?: within "([^\"]*)")?$/ do |selector|
  with_scope(selector) do
    if page.respond_to? :should
      page.should have_content(@exercise.name)
    else
      assert page.has_content?(@exercise.name)
    end
  end
end

When /^(?:|I )press "([^\"]*)"(?: within "([^\"]*)")?$/ do |button, selector|
  with_scope(selector) do
    click_button(button, visible: false)
  end
end

When /^(?:|I )choose "([^\"]*)"(?: within "([^\"]*)")?$/ do |button, selector|
  with_scope(selector) do
    choose("category_#{button}", visible: false)
  end
end

When /^(?:|I )click the link "([^\"]*)"(?: within "([^\"]*)")?$/ do |link, selector|
  with_scope(selector) do
    click_link(link)
  end
end

When /^I enter "(.*)" into "(.*)"$/ do |value, field|
    fill_in(field, :with => value)
end

When /^I enter exercise name into "(.*)"$/ do |field|
    fill_in(field, :with => @exercise.name)
end

When /^I enter unit name into "(.*)"$/ do |field|
    fill_in(field, :with => @unit.name)
end

When /^I select exercise name in "(.*)"$/ do |field|
    select @exercise.name, :from => field
end

When /^I select unit name in "(.*)"$/ do |field|
    select @unit.name, :from => field
end

Given /^A user with name "(.*?)" and UID "(.*?)" and auth provider "(.*?)"$/ do |username, uid, provider|
  provider.downcase!
  provider = 'google_oauth2' if provider.eql?('google')
  @user = FactoryBot.create(:user, :name => username, :uid => uid, :provider => provider)
end

Given /^There exists a valid exercise with name "(.*?)"$/ do |name|
  @exercise = FactoryBot.create(:exercise, :name => name, :category => "Strength")
end

Given /^There exists a valid unit with name "(.*?)"$/ do |name|
  @unit = FactoryBot.create(:unit, :name => name, :category => "Strength")
end

When /^I login using "(.*?)" as the user$/ do |provider|
  logon(provider, @user.name, @user.uid)
end
 
def logon(provider, username='Inigo Montoya', oauth_uid='123')
  
  provider.downcase!
  provider = 'google_oauth2' if provider.eql?('google')
  OmniAuth.config.add_mock(provider.to_sym, {:uid => oauth_uid, :provider => provider, :info => {:name => username}, :credentials => {:token => "random_token", :expires_at => 0}})
 
  
  visit '/'
  click_link 'Sign in with Google'
end

Given /the following exercises exist/ do |exercise_table|
  exercise_table.hashes.each do |exercise|
    Exercise.create(exercise)
  end
end

Given /the following units exist/ do |units_table|
  units_table.hashes.each do |unit|
    Unit.create(unit)
  end
end

Given /the task has the following sets/ do |sets_table|
  sets_table.hashes.each do |set|
    s = ExerciseSet.create(rep_count: set[:rep_count], 
                       rep_value: set[:rep_value],
                       rep_unit:  set[:rep_unit],
                       task_id: @task.id, 
                       state: State.saved)
  end
end

Given /^I wait for (.*?) second$/ do |seconds|
  sleep seconds.to_i
end

Then /^I save the page$/ do
  save_page
end

Then /^I wait for ajax$/ do
  wait_for_ajax
end

Then /^I send keys down, tab to "(.*?)"$/ do |field|
  find(field).native.send_keys(:down)
  find(field).native.send_keys(:tab)
end

Given /^I have the "(.*?)" workout planned$/ do |workout_name|
  @workout = Workout.create(name: workout_name, uid: 1, user_id: @user.id, state: State.saved)
end

Given /^the workout has the "(.*?)" task$/ do |exercise_name|
  exercise = Exercise.where(name: exercise_name).first
  @task = Task.create(exercise_id: exercise.id, workout_id: @workout.id, state: State.saved)
end

Given /^I check "(.*?)"$/ do |element|
  find(:css, element).set(true)
end

Given /^an admin user exists$/ do
  provider = 'google_oauth2'
  @admin = FactoryBot.create(:user, :name => "admin", :uid => "1", :provider => provider)
end