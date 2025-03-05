import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
import coremltools as ct

# Load and prepare data
df = pd.read_csv('melbourne_housing.csv')
df['Price'] = pd.to_numeric(df['Price'], errors='coerce').dropna()
df = df[df.Price > 50000]

# Manual ordinal encoding
df['Suburb'] = df['Suburb'].astype('category').cat.codes
df['Type'] = df['Type'].astype('category').cat.codes

# Train model
X = df[['Suburb', 'Rooms', 'Type', 'Distance']]
y = df['Price']
model = RandomForestRegressor(n_estimators=100)
model.fit(X, y)

# Convert with CORRECT syntax for coremltools 6.3.0
coreml_model = ct.converters.sklearn.convert(
    model,
    inputs=[
        ct.TensorType(name="Suburb", dtype=np.int64),
        ct.TensorType(name="Rooms", dtype=np.int64),
        ct.TensorType(name="Type", dtype=np.int64),
        ct.TensorType(name="Distance", dtype=np.float64),
    ],
    outputs=[ct.TensorType(name="Price", dtype=np.float64)]
)

coreml_model.save("HousePricePredictor.mlmodel")