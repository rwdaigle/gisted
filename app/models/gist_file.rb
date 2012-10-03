class GistFile < ActiveRecord::Base

  attr_accessible :gist_id, :filename, :raw_url, :language, :file_type, :content, :size_bytes

  belongs_to :gist

  class << self

    def import(gist_id, gh_file)

      attributes = {
        gist_id: gist_id, filename: gh_file.filename, raw_url: gh_file.raw_url,
        language: gh_file.language, file_type: gh_file.type, size_bytes: gh_file['size'],
        content: gh_file.content
      }

      if(existing_file = where(gist_id: gist_id, filename: gh_file.filename).first)
        existing_file.update_attributes(attributes)
        existing_file
      else
        create(attributes)
      end
    end
  end
end
