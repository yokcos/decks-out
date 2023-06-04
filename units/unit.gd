extends Resource
class_name Unit


@export var id := ""
@export var name := ""
@export var description := ""
@export var hp: float = 1
@export var hp_per_level: float = 1
@export var attacks := PackedVector2Array()
@export var sprite: Texture = null


func instantiate() -> UnitInstance:
	var new_unit = UnitInstance.new()
	new_unit.unit = self
	return new_unit

