import torch 
from detecto import core, utils, visualize

print(torch.cuda.is_available())

dataset = core.Dataset('images_and_annotations')
model = core.Model(['WM_well'])

print(dataset._csv.T)

model.fit(dataset)

model.save('model_weights.pth')

model = core.Model.load('model_weights.pth', ['WM_well'])