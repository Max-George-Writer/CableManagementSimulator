extends Node2D

var grid_size = 32  # Size of each grid cell

func _ready():
	print("BackgroundGrid ready.")
	queue_redraw()  # Trigger an initial redraw

func _draw():
	var viewport_size = get_viewport_rect().size
	for x in range(0, int(viewport_size.x), grid_size):
		draw_line(Vector2(x, 0), Vector2(x, viewport_size.y), Color(0.5, 0.5, 0.5, 0.2))
	for y in range(0, int(viewport_size.y), grid_size):
		draw_line(Vector2(0, y), Vector2(viewport_size.x, y), Color(0.5, 0.5, 0.5, 0.2))
