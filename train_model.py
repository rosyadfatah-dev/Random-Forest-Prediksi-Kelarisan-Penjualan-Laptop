import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from imblearn.over_sampling import SMOTE
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix
import joblib
import warnings
warnings.filterwarnings('ignore')

def main():
    print("Loading dataset...")
    df = pd.read_excel("dataset_laptop_labeled.xlsx")
    
    # Preprocessing
    print("Preprocessing data...")
    # Clean up column names just in case
    df.columns = df.columns.str.strip().str.lower()
    
    # Extract 'merek' from 'model'
    if 'model' in df.columns:
        df['merek'] = df['model'].apply(lambda x: str(x).split()[0].upper() if pd.notna(x) else np.nan)
    else:
        print("Warning: 'model' column not found, assuming 'merek' exists")
        
    # Missing value imputation
    # cpu -> mode
    if 'cpu' in df.columns:
        df['cpu'] = df['cpu'].fillna(df['cpu'].mode()[0])
    
    # numerical columns -> median
    num_cols = ['ram', 'memory', 'layar', 'harga']
    for col in num_cols:
        if col in df.columns:
            # ensure numeric
            df[col] = pd.to_numeric(df[col], errors='coerce')
            df[col] = df[col].fillna(df[col].median())
            
    # One-Hot Encoding on categorical columns ('cpu', 'merek')
    cat_cols = ['cpu', 'merek']
    df_encoded = pd.get_dummies(df, columns=[c for c in cat_cols if c in df.columns])
    
    # Ensure label column exists
    if 'label' not in df.columns:
        print("Error: 'label' column not found in dataset")
        return
        
    X = df_encoded.drop(columns=['label', 'model', 'no', 'id'], errors='ignore')
    y = df['label']
    
    feature_columns = X.columns.tolist()
    
    # Train/Test Split
    print("Splitting data...")
    # Use the requested seed (modulo max uint32 for sklearn random_state)
    random_state_split = 1781173957301 % (2**32)
    random_state_rf = 1781174155410 % (2**32)
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, stratify=y, random_state=random_state_split
    )
    
    # Train Random Forest without SMOTE
    print("\n--- Evaluating WITHOUT SMOTE ---")
    rf_no_smote = RandomForestClassifier(
        n_estimators=100,
        criterion='entropy',
        max_features='sqrt',
        random_state=random_state_rf
    )
    rf_no_smote.fit(X_train, y_train)
    y_pred_no = rf_no_smote.predict(X_test)
    acc_no = accuracy_score(y_test, y_pred_no)
    print(f"Accuracy (No SMOTE): {acc_no:.4f}")
    
    # Apply SMOTE
    print("\n--- Evaluating WITH SMOTE ---")
    random_state_smote = 4586618683546954528 % (2**32)
    smote = SMOTE(k_neighbors=5, random_state=random_state_smote)
    X_train_res, y_train_res = smote.fit_resample(X_train, y_train)
    
    # Train Random Forest
    print("Training Random Forest...")
    rf = RandomForestClassifier(
        n_estimators=100,
        criterion='entropy',
        max_features='sqrt',
        random_state=random_state_rf
    )
    rf.fit(X_train_res, y_train_res)
    
    # Evaluation
    print("Evaluating model...")
    y_pred = rf.predict(X_test)
    
    acc = accuracy_score(y_test, y_pred)
    prec = precision_score(y_test, y_pred, average='macro', zero_division=0)
    rec = recall_score(y_test, y_pred, average='macro', zero_division=0)
    f1 = f1_score(y_test, y_pred, average='macro', zero_division=0)
    f1_weighted = f1_score(y_test, y_pred, average='weighted', zero_division=0)
    cm = confusion_matrix(y_test, y_pred)
    
    print(f"Accuracy: {acc:.4f}")
    print(f"Precision (Macro): {prec:.4f}")
    print(f"Recall (Macro): {rec:.4f}")
    print(f"F1-Score (Macro): {f1:.4f}")
    print(f"F1-Score (Weighted): {f1_weighted:.4f}")
    print("Confusion Matrix:")
    print(cm)
    
    # Save model
    print("Saving model...")
    model_data = {
        'model': rf,
        'feature_columns': feature_columns,
        'metadata': {
            'accuracy': acc,
            'f1_weighted': f1_weighted
        }
    }
    joblib.dump(model_data, "model.pkl")
    print("Model saved to model.pkl successfully.")

if __name__ == "__main__":
    main()
