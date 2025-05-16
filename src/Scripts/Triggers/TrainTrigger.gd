extends Area3D
## Other train checker.
## Made by Yni, licensed under MIT license
class_name TrainTrigger

var emergency_stop: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area3D) -> void:
	if area is StationTrigger:
		if !area.enter:
			get_parent().emergency_stop = true


func _on_area_exited(area: Area3D) -> void:
	if area is StationTrigger:
		if !area.enter:
			get_parent().emergency_stop = false
