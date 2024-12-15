import librosa
import numpy as np
import tensorflow as tf
from flask import Flask, request, jsonify
from functions import preprocess_audio_for_model  

model_path = "C://Users//ASUS//Desktop//MoodCallFinal//API_audio.h5"
model = tf.keras.models.load_model(model_path)

app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict_emotion():
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No file selected"}), 400
    
    try:
        data, sr = librosa.load(file, duration=2.5, offset=0.6)
        features = preprocess_audio_for_model(data, sr)
        predictions = model.predict(features)
        predicted_class = int(np.argmax(predictions, axis=1)[0])
        
        return jsonify({"predicted_class": predicted_class})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
