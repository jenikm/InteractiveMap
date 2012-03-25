# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def javascript_dom_loaded(function)
    javascript_tag %{document.observe('dom:loaded', function() { #{function} });}
  end

end
