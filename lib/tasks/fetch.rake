namespace :fetch do

  task :periodic => :environment do
    QC.enqueue("GistFetcher.fetch")
  end
  
end