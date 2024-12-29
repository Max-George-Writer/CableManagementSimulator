extends Node2D

@onready var cables_container = $Cables
@onready var ui = $UI

var active_cable = null
var cable_color = Color(1, 0, 0)
var vertex_color = Color(0, 1, 0)  # Green dots for vertices
var vertex_radius = 3  # Radius of each dot
var total_length = 0.0
var cost_per_foot = 2.0
var debug_collision_point = null  # For visualizing collisions
var current_cursor_position = Vector2.ZERO  # Position of the cursor for dragging

func snap_to_grid(pos: Vector2, grid_size: int) -> Vector2:
	return Vector2(round(pos.x / grid_size) * grid_size, round(pos.y / grid_size) * grid_size)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var snapped_position = snap_to_grid(get_global_mouse_position(), 32)
			if active_cable == null:
				# Start a new cable
				active_cable = Line2D.new()
				active_cable.default_color = cable_color
				active_cable.width = 4
				cables_container.add_child(active_cable)
				active_cable.add_point(snapped_position)  # First point added immediately
			else:
				var last_point = active_cable.points[-1]
				if is_cable_colliding(last_point, snapped_position):
					ui.show_warning("Cannot place cable here, collision detected!")
				else:
					active_cable.add_point(snapped_position)
					total_length += last_point.distance_to(snapped_position)
					ui.update_stats(total_length, total_length * cost_per_foot)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if active_cable != null:
				print("Cable finalized with %s points" % active_cable.points.size())
				active_cable = null
				total_length = 0.0

func _process(delta):
	if active_cable != null:
		current_cursor_position = snap_to_grid(get_global_mouse_position(), 32)
		queue_redraw()  # Trigger redraw for live updates

func is_cable_colliding(start: Vector2, end: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state

	# Create a PhysicsRayQueryParameters2D object
	var ray_params = PhysicsRayQueryParameters2D.new()
	ray_params.from = start
	ray_params.to = end
	ray_params.collide_with_bodies = true
	ray_params.collide_with_areas = true

	# Perform the raycast
	var result = space_state.intersect_ray(ray_params)
	if result != null:
		if "collider" in result:
			var collider = result["collider"]
			var collision_position = result["position"]
			print("Collision detected with: %s at position %s" % [collider.name, collision_position])
			debug_collision_point = collision_position  # Save the collision point for visualization
			queue_redraw()
			return true
		else:
			print("Collision result is missing 'collider' key: %s" % result)
	
	debug_collision_point = null  # Clear collision visualization if no collision
	queue_redraw()
	return false

func _draw():
	# Draw collision debug point
	if debug_collision_point != null:
		draw_circle(debug_collision_point, 5, Color(1, 0, 0))  # Red circle at collision point

	# Draw vertices of active cables as dots
	if active_cable != null:
		for point in active_cable.points:
			draw_circle(point, vertex_radius, vertex_color)  # Green dots for each vertex

		# Draw the dragging segment from the last vertex to the cursor
		var last_point = active_cable.points[-1]
		draw_line(last_point, current_cursor_position, cable_color, 4)
