# frozen_string_literal: true

require 'json'

# Tool for generating data visualizations and graphs from Airbnb analysis results
# Creates various chart types to visualize pricing, value, and market data
class GraphGenerator
  def initialize
  end

  # Generate a price comparison chart
  def generate_price_comparison_chart(analysis_results)
    return nil if analysis_results.empty?

    chart_data = extract_price_data(analysis_results)
    
    chart_config = {
      type: 'bar',
      title: 'Airbnb Price Comparison by Location',
      x_axis: 'Location',
      y_axis: 'Average Price per Night ($)',
      data: chart_data,
      colors: ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57'],
      metadata: {
        generated_at: Time.now.iso8601,
        total_locations: analysis_results.length,
        chart_type: 'price_comparison'
      }
    }

    save_chart(chart_config, 'price_comparison_chart.json')
    puts "📊 Generated price comparison chart with #{chart_data.length} locations"
    
    chart_config
  end

  # Generate value rating distribution chart
  def generate_value_distribution_chart(analysis_results)
    return nil if analysis_results.empty?

    value_counts = count_value_ratings(analysis_results)
    
    chart_config = {
      type: 'pie',
      title: 'Value Rating Distribution',
      data: value_counts.map { |rating, count| { label: rating, value: count } },
      colors: ['#2ECC71', '#F39C12', '#E74C3C', '#95A5A6'],
      metadata: {
        generated_at: Time.now.iso8601,
        total_analyzed: analysis_results.length,
        chart_type: 'value_distribution'
      }
    }

    save_chart(chart_config, 'value_distribution_chart.json')
    puts "📊 Generated value distribution chart"
    
    chart_config
  end

  # Generate guest capacity vs price scatter plot
  def generate_capacity_price_scatter(analysis_results)
    return nil if analysis_results.empty?

    scatter_data = analysis_results.map do |result|
      price = extract_numeric_price(result[:average_price])
      guests = result[:guests] || 2
      
      {
        x: guests,
        y: price,
        label: result[:location],
        color: color_by_value_rating(result[:value_rating])
      }
    end.compact

    chart_config = {
      type: 'scatter',
      title: 'Guest Capacity vs Average Price',
      x_axis: 'Number of Guests',
      y_axis: 'Average Price per Night ($)',
      data: scatter_data,
      metadata: {
        generated_at: Time.now.iso8601,
        chart_type: 'capacity_price_scatter'
      }
    }

    save_chart(chart_config, 'capacity_price_scatter.json')
    puts "📊 Generated capacity vs price scatter plot"
    
    chart_config
  end

  # Generate seasonal trend line chart
  def generate_seasonal_trends_chart(analysis_results)
    return nil if analysis_results.empty?

    # Simulate seasonal data based on location patterns
    seasonal_data = generate_seasonal_data(analysis_results)
    
    chart_config = {
      type: 'line',
      title: 'Seasonal Price Trends by Location',
      x_axis: 'Month',
      y_axis: 'Relative Price Change (%)',
      data: seasonal_data,
      colors: ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57'],
      metadata: {
        generated_at: Time.now.iso8601,
        chart_type: 'seasonal_trends'
      }
    }

    save_chart(chart_config, 'seasonal_trends_chart.json')
    puts "📊 Generated seasonal trends chart"
    
    chart_config
  end

  # Generate comprehensive dashboard with multiple charts
  def generate_dashboard(analysis_results)
    return nil if analysis_results.empty?

    dashboard = {
      title: 'Airbnb Market Analysis Dashboard',
      generated_at: Time.now.iso8601,
      summary: generate_summary_stats(analysis_results),
      charts: [
        generate_price_comparison_chart(analysis_results),
        generate_value_distribution_chart(analysis_results),
        generate_capacity_price_scatter(analysis_results),
        generate_seasonal_trends_chart(analysis_results)
      ].compact
    }

    save_chart(dashboard, 'airbnb_dashboard.json')
    puts "📊 Generated comprehensive dashboard with #{dashboard[:charts].length} charts"
    
    dashboard
  end

  private

  def extract_price_data(analysis_results)
    analysis_results.map do |result|
      location = result[:location]
      price = extract_numeric_price(result[:average_price])
      
      { label: location, value: price } if location && price
    end.compact
  end

  def extract_numeric_price(price_str)
    return nil unless price_str
    price_str.to_s.gsub(/[^\d]/, '').to_i
  end

  def count_value_ratings(analysis_results)
    ratings = analysis_results.map { |r| r[:value_rating] }.compact
    
    {
      'Excellent' => ratings.count('Excellent'),
      'Good' => ratings.count('Good'),
      'Fair' => ratings.count('Fair'),
      'Poor' => ratings.count('Poor')
    }.reject { |_, count| count.zero? }
  end

  def color_by_value_rating(rating)
    case rating
    when 'Excellent' then '#2ECC71'
    when 'Good' then '#F39C12'  
    when 'Fair' then '#E74C3C'
    when 'Poor' then '#95A5A6'
    else '#3498DB'
    end
  end

  def generate_seasonal_data(analysis_results)
    months = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]
    
    analysis_results.first(5).map do |result|
      location = result[:location]
      base_price = extract_numeric_price(result[:average_price]) || 100
      
      # Generate realistic seasonal variations based on location
      seasonal_multipliers = get_seasonal_multipliers(location)
      
      {
        label: location,
        data: months.zip(seasonal_multipliers).map do |month, multiplier|
          { x: month, y: ((multiplier - 1) * 100).round(1) }
        end
      }
    end.compact
  end

  def get_seasonal_multipliers(location)
    city = location.to_s.downcase.split(',').first.strip
    
    case city
    when 'paris'
      [0.9, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.3, 1.1, 1.0, 0.9, 1.0]
    when 'barcelona'
      [0.8, 0.8, 0.9, 1.0, 1.1, 1.4, 1.5, 1.4, 1.2, 1.0, 0.9, 0.8]
    when 'tokyo'
      [0.9, 0.9, 1.3, 1.4, 1.2, 1.0, 1.1, 1.1, 1.0, 1.1, 1.0, 0.9]
    when 'new york'
      [0.8, 0.8, 0.9, 1.1, 1.2, 1.1, 1.0, 1.0, 1.2, 1.3, 1.0, 1.1]
    else
      # Generic seasonal pattern
      [0.9, 0.9, 1.0, 1.1, 1.2, 1.3, 1.2, 1.1, 1.1, 1.0, 0.9, 0.9]
    end
  end

  def generate_summary_stats(analysis_results)
    prices = analysis_results.map { |r| extract_numeric_price(r[:average_price]) }.compact
    
    {
      total_locations: analysis_results.length,
      average_price: prices.empty? ? 0 : (prices.sum / prices.length).round,
      price_range: prices.empty? ? [0, 0] : [prices.min, prices.max],
      excellent_value_count: analysis_results.count { |r| r[:value_rating] == 'Excellent' },
      most_expensive: analysis_results.max_by { |r| extract_numeric_price(r[:average_price]) || 0 }&.dig(:location),
      best_value: analysis_results.find { |r| r[:value_rating] == 'Excellent' }&.dig(:location)
    }
  end

  def save_chart(chart_data, filename)
    filepath = File.join('outputs/charts', filename)
    
    File.write(filepath, JSON.pretty_generate(chart_data))
    puts "💾 Saved chart data to #{filepath}"
  end
end
