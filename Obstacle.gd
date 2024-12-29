extends StaticBody2D

func _ready():
	name = "Obstacle_%s" % str(randi())  # Give a unique name for debugging
	print("Obstacle ready: %s" % name)
