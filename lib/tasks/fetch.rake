namespace :fetch do

  task :periodic => :environment do
    GistFetcher.fetch
  end
  
end