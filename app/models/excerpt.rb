module Excerpt
  include Radiant::Taggable
  
  desc %Q{ Returns the first N characters (default 200) of the text, closing html tags properly. 
    The exact length will be off based on how many open tags must be closed. This tag doesn't work very 
    well for short excerpts with lots of opening tags.
    
    *Usage:*
    
    <pre><code><r:excerpt [length="200"] [strip_html="true|false"] [ok_tags="a href, b, br, p, i, em, strong"]>
      ...
    </r:excerpt></code></pre>
  }
  tag "excerpt" do |tag|
    tag.attr['length'] ||= 200
    tag.attr['strip_html'] ||= false
    tag.attr['ok_tags'] ||= "a href, b, br, p, i, em, strong"

    content = object_to_boolean(tag.attr['strip_html']) ? helper.strip_tags(tag.expand).gsub(/\s+/," ") : tag.expand
    
    length = tag.attr['length'].to_i
    
    truncated_text = helper.truncate(content, :length => length)
    sanitize_excerpt(truncated_text, tag.attr['ok_tags'])
  end
  
  # Adapted from http://snippets.dzone.com/posts/show/3822
  # !!Fails if the end of the html contains an opening tag that doesn't close ie. "laksdjlk<a href"
  def sanitize_excerpt(html, okTags)
    # no closing tag necessary for these
    soloTags = ["br","hr"]

    # Build hash of allowed tags with allowed attributes
    tags = okTags.downcase().split(',').collect!{ |s| s.split(' ') }
    allowed = Hash.new
    tags.each do |s|
      key = s.shift
      allowed[key] = s
    end

    # Analyze all <> elements
    stack = Array.new
    result = html.gsub( /(<.*?>)/m ) do | element |
      if element =~ /\A<\/(\w+)/ then
        # </tag>
        tag = $1.downcase
        if allowed.include?(tag) && stack.include?(tag) then
          # If allowed and on the stack
          # Then pop down the stack
          top = stack.pop
          out = "</#{top}>"
          until top == tag do
            top = stack.pop
            out << "</#{top}>"
          end
          out
        end
      elsif element =~ /\A<(\w+)\s*\/>/
        # <tag />
        tag = $1.downcase
        if allowed.include?(tag) then
          "<#{tag} />"
        end
      elsif element =~ /\A<(\w+)/ then
        # <tag ...>
        tag = $1.downcase
        if allowed.include?(tag) then
          if ! soloTags.include?(tag) then
            stack.push(tag)
          end
          if allowed[tag].length == 0 then
            # no allowed attributes
            "<#{tag}>"
          else
            # allowed attributes?
            out = "<#{tag}"
            while ( $' =~ /(\w+)=("[^"]+")/ )
              attr = $1.downcase
              valu = $2
              if allowed[tag].include?(attr) then
                out << " #{attr}=#{valu}"
              end
            end
            out << ">"
          end
        end
      end
    end

    # eat up unmatched leading >
    while result.sub!(/\A([^<]*)>/m) { $1 } do end

    # eat up unmatched trailing <
    while result.sub!(/<([^>]*)\Z/m) { $1 } do end

    # clean up the stack
    if stack.length > 0 then
      result << "</#{stack.reverse.join('></')}>"
    end

    result
  end

  def helper
    @helper ||= ActionView::Base.new
  end
  
  def object_to_boolean(value)
    return [true, "true", 1, "1", "T", "t"].include?(value.class == String ? value.downcase : value)
  end
end