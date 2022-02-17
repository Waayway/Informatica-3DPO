extends Spatial

var basePosition: Vector3 = Vector3.ZERO
var differentHeight: float = .1
var speed = 3

var counter = 0
func _ready():
	basePosition = global_transform.origin

func _process(delta):
	counter += speed*delta
	var height = sin(counter)*differentHeight
	var newPosition = basePosition
	newPosition.y += height
	print(height)
	global_transform.origin = newPosition
