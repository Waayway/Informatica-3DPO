extends Spatial

export var id: String = ""
var basePosition: Vector3 = Vector3.ZERO
var differentHeight: float = .1
var speed = 3
var ready: bool = false

var counter = 0
func _ready():
	basePosition = global_transform.origin

func _process(delta):
	counter += speed*delta
	var height = sin(counter)*differentHeight
	var newPosition = basePosition
	newPosition.y += height
	global_transform.origin = newPosition

func change_color_to_ready(isReady: bool):
	ready = isReady
	var color = Color.white
	if ready:
		color = Color.green
	$Player.get_surface_material(0).albedo_color = color
	
func change_name_above_head(name: String):
	get_parent().get_node("Spatial/Viewport/Label").text = name
