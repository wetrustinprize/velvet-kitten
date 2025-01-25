extends Resource
class_name BallInfo

enum TYPE {
	BLACK,
	GREEN,
	YELLOW,
	PURPLE,
	BLUE,
}

@export var type: TYPE = TYPE.BLACK

static func random() -> BallInfo:
	var resource = BallInfo.new()

	resource.type = TYPE.values()[randi_range(1, TYPE.values().size() - 1)]

	return resource
