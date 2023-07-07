extends Node2D

func setcenter(node, origin):
	node.position = origin;

func _ready():
	for i in range(get_child_count()):
		setcenter(self.get_child(i), Vector2.ZERO)
	#setcenter()

