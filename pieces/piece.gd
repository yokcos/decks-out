extends Resource
class_name Piece


@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

@export var cost: float = 1
@export var gusto: float = 1
@export var units: Array[Unit] = []

@export var image: Texture = null

