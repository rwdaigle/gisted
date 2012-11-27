namespace :gisted do

  task :work => :environment do
    GistedWorker.new.start
  end

  desc "Delete all gist data, and do a fresh fetch and reindex of all user data"
  task :rebuild => :environment do
    Gist.destroy_all
    Gist.tire.index.delete
    Gist.tire.index.create
    GistFetcher.fetch
    QC.enqueue("User.refresh_indexes", true)
  end
end