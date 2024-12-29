extends Control

# Onready variables for labels
@onready var length_label = $LengthCounter
@onready var cost_label = $CostDisplay
@onready var warnings_label = $Warnings

func _ready():
	# Initialize the labels, with error handling
	if length_label != null:
		length_label.text = "Length: 0 ft"
	else:
		print("Error: LengthCounter node is missing!")

	if cost_label != null:
		cost_label.text = "Cost: $0"
	else:
		print("Error: CostDisplay node is missing!")

	if warnings_label != null:
		warnings_label.text = "Warnings: None"
	else:
		print("Error: Warnings node is missing!")

# Function to update the Length and Cost stats dynamically
func update_stats(length, cost):
	if length_label != null:
		length_label.text = "Length: %s ft" % length
	if cost_label != null:
		cost_label.text = "Cost: $%s" % cost

# Function to display a warning
func show_warning(message):
	if warnings_label != null:
		warnings_label.text = "Warnings: %s" % message

# Function to clear the warning
func clear_warning():
	if warnings_label != null:
		warnings_label.text = "Warnings: None"
