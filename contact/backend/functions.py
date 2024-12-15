from flask import Flask, request, jsonify
import librosa
import numpy as np
import tensorflow as tf

model = "C://Users//ASUS//Desktop//MoodCallFinal//API_audio.h5"

def zcr(data, frame_length=2048, hop_length=512):
    zcr = librosa.feature.zero_crossing_rate(y=data, frame_length=frame_length, hop_length=hop_length)
    return np.squeeze(zcr)

def rmse(data, frame_length=2048, hop_length=512):
    rmse = librosa.feature.rms(y=data, frame_length=frame_length, hop_length=hop_length)
    return np.squeeze(rmse)

def mfcc(data, sr, frame_length=2048, hop_length=512, flatten: bool = True):
    mfcc_feature = librosa.feature.mfcc(y=data, sr=sr)
    return np.squeeze(mfcc_feature.T) if not flatten else np.ravel(mfcc_feature.T)

def extract_features_for_testing(data, sr, frame_length=2048, hop_length=512, mfcc_coeffs=40):
    zcr_feature = zcr(data, frame_length, hop_length)
    rms_feature = rmse(data, frame_length, hop_length)
    mfcc_feature = librosa.feature.mfcc(y=data, sr=sr, n_mfcc=mfcc_coeffs, hop_length=hop_length).T
    
    features = np.hstack((
        zcr_feature[:len(mfcc_feature)],  
        rms_feature[:len(mfcc_feature)],
        mfcc_feature.flatten()
    ))
    return features

def preprocess_audio_for_model(data, sr, duration=2.5, offset=0.6, target_length=2376):
    features = extract_features_for_testing(data, sr)
    if len(features) < target_length:
        features = np.pad(features, (0, target_length - len(features)), mode='constant')
    elif len(features) > target_length:
        features = features[:target_length]
    features = features.reshape(target_length, 1)
    return np.expand_dims(features, axis=0)