extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 7.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera

func _enter_tree():
	set_multiplayer_authority(str(name).to_int(), true)

func _ready():
	if not is_multiplayer_authority(): return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	#Handle Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	#Handle Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	#Handle Sprint
	if(Input.is_action_pressed("sprint")):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	#Handle Directional Movement
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)

	move_and_slide()
