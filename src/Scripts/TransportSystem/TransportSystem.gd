extends PathFollow3D
## Moving transport system
## Made by Yni, licensed under MIT license.
class_name TransportSystem

## Launch or stop
signal changed_launch_state(start: bool)
## Lock or unlock moving
signal changed_lock_state(start: bool)
enum TransportType {CABLECAR, TRAIN}
## Is this transport work like cable car, or a train?
@export var transport_type: TransportType = TransportType.CABLECAR
## Transport locker
@export var locked: bool = false
## Transport speed
@export var speed: float = 3
## Is moving check
@export var is_moving: bool = false
## Sound, that will play during move
@export var move_sound: String = "res://Sounds/General/CableCar/CableCar.ogg"
## Door open sound
@export var open_door_sounds : PackedStringArray
## Door close sound
@export var close_door_sounds : PackedStringArray
## Objects to move ("teleport" is here because of historical reasons)
@export var objects_to_teleport : Array
## Stops
@export var waypoints : Dictionary = {}
## Lock player movement inside
@export var lock_player_inside: bool = false
# Right is true, left is false.
#@export var which_door_open_on_start: bool = true
## Left door check
var left_door_open: bool = false
## Right door check
var right_door_open: bool = false
#
#var move_pos = 0
## Last stop position
var last_move = 0
## Is at end? If is, do not open the doors
var at_end: bool = false
## Real speed
var sample_speed = speed / 10

# Called when the node enters the scene tree for the first time.
func _ready():
	$Move.stream = load(move_sound)
	if !is_moving:
		stop()

 # Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if waypoints != null:
		if is_moving && waypoints.size() > 0:
			if progress > waypoints.keys()[last_move] - 0.02 && !at_end:
				sample_speed /= 2
				$Move.volume_db -= 0.1
			elif sample_speed < speed:
				sample_speed *= 2
			#if last_move != 0:
				#progress_ratio = move_toward(progress_ratio, waypoints.keys()[last_move], speed * delta)
			progress += sample_speed * delta
			#else:
				#progress_ratio = move_toward(progress_ratio, 1, speed * delta)
				#progress_ratio += sample_speed * delta
			if progress_ratio + 0.001 >= 1:
				progress_ratio = 0
			for i in range(objects_to_teleport.size()):
				var node: Node3D = get_node(objects_to_teleport[i])
				if lock_player_inside:
					node.global_position = global_position
				else:
					node.global_position = node.global_position.move_toward(global_position, speed * delta)
			# remember, floating numbers needs IsEqualApprox, Yni!
			if progress + 0.01 >= waypoints.keys()[last_move]:
				if transport_type == TransportType.TRAIN && (last_move == waypoints.size() / 2 || last_move == 0):
					at_end = true
					stop()
				elif last_move == 0 && progress > waypoints.keys()[waypoints.size() - 1]:
					at_end = true
				else:
					at_end = false
					stop()
## Stop function
func stop():
	$Move.stop()
	changed_launch_state.emit(false)
	#move_pos = last_move
	if !at_end:
		call("open_dest_doors", waypoints[waypoints.keys()[last_move]])
	is_moving = false
	await get_tree().create_timer(10.0).timeout
	if !locked:
		transport_move(true)

## Open the door
func door_open(left_or_right: bool):
	var rng = RandomNumberGenerator.new()
	if left_or_right:
		$AnimationPlayer.play("door_open_right")
		right_door_open = true
	else:
		$AnimationPlayer.play("door_open_left")
		left_door_open = true
	set_physics_process(false)
	if !open_door_sounds.is_empty():
		for node in $DoorSounds.get_children():
			if node is AudioStreamPlayer3D:
				node.stream = load(open_door_sounds[rng.randi_range(0, open_door_sounds.size() - 1)])
				node.play()
## Closes the door
func door_close():
	var rng = RandomNumberGenerator.new()
	if left_door_open:
		$AnimationPlayer.play_backwards("door_open_left")
		left_door_open = false
	if right_door_open:
		$AnimationPlayer.play_backwards("door_open_right")
		right_door_open = false
	$AnimationPlayer.connect("animation_finished", _on_animation_finished)
	if !close_door_sounds.is_empty():
		for node in $Model/DoorSounds.get_children():
			if node is AudioStreamPlayer3D:
				node.stream = load(close_door_sounds[rng.randi_range(0, close_door_sounds.size() - 1)])
				node.play()

## Moves transport (network method or just a helper function)
#@rpc("any_peer", "call_local")
func call_transport():
	if is_moving:
		return
	transport_move(true)
## Moves transport
func transport_move(close_door : bool):
	if close_door:
		door_close()
	changed_launch_state.emit(true)
	is_moving = true
	if last_move < waypoints.size() - 1:
		last_move += 1
	else:
		last_move = 0
	$Move.volume_db = 0
	$Move.play()
## Opens destination doors. Right is true, left is false.
#@rpc("any_peer", "call_local")
func open_dest_doors(left_or_right: bool):
	door_open(left_or_right)

func on_player_area_body_entered(body):
	if body is CharacterBody3D: #|| body is Pickable || body is LootableAmmo:
		call("add_object", body.get_path())

func on_player_area_body_exited(body):
	if body is CharacterBody3D: # || body is Pickable || body is LootableAmmo:
		call("remove_object", body.get_path())

#@rpc("any_peer", "call_local")
func add_object(name):
	objects_to_teleport.append(name)


#@rpc("any_peer", "call_local")
func remove_object(name):
	objects_to_teleport.erase(name)
## Lock or unlock transport (unused, but can be useful, if you want to control movement)
func interact():
	locked = !locked
	if locked == false:
		await get_tree().create_timer(10.0).timeout
		transport_move(true)

func _on_animation_finished(anim_name):
	$AnimationPlayer.disconnect("animation_finished", _on_animation_finished)
	set_physics_process(true)
