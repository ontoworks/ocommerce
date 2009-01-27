xml.urlset do
  xml.url do
    xml.loc("http://www.theprinterdepot.net")
    xml.changefreq("daily")
  end
  @products.each do |p|
    @lastmod = nil
    if p.updated_at.nil?
      if !p.created_at.nil?
        @date = p.created_at.to_date
      end
    else
      @date = p.updated_at.to_date
    end
    xml.url do
      xml.loc("http://www.theprinterdepot.net#{p.url}")
      xml.lastmod(@date)
      xml.changefreq("weekly")
    end
  end
end