# Godot train system
## Info.
An example of moving system.
Metrowagon model is under CC-BY license (made by me!)
The TransportSystem code is licensed under [MIT License](/LICENSE.MIT)

## Features
- Automatic door open (left or right), also determined stops by Path3D value.
- Forward train detection
- Player will not rotate in the train.

## How to create "transport" and make it moving
1. Import your model
2. Create "TransportSystem" node as a root of new prefab scene
3. Move all meshes (except doors) under an AnimatableBody3D
4. Set the animatable path to AnimatableBody3D in a dialog
5. For opening doors, these animations "door_open_left" and "door_open_right" must be in this scene. If they don't exist, you need to create them.
6. Create Area3D and a collision shape (fill the player area in this shape). Connect the `body_entered` and `body_exited` signals to `on_player_area_body_entered()` and `on_player_area_body_exited()`. (Necessary for smooth movement)
7. Create Move AudioStreamPlayer3D for playing Move sounds.
8. (Optional) Add Train (to the head wagon only) and Station (to the head and back (in the last wagon, you need to disable enter boolean in inspector)) triggers as Area 3D. They are useful, when you are calculating station and train bounds.
9. (Optional) Create DoorSounds node3d and put AudioStreamPlayers3D to play the door sounds.
10. Create or open a game scene with Path3D.
11. Add the transport prefab as a child to Path3D

![image](./src/icon.png "title")