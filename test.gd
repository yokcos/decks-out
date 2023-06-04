extends Node


var grid: Grid = Grid.new()

func _ready():
	grid.add_cell_rectangle( Vector2i(-2, -2), Vector2i(2, -1), 2 )
	grid.add_cell_rectangle( Vector2i(-2, 0) , Vector2i(2, 0) , 0 )
	grid.add_cell_rectangle( Vector2i(-2, 1) , Vector2i(2, 2) , 1 )
	
	grid.debug_message.connect( _on_grid_message )
	grid.add_unit( Vector2(0, 1) , load("res://units/units/bully.tres") )
	grid.add_unit( Vector2(0, 0) , load("res://units/units/peon.tres") )
	grid.add_unit( Vector2(-1, 0), load("res://units/units/knave.tres") )
	grid.add_unit( Vector2(1, 0) , load("res://units/units/knave.tres") )
	grid.add_unit( Vector2(-2, 1), load("res://units/units/knave.tres") )
	
	$display_grid.grid = grid

func _input(event):
	if event.is_action_pressed( "ui_accept" ):
		grid.resolve_turn()
	if event.is_action_pressed( "ui_left" ):
		grid.push_unit( Vector2i(1, 0), Vector2i(-1, 0), 3 )


func _on_grid_message(what: String):
	#print(what)
	pass
