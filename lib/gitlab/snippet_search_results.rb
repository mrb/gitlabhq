module Gitlab
  class SnippetSearchResults < SearchResults
    include SnippetsHelper

    attr_reader :limit_snippet_ids

    def initialize(limit_snippet_ids, query)
      @limit_snippet_ids = limit_snippet_ids
      @query = query
    end

    def objects(scope, page = nil)
      case scope
      when 'snippet_titles'
        Kaminari.paginate_array(snippet_titles).page(page).per(per_page)
      when 'snippet_blobs'
        Kaminari.paginate_array(snippet_blobs).page(page).per(per_page)
      else
        super
      end
    end

    def total_count
      @total_count ||= snippet_titles_count + snippet_blobs_count
    end

    def snippet_titles_count
      @snippet_titles_count ||= snippet_titles.count
    end

    def snippet_blobs_count
      @snippet_blobs_count ||= snippet_blobs.count
    end

    private

    def snippet_titles
      Snippet.where(id: limit_snippet_ids).search(query).order('updated_at DESC')
    end

    def snippet_blobs
      search = Snippet.where(id: limit_snippet_ids).search_code(query)
      search = search.order('updated_at DESC').to_a
      snippets = []
      search.each { |e| snippets << chunk_snippet(e) }
      snippets
    end

    def default_scope
      'snippet_blobs'
    end
  end
end
