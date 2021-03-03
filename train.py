import torch 
from detecto import core, utils, visualize

print(torch.cuda.is_available())

dataset = core.Dataset('images_and_annotations')

val_dataset = core.Dataset('validation')

loader = core.DataLoader(dataset, batch_size=1, shuffle=True)

model = core.Model(['WM_well'])

print(dataset._csv.T)

losses = model.fit(loader, val_dataset, epochs=10, learning_rate=0.001, 
                   lr_step_size=5, verbose=True)
                   

model.save('model_weights.pth')

model = core.Model.load('model_weights.pth', ['WM_well'])

plt.plot(losses)
plt.show()