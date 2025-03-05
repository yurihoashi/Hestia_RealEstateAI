import json
from collections import defaultdict

# LOAD JSON FILE
with open("Hestia/Preview Content/Data/ausDataset.json", "r") as file:
    data = json.load(file)

# GROUP UNIQUE SUBURBS BY STATE
suburbs_by_state = defaultdict(set)  # Use a set to avoid duplicates

for entry in data["data"]:
    state = entry["state"]
    suburb = entry["suburb"]
    suburbs_by_state[state].add(suburb)  # Add to a set (automatically removes duplicates)

# CONVERT SETS TO LISTS FOR JSON COMPATIBILITY
suburbs_by_state = {state: sorted(list(suburbs)) for state, suburbs in suburbs_by_state.items()}  # Sort for readability

# SAVE TO A NEW FILE
with open("suburbs_by_state.json", "w") as outfile:
    json.dump(suburbs_by_state, outfile, indent=4)

print("File 'suburbs_by_state.json' created successfully!")