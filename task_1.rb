require 'net/http'
require 'uri'
require 'nokogiri'
require 'json'

def request   
  uri = URI.parse("https://www.nasa.gov/api/2/ubernode/479003")
  request = Net::HTTP::Get.new(uri)
  request["Authority"] = "www.nasa.gov"
  request["Accept"] = "application/vnd.api+json"
  request["Accept-Language"] = "en-US,en;q=0.9"
  request["Referer"] = "https://www.nasa.gov/"
  request["Sec-Ch-Ua"] = "\"Not_A Brand\";v=\"99\", \"Google Chrome\";v=\"109\", \"Chromium\";v=\"109\""
  request["Sec-Ch-Ua-Mobile"] = "?0"
  request["Sec-Ch-Ua-Platform"] = "\"Linux\""
  request["Sec-Fetch-Dest"] = "empty"
  request["Sec-Fetch-Mode"] = "cors"
  request["Sec-Fetch-Site"] = "same-origin"
  request["User-Agent"] = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
  request["X-Requested-With"] = "XMLHttpRequest"
  
  req_options = {
    use_ssl: uri.scheme == "https",
  }
  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end
end

response = request
data = JSON.parse(response.body)
result_hash = {}
result_hash[:title] = data["_source"]["title"]
result_hash[:date] = data["_source"]["promo-date-time"].split('T')[0]
result_hash[:release_id] = data["_source"]["release-id"]
article = Nokogiri::HTML(data["_source"]["body"])
article.css('.dnd-atom-wrapper').remove
result_hash[:article] = article.text
puts result_hash
