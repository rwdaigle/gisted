namespace :search do

  # Reindex all gists
  task :reindex => :environment do
    User.refresh_indexes
  end

  # Delete existing gist index, create new one and reindex all gists
  task :rebuild => :environment do
    Gist.tire.index.delete
    Gist.tire.index.create
    User.refresh_indexes
  end

end