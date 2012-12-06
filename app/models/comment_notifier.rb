class CommentNotifier

  class << self

    def gist_commented(gist_id)
      gist = Gist.find(gist_id)
      user = gist.user
      if(user.notify_comments?)
        log({ns: self, fn: __method__, measure: true, at: 'sending-notification'}, gist, user)
        Pony.mail(:to => user.gh_email, :subject => "\"#{gist.description}\" has a new comment", :body => <<-EOS)
The extremely unsophisticated comment-detection algorithm at Gisted would like to let you know that you have a new comment on your "#{gist.description}" gist.

View your gist's comments at #{gist.url}#comments

---
-Gisted (https://gistedapp.herokuapp.com/)

If this email offends your delicate sensibilities, you can opt out by clikcing the "turn off comment notifications" link on the Gisted interface: https://gistedapp.herokuapp.com/ or by complaining directly to @rwdaigle.
        EOS
      end
    end
  end
end