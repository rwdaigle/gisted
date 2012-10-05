namespace :search do

  # Reindex all gists
  task :reindex => :environment do
    Gist.reindex
  end

  # Delete existing gist index, create new one and reindex all gists
  task :rebuild => :environment do
    Gist.tire.index.delete
    Gist.tire.index.create
    Gist.reindex
  end

end