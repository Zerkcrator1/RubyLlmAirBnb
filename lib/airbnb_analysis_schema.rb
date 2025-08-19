# frozen_string_literal: true

# Schema for structured Airbnb analysis responses
# Ensures consistent AI output format for reliable data processing
class AirbnbAnalysisSchema
  def self.listing_schema
    {
      type: 'object',
      properties: {
        location: { type: 'string', description: 'Property location' },
        property_type: { type: 'string', description: 'Type of property (apartment, house, etc.)' },
        guests: { type: 'integer', description: 'Number of guests accommodated' },
        average_price: { type: 'string', description: 'Average nightly price (e.g., $120)' },
        price_range: { type: 'string', description: 'Min-max price range (e.g., $80-160)' },
        peak_season_price: { type: 'string', description: 'Peak season pricing (e.g., $180)' },
        value_rating: { 
          type: 'string', 
          enum: ['Excellent', 'Good', 'Fair', 'Poor'],
          description: 'Value assessment rating' 
        },
        best_neighborhoods: { type: 'string', description: 'Top 3 recommended neighborhoods' },
        seasonal_trends: { type: 'string', description: 'Key seasonal pricing patterns' },
        booking_tips: { type: 'string', description: 'Specific booking optimization tips' },
        market_insights: { type: 'string', description: 'Unique market characteristics' },
        competition_level: {
          type: 'string',
          enum: ['Low', 'Medium', 'High'],
          description: 'Market competition level'
        }
      },
      required: [
        'location', 'property_type', 'guests', 'average_price', 
        'price_range', 'value_rating', 'best_neighborhoods'
      ]
    }
  end
end
