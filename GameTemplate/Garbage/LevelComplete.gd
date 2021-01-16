extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "body_entered")
	pass # Replace with function body.

func body_entered(body: Node):
	if(body.is_in_group('player')):
		# emit win signal to game controller
		print("Win Condition Met")

