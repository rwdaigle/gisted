class GistFile < ActiveRecord::Base

  attr_accessible :gist_id, :filename, :raw_url, :language, :file_type, :content, :size_bytes

  belongs_to :gist, :touch => true

  class << self

    def import(gh_gist)

      gist = Gist.where(gh_id: gh_gist['id']).first

      gh_gist.files.each do |filename, gh_file|

        attributes = {
          gist_id: gist.id, filename: gh_file.filename, raw_url: gh_file.raw_url,
          language: gh_file.language, file_type: gh_file.type, size_bytes: gh_file['size'],
          content: gh_file.content
        }

        if(existing_file = where(gist_id: gist.id, filename: gh_file.filename).first)
          log({ns: self, fn: __method__, at: "gist-file-updated"}, gist, existing_file)
          existing_file.update_attributes(attributes)
          existing_file
        else
          new_file = create(attributes)
          log({ns: self, fn: __method__, at: "gist-file-created"}, gist, new_file)
          new_file
        end
      end
    end
  end

  def to_log
    { file_id: id, file_filename: filename }
  end

  def indexed_attributes
    {
      filename: filename,
      content: content,
      language: language,
      file_type: file_type,
      size_bytes: size_bytes
    }
  end
end