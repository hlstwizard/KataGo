import tensorflow as tf
import coremltools as ct
import numpy as np

export_dir = "./saved_model2"

from coremltools.converters.mil import Builder as mb
from coremltools.converters.mil import register_tf_op


def verify():
    model = tf.keras.models.load_model(export_dir)


def convert():
    mlmodel = ct.convert(export_dir, source="tensorflow")

    mlmodel.save(export_dir.replace("pb", "mlmodel"))

convert()
