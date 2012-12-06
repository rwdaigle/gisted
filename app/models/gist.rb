class Gist < ActiveRecord::Base

  include Tire::Model::Search

  attr_accessible :gh_id, :user_id, :owner_gh_id, :owner_gh_username, :owner_gh_avatar_url, :description, :url, :git_pull_url, :git_push_url, :public,
    :comment_count, :gh_created_at, :gh_updated_at, :starred, :owned

  belongs_to :user, :touch => true
  has_many :files, :class_name => 'GistFile', :dependent => :delete_all

  before_save :check_for_new_comments

  scope :with_ids, lambda { |ids| where(ids.any? ? ["id in (?)", ids] : "1 = 0") }
  scope :starred, where(starred: true)
  scope :not_starred, where(["starred = ? OR starred IS NULL", false])
  scope :since, lambda { |time| time ? where(["updated_at > ?", time]) : scoped }

  index_name ELASTICSEARCH_INDEX_NAME

  mapping do
    indexes :description, :analyzer => 'snowball', :boost => 100
    indexes :gh_updated_at, type: 'date'
    indexes :user_id, :analyzer => :not_analyzed
    indexes :owner_gh_username, analyzer: 'keyword'
    indexes :starred, :analyzer => :not_analyzed
    indexes :files do
      indexes :filename, analyzer: 'standard', :boost => 10
      indexes :content, analyzer: 'snowball'
      indexes :language, analyzer: 'keyword'
      indexes :file_type, analyzer: 'standard'
    end
  end

  class << self

    def import(user_id, gh_gist, overrides = {})

      user = User.find(user_id)
      owned = (user.gh_id == gh_gist.user['id'])
      gh_id = gh_gist['id']

      attributes = {
        gh_id: gh_id, user_id: user.id, owner_gh_id: gh_gist.user['id'], owner_gh_username: gh_gist.user.login, owner_gh_avatar_url: gh_gist.user.avatar_url,
        description: gh_gist.description, url: gh_gist.html_url, git_push_url: gh_gist.git_push_url,
        git_pull_url: gh_gist.git_pull_url, public: gh_gist.public, comment_count: gh_gist.comments, owned: owned,
        gh_created_at: gh_gist.created_at, gh_updated_at: gh_gist.updated_at
      }.merge(overrides)

      if(existing_gist = user.gists.where(gh_id: gh_id).first)
        log({ns: self, fn: __method__, measure: true, at: 'gist-imported'}, user, existing_gist)
        existing_gist.update_attributes(attributes)
        existing_gist
      else
        new_gist = create(attributes)
        log({ns: self, fn: __method__, measure: true, at: 'gist-created'}, user, new_gist)
        new_gist
      end
    end

    # Clean me up!
    def search(user, q)
      log({ns: self, fn: __method__, query: q, measure: true, at: 'search'}, user)
      results = with_cache(search_cache_key(user, q)) do
        if(!q.blank?)
          log({ns: self, fn: __method__, query: q, measure: true}, user) do
            begin

              # Preprocess
              query_params = preprocess(user, q)

              tire.search :load => true do
                query { string query_params[:query] }
                fields query_params[:fields]
                query_params[:filter].each do |field, value|
                  filter :term, field => value
                end
                size query_params[:size]
              end
            rescue Tire::Search::SearchRequestFailed => e
              if(e.message.include?("SearchParseException")) # Swallow malformed queries
                return []
              else
                raise
              end
            end
          end
        else
          []
        end
      end

      log({ns: self, fn: __method__, query: q, measure: true, at: 'search-results'}, {:'result-count' => results.size}, user)
      results
    end

    def preprocess(user, q)

      # Standard stuff
      query = {}
      query[:fields] = [:description, :'files.filename', :'files.content']
      query[:filter] = {:user_id => user.id}
      query[:size] = 15

      # Extract "@jonmountjoy" owner syntax from queries
      if(owner_match = %r{@(\w+)}.match(q))
        query[:filter][:owner_gh_username] = owner = owner_match[1]
        q = q.sub("@#{owner}", "")
      end

      query[:query] = q.blank? ? "*" : q
      query
    end

    def reindex(gists = scoped)
      log({ns: self, fn: __method__}) do
        gists.find_in_batches(batch_size: ENV['ELASTICSEARCH_IMPORT_BATCH_SIZE'].to_i) do |gist_batch|
          tire.index.import(gist_batch)
        end
        # tire.index.refresh  # @nz said this wasn't needed
      end
    end

    def search_cache_key(user, q)
      "#{CACHE_ACTIVE ? CACHE_VERSION : "no-cache"}-user_id:#{user.id}-updated_at:#{user.updated_at}-#{q}"
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
      owner_gh_username: owner_gh_username,
      description: description,
      public: public?,
      starred: starred?,
      gh_updated_at: gh_updated_at,
      comment_count: comment_count,
      files: files.collect(&:indexed_attributes)
    }
  end

  private

  def check_for_new_comments
    if(!new_record? && comment_count_changed?)
      log({ns: self, fn: __method__, measure: true, at: 'comment-count-changed'}, self, user)
      QC.enqueue("CommentNotifier.gist_commented", id) if comment_count.to_i > comment_count_was.to_i
    end
  end

end
