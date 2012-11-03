
#require 'ferret'
#include Ferret::Analysis
#include Ferret::Index
#include Ferret::Search

#
# A search engine for Post and Topic objects.
#
# Inserting objects:
#
#   topic = Topic.new(...)
#   SearchEngine.insert_topic(topic.id, topic.title)
#
#   post = Post.new(...)
#   SearchEngine.insert_post(post.id, post.content)
#
# Searching:
#
#   terms = ['first','topic']
#   topics = Topic.find(SearchEngine.search_topics(terms))
#
#   terms = ['first','post']
#   posts = Post.find(SearchEngine.search_topics(terms))
#
class SearchEngine

  @@index = nil

  #
  # PUBLIC METHODS
  #

  #
  # Insert topic title.
  #
  # @param id Topic object id
  # @param title Topic object title
  #
  def self.insert_topic(id, title)
    #begin
    #  init_index()
    #rescue
    #  sleep 0.2
    #  init_index()
    #end

    #begin
    #  @@index << {:model=>:topic,:id=>id,:title=>title}
    #rescue
    #  sleep 0.3
    #  @@index << {:model=>:topic,:id=>id,:title=>title}
    #end
  end

  #
  # Insert post content.
  #
  # @param id Post object id
  # @param content Post object content
  #
  def self.insert_post(id, content)
    #begin
    #  init_index()
    #rescue
    #  sleep 0.3
    #  init_index()
    #end

    #begin
    #  @@index << {:model=>:post,:id=>id,:content=>content}
    #rescue
    #  sleep 0.4
    #  @@index <<  {:model=>:post,:id=>id,:content=>content}
    #end
  end

  #
  # Search topics that match an array of terms.
  #
  # @param terms an array of terms in lowercase (String)
  # @return an array of Topic ids.
  #
  def self.search_topics(terms)
    #init_index()
    # TODO: implement index paging
    #return @@index.search(create_topic_query(terms),
    #                      {:limit=>:all,
    #                       :sort=>"id DESC"}).hits.map{|h| @@index[h.doc][:id]}
    return []
  end

  #
  # Search posts that match an array of terms.
  #
  # @param terms an array of terms in lowercase (String)
  # @return an array of Post ids.
  #
  def self.search_posts(terms)
    #init_index()
    # TODO: implement index paging
    #return @@index.search(create_post_query(terms), 
    #                      {:limit=>:all,
    #                       :sort=>"id DESC"}).hits.map{|h| @@index[h.doc][:id]}
    return []
  end


  #
  # PRIVATE METHODS
  #

  private 

  #
  # An analyzer that uses stem and stop filters.
  #
  #class MyAnalyzer < Analyzer
  #  def token_stream(field, str)
  #    return StopFilter.new(
  #           LowerCaseFilter.new(
  #           StandardTokenizer.new(str)))
  #  end
  #end

  #
  # Create a multi-term query over posts.
  #
  # @param terms an array of terms (String)
  #
  def self.create_post_query(terms)
    #query = MultiTermQuery.new(:content, :max_term=>10)
    #terms.each {|term| query << term}
    #return query
  end

  #
  # Create a multi-term query over topics.
  #
  # @param terms an array of terms (String)
  #
  def self.create_topic_query(terms)
    #query = MultiTermQuery.new(:title, :max_term=>10)
    #terms.each {|term| query << term}
    #return query
  end

  #
  # Initialize the index.
  #
  def self.init_index()
    #if not @@index 
    #  @@index = Index.new(:path=>INDEX_WORK_DIR,
    #                      :key=>[:model,:id],
    #                      :analyzer=>MyAnalyzer.new) 
    #end
  end

end
