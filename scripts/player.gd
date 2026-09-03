extends CharacterBody3D

var speed := 5.5
var sprint_speed := 9.0
var gravity := 18.0
var camera: Camera3D
var pivot: Node3D
var riding := false
var horse: Node3D
signal interaction_changed(message: String)

func setup(target_camera: Camera3D, target_pivot: Node3D, target_horse: Node3D) -> void:
 camera = target_camera
 pivot = target_pivot
 horse = target_horse

func _physics_process(delta: float) -> void:
 var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
 var basis := camera.global_transform.basis
 var forward := -basis.z; forward.y = 0.0; forward = forward.normalized()
 var right := basis.x; right.y = 0.0; right = right.normalized()
 var direction := (right * input_vec.x + forward * input_vec.y).normalized()
 var current_speed := sprint_speed if Input.is_action_pressed("run") else speed
 if riding: current_speed *= 1.45
 velocity.x = move_toward(velocity.x, direction.x * current_speed, delta * 18.0)
 velocity.z = move_toward(velocity.z, direction.z * current_speed, delta * 18.0)
 if not is_on_floor(): velocity.y -= gravity * delta
 else: velocity.y = 0.0
 if direction.length() > 0.1:
  var target_angle := atan2(direction.x, direction.z)
  rotation.y = lerp_angle(rotation.y, target_angle, delta * 10.0)
 move_and_slide()
 global_position.x = clamp(global_position.x, -58.0, 58.0)
 global_position.z = clamp(global_position.z, -58.0, 58.0)
 if horse and global_position.distance_to(horse.global_position) < 3.0:
  interaction_changed.emit("[E]  Mount the frontier horse")
 else:
  interaction_changed.emit("WASD  Move     Shift/Space  Sprint")
 if Input.is_action_just_pressed("interact") and horse and global_position.distance_to(horse.global_position) < 3.0:
  riding = not riding
  interaction_changed.emit("Mounted — ride across the frontier" if riding else "Dismounted")
  if riding:
   horse.visible = false
   speed = 8.0
  else:
   horse.visible = true
   speed = 5.5
