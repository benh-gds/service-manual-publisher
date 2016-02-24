require 'rails_helper'

RSpec.describe SearchIndexer do
  it "indexes topics in rummager" do
    index = double(:rummageable_index)
    plek = Plek.current.find('rummager')
    expect(Rummageable::Index).to receive(:new).with(plek, "/service-manual").and_return index
    topic = Topic.create!(
      path: "/service-manual/topic1",
      title: "The Topic Title",
      description: "The Topic Description",
    )
    expect(index).to receive(:add_batch).with([{
      _type:             "edition",
      description:       topic.description,
      indexable_content: topic.title + "\n\n" + topic.description,
      title:             topic.title,
      link:              topic.path,
      organisations:     ["government-digital-service"]
    }])
    TopicSearchIndexer.new(topic).index
  end
end