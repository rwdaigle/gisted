class MonitorsController < ApplicationController
  
  def heartbeat
    respond_to do |format|
      format.json do
        render :json => {
          'search' => test_search,
          'db' => test_db,
          'cache' => !Rails.cache.exist?('monitors-heartbeat-foobar')
        }
      end
    end
  end

  private

  def test_search
    results = Gist.tire.search do
      query { string "*" }
      size 1
    end
    raise "SearchCheckFail" unless results.any?
    true
  end

  def test_db
    raise "DatabaseCheckFail" if Gist.order(:id).first.nil?
    true
  end

  def test_cache
    raise "CacheCheckFail" unless !Rails.cache.exist?('monitors-heartbeat-foobar')
    true
  end
end