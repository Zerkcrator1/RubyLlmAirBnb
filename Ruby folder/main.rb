# frozen_string_literal: true

require 'dotenv/load'
require 'ruby_llm'
require 'json'
require 'fileutils'
require_relative 'lib/utils/csv_handler'

# Simple Airbnb price analysis using direct RubyLLM calls
def analyze_airbnb_location(location, guests, check_in, check_out, budget_max, property_type)
  prompt = <<~PROMPT
    Analyze Airbnb pricing and availability for this search:
    
    Location: #{location}
    Guests: #{guests}
    Check-in: #{check_in || 'Flexible'}
    Check-out: #{check_out || 'Flexible'}
    Budget: #{budget_max ? "Up to $#{budget_max}/night" : 'Flexible'}
    Property Type: #{property_type || 'Any'}
    
    Provide a comprehensive analysis including:
    1. Current market rates and price ranges
    2. Best value neighborhoods and areas
    3. Property recommendations for this group size
    4. Seasonal pricing patterns
    5. Booking tips and strategies
    6. Value assessment (Excellent/Good/Fair/Poor)
    
    Format your response as a detailed market analysis with specific recommendations.
  PROMPT

  chat = RubyLLM.chat(model: 'anthropic/claude-3.5-sonnet')
  response = chat.ask(prompt)
  
  {
    location: location,
    guests: guests,
    check_in: check_in,
    check_out: check_out,
    budget_max: budget_max,
    property_type: property_type,
    analysis: response.content,
    analyzed_at: Time.now.iso8601,
    success: true
  }
end

# Generate summary report
def generate_summary_report(results)
  return if results.empty?

  puts "\n📊 AIRBNB ANALYSIS SUMMARY"
  puts "=" * 50

  results.each_with_index do |result, index|
    puts "\n#{index + 1}. 📍 #{result[:location]}"
    puts "   👥 Guests: #{result[:guests]}"
    puts "   📅 Dates: #{result[:check_in] || 'Flexible'} to #{result[:check_out] || 'Flexible'}"
    puts "   💰 Budget: #{result[:budget_max] ? "$#{result[:budget_max]}/night" : 'Flexible'}"
    puts "   🏠 Type: #{result[:property_type] || 'Any'}"
    puts "   ✅ Status: Analyzed"
  end

  puts "\n📈 STATISTICS"
  puts "   Total Locations: #{results.length}"
  puts "   All Analyses: Complete"

  puts "\n" + "=" * 50
end

# STEP 1: CONFIGURE RUBYLLM
puts "🏠 Airbnb AI Scraper & Analyzer"
puts "=" * 40

# Check for API key
api_key = ENV['OPENROUTER_API_KEY']

if api_key.nil? || api_key.empty?
  puts "❌ OPENROUTER_API_KEY not found!"
  puts "Please set your OpenRouter API key in the environment or .env file"
  exit 1
end

RubyLLM.configure do |config|
  config.openrouter_api_key = api_key
end

puts "✅ RubyLLM configured with OpenRouter API"

# STEP 2: PROCESS EACH SEARCH REQUEST FROM CSV
puts 'Processing searches/search_criteria.csv...'
search_requests = CsvHandler.read('searches/search_criteria.csv')
analysis_results = []

if search_requests.empty?
  puts "❌ No search criteria found in searches/search_criteria.csv"
  puts "Please add search criteria and try again."
  exit 1
end

# Process each search request
search_requests.each_with_index do |search_request, index|
  puts "\nProcessing search #{index + 1}/#{search_requests.length}..."
  puts "🔍 Analyzing #{search_request['location']}..."

  # Get AI-powered analysis
  result = analyze_airbnb_location(
    search_request['location'],
    (search_request['guests'] || '2').to_i,
    search_request['check_in'],
    search_request['check_out'],
    search_request['budget_max']&.to_i,
    search_request['property_type']
  )

  if result[:success]
    puts "✅ Analysis completed for #{search_request['location']}"
    
    # Display a preview of the analysis
    puts "\n📋 Analysis Preview:"
    puts result[:analysis][0..300] + "..."
    
    analysis_results << result
  else
    puts "❌ Failed to analyze #{search_request['location']}"
  end
end

# STEP 3: EXPORT ALL RESULTS TO JSON AND CSV
puts '\nExporting all results...'

# Ensure outputs directory exists
FileUtils.mkdir_p('outputs')

# Save detailed JSON results
output_file = 'outputs/airbnb_analysis_results.json'
File.write(output_file, JSON.pretty_generate(analysis_results))
puts "📄 Detailed results saved to #{output_file}"

# Create CSV summary
csv_data = analysis_results.map do |result|
  {
    'location' => result[:location],
    'guests' => result[:guests],
    'check_in' => result[:check_in],
    'check_out' => result[:check_out],
    'budget_max' => result[:budget_max],
    'property_type' => result[:property_type],
    'analyzed_at' => result[:analyzed_at]
  }
end

csv_output_file = 'outputs/airbnb_analysis_summary.csv'
CsvHandler.export(csv_data, csv_output_file)
puts "📊 Summary saved to #{csv_output_file}"

# STEP 4: GENERATE SUMMARY REPORT
puts '\nGenerating summary report...'
generate_summary_report(analysis_results)

puts "\n🎉 Airbnb analysis completed successfully!"
puts "Check the outputs/ directory for detailed results."
