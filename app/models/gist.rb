class Gist < ActiveRecord::Base

  attr_accessible :gh_id, :user_id, :description, :url, :git_pull_url, :git_push_url, :public, :comment_count, :gh_created_at, :gh_updated_at

  belongs_to :user
  has_many :files, :class_name => 'GistFile', :dependent => :delete_all

  class << self

    def import(gh_gist)
      gist = import_gist(gh_gist)
      gist.import_files(gh_gist)
      gist
    end

    protected

    def import_gist(gh_gist)

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
        Gist.create(attributes)
      end
    end
  end

  def import_files(gh_gist)
    gh_gist.files.each do |filename, gh_file|
      GistFile.import(id, gh_file)
    end
  end
end
