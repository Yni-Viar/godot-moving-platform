extends Area3D
## Detects station
## Need to be placed at head wagon (with enter = true), and the last wagon (with enter = false)
## Made by Yni, licensed under MIT license
class_name StationTrigger

## Entering - true, exiting - false
@export var enter: bool = true
