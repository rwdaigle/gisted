module GistsHelper

  def search_result_link(result)
    text = (result.highlight && result.highlight.description) ? result.highlight['description'].first.html_safe : result.description
    text = "<em>Untitled</em>".html_safe if text.blank?
    link_to(text, result.url)
  end

  def files_display(result)
    # tag(:script, :src => "#{result.url}.js").html_safe
    result.files.collect do |file|
      content_tag(:script, nil, :src => "#{result.url}.js?file=#{file.filename}")
    end.join("<br/>").html_safe
  end
end