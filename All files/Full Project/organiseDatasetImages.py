# created: 3.3.25
# author: Yuri Hoashi
# overview: to categorise datasets into train, val, test, in a certain folder type for createML

import pandas as pd
import os
import shutil
from sklearn.model_selection import train_test_split

# Configuration
csv_path = "dataset_of_images/labels.csv"
source_folder = "dataset_of_images/all_images" 
dest_root = "datasets_of_images/sorted_images"

# Read CSV labels
df = pd.read_csv(csv_path)

# Create class folders for training, validation, and testing
for split in ['train', 'val', 'test']:
    os.makedirs(os.path.join(dest_root, split), exist_ok=True)

# Create a 70%/15%/15% split for training, validation, and testing
train_df, temp_df = train_test_split(df, test_size=0.3, random_state=42)
val_df, test_df = train_test_split(temp_df, test_size=0.5, random_state=42)

# Dictionary to hold the dataframes
splits = {'train': train_df, 'val': val_df, 'test': test_df}

# Move images into corresponding split folders
for split, split_df in splits.items():
    for index, row in split_df.iterrows():
        class_name = row['house_type']
        filename = row['file_label']
        src_path = os.path.join(source_folder, filename)
        
        # Create class folder if needed in the split folder
        dest_folder = os.path.join(dest_root, split, class_name)
        os.makedirs(dest_folder, exist_ok=True)
        
        # Move/copy the file
        if os.path.exists(src_path):
            shutil.copy(src_path, os.path.join(dest_folder, filename))
            print(f"Moved {filename} to {split}/{class_name} folder")
        else:
            print(f"Missing file: {filename}")

print("Dataset split and organization complete!")