class MonitorsController < ApplicationController
  
  def heartbeat
    respond_to do |format|
      format.json do
        render :json => {
          'search' => test_search.any?,
          'db' => !Gist.order(:id).first.nil?,
          'cache' => !Rails.cache.exist?('monitors-heartbeat-foobar')
        }
      end
    end
  end

  private

  def test_search
    Gist.tire.search do
      query { string "*" }
      size 1
    end
  end
end