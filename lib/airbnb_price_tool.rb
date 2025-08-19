# frozen_string_literal: true

# Tool for getting Airbnb price insights for specific locations and criteria
# Provides market-based price analysis and value recommendations
class AirbnbPriceTool
  def initialize
    @price_database = load_price_database
  end

  def get_price_analysis(location:, property_type: 'apartment', guests: 2)
    base_prices = get_base_prices(location, property_type, guests)
    
    {
      location: location,
      property_type: property_type,
      guests: guests,
      average_price: base_prices[:average],
      price_range: base_prices[:range],
      peak_season_price: base_prices[:peak],
      value_rating: assess_value(base_prices[:average_num], location),
      best_neighborhoods: get_value_neighborhoods(location),
      booking_tips: get_booking_tips(location, base_prices[:average_num]),
      market_trends: get_market_trends(location),
      competition_level: get_competition_level(location)
    }
  end

  private

  def load_price_database
    {
      'paris' => {
        apartment: { base: 120, range: [80, 180], peak_multiplier: 1.4 },
        house: { base: 200, range: [150, 300], peak_multiplier: 1.5 }
      },
      'tokyo' => {
        apartment: { base: 90, range: [60, 140], peak_multiplier: 1.6 },
        house: { base: 180, range: [120, 250], peak_multiplier: 1.7 }
      },
      'new york' => {
        apartment: { base: 180, range: [120, 280], peak_multiplier: 1.3 },
        house: { base: 350, range: [250, 500], peak_multiplier: 1.4 }
      },
      'london' => {
        apartment: { base: 140, range: [100, 200], peak_multiplier: 1.3 },
        house: { base: 250, range: [180, 350], peak_multiplier: 1.4 }
      },
      'barcelona' => {
        apartment: { base: 100, range: [70, 150], peak_multiplier: 1.5 },
        house: { base: 180, range: [130, 250], peak_multiplier: 1.6 }
      },
      'amsterdam' => {
        apartment: { base: 130, range: [90, 190], peak_multiplier: 1.4 },
        house: { base: 220, range: [160, 320], peak_multiplier: 1.5 }
      },
      'rome' => {
        apartment: { base: 110, range: [75, 165], peak_multiplier: 1.5 },
        house: { base: 200, range: [140, 280], peak_multiplier: 1.6 }
      },
      'berlin' => {
        apartment: { base: 95, range: [65, 140], peak_multiplier: 1.3 },
        house: { base: 170, range: [120, 240], peak_multiplier: 1.4 }
      },
      'prague' => {
        apartment: { base: 70, range: [50, 105], peak_multiplier: 1.4 },
        house: { base: 130, range: [90, 180], peak_multiplier: 1.5 }
      },
      'lisbon' => {
        apartment: { base: 85, range: [60, 125], peak_multiplier: 1.4 },
        house: { base: 150, range: [110, 210], peak_multiplier: 1.5 }
      }
    }
  end

  def get_base_prices(location, property_type, guests)
    city_key = location.downcase.split(',').first.strip
    type_key = property_type.downcase.to_sym
    
    if @price_database[city_key] && @price_database[city_key][type_key]
      data = @price_database[city_key][type_key]
      base_price = data[:base]
      
      # Adjust for guest count
      guest_multiplier = guests > 2 ? 1 + ((guests - 2) * 0.2) : 1
      adjusted_price = (base_price * guest_multiplier).round
      
      range_min = (data[:range][0] * guest_multiplier).round
      range_max = (data[:range][1] * guest_multiplier).round
      peak_price = (adjusted_price * data[:peak_multiplier]).round
      
      {
        average: "$#{adjusted_price}",
        average_num: adjusted_price,
        range: "$#{range_min}-#{range_max}",
        peak: "$#{peak_price}"
      }
    else
      # Generic pricing for unknown locations
      base_price = 110
      guest_multiplier = guests > 2 ? 1 + ((guests - 2) * 0.2) : 1
      adjusted_price = (base_price * guest_multiplier).round
      
      {
        average: "$#{adjusted_price}",
        average_num: adjusted_price,
        range: "$#{(adjusted_price * 0.7).round}-#{(adjusted_price * 1.4).round}",
        peak: "$#{(adjusted_price * 1.5).round}"
      }
    end
  end

  def assess_value(price, location)
    city_key = location.downcase.split(',').first.strip
    
    case city_key
    when 'tokyo', 'barcelona', 'prague', 'lisbon'
      price < 120 ? 'Excellent' : price < 160 ? 'Good' : 'Fair'
    when 'paris', 'london', 'amsterdam'
      price < 150 ? 'Excellent' : price < 200 ? 'Good' : 'Fair'
    when 'new york'
      price < 200 ? 'Excellent' : price < 300 ? 'Good' : 'Fair'
    else
      price < 130 ? 'Excellent' : price < 180 ? 'Good' : 'Fair'
    end
  end

  def get_value_neighborhoods(location)
    city_key = location.downcase.split(',').first.strip
    
    neighborhoods = {
      'paris' => 'Le Marais, Bastille, Canal Saint-Martin',
      'tokyo' => 'Koenji, Nakano, Shimokitazawa',
      'new york' => 'Brooklyn Heights, Astoria, Long Island City',
      'london' => 'Greenwich, Walthamstow, Crystal Palace',
      'barcelona' => 'Gràcia, El Born, Poblenou',
      'amsterdam' => 'Jordaan, De Pijp, Oost',
      'rome' => 'Trastevere, San Lorenzo, Testaccio',
      'berlin' => 'Kreuzberg, Friedrichshain, Prenzlauer Berg',
      'prague' => 'Vinohrady, Karlín, Smíchov',
      'lisbon' => 'Príncipe Real, Alcântara, Marvila'
    }
    
    neighborhoods[city_key] || 'Central areas, Local neighborhoods, Transit-connected zones'
  end

  def get_booking_tips(location, average_price)
    tips = [
      "Book 2-3 months in advance for best selection",
      "Consider weekday stays for 10-15% savings",
      "Look for properties with 4.5+ ratings and 20+ reviews"
    ]
    
    if average_price > 150
      tips << "Message hosts directly for potential discounts on longer stays"
      tips << "Check for new listings with introductory pricing"
    else
      tips << "Book early in the week for best rates"
      tips << "Consider slightly outer neighborhoods with good transport"
    end
    
    tips.join("; ")
  end

  def get_market_trends(location)
    city_key = location.downcase.split(',').first.strip
    
    trends = {
      'paris' => 'Steady demand year-round, summer peak pricing',
      'tokyo' => 'Spring cherry blossom season premium, winter value opportunities',
      'new york' => 'Fall and spring peak seasons, summer Broadway premium',
      'london' => 'Summer tourist peak, winter shoulder season savings',
      'barcelona' => 'Summer beach season premium, mild winter demand',
      'amsterdam' => 'Spring tulip season peak, canal-view premium',
      'rome' => 'Spring/fall optimal weather premium, summer heat discounts',
      'berlin' => 'Summer festival season peak, stable year-round demand',
      'prague' => 'Christmas market season premium, spring/fall value',
      'lisbon' => 'Year-round appeal, summer coastal premium'
    }
    
    trends[city_key] || 'Seasonal variation typical, book advance for peak periods'
  end

  def get_competition_level(location)
    city_key = location.downcase.split(',').first.strip
    
    high_competition = ['paris', 'new york', 'london', 'barcelona', 'amsterdam']
    medium_competition = ['tokyo', 'rome', 'berlin']
    
    if high_competition.include?(city_key)
      'High'
    elsif medium_competition.include?(city_key)
      'Medium'
    else
      'Low'
    end
  end
end
