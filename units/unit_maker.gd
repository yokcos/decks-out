extends "res://management/construction/maker.gd"


@export var image_folder = "res://units/images/"


func make_thing( what: Array ):
	var new_unit = Unit.new()
	
	var id: String = what[0]
	id = id.to_snake_case()
	new_unit.id = id
	new_unit.name = what[0]
	new_unit.description = what[1]
	new_unit.hp = what[2]
	new_unit.hp_per_level = what[3]
	
	var image_path = "%s%s.png" % [image_folder, id]
	if ResourceLoader.exists(image_path):
		var new_image = ResourceLoader.load(image_path)
		new_unit.sprite = new_image
	
	var these_attacks := PackedVector2Array()
	var attacks: String = what[4]
	var attack_strings := attacks.split(";", false)
	for i in attack_strings:
		var this_string := i.replace(" ", "")
		this_string = this_string.replace("(", "")
		this_string = this_string.replace(")", "")
		var axes := this_string.split(",")
		var this_vector := Vector2i( int(axes[0]), int(axes[1]) )
		these_attacks.append( this_vector )
	new_unit.attacks = these_attacks
	
	ResourceSaver.save(new_unit, "%s%s.tres" % [output_folder, id])
