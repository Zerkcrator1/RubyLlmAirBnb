# 🏠 Airbnb AI Analyzer

AI-powered Airbnb market analysis tool using RubyLLM and Claude 3.5 Sonnet.

## What it does

Analyzes multiple Airbnb locations from a CSV file and provides:
- Market rates and price ranges
- Best value neighborhoods
- Property recommendations
- Seasonal pricing patterns
- Booking strategies

## Setup

1. Install gems:
```bash
bundle install
```

2. Add your API key to `.env`:
```
OPENROUTER_API_KEY=your_api_key_here
```

## Usage

1. Edit `searches/search_criteria.csv` with your locations:
```csv
location,check_in,check_out,guests,budget_max,property_type
"Paris, France",2024-12-01,2024-12-05,2,150,apartment
"New York, NY",2024-11-15,2024-11-20,4,200,
```

2. Run the analysis:
```bash
ruby main.rb
```

3. Check results in `outputs/` directory:
- `airbnb_analysis_results.json` - Full AI analysis
- `airbnb_analysis_summary.csv` - Summary data

## Example Output

```
🏠 Airbnb AI Scraper & Analyzer
========================================
✅ RubyLLM configured with OpenRouter API
Processing searches/search_criteria.csv...

Processing search 1/2...
🔍 Analyzing Paris, France...
✅ Analysis completed for Paris, France
```

That's it! 🎉
