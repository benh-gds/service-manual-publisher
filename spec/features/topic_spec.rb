require 'rails_helper'
require 'capybara/rails'
require 'gds_api/publishing_api_v2'

RSpec.describe "Creating topics", type: :feature do
  let(:api_double) { double(:publishing_api) }

  it "save a draft topic", js: true do
    stub_const("PUBLISHING_API", api_double)
    expect(api_double).to receive(:put_content)
                            .once
                            .with(an_instance_of(String), be_valid_against_schema('service_manual_topic'))
    expect(api_double).to receive(:patch_links)
                            .once
                            .with(an_instance_of(String), an_instance_of(Hash))
    guide1 = create(:guide, latest_edition: build(:edition, title: 'Guide 1'))
    guide2 = create(:guide, latest_edition: build(:edition, title: 'Guide 2'))

    visit root_path
    click_link "Manage Topics"
    click_link "Create a Topic"

    expect(page).to_not have_button('Publish')

    fill_in "Path", with: "/service-manual/something"
    fill_in "Title", with: "The title"
    fill_in "Description", with: "The description"
    click_button "Add Heading"
    fill_in "Heading Title", with: "The heading title"
    fill_in "Heading Description", with: "The heading description"
    add_guide 'Guide 1'
    add_guide 'Guide 2'
    click_button "Save"

    # Reload the page to be sure the fields don't contain params from the
    # previous request
    visit current_path

    expect(page).to have_field('Title', with: 'The title')
    expect(page).to have_field('Description', with: 'The description')

    within_the_only_grouping do
      expect(find('.js-topic-title').value).to eq('The heading title')
      expect(find('.js-topic-description').value).to eq('The heading description')

      guide_fields = find_all('.js-topic-guide')
      expect(guide_fields[0].all('option').detect(&:selected?).text).to eq('Guide 1')
      expect(guide_fields[1].all('option').detect(&:selected?).text).to eq('Guide 2')
    end

    expect(page).to have_button('Publish')
  end

  def within_the_only_grouping(&block)
    within(:xpath, %{//ul[contains(concat(' ', @class, ' '), ' js-sortable-topic-list ')]}, &block)
  end

  def add_guide(name)
    click_button "Add Guide"

    all_guide_fields = all(".js-topic-guide")
    all_guide_fields[all_guide_fields.length - 1].find(:xpath, ".//option[.='#{name}']").select_option
  end

  it "publishes an existing draft" do
    topic = build(:topic)
    topic.save!

    publishing_api = double(:publishing_api)
    stub_const("PUBLISHING_API", publishing_api)
    expect(publishing_api).to receive(:publish)

    visit edit_topic_path(topic)
    click_button 'Publish'

    within('.alert') do
      expect(page).to have_content('Topic has been published')
    end
  end
end

RSpec.describe "topic editor", type: :feature do
  it "can view topics" do
    topic = Topic.create!(
      path: "/service-manual/topic1",
      title: "Topic 1",
      description: "A Description",
    )
    visit root_path
    click_link "Manage Topics"
    click_link "Topic 1"
    expect(page).to have_link "View", href: "http://www.dev.gov.uk/service-manual/topic1"
  end
end
