# frozen_string_literal: true

class PageTheFirst
  attr_reader :next_url

  def initialize(url)
    @next_url = url
  end

  def next
    Page.next(next_url)
  end
end
