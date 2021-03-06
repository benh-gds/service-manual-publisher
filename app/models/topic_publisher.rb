class TopicPublisher
  attr_reader :topic, :publishing_api

  def initialize(topic:, publishing_api: PUBLISHING_API)
    @topic = topic
    @publishing_api = publishing_api
  end

  def save_draft
    topic_presenter = TopicPresenter.new(topic)
    email_alert_signup_presenter = TopicEmailAlertSignupPresenter.new(topic)

    save_catching_gds_api_errors do
      publishing_api.put_content(email_alert_signup_presenter.content_id, email_alert_signup_presenter.content_payload)

      publishing_api.put_content(topic_presenter.content_id, topic_presenter.content_payload)
      publishing_api.patch_links(topic_presenter.content_id, topic_presenter.links_payload)
    end
  end

  def publish
    save_catching_gds_api_errors do
      publishing_api.publish(topic.content_id, topic.update_type)
      publishing_api.publish(topic.email_alert_signup_content_id, topic.update_type)
    end
  end

private

  def save_catching_gds_api_errors
    begin
      ActiveRecord::Base.transaction do
        if topic.save
          yield

          Response.new(success: true)
        else
          Response.new(success: false)
        end
      end
    rescue GdsApi::HTTPErrorResponse => e
      Airbrake.notify(e)
      error_message = e.error_details['error']['message'] rescue "Could not communicate with upstream API"
      Response.new(success: false, error: error_message)
    end
  end

  class Response
    def initialize(options = {})
      @success = options.fetch(:success)
      @error = options[:error]
    end

    def success?
      @success
    end

    attr_reader :error
  end
end
