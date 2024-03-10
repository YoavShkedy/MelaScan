import csv
import os
import random
import pydicom
import numpy as np
from PIL import Image
from shutil import copyfile


def sort_data(data_sorted=False):
    """Sorts the data into directories if not already sorted.

    :param data_sorted: Indicates if the data is already sorted.
    :type data_sorted: bool.
    """

    if data_sorted:
        return

    images_dir = "images"
    benign_dir = "images/benign"
    malignant_dir = "images/malignant"
    ISIC_labels_csv = "ISIC_2020_Training_GroundTruth_v2.csv"

    BENIGN = "benign"
    MALIGNANT = "malignant"

    diagnosis = {}

    with open(ISIC_labels_csv) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=",")
        next(csv_reader)  # skip header line

        for line in csv_reader:
            img_name = line[0]
            benign_malignant = line[7]
            diagnosis.update({img_name: benign_malignant})

    for img_name in os.listdir(images_dir):
        img_name = img_name.split(".")[0]

        # Copy to benign directory
        if diagnosis.get(img_name) == BENIGN:
            source = os.path.join(images_dir, img_name + ".dcm")
            target = os.path.join(benign_dir, img_name + ".dcm")
            copyfile(source, target)

        # Copy to malignant directory
        elif diagnosis.get(img_name) == MALIGNANT:
            source = os.path.join(images_dir, img_name + ".dcm")
            target = os.path.join(malignant_dir, img_name + ".dcm")
            copyfile(source, target)


def split_data(source_dir, training_dir, validation_dir, split_size):
    """Splits the data into training data and validation data by a determined portion.

    :param source_dir: Source directory containing the files.
    :param training_dir: Training directory that a portion of the files will be copied to.
    :param validation_dir: Validation directory that a portion of the files will be copied to.
    :param split_size: Split size to determine the portion.
    :type source_dir: str.
    :type training_dir: str.
    :type validation_dir: str.
    :type split_size: int.
    """

    all_images = []

    for file_name in os.listdir(source_dir):
        file_path = os.path.join(source_dir, file_name)

        if os.path.getsize(file_path):
            all_images.append(file_name)
        else:
            print("{} is of length zero, so ignoring".format(file_name))

    split_point = int(len(all_images) * split_size)
    shuffled_images = random.sample(all_images, len(all_images))
    training_images = shuffled_images[:split_point]
    validation_images = shuffled_images[split_point:]

    for file_name in training_images:
        source = os.path.join(source_dir, file_name)
        target = os.path.join(training_dir, file_name)
        copyfile(source, target)

    for file_name in validation_images:
        source = os.path.join(source_dir, file_name)
        target = os.path.join(validation_dir, file_name)
        copyfile(source, target)


def dcm_to_jpg(file_name):
    """Converts the specified dcm file to a jpg file.

        :param file_name: Name of the dcm file to be converted.
        :type file_name: str.
        :return: The converted jpg file.
        """

    img = pydicom.dcmread(file_name)
    img = img.pixel_array.astype(float)
    rescaled_image = (np.maximum(img, 0) / img.max()) * 255  # float pixels
    final_image = np.uint8(rescaled_image)  # integers pixels
    final_image = Image.fromarray(final_image)
    return final_image
