import json
from collections import defaultdict

# LOAD JSON FILE
with open("Hestia/Preview Content/Data/ausDataset.json", "r") as file:
    data = json.load(file)

# CREATE DICTIONARY TO STORE MEDIAN INCOMES
suburb_incomes = defaultdict(dict)

# EXTRACT INCOME DATA
for entry in data["data"]:
    try:
        state = entry["state"]
        suburb = entry["suburb"]
        income = entry["median_income"]
        
        # Store with state as primary key, suburb as secondary key
        suburb_incomes[state][suburb] = income
        
    except KeyError as e:
        print(f"Missing key {e} in entry: {entry}")
        continue

# SAVE TO NEW FILE
with open("suburb_incomes.json", "w") as outfile:
    json.dump(suburb_incomes, outfile, indent=4)

print("File 'suburb_incomes.json' created with median incomes!")