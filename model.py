import keras
import tensorflow as tf
import matplotlib.pyplot as plt

from PIL import ImageFile
from keras.optimizers import Adam
from keras.applications import ResNet50
from keras.preprocessing.image import ImageDataGenerator

ImageFile.LOAD_TRUNCATED_IMAGES = True

METRICS = [
    keras.metrics.BinaryAccuracy(name="accuracy"),
    keras.metrics.Precision(name="precision"),
    keras.metrics.Recall(name="recall"),
    keras.metrics.AUC(name="auc"),
]


class MyCallback(tf.keras.callbacks.Callback):
    """Callback class that stops training once accuracy reaches 99%."""

    def on_epoch_end(self, epoch, logs={}):
        if logs.get("accuracy") > 0.99:
            print("\nReached 99% accuracy, so cancelling training!")
            self.model.stop_training = True


def train_val_generators(training_dir, validation_dir):
    """Creates the training and validation data generators.

        :param training_dir: Directory path containing the training images.
        :param validation_dir: Directory path containing the testing/validation images.
        :return: (training_generator, validation_generator) tuple containing the generators.
        """

    # Training data generator with data augmentation
    train_datagen = ImageDataGenerator(rescale=1.0 / 255.0,
                                       rotation_range=40,
                                       width_shift_range=0.2,
                                       height_shift_range=0.2,
                                       shear_range=0.2,
                                       zoom_range=0.2,
                                       horizontal_flip=True,
                                       fill_mode="nearest")

    training_generator = train_datagen.flow_from_directory(directory=training_dir,
                                                           batch_size=128,
                                                           class_mode="binary",
                                                           target_size=(224, 224))

    # Validation data generator
    validation_datagen = ImageDataGenerator(rescale=1.0 / 255.0)

    validation_generator = validation_datagen.flow_from_directory(directory=validation_dir,
                                                                  batch_size=128,
                                                                  class_mode="binary",
                                                                  target_size=(224, 224))
    return training_generator, validation_generator


def create_model():
    """"Defines a keras model to classify between two types of data."""

    model = tf.keras.models.Sequential([
        # Convolution and max pooling layers
        tf.keras.layers.Conv2D(32, (3, 3), activation="relu", input_shape=(224, 224, 3)),
        tf.keras.layers.MaxPooling2D(2, 2),
        tf.keras.layers.Conv2D(64, (3, 3), activation="relu"),
        tf.keras.layers.MaxPooling2D(2, 2),
        tf.keras.layers.Conv2D(128, (3, 3), activation="relu"),
        tf.keras.layers.MaxPooling2D(2, 2),
        tf.keras.layers.Conv2D(256, (3, 3), activation="relu"),
        tf.keras.layers.MaxPooling2D(2, 2),

        # Flatten, dropout and dense layers
        tf.keras.layers.Flatten(),
        tf.keras.layers.Dense(512, activation="relu"),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(1, activation="sigmoid")
    ])

    model.compile(optimizer=Adam(learning_rate=3e-4),
                  loss="binary_crossentropy",
                  metrics=METRICS)

    return model


def create_transfer_model():
    """Defines a keras model using transfer learning with ResNet50."""

    # Load the ResNet50 model with its pre-trained weights, but without its final classification layers
    base_model = ResNet50(input_shape=(224, 224, 3), include_top=False, weights="imagenet")

    # Freeze the layers of the base model
    for layer in base_model.layers:
        layer.trainable = False

    # Add custom layers on top of the base model
    x = base_model.output
    x = tf.keras.layers.Flatten()(x)
    x = tf.keras.layers.Dense(512, activation='relu')(x)
    x = tf.keras.layers.Dropout(0.2)(x)
    predictions = tf.keras.layers.Dense(1, activation='sigmoid')(x)

    # Construct the full model
    model = tf.keras.Model(inputs=base_model.input, outputs=predictions)

    model.compile(optimizer=Adam(learning_rate=3e-4),
                  loss="binary_crossentropy",
                  metrics=METRICS)

    return model


def plot_history(history):
    """Plot the chart for accuracy and loss on both training and validation.

    :param history: History of trained model.
    :type history: History object.
    """

    acc = history.history["accuracy"]
    val_acc = history.history["val_accuracy"]
    loss = history.history["loss"]
    val_loss = history.history["val_loss"]

    epochs = range(len(acc))

    plt.plot(epochs, acc, 'r', label="Training Accuracy")
    plt.plot(epochs, val_acc, 'b', label="Validation Accuracy")
    plt.title("Training and Validation Accuracy")
    plt.legend()
    plt.figure()

    plt.plot(epochs, loss, 'r', label="Training Loss")
    plt.plot(epochs, val_loss, 'b', label="Validation Loss")
    plt.title("Training and Validation Loss")
    plt.legend()

    plt.show()
