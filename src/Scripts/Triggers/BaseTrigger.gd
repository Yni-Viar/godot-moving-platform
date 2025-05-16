extends Area3D
class_name BaseTrigger
## Made by Yni, licensed under CC0.
## Trigger base function.

enum GraphicDevice {OPENGL3, RD, BOTH}
@export var graphic_device: GraphicDevice = GraphicDevice.BOTH

func _ready() -> void:
	pass
