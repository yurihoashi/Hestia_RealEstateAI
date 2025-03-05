import json
from collections import defaultdict

def process_suburb_data():
    # Load data
    with open("Hestia/Preview Content/Data/ausDataset.json", "r") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError:
            print("Invalid JSON file")
            return

    # Process data
    suburbs_by_state = defaultdict(set)
    
    for entry in data.get("data", []):
        try:
            # Normalize data
            state = entry["state"].strip().upper()
            suburb = entry["suburb"].strip().title()
        except KeyError as e:
            print(f"Skipping entry missing {e}: {entry}")
            continue
            
        suburbs_by_state[state].add(suburb)
    
    # Convert to sorted lists
    processed = {
        state: sorted(suburbs) 
        for state, suburbs in suburbs_by_state.items()
    }
    
    # Save output
    with open("incomeDataBySuburb.json", "w") as f:
        json.dump(processed, f, indent=2)
    
    print("Successfully created suburbs_by_state.json")

if __name__ == "__main__":
    process_suburb_data()