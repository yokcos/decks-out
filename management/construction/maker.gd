extends Node


@export var input_file := "res://data/data.csv"
@export var output_folder := "res://pieces/pieces/"


func _ready():
	make_things()


func make_things(path: String = input_file):
	var file = FileAccess.open(path, FileAccess.READ)
	var i: int = 0
	while !file.eof_reached():
		var this_data := file.get_csv_line()
		if i > 0 and this_data.size() > 0 and this_data[0] != "":
			make_thing(this_data)
		i += 1
	file.close()

func make_thing( what: Array ):
	pass
