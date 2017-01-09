require "csv"

desc "Generates a list of published editions as a CSV"
task generate_list_of_published_editions: :environment do
  csv = CSV.generate do |rows|
    rows << %w(
      guide_id
      guide_slug
      edition_version
      edition_id
      edition_update_type
      edition_title
      edition_change_note
      edition_reason_for_change
    )

    Guide.live.find_each do |guide|
      editions = guide.editions.published
      editions.each do |edition|
        rows << [
          guide.id,
          guide.slug,
          edition.version,
          edition.id,
          edition.update_type,
          edition.title,
          edition.change_note,
          edition.reason_for_change
        ]
      end
    end
  end

  puts csv
end
