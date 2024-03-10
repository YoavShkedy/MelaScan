# MelanomaDetector iOS App
MelanomaDetector aims to predict if a mole is malignant or benign using a trained machine learning model. Users can capture images of their moles using the iPhone camera, and the app provides a prediction based on the image.

🚫 **Disclaimer**: This app is intended for informational purposes only. It does not offer medical advice or diagnostic services. Always consult with a healthcare professional for any medical concerns.

## Features
* Capture images directly from your iPhone's camera.
* Immediate prediction after capturing the image.
* Clean and user-friendly interface.

## Requirements
* iOS 14.0 or later.

## Usage
* Launch the app.
* Tap the 'Capture' button to open the iPhone's camera.
* Take a clear photo of the mole you want to analyze.
* The app will then display a prediction of whether the mole appears to be malignant or benign.

## Model Details
The app uses a TensorFlow Lite model trained on the ISIC dataset with over 50,000 images. The current model accuracy is approximately 80%. For a deeper dive into the model, please refer to the provided documentation in the docs directory.
