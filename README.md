# 🏠 Enhanced Airbnb AI Scraper & Analyzer

Advanced AI-powered Airbnb market analysis tool with real web scraping, structured data processing, and comprehensive visualizations.

## What it does

Analyzes multiple Airbnb locations with enhanced capabilities:
- **Real Web Scraping**: Uses Firecrawl API to gather live Airbnb data
- **Structured AI Responses**: Schema-validated outputs for consistent data
- **Market Analysis**: Price ranges, value ratings, and competition levels
- **Data Visualizations**: Interactive charts and comprehensive dashboards
- **Neighborhood Intelligence**: Best value areas and booking strategies
- **Seasonal Insights**: Price trends and optimal booking timing
- **Comprehensive Reporting**: JSON, CSV, and visual outputs

## Setup

1. Install gems:
```bash
bundle install
```

2. Set up your API keys in `.env`:
```
OPENROUTER_API_KEY=your_openrouter_api_key_here
FIRECRAWL_API_KEY=your_firecrawl_api_key_here  # Optional, for real web scraping
```

Without FIRECRAWL_API_KEY, the tool will use realistic simulated data for demonstration.

## Usage

1. Edit `searches/search_criteria.csv` with your locations (now includes 10 locations with 2025 dates):
```csv
location,check_in,check_out,guests,budget_max,property_type
"Paris, France",2025-03-15,2025-03-20,2,150,apartment
"New York, NY",2025-04-10,2025-04-15,4,200,
"Tokyo, Japan",2025-05-01,2025-05-06,2,100,
# ... 7 more destinations included
```

2. Run the analysis:
```bash
ruby main.rb
```

3. Check comprehensive results in `outputs/` directory:
- `airbnb_analysis_results.json` - Complete analysis with all data points
- `airbnb_analysis_summary.csv` - Enhanced CSV with 14 columns of data
- `outputs/charts/` - Data visualizations and interactive dashboard

## Enhanced Features

### 🔍 Real Web Scraping
- Firecrawl API integration for live Airbnb data
- 15-25 listings analyzed per location
- Falls back to realistic simulated data if API unavailable

### 📊 Schema-Validated AI Responses
- Structured JSON outputs with consistent formatting
- Value ratings, competition levels, and market insights
- Prevents AI hallucinations with predefined schemas

### 📈 Data Visualizations
- Price comparison bar charts
- Value distribution pie charts
- Guest capacity vs price scatter plots
- Seasonal trend analysis
- Comprehensive interactive dashboard

### 💎 Enhanced Market Analysis
- Competition level assessment (Low/Medium/High)
- Neighborhood value recommendations
- Seasonal pricing patterns
- Booking optimization strategies

## Example Output

```
🏠 Enhanced Airbnb AI Scraper & Analyzer
==================================================
✅ RubyLLM configured with OpenRouter API
🚀 Processing 10 enhanced search requests...

🔍 Starting comprehensive analysis for Paris, France...
📡 Found 23 real listings via Firecrawl
✅ Structured AI analysis completed with schema validation
✅ Comprehensive analysis completed for Paris, France

📋 Analysis Preview:
   💰 Average Price: $142
   📊 Value Rating: Good
   🏘️  Best Areas: Le Marais, Bastille, Canal Saint-Martin
   📈 Market Trend: Steady demand year-round, summer peak pricing

📊 Generating data visualizations...
📈 All visualizations saved to outputs/charts/ directory
🎯 Dashboard includes 4 interactive charts

🎉 Enhanced Airbnb analysis completed successfully!
📊 10 locations analyzed with comprehensive data
📈 Data visualizations generated in outputs/charts/
```

That's it! 🎉
