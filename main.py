from model import *
from preprocess_utils import *

import pathlib
import tensorflow as tf
from PIL import ImageFile

tf.get_logger().setLevel('ERROR')
ImageFile.LOAD_TRUNCATED_IMAGES = True

# Set paths to directories
project_path = "/Users/dell/Yoav/PythonProjects/MelanomaDetector"

IMAGES_DIR = os.path.join(project_path, "images")
BENIGN_SOURCE_DIR = os.path.join(IMAGES_DIR, "benign")
MALIGNANT_SOURCE_DIR = os.path.join(IMAGES_DIR, "malignant")

TRAINING_DIR = os.path.join(project_path, "training")
VALIDATION_DIR = os.path.join(project_path, "validation")

TRAINING_BENIGN_DIR = os.path.join(TRAINING_DIR, "benign")
TRAINING_MALIGNANT_DIR = os.path.join(TRAINING_DIR, "malignant")

VALIDATION_BENIGN_DIR = os.path.join(VALIDATION_DIR, "benign")
VALIDATION_MALIGNANT_DIR = os.path.join(VALIDATION_DIR, "malignant")


def empty_dir(dir):
    """
    Empties the specified directory by removing all its contents.

    :param dir: Path to the directory to be emptied.
    :type dir: str.
    """
    if len(os.listdir(dir)) > 0:
        for file in os.scandir(dir):
            os.remove(file.path)


def reset_dirs():
    """
    Empties the training and validation directories for benign and malignant images.

    - Clears any existing images to avoid residue from previous runs.
    - Splits data from source directories into training and validation based on a defined split ratio.
    - Prints counts of images in original, training, and validation directories.
    """

    # Empty directories if not already empty
    empty_dir(TRAINING_BENIGN_DIR)
    empty_dir(TRAINING_MALIGNANT_DIR)
    empty_dir(VALIDATION_BENIGN_DIR)
    empty_dir(VALIDATION_MALIGNANT_DIR)

    # Define split size
    split_size = 0.8

    # Split the data into training and validation directories
    split_data(BENIGN_SOURCE_DIR, TRAINING_BENIGN_DIR, VALIDATION_BENIGN_DIR, split_size)
    split_data(MALIGNANT_SOURCE_DIR, TRAINING_MALIGNANT_DIR, VALIDATION_MALIGNANT_DIR, split_size)

    # Original directories' size
    print(f"\nOriginal benign directory has {len(os.listdir(BENIGN_SOURCE_DIR)) - 1} images")
    print(f"Original malignant directory has {len(os.listdir(MALIGNANT_SOURCE_DIR)) - 1} images\n")

    # Training and validation splits
    print(f"There are {len(os.listdir(TRAINING_BENIGN_DIR)) - 1} images of benign moles for training")
    print(f"There are {len(os.listdir(TRAINING_MALIGNANT_DIR)) - 1} images of malignant moles for training")
    print(f"There are {len(os.listdir(VALIDATION_BENIGN_DIR)) - 1} images of benign moles for validation")
    print(f"There are {len(os.listdir(VALIDATION_MALIGNANT_DIR)) - 1} images of malignant moles for validation")


def main():
    # reset_dirs()

    # Get data generators for both training and validation data
    training_generator, validation_generator = train_val_generators(TRAINING_DIR, VALIDATION_DIR)

    # Create model
    model = create_transfer_model()

    # Train model
    callbacks = MyCallback()

    history = model.fit(training_generator,
                        epochs=50,
                        verbose=2,
                        validation_data=validation_generator,
                        callbacks=[callbacks]
                        )

    # Plot the chart for accuracy and loss on both training and validation
    plot_history(history)

    # Use the tf.saved_model API to save model in the SavedModel format
    export_dir = 'saved_model/2 - transfer'
    tf.saved_model.save(model, export_dir)

    # Select mode of optimization
    mode = "Speed"

    if mode == 'Storage':
        optimization = tf.lite.Optimize.OPTIMIZE_FOR_SIZE
    elif mode == 'Speed':
        optimization = tf.lite.Optimize.OPTIMIZE_FOR_LATENCY
    else:
        optimization = tf.lite.Optimize.DEFAULT

    # Use the TFLiteConverter SavedModel API to initialize the converter
    converter = tf.lite.TFLiteConverter.from_saved_model(export_dir)

    # Set the optimizations
    converter.optimizations = [optimization]

    # Invoke the converter to finally generate the TFLite model
    tflite_model = converter.convert()
    tflite_model_file = pathlib.Path('./transfer_model.tflite')
    tflite_model_file.write_bytes(tflite_model)


if __name__ == "__main__":
    main()
