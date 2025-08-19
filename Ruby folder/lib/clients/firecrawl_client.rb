# frozen_string_literal: true

# Firecrawl API Client for web scraping Airbnb data
require 'httparty'
require 'json'

class FirecrawlClient
  include HTTParty
  
  def initialize(api_key = nil)
    @api_key = api_key || ENV['FIRECRAWL_API_KEY']
    @base_url = 'https://api.firecrawl.dev/v1'
    
    raise "FIRECRAWL_API_KEY not found in environment variables" unless @api_key
    
    self.class.headers({
      'Authorization' => "Bearer #{@api_key}",
      'Content-Type' => 'application/json'
    })
    
    self.class.default_timeout 30
  end

  # Search Airbnb listings for a specific location
  def search_airbnb_listings(location, options = {})
    search_query = build_airbnb_search_query(location, options)
    
    puts "🔍 Searching Airbnb for: #{search_query}"
    
    payload = {
      query: search_query,
      pageOptions: {
        onlyMainContent: true,
        includeHtml: false,
        screenshot: false
      },
      searchOptions: {
        limit: options[:limit] || 20
      }
    }

    make_request("#{@base_url}/search", payload)
  end

  private

  def build_airbnb_search_query(location, options)
    query_parts = ["Airbnb", location]
    
    query_parts << "#{options[:guests]} guests" if options[:guests]
    query_parts << options[:property_type] if options[:property_type]
    query_parts << "under $#{options[:budget_max]}" if options[:budget_max]
    query_parts << "#{options[:check_in]} to #{options[:check_out]}" if options[:check_in] && options[:check_out]
    
    query_parts.join(' ')
  end

  def make_request(endpoint, payload)
    retries = 0
    max_retries = 3
    
    begin
      response = self.class.post(endpoint, body: payload.to_json)
      
      if response.success?
        result = JSON.parse(response.body)
        puts "✅ Firecrawl request successful - found #{result.dig('data')&.length || 0} results"
        result
      else
        raise "Firecrawl API error: #{response.code} - #{response.body}"
      end
    rescue => e
      retries += 1
      if retries <= max_retries
        puts "⚠️  Retry #{retries}/#{max_retries} for Firecrawl request"
        sleep(1 * retries) # Exponential backoff
        retry
      else
        puts "❌ Failed after #{max_retries} retries: #{e.message}"
        { 'data' => [], 'error' => e.message }
      end
    end
  end
end
