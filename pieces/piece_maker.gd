extends "res://management/construction/maker.gd"



func make_thing(what: Array):
	var new_piece = Piece.new()
	
	var id: String = what[0]
	id = id.to_snake_case()
	new_piece.id = id
	new_piece.title = what[0]
	new_piece.description = what[1]
	new_piece.cost = float(what[2])
	new_piece.gusto = float(what[3])
	
	
	
	ResourceSaver.save(new_piece, "%s%s.tres" % [output_folder, id])
