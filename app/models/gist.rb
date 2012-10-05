class Gist < ActiveRecord::Base

  include Tire::Model::Search

  attr_accessible :gh_id, :user_id, :description, :url, :git_pull_url, :git_push_url, :public,
    :comment_count, :gh_created_at, :gh_updated_at

  belongs_to :user
  has_many :files, :class_name => 'GistFile', :dependent => :delete_all

  mapping do
    indexes :description, :analyzer => 'snowball', :boost => 10
    indexes :gh_created_at, type: 'date'
    indexes :files do
      indexes :filename, analyzer: 'keyword'
      indexes :content, analyzer: 'snowball'
      indexes :language, analyzer: 'keyword'
      indexes :file_type, analyzer: 'keyword'
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
        existing_gist.update_attributes(attributes)
        existing_gist
      else
        create(attributes)
      end
    end

    def search(q)
      tire.search do
        query { string q }
        sort { by :gh_created_at, 'desc' }
        highlight :description, :'files.content'
      end
    end

    def reindex
      find_each { |gist| gist.update_index }
      tire.index.refresh
    end
  end

  # Required for Tire/Elasticsearch
  def to_indexed_json
    indexed_attributes.to_json
  end

  def indexed_attributes
    {
      description: description,
      url: url,
      public: public?,
      gh_created_at: gh_created_at,
      gh_updated_at: gh_updated_at,
      files: files.collect(&:indexed_attributes)
    }
  end
end
