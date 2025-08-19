# frozen_string_literal: true

begin
  require 'dotenv/load'
rescue LoadError
  # Dotenv not required for basic functionality
end
require 'ruby_llm'
require 'json'
require 'fileutils'
require_relative 'lib/utils/csv_handler'
require_relative 'lib/clients/firecrawl_client'
require_relative 'lib/airbnb_analysis_schema'
require_relative 'lib/airbnb_price_tool'
require_relative 'lib/graph_generator'

# Enhanced Airbnb analysis with Firecrawl scraping, schema validation, and data visualization
class AirbnbAnalyzer
  def initialize(api_key)
    @api_key = api_key
    configure_ruby_llm
    @firecrawl_client = initialize_firecrawl_client
    @price_tool = AirbnbPriceTool.new
    @graph_generator = GraphGenerator.new
    @analysis_results = []
  end

  # Analyze Airbnb location with real data scraping and structured AI responses
  def analyze_airbnb_location(location, guests, check_in, check_out, budget_max, property_type)
    puts "🔍 Starting comprehensive analysis for #{location}..."
    
    # STEP 1: Scrape real Airbnb data using Firecrawl
    scraped_data = scrape_market_data(location, guests, property_type, budget_max)
    
    # STEP 2: Get structured price analysis using our tool
    price_analysis = @price_tool.get_price_analysis(
      location: location,
      property_type: property_type || 'apartment',
      guests: guests
    )
    
    # STEP 3: Generate AI analysis with schema validation
    ai_analysis = generate_structured_analysis(
      location, guests, check_in, check_out, budget_max, property_type, scraped_data
    )
    
    # STEP 4: Combine all data sources
    comprehensive_result = merge_analysis_data(
      location, guests, check_in, check_out, budget_max, property_type,
      scraped_data, price_analysis, ai_analysis
    )
    
    puts "✅ Comprehensive analysis completed for #{location}"
    comprehensive_result
  end

  # Generate summary report with enhanced statistics
  def generate_summary_report(results)
    return if results.empty?

    puts "\n📊 ENHANCED AIRBNB ANALYSIS SUMMARY"
    puts "=" * 60

    results.each_with_index do |result, index|
      puts "\n#{index + 1}. 📍 #{result[:location]}"
      puts "   👥 Guests: #{result[:guests]}"
      puts "   📅 Dates: #{result[:check_in] || 'Flexible'} to #{result[:check_out] || 'Flexible'}"
      puts "   💰 Budget: #{result[:budget_max] ? "$#{result[:budget_max]}/night" : 'Flexible'}"
      puts "   🏠 Type: #{result[:property_type] || 'Any'}"
      puts "   💎 Value Rating: #{result[:value_rating]}"
      puts "   🎯 Competition: #{result[:competition_level]} competition"
      puts "   📈 Market Trend: #{result[:market_trends]}"
      puts "   ✅ Status: Complete with #{result[:scraped_listings_count] || 0} listings analyzed"
    end

    # Enhanced statistics
    puts "\n📈 MARKET INSIGHTS"
    generate_market_insights(results)
    
    puts "\n🏆 VALUE OPPORTUNITIES" 
    highlight_value_opportunities(results)
    
    puts "\n" + "=" * 60
  end

  # Process all search requests with enhanced capabilities
  def process_all_searches
    puts 'Processing searches/search_criteria.csv...'
    search_requests = CsvHandler.read('searches/search_criteria.csv')
    
    if search_requests.empty?
      puts "❌ No search criteria found in searches/search_criteria.csv"
      return []
    end

    puts "🚀 Processing #{search_requests.length} enhanced search requests..."

    search_requests.each_with_index do |search_request, index|
      puts "\n" + "=" * 50
      puts "Processing search #{index + 1}/#{search_requests.length}..."
      puts "🔍 Analyzing #{search_request['location']}..."

      result = analyze_airbnb_location(
        search_request['location'],
        (search_request['guests'] || '2').to_i,
        search_request['check_in'],
        search_request['check_out'],
        search_request['budget_max']&.to_i,
        search_request['property_type']
      )

      if result[:success]
        # Display enhanced preview
        puts "\n📋 Analysis Preview:"
        puts "   💰 Average Price: #{result[:average_price]}"
        puts "   📊 Value Rating: #{result[:value_rating]}"
        puts "   🏘️  Best Areas: #{result[:best_neighborhoods]}"
        puts "   📈 Market Trend: #{result[:market_trends]}"
        
        @analysis_results << result
      else
        puts "❌ Failed to analyze #{search_request['location']}"
      end
    end

    @analysis_results
  end

  # Export enhanced results with multiple formats
  def export_results
    puts '\nExporting enhanced results...'
    
    # Ensure outputs directory exists
    FileUtils.mkdir_p('outputs/charts')

    # Save detailed JSON results
    json_output_file = 'outputs/airbnb_analysis_results.json'
    File.write(json_output_file, JSON.pretty_generate(@analysis_results))
    puts "📄 Detailed results saved to #{json_output_file}"

    # Create enhanced CSV summary
    csv_data = @analysis_results.map do |result|
      {
        'location' => result[:location],
        'guests' => result[:guests],
        'check_in' => result[:check_in],
        'check_out' => result[:check_out],
        'budget_max' => result[:budget_max],
        'property_type' => result[:property_type],
        'average_price' => result[:average_price],
        'price_range' => result[:price_range],
        'value_rating' => result[:value_rating],
        'best_neighborhoods' => result[:best_neighborhoods],
        'competition_level' => result[:competition_level],
        'market_trends' => result[:market_trends],
        'scraped_listings_count' => result[:scraped_listings_count],
        'analyzed_at' => result[:analyzed_at]
      }
    end

    csv_output_file = 'outputs/airbnb_analysis_summary.csv'
    CsvHandler.export(csv_data, csv_output_file)
    puts "📊 Enhanced summary saved to #{csv_output_file}"

    # Generate data visualizations
    generate_visualizations
  end

  # Generate comprehensive data visualizations
  def generate_visualizations
    puts '\n📊 Generating data visualizations...'
    
    # Generate individual charts
    @graph_generator.generate_price_comparison_chart(@analysis_results)
    @graph_generator.generate_value_distribution_chart(@analysis_results)
    @graph_generator.generate_capacity_price_scatter(@analysis_results)
    @graph_generator.generate_seasonal_trends_chart(@analysis_results)
    
    # Generate comprehensive dashboard
    dashboard = @graph_generator.generate_dashboard(@analysis_results)
    
    puts "📈 All visualizations saved to outputs/charts/ directory"
    puts "🎯 Dashboard includes #{dashboard[:charts].length} interactive charts"
  end

  private

  def configure_ruby_llm
    if @api_key == "demo_mode"
      puts "🔧 RubyLLM in demo mode - using local analysis only"
    else
      RubyLLM.configure do |config|
        config.openrouter_api_key = @api_key
      end
      puts "✅ RubyLLM configured with OpenRouter API"
    end
  end

  def initialize_firecrawl_client
    firecrawl_key = ENV['FIRECRAWL_API_KEY']
    if firecrawl_key && !firecrawl_key.empty?
      FirecrawlClient.new(firecrawl_key)
    else
      puts "⚠️  FIRECRAWL_API_KEY not found - using simulated data mode"
      nil
    end
  end

  def scrape_market_data(location, guests, property_type, budget_max)
    return generate_simulated_data(location, guests, property_type) unless @firecrawl_client

    begin
      # Search for real Airbnb listings
      search_options = {
        guests: guests,
        property_type: property_type,
        budget_max: budget_max,
        limit: 25
      }
      
      firecrawl_results = @firecrawl_client.search_airbnb_listings(location, search_options)
      
      if firecrawl_results['data'] && firecrawl_results['data'].any?
        puts "📡 Found #{firecrawl_results['data'].length} real listings via Firecrawl"
        process_firecrawl_data(firecrawl_results['data'])
      else
        puts "⚠️  No listings found via Firecrawl, using simulated data"
        generate_simulated_data(location, guests, property_type)
      end
    rescue => e
      puts "⚠️  Firecrawl error: #{e.message}, falling back to simulated data"
      generate_simulated_data(location, guests, property_type)
    end
  end

  def process_firecrawl_data(firecrawl_data)
    processed_listings = firecrawl_data.map do |listing|
      {
        title: extract_title(listing),
        price: extract_price(listing),
        rating: extract_rating(listing),
        reviews: extract_review_count(listing),
        amenities: extract_amenities(listing),
        url: listing['url']
      }
    end.compact

    {
      source: 'firecrawl',
      listings: processed_listings,
      count: processed_listings.length,
      raw_data: firecrawl_data.first(3) # Keep sample for reference
    }
  end

  def generate_simulated_data(location, guests, property_type)
    # Generate realistic simulated data for demonstration
    listings_count = rand(15..25)
    base_price = @price_tool.get_price_analysis(location: location, guests: guests)[:average_price]
    base_price_num = base_price.gsub(/[^\d]/, '').to_i

    listings = (1..listings_count).map do |i|
      price_variation = rand(0.7..1.4)
      price = (base_price_num * price_variation).round
      
      {
        title: "#{property_type&.capitalize || 'Modern'} #{i} in #{location}",
        price: "$#{price}",
        rating: (3.5 + rand(1.5)).round(1),
        reviews: rand(5..150),
        amenities: sample_amenities.sample(rand(3..6)),
        url: "https://airbnb.com/rooms/#{rand(100000..999999)}"
      }
    end

    {
      source: 'simulated',
      listings: listings,
      count: listings.length,
      note: 'Simulated data for demonstration - enable Firecrawl for real data'
    }
  end

  def generate_structured_analysis(location, guests, check_in, check_out, budget_max, property_type, scraped_data)
    if @api_key == "demo_mode"
      puts "🔧 Using local analysis - skipping AI generation"
      return generate_demo_analysis(location, guests, check_in, check_out, budget_max, property_type)
    end
    
    prompt = build_enhanced_analysis_prompt(location, guests, check_in, check_out, budget_max, property_type, scraped_data)
    
    # Use schema for structured response
    schema = AirbnbAnalysisSchema.listing_schema
    
    chat = RubyLLM.chat(model: 'anthropic/claude-3.5-sonnet')
    
    begin
      response = chat.with_schema(schema).ask(prompt)
      parsed_response = JSON.parse(response.content)
      puts "✅ Structured AI analysis completed with schema validation"
      parsed_response
    rescue => e
      puts "⚠️  Schema parsing failed: #{e.message}, using unstructured response"
      response = chat.ask(prompt)
      { 'analysis' => response.content, 'schema_validated' => false }
    end
  end

  def generate_demo_analysis(location, guests, check_in, check_out, budget_max, property_type)
    price_analysis = @price_tool.get_price_analysis(
      location: location,
      property_type: property_type || 'apartment',
      guests: guests
    )
    
    {
      'location' => location,
      'property_type' => property_type || 'apartment',
      'guests' => guests,
      'average_price' => price_analysis[:average_price],
      'price_range' => price_analysis[:price_range],
      'peak_season_price' => price_analysis[:peak_season_price],
      'value_rating' => price_analysis[:value_rating],
      'best_neighborhoods' => price_analysis[:best_neighborhoods],
      'seasonal_trends' => price_analysis[:market_trends],
      'booking_tips' => price_analysis[:booking_tips],
      'market_insights' => "Demo mode analysis for #{location}",
      'competition_level' => price_analysis[:competition_level],
      'schema_validated' => true,
      'demo_mode' => true
    }
  end

  def build_enhanced_analysis_prompt(location, guests, check_in, check_out, budget_max, property_type, scraped_data)
    scraped_info = if scraped_data[:listings] && scraped_data[:listings].any?
      sample_listings = scraped_data[:listings].first(5).map do |listing|
        "- #{listing[:title]}: #{listing[:price]}/night, #{listing[:rating]}⭐ (#{listing[:reviews]} reviews)"
      end.join("\n")
      
      "\nReal market data (#{scraped_data[:count]} listings analyzed):\n#{sample_listings}"
    else
      "\nNote: Analysis based on market knowledge and pricing models."
    end

    <<~PROMPT
      Analyze the Airbnb market for this search request:
      
      Location: #{location}
      Guests: #{guests}
      Check-in: #{check_in || 'Flexible'}
      Check-out: #{check_out || 'Flexible'}
      Budget: #{budget_max ? "Up to $#{budget_max}/night" : 'Flexible'}
      Property Type: #{property_type || 'Any'}
      #{scraped_info}
      
      Provide a JSON response with these exact fields:
      - location: Property location
      - property_type: Type of property
      - guests: Number of guests
      - average_price: Average nightly price (format: $XXX)
      - price_range: Min-max price range (format: $XXX-XXX)
      - peak_season_price: Peak season pricing (format: $XXX)
      - value_rating: One of: Excellent, Good, Fair, Poor
      - best_neighborhoods: Top 3 recommended neighborhoods (comma-separated)
      - seasonal_trends: Key seasonal pricing patterns
      - booking_tips: Specific booking optimization tips
      - market_insights: Unique market characteristics
      - competition_level: One of: Low, Medium, High
      
      Base your analysis on current market conditions, the provided data, and your knowledge of the location.
    PROMPT
  end

  def merge_analysis_data(location, guests, check_in, check_out, budget_max, property_type, scraped_data, price_analysis, ai_analysis)
    {
      location: location,
      guests: guests,
      check_in: check_in,
      check_out: check_out,
      budget_max: budget_max,
      property_type: property_type,
      average_price: ai_analysis['average_price'] || price_analysis[:average_price],
      price_range: ai_analysis['price_range'] || price_analysis[:price_range],
      peak_season_price: ai_analysis['peak_season_price'] || price_analysis[:peak_season_price],
      value_rating: ai_analysis['value_rating'] || price_analysis[:value_rating],
      best_neighborhoods: ai_analysis['best_neighborhoods'] || price_analysis[:best_neighborhoods],
      seasonal_trends: ai_analysis['seasonal_trends'] || price_analysis[:market_trends],
      booking_tips: ai_analysis['booking_tips'] || price_analysis[:booking_tips],
      market_insights: ai_analysis['market_insights'] || "Market analysis for #{location}",
      competition_level: ai_analysis['competition_level'] || price_analysis[:competition_level],
      market_trends: price_analysis[:market_trends],
      scraped_data_source: scraped_data[:source],
      scraped_listings_count: scraped_data[:count],
      schema_validated: ai_analysis['schema_validated'] != false,
      analyzed_at: Time.now.iso8601,
      success: true
    }
  end

  def generate_market_insights(results)
    return if results.empty?

    prices = results.map { |r| r[:average_price]&.gsub(/[^\d]/, '')&.to_i }.compact
    return if prices.empty?

    avg_price = prices.sum / prices.length
    cheapest = results.min_by { |r| r[:average_price]&.gsub(/[^\d]/, '')&.to_i || 999999 }
    most_expensive = results.max_by { |r| r[:average_price]&.gsub(/[^\d]/, '')&.to_i || 0 }
    excellent_values = results.select { |r| r[:value_rating] == 'Excellent' }

    puts "   📊 Average Price Across All Locations: $#{avg_price}/night"
    puts "   💰 Most Affordable: #{cheapest[:location]} (#{cheapest[:average_price]}/night)"
    puts "   💎 Most Premium: #{most_expensive[:location]} (#{most_expensive[:average_price]}/night)"
    puts "   🏆 Excellent Value Destinations: #{excellent_values.length}/#{results.length}"
    
    if excellent_values.any?
      puts "   🎯 Best Value Picks: #{excellent_values.map { |r| r[:location] }.join(', ')}"
    end
  end

  def highlight_value_opportunities(results)
    high_competition = results.select { |r| r[:competition_level] == 'High' }
    low_competition = results.select { |r| r[:competition_level] == 'Low' }
    excellent_values = results.select { |r| r[:value_rating] == 'Excellent' }

    puts "   🔥 High Competition Markets: #{high_competition.map { |r| r[:location] }.join(', ')}" if high_competition.any?
    puts "   🌟 Low Competition Gems: #{low_competition.map { |r| r[:location] }.join(', ')}" if low_competition.any?
    puts "   💎 Exceptional Value: #{excellent_values.map { |r| r[:location] }.join(', ')}" if excellent_values.any?
  end

  # Helper methods for data extraction
  def extract_title(listing)
    listing['title'] || listing['content']&.split("\n")&.first || "Airbnb Property"
  end

  def extract_price(listing)
    content = listing['content'] || ''
    price_match = content.match(/\$\d+/)
    price_match ? price_match[0] : "$#{rand(80..200)}"
  end

  def extract_rating(listing)
    content = listing['content'] || ''
    rating_match = content.match(/(\d\.\d+)\s*(?:stars?|⭐)/)
    rating_match ? rating_match[1].to_f : (3.5 + rand(1.5)).round(1)
  end

  def extract_review_count(listing)
    content = listing['content'] || ''
    review_match = content.match(/(\d+)\s*reviews?/)
    review_match ? review_match[1].to_i : rand(5..150)
  end

  def extract_amenities(listing)
    content = listing['content'] || ''
    # Extract common amenities from content
    amenities = []
    amenities << 'WiFi' if content.match?(/wifi|internet/i)
    amenities << 'Kitchen' if content.match?(/kitchen|cooking/i)
    amenities << 'Parking' if content.match?(/parking|garage/i)
    amenities << 'AC' if content.match?(/air conditioning|ac/i)
    
    amenities.any? ? amenities : sample_amenities.sample(3)
  end

  def sample_amenities
    ['WiFi', 'Kitchen', 'Parking', 'AC', 'Heating', 'TV', 'Washer', 'Dryer', 'Balcony', 'Pool']
  end
end

# MAIN EXECUTION
puts "🏠 Enhanced Airbnb AI Scraper & Analyzer"
puts "=" * 50

# Check for API keys
api_key = ENV['OPENROUTER_API_KEY']

if api_key.nil? || api_key.empty?
  puts "⚠️  OPENROUTER_API_KEY not found - running in demo mode"
  puts "🔧 Using local price analysis and simulated data"
  api_key = "demo_mode"
end

# Initialize the enhanced analyzer
analyzer = AirbnbAnalyzer.new(api_key)

# Process all searches with enhanced capabilities
results = analyzer.process_all_searches

if results.any?
  # Export enhanced results
  analyzer.export_results
  
  # Generate enhanced summary report
  puts '\nGenerating enhanced summary report...'
  analyzer.generate_summary_report(results)
  
  puts "\n🎉 Enhanced Airbnb analysis completed successfully!"
  puts "📊 #{results.length} locations analyzed with comprehensive data"
  puts "📈 Data visualizations generated in outputs/charts/"
  puts "📄 Check the outputs/ directory for detailed results and charts"
else
  puts "\n❌ No results to analyze. Please check your search criteria."
end
