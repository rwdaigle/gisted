Rack::Worker.cache = Dalli::Client.new(nil, {:expires_in => 300})
Rack::Worker.queue = QC