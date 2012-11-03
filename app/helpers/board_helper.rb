module BoardHelper

  AUTO_LINK_RE = /
                  (                       # leading text
                    <\w+.*?>|             #   leading HTML tag, or 
                    [^=!:'"\/]|           #   leading punctuation, or
                    ^                     #   beginning of line
                  )
                  (
                    (?:http[s]?:\/\/)|    # protocol spec, or
                    (?:www\.)             # www.*
                  )
                  (
                    ([\w]+:?[\~\,\+\%:;=?&\/.-]+?)*    # url segment
                    \w+[\/]?              # url tail
                    (?:\#\w*)?            # trailing anchor
                  )
                  ([[:punct:]]|\s|<|$)    # trailing text
                 /x unless const_defined?(:AUTO_LINK_RE)

  #
  # Turn all image urls into image tags.
  #
  def auto_image(html)
    return html.gsub(%r{http(s?):[a-z0-9/.\-_%~/\=\?\:]+(.gif|.jpg|.jpeg|.png|.bmp|.tif|.tiff)(?:\?[\w\=\.]+)?}i,
                     '<img src="\0"/>')
  end

  # Turns all urls into clickable links.  If a block is given, each url
  # is yielded and the result is used as the link text.  Example:
  #   auto_link_urls(post.body, :all, :target => '_blank') do |text|
  #     truncate(text, 15)
  #   end
  def my_auto_link(text, href_options = {})
    extra_options = tag_options(href_options.stringify_keys) || ""
    text.gsub(AUTO_LINK_RE) do
      all, a, b, c, d = $&, $1, $2, $3, $5
      if a =~ /<a\s/i # don't replace URL's that are already linked
        all
      else
        text = b + c
        text = yield(text) if block_given?
        %(#{a}<a href="#{b=="www."?"http://www.":b}#{c}"#{extra_options}>#{text}</a>#{d})
      end
    end
  end

  #
  # Turn all newlines to "<br/>"
  #
  def newline_to_br(html)
    return html.gsub("\r\n", "<br/>\n")
  end

  #
  # Get unissued invites of the current session
  #

  def get_unissued_invites()
    User.find(session[:user_id]).unissued_invites
  end

  def get_unread_message_count()
    return User.find(session[:user_id]).get_unread_message_count()
  end

  #
  # Misc
  #

  def user_disable_images()
    return User.find(session[:user_id]).disable_images
  end

  def user_disable_unread_messages()
    return User.find(session[:user_id]).disable_unread_messages
  end

end
