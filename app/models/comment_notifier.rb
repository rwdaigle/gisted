class CommentNotifier

  class << self

    def gist_commented(gist_id)
      gist = Gist.find(gist_id)
      user = gist.user
      # Mail!
    end
  end
end