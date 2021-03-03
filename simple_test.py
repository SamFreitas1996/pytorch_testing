import torch
from detecto import core, utils, visualize

x = torch.rand(5,3)

print(x)

print(torch.cuda.is_available())

image = utils.read_image('fruit.jpg')
model = core.Model()

labels, boxes, scores = model.predict_top(image)
visualize.show_labeled_image(image, boxes, labels)