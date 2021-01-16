extends KinematicBody2D

var enabled:bool = false
var gravity = Vector2(0, 10)
var jump_strength = 400
var run_force = 10
var max_run_speed = 300
var velocity = Vector2()
enum jump_states {
	GROUNDED,
	JUMP_PRESSED,
	JUMPING,
	FALLING
}
var jump_state = jump_states.GROUNDED;

onready var timeline_interface = $TimelineInterface


func _ready():
	timeline_interface.connect("get_frame", self, "get_frame")
	timeline_interface.connect("apply_frame", self, "apply_frame")
	timeline_interface.connect("playing_changed", self, "playing_changed")
	
		 
func get_frame():
	prints("get_frame")
	timeline_interface.done({
		"velocity": velocity, 
		"transform": transform,
		"jump_state":jump_state
	})


func apply_frame(frame, prev_frame, delta):
	prints("apply frame", frame, prev_frame, delta)
	transform = prev_frame.transform.interpolate_with(frame.transform, delta)
	velocity = prev_frame.velocity.linear_interpolate(frame.velocity, delta)
	jump_state = prev_frame.jump_state;


func _physics_process(delta):
	var dir = Vector2.ZERO
	dir.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	dir.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")

	if is_on_floor():
		jump_state = jump_states.GROUNDED;
	
	if jump_state == jump_states.GROUNDED:
		if Input.get_action_strength("Jump") > 0:
			jump_state = jump_states.JUMP_PRESSED;
	
	if jump_state == jump_states.JUMP_PRESSED:
		velocity.y = -jump_strength;
		jump_state = jump_states.JUMPING

	if jump_state == jump_states.JUMPING and velocity.y > 0:
		jump_state = jump_states.FALLING

	if jump_state == jump_states.JUMPING and Input.get_action_strength("Jump") == 0:
		jump_state = jump_states.FALLING
		velocity.y *= 0.75;

	if jump_state == jump_states.FALLING:
		velocity += gravity 


	if dir.x:
		# Get absolute current speed
		var v = abs(velocity.x)
		# Get diff from current speed to maximum speed
		var force = min(run_force, max_run_speed - v);
		
		velocity.x += dir.x * force;
		#velocity +=  sign(dir.x) * max_delta;

	velocity += gravity;
	var prev_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, deg2rad(45), true)
	if dir.x == 0:
		var v = abs(velocity.x)
		velocity.x -=  sign(velocity.x) * min(v, run_force) *.9
	
	
	for i in get_slide_count():
		var other = get_slide_collision(i).collider as KinematicBody2D
		if other and "velocity" in other:
			other.velocity += prev_velocity * 0.5

func playing_changed(playing):
	var PLAYING = timeline_interface.PLAYING
	enabled = playing == PLAYING.PLAYING
	set_physics_process(enabled)




