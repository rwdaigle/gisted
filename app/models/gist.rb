class Gist < ActiveRecord::Base

  include Tire::Model::Search

  attr_accessible :gh_id, :user_id, :description, :url, :git_pull_url, :git_push_url, :public,
    :comment_count, :gh_created_at, :gh_updated_at

  belongs_to :user
  has_many :files, :class_name => 'GistFile', :dependent => :delete_all

  index_name ELASTICSEARCH_INDEX_NAME

  mapping do
    indexes :description, :analyzer => 'snowball', :boost => 10
    indexes :gh_created_at, type: 'date'
    indexes :user_id, :analyzer => :not_analyzed
    indexes :files do
      indexes :filename, analyzer: 'standard', :boost => 5
      indexes :content, analyzer: 'snowball'
      indexes :language, analyzer: 'keyword'
      indexes :file_type, analyzer: 'standard'
    end
  end

  class << self

    def import(gh_gist)

      user = User.where(gh_id: gh_gist.user.id).first
      gh_id = gh_gist['id']

      attributes = {
        gh_id: gh_id, user_id: user.id, description: gh_gist.description,
        url: gh_gist.html_url, git_push_url: gh_gist.git_push_url, git_pull_url: gh_gist.git_pull_url,
        public: gh_gist.public, comment_count: gh_gist.comments,
        gh_created_at: gh_gist.created_at, gh_updated_at: gh_gist.updated_at
      }

      if(existing_gist = where(gh_id: gh_id).first)
        log({ns: self, fn: __method__, measure: true, at: 'gist-imported'}, user, existing_gist)
        existing_gist.update_attributes(attributes)
        existing_gist
      else
        new_gist = create(attributes)
        log({ns: self, fn: __method__, measure: true, at: 'gist-created'}, user, new_gist)
        new_gist
      end
    end

    def search(user, q)
      log({ns: self, fn: __method__, query: q, measure: true, at: 'search'}, user)
      results = []
      begin
        results = with_cache(search_cache_key(user, q)) do
          if(!q.blank?)
            log({ns: self, fn: __method__, query: q, measure: true}, user) do
              tire.search do
                query { string q }
                fields [:description, :url, :public, :gh_updated_at, :id, :comment_count, :'files.filename', :'files.language']
                # sort { by :gh_created_at, 'desc' }
                filter :term, :user_id => user.id
                highlight :description, :options => { :tag => "<em>" }
                size 15
              end
            end
          else
            []
          end
        end

        log({ns: self, fn: __method__, query: q, measure: true, at: 'search-results'}, {:'result-count' => results.size}, user)

      rescue Exception => e
        Airbrake.notify(e, :params => { :query => q }.merge(user.to_log))
        log_exception({ns: self, fn: __method__, query: q, measure: true, at: 'exception'}, user)
      ensure
        return results
      end
    end

    def reindex(gists = scoped)
      log({ns: self, fn: __method__}) do
        tire.index.import gists
        # tire.index.refresh  # @nz said this wasn't needed
      end
    end

    def search_cache_key(user, q)
      "#{CACHE_ACTIVE ? CACHE_VERSION : "no-cache"}-user_id:#{user.id}-updated_at:#{user.last_gh_fetch ? user.last_gh_fetch.to_i : "never"}-#{q}"
    end

    def with_cache(key)
      if CACHE_ACTIVE
        Rails.cache.fetch(key) do
          yield
        end
      else
        yield
      end
    end
  end

  def to_log
    { gist_id: id, gist_gh_id: gh_id, gist_description: description }
  end

  # Required for Tire/Elasticsearch
  def to_indexed_json
    indexed_attributes.to_json
  end

  def indexed_attributes
    {
      user_id: user_id,
      description: description,
      url: url,
      public: public?,
      gh_created_at: gh_created_at,
      gh_updated_at: gh_updated_at,
      comment_count: comment_count,
      files: files.collect(&:indexed_attributes)
    }
  end

end
