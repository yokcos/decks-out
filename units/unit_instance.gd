extends RefCounted
class_name UnitInstance


var unit: Unit = null
var hp: float = 1
var damage: float = 1
var level: int = 1
var team: int = 1
var position: Vector2i = Vector2i()
var flying: bool = false


signal attack_dealt
signal died


func take_damage( dmg: DamageInstance ):
	hp -= dmg.damage
	if hp <= 0:
		die()

func perform_attack( where: Vector2i ):
	var this_dmg = DamageInstance.new()
	this_dmg.damage = damage
	attack_dealt.emit( position, where, this_dmg )

func perform_attacks():
	for this_attack in unit.attacks:
		perform_attack( Vector2i(this_attack) )

func connect_to_grid( what: Grid ):
	attack_dealt.connect( what._on_attack_dealt )
	died.connect( what._on_unit_slain )

func resolve_turn():
	perform_attacks()

func die():
	died.emit( position )
