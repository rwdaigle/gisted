namespace :fetch do

  task :periodic => :environment do
    GistFetcher.fetch
    QC.enqueue("User.refresh_indexes")    
  end
  
end