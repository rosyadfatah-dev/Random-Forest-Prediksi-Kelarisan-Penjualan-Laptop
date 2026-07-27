from flask import Flask, request, jsonify, render_template
import joblib
import pandas as pd
import numpy as np

app = Flask(__name__)

# Load model
def load_model():
    try:
        model_data = joblib.load("model.pkl")
        return model_data['model'], model_data['feature_columns']
    except Exception as e:
        print(f"Error loading model: {e}")
        return None, []

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/predict', methods=['POST'])
def predict():
    model, feature_columns = load_model()
    if not model:
        return jsonify({'error': 'Model not loaded'}), 500
        
    try:
        data = request.json
        
        # Extract features
        cpu = data.get('cpu', '')
        ram = float(data.get('ram', 0))
        memory = float(data.get('memory', 0))
        layar = float(data.get('layar', 0))
        harga = float(data.get('harga', 0))
        merek = data.get('merek', '').upper()
        
        # Create dataframe for prediction
        input_data = pd.DataFrame([{
            'ram': ram,
            'memory': memory,
            'layar': layar,
            'harga': harga,
            'cpu': cpu,
            'merek': merek
        }])
        
        # One-hot encoding using same columns as training
        input_encoded = pd.get_dummies(input_data, columns=['cpu', 'merek'])
        
        # Realign columns to match training features
        for col in feature_columns:
            if col not in input_encoded.columns:
                input_encoded[col] = False # Changed to boolean for pd.get_dummies dummy output dtype
                
        # Keep only the training columns in the same order
        X = input_encoded[feature_columns]
        # ensure X doesn't have object columns
        X = X.astype(float)
        
        # Predict
        pred = model.predict(X)[0]
        proba = model.predict_proba(X)[0]
        confidence = float(max(proba)) * 100
        
        result = {
            'prediction': str(pred),
            'confidence': f"{confidence:.2f}%",
            'probabilities': {str(c): float(p) for c, p in zip(model.classes_, proba)}
        }
        
        return jsonify(result)
        
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/api/info', methods=['GET'])
def get_info():
    model, feature_columns = load_model()
    # Extract unique CPUs and Brands from the feature columns
    cpus = []
    brands = []
    
    for col in feature_columns:
        if col.startswith('cpu_'):
            cpus.append(col[4:])
        elif col.startswith('merek_'):
            brands.append(col[6:])
            
    return jsonify({
        'cpus': sorted(cpus) if cpus else ['INTEL', 'AMD', 'APPLE'],
        'brands': sorted(brands) if brands else ['ACER', 'ASUS', 'LENOVO', 'HP', 'MSI', 'APPLE', 'DELL']
    })

if __name__ == '__main__':
    app.run(debug=True, port=5000)
