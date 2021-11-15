import tensorflow as tf

import coremltools as ct

import numpy as np


# export_dir = "./export"
# export_dir = "./tf1.15_export"
# export_dir = "~/Desktop/export"
export_dir = "./saved_model2"
export_dir = "./disabled_v2_saved_model2"
# export_dir = "./tmp/frozen_model.pb"


from coremltools.converters.mil import Builder as mb
from coremltools.converters.mil import register_tf_op

# @register_tf_op
# def Switch(context, node):
#     pred = context[node.inputs[1]]

#     true_output_var = context[node.inputs[0]]
#     false_output_var = context[node.inputs[0]]

#     def true_fn():
#         return mb.identity(x=true_output_var)

#     def false_fn():
#         return mb.identity(x=false_output_var)

#     x = mb.cond(pred=pred, _true_fn=true_fn, _false_fn=false_fn, name=node.name)
#     context.add(node.name, x)

# @register_tf_op
# def Merge(context, node):
#     context.add(node.name, context[node.inputs[0]])

def verify():
    model = tf.keras.models.load_model(export_dir)
    # model is AutoTrackable
    # model.predict(test_input)


def convert():
    mlmodel = ct.convert(export_dir, source="tensorflow")

    mlmodel.save(export_dir.replace("pb", "mlmodel"))

# verify()
convert()