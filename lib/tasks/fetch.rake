namespace :fetch do

  task :periodic => :environment do
    GistFetcher.fetch
    QUEUE.enqueue("User.refresh_indexes")    
  end
  
end