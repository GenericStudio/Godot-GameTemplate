extends KinematicBody2D

var enabled:bool = false
var gravity = Vector2(0, 2);
var velocity = Vector2()

onready var timeline_interface = $TimelineInterface


func _ready():
	timeline_interface.connect("get_frame", self, "get_frame")
	timeline_interface.connect("apply_frame", self, "apply_frame")
	timeline_interface.connect("playing_changed", self, "playing_changed")
	
	
		 
func get_frame():
	prints("get_frame")
	timeline_interface.done({
		"velocity": velocity, 
		"transform": transform
	})


func apply_frame(frame, prev_frame, delta):
	prints("apply frame", frame, prev_frame, delta)
	transform = prev_frame.transform.interpolate_with(frame.transform, delta)
	velocity = prev_frame.velocity.linear_interpolate(frame.velocity, delta)


func _physics_process(delta):
	velocity += gravity;
	velocity = move_and_slide(velocity, Vector2.UP, false, 4, deg2rad(45), false)
		

func playing_changed(playing):
	var PLAYING = timeline_interface.PLAYING
	enabled = playing == PLAYING.PLAYING
	set_physics_process(enabled)




