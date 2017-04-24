# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'base64'

p Encoding.default_external

agent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari' }
comic = Comic.last.url
number = comic[28..-2].to_i
web_address = comic[0..27]
elastic_map = ENV['ELASTIC_MAP']
elastic_search_url = ENV['ELASTIC_SEARCH']
(number..419649).each do |num|
  url = "#{web_address}#{num}/"
  puts url
  puts num
# base =  ENV['SITE']
# (1..419649).each do |num|
#   url = base + "#{num}/"
  begin
  page = agent.get(url)
  rescue Exception => e
    puts e
    next
  end
  html_results = Nokogiri::HTML(page.body)
  if html_results.at_css('.no_cover').nil?
    series = ''
    issue = ''
    title = ''
    writer = ''
    img_url = ''
    img64 = ''

    series = html_results.at_css('#series_name a').text
    issue = html_results.at_css('.issue_number').text unless html_results.at_css('.issue_number').nil?
    title_text = html_results.at_css('.sequence.header.title .title.left').text
    title = title_text unless title_text == '[no title indexed]'
    img_url = html_results.at_css('.coverImage img').attr('src')
    writer = html_results.at_css('.credits span.credit_value').text

    uri = URI.parse(img_url)
    str = uri.read
    img64 = "data:"+ str.content_type + ";base64," + Base64.encode64(str)

    elastic_search = Comic.create(url: url, series: series, issue: issue, title: title,
                 writer: writer, img_url: img_url, img64: img64, page: page)
    if elastic_search.id != nil
      agent.post("#{elastic_search_url}#{elastic_map}#{elastic_search.id}", {"series"=> elastic_search.series, "issue"=> elastic_search.issue, "title"=> elastic_search.title, "writer"=> elastic_search.writer}.to_json, {'Content-Type' => 'application/json'})
    end
  else
    puts "nope"
  end
  sleep(rand(3))
end