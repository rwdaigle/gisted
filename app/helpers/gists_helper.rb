module GistsHelper

  def search_result_link(result)
    text = result.description
    text = "<em>Untitled</em>".html_safe if text.blank?
    link_to(text, result.url, :class => 'gist-url')
  end

  def files_display(result)
    # tag(:script, :src => "#{result.url}.js").html_safe
    result.files.collect do |file|
      content_tag(:script, nil, :src => "#{result.url}.js?file=#{file.filename}")
    end.join("<br/>").html_safe
  end

  def search_result_styles(result)
    styles = result.public? ? 'public' : 'private'
    styles += result.starred? ? ' starred' : ''
    styles += ' ' + result['files.language'].collect(&:downcase).uniq.join(' ')
  end
end