extends Area2D # O el nodo que sea tu meta



func _on_body_entered(body):

	if body.name == "Personaje": # O tu lógica de detección

		game_over_win()



func game_over_win():

	print("¡VICTORIA!")

	

	# ESTA es la clave: Llamamos al grupo, NO creamos nodos nuevos

	get_tree().call_group("timer", "end_race")

	

	set_deferred("monitoring", false)



@export var timer_del_nivel : Node



func _ready():

	# Nos aseguramos de que esté encendido

	monitoring = true



func _physics_process(delta):

	# 1. Preguntamos: ¿Quién está dentro de mí ahora mismo?

	var cuerpos_dentro = get_overlapping_bodies()

	

	##Revisamos la lista de intrusos

	for cuerpo in cuerpos_dentro:



		if cuerpo.name == "Personaje": ## si el intruso es un personaje se apaga

			game_over_win()

			# Apagamos el escáner para no ganar 100 veces

			set_physics_process(false) 
