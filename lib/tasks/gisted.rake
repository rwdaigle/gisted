namespace :gisted do

  task :work => :environment do
    GistedWorker.new.start
  end
end