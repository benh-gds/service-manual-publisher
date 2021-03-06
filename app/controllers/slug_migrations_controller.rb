class SlugMigrationsController < ApplicationController
  def index
    @migrations = SlugMigration.order(updated_at: :desc)
    if params[:completed].present?
      @migrations.where!(completed: params[:completed])
    end

    @completed_count = SlugMigration.where(completed: true).count
    @incompleted_count = SlugMigration.where(completed: false).count
  end

  def edit
    @slug_migration = SlugMigration.find(params[:id])
  end

  def update
    @slug_migration = SlugMigration.find(params[:id])

    slug_migration_parameters = params.require(:slug_migration)
      .permit(:redirect_to)
    slug_migration_parameters[:completed] = true

    ActiveRecord::Base.transaction do
      if @slug_migration.update_attributes(slug_migration_parameters)
        RedirectPublisher.new.process(
          content_id: @slug_migration.content_id,
          old_path:   @slug_migration.slug,
          new_path:   @slug_migration.redirect_to,
        )

        redirect_to slug_migration_path(@slug_migration), notice: "Slug Migration has been completed"
      else
        render action: :edit
      end
    end
  rescue GdsApi::HTTPServerError
    flash[:error] = "An error was encountered while trying to publish the slug redirect"
    render action: :edit
  rescue GdsApi::HTTPNotFound
    flash[:error] = "Couldn't migrate slug because the previous slug does not exist"
    render action: :edit
  end

  def show
    @slug_migration = SlugMigration.find(params[:id])
  end
end
