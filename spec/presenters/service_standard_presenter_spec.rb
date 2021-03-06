require "rails_helper"

RSpec.describe ServiceStandardPresenter, "#content_id" do
  it "returns a preassigned UUID" do
    expect(
      described_class.new.content_id
    ).to eq("00f693d4-866a-4fe6-a8d6-09cd7db8980b")
  end
end

RSpec.describe ServiceStandardPresenter, "#content_payload" do
  it "returns a payload that validates against the service standard schema" do
    payload = described_class.new.content_payload

    expect(payload).to be_valid_against_schema 'service_manual_service_standard'
  end

  it "returns a hash suitable for a service standard draft" do
    expected_payload = {
      base_path: '/service-manual/service-standard',
      document_type: 'service_manual_service_standard',
      locale: 'en',
      phase: 'beta',
      publishing_app: 'service-manual-publisher',
      rendering_app: 'service-manual-frontend',
      routes: [
        { type: 'exact', path: '/service-manual/service-standard' }
      ],
      schema_name: 'service_manual_service_standard',
      title: 'Digital Service Standard',
      description: "The Digital Service Standard is a set of 18 criteria to help government create and run good digital services.",
      details: {
        body: "All public facing transactional services must meet the standard. It’s used by departments and the Government Digital Service to check whether a service is good enough for public use.",
      }
    }

    expect(
      described_class.new.content_payload
    ).to eq(expected_payload)
  end
end

RSpec.describe ServiceStandardPresenter, '#links_payload' do
  it "includes a link to the email alert signup for the service standard" do
    presented_service_standard = described_class.new

    links = presented_service_standard.links_payload[:links]

    expect(links).to include(
      email_alert_signup: ["4a94ae54-5a47-40c1-b9aa-ff47dcaace85"]
    )
  end
end
