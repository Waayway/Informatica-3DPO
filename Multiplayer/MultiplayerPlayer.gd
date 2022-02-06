extends KinematicBody

export var id: String = ""

var nextPoint: Vector3 = Vector3.ZERO
var speedToPoint: float = 0.0

func _ready():
	pass

func _process(delta):
	if self.global_transform.origin != nextPoint:
		var gap = Vector3(nextPoint - global_transform.origin)
		move_and_slide(gap.normalized()*speedToPoint*delta)

func setNewPoint(newPoint: Vector3):
	nextPoint = newPoint
	speedToPoint = global_transform.origin.distance_to(nextPoint) * (1/0.0166)
	print(nextPoint, speedToPoint)
