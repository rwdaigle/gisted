module GistsHelper

  def search_result_link(result)
    text = (result.highlight && result.highlight.description) ? result.highlight['description'].first.html_safe : result.description
    text = "<em>Untitled</em>".html_safe if text.blank?
    link_to(text, result.url)
  end
end