require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  let(:gary) { build(:user, name: "Gary", email: "gary@example.com") }
  let(:luke) { build(:user, name: "Luke") }
  let(:guide) { create(:guide, slug: '/service-manual/topic-name/agile-delivery', editions: [edition]) }
  let(:edition) { build(:edition, title: "Agile", author: gary) }

  before do
    guide.save!
    allow_any_instance_of(Edition).to receive(:notification_subscribers).and_return([gary])
  end

  describe "#comment_added" do
    it "contains the comment text, author name and a link" do
      comment = edition.comments.create!(comment: "Looking good", user: luke)

      email = NotificationMailer.comment_added(comment).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(email.to).to eq ["gary@example.com"]
      expect(email.subject).to eq "New comment on \"Agile\""

      email.parts.each do |part|
        expect(part.body.to_s).to include "Luke"
        expect(part.body.to_s).to include "Looking good"
        expect(part.body.to_s).to include "guides/#{guide.id}/editions"
      end
    end

    it "presents multi line comments correctly" do
      comment_text = <<-COMMENT.strip_heredoc
        This guide sure could use more cow bell.
        Cow bell makes everything better!

        Much better.
      COMMENT

      formatted_comment = <<-COMMENT.strip_heredoc
        <p>This guide sure could use more cow bell.
        <br />Cow bell makes everything better!</p>

        <p>Much better.
        </p>
      COMMENT

      comment = edition.comments.create!(comment: comment_text, user: luke)

      email = NotificationMailer.comment_added(comment).deliver_now

      # The HTML part of the email should include the comment wrapped in
      # paragraph tags and using line breaks
      expect(email.html_part.body.to_s).to include formatted_comment

      # The text part of the email should include the comment with normal
      # whitespace.
      expect(email.text_part.body.to_s).to include comment_text
    end
  end

  describe "#ready_for_publishing" do
    before do
      edition.create_approval(user: luke)
      edition.update_attribute(:state, 'ready')
    end

    it "contains the edition title, approver's name and a link" do
      email = NotificationMailer.ready_for_publishing(guide).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(email.to).to eq ["gary@example.com"]
      expect(email.subject).to eq "\"Agile\" ready for publishing"

      email.parts.each do |part|
        expect(part.body.to_s).to include "Luke"
        expect(part.body.to_s).to include "\"Agile\""
        expect(part.body.to_s).to include edit_guide_path(guide)
      end
    end
  end

  describe "#published" do
    it "contains the edition title, publisher's name and a link" do
      email = NotificationMailer.published(guide, luke).deliver_now

      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(email.to).to eq ["gary@example.com"]
      expect(email.subject).to eq "\"Agile\" has been published"

      email.parts.each do |part|
        expect(part.body.to_s).to include "Luke"
        expect(part.body.to_s).to include "\"Agile\""
        expect(part.body.to_s).to include "#{Plek.find('www')}/service-manual/topic-name/agile-delivery"
      end
    end
  end
end
