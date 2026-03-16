extends Area2D

func _ready():
	# Nos aseguramos de que esté encendido
	monitoring = true

func _physics_process(delta):
	# 1. Preguntamos: ¿Quién está dentro de mí ahora mismo?
	var cuerpos_dentro = get_overlapping_bodies()
	
	# 2. Revisamos la lista de intrusos
	for cuerpo in cuerpos_dentro:
		# CHIVATO: Imprime todo lo que toque (Suelo, Paredes, Personaje...)
		print("La meta está tocando a: ", cuerpo.name)
		
		# 3. Si el intruso es el Personaje... ¡BINGO!
		if cuerpo.name == "Personaje": 
			game_over_win()
			# Apagamos el escáner para no ganar 100 veces
			set_physics_process(false) 

func game_over_win():
	print("¡VICTORIA POR FUERZA BRUTA!")
	get_tree().call_group("timer", "end_race")
	set_deferred("monitoring", false)
