# Service-manual-publisher

Service Manual Publisher is in very early stages and is going to be used for publishing and maintaining https://gov.uk/service-manual. This application will replace the current [service manual application](https://github.com/alphagov/government-service-design-manual).

## Screenshots

![Landing page screenshot](http://i.imgur.com/UHqjufR.png)

![Edit interface screenshot](http://i.imgur.com/sFP1IUD.png)

## Nomenclature

- **Guide**: A service manual guide is the main document format used for manuals.
- **Guide Community**: A profile page that represents the community who curate a collection of guides.
- **Topic**: A collection of guides.

## Technical documentation

PostgreSQL-backed Rails 4 "Publishing 2.0" application for internal use, with no public facing aspect.

### Dependencies

- [publishing-api](https://github.com/alphagov/publishing-api)
- PostgreSQL

#### Optional dependencies

**To handle image uploads**

- [asset_manager](https://github.com/alphagov/asset-manager)

**To persist and render guides**

- [content-store](https://github.com/alphagov/content-store)
- [service-manual-frontend](https://github.com/alphagov/service-manual-frontend)

**To index and search published guides**

- [rummager](https://github.com/alphagov/rummager)
- [designprinciples](https://github.com/alphagov/design-principles)
- [frontend](https://github.com/alphagov/frontend)

_NB: Every application above may have its own dependencies_

You will need to clone down all these repositories, and run the following commands
for each one:

```
bundle
bundle exec rake db:setup
```

### Development

You can use [Bowler](https://github.com/JordanHatch/bowler) to automatically run
the application and all of its dependencies. To do this, you'll need to check
out the [development repository](https://github.gds/gds/development) where the
`Pinfile` is located.

```
cd /var/govuk/development
bowl service-manual-publisher service-manual-frontend
```

Alternatively, run `./startup.sh` in the `service-manual-publisher` directory on
the development VM.

```
cd /var/govuk/service-manual-publisher
./startup.sh
```

The application runs on port `3111` by default. If you're using the GDS VM it's
exposed on http://service-manual-publisher.dev.gov.uk.

The application has a style guide that can be accessed on `/style-guide`.

### Seeding old service manual data

The sample data is taken from the existing (to be deprecated)
[government-service-design-manual](https://github.com/alphagov/government-service-design-manual/) repository.
If you don't have a local clone of the
[government-service-design-manual](https://github.com/alphagov/government-service-design-manual/),
it will be cloned for you.

```
bundle exec rake import_old_service_manual_content
```

### Testing

`bundle exec rake`

## Migration from the original service manual

### Search

During the migration we have to manage items being added to the search index from the original service manual and the new one.

A JSON file containing the search data to be indexed is generated by [a script in goverment-service-design-manual](https://github.com/alphagov/government-service-design-manual/blob/master/compile.sh). A metadata attribute can be added to a migrated page to indicate that we no longer want to index the page in search. [Here is an example](https://github.com/alphagov/government-service-design-manual/commit/dd2943e6e0602225f088c77248e695c78eb8a8d1). During the deploy process this JSON file is sent to Rummager to be indexed by [a rake task in design-principles](https://github.com/alphagov/design-principles/blob/master/lib/tasks/rummager.rake). Finally, also during the deploy process, the search index for the original service manual is dropped and recreated [here](https://github.com/alphagov/govuk-puppet/blob/master/modules/govuk_jenkins/templates/jobs/service_manual_rebuild_search_index.yaml.erb).

## Licence

[MIT License](LICENCE)
