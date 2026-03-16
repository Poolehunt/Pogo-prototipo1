extends Node

# --- CONFIGURACIÓN DE JUGADORES ---
var quantity_of_players: int = 1
var turno_actual: int = 1

# --- MEMORIA DE LA COPA ---
# Aquí se guardan la SUMA de tiempos de cada jugador
var tiempos_totales: Array = [] 

# Aquí guardamos el mejor tiempo (Récord) del nivel actual
var record_actual: float = 9999.0 

# --- SISTEMA DE NIVELES (PLAYLIST) ---
# Lista de rutas a tus escenas. ¡Añade aquí tus niveles nuevos!
var playlist_niveles: Array = [
	"res://escenarios/nivel.tscn", 
	"res://NIVELES Y MENU/fin.tscn"
]

# Índice para saber en qué mapa estamos (0 = primero, 1 = segundo...)
var indice_nivel_actual: int = 0 

# --- FUNCIÓN DE REINICIO ---
func resetear_datos():
	turno_actual = 1
	indice_nivel_actual = 0 
	record_actual = 9999.0
	tiempos_totales = []
	
	# Creamos los espacios para sumar tiempos (ej: [0.0, 0.0])
	for i in range(quantity_of_players):
		tiempos_totales.append(0.0)
		
	print("Datos reiniciados. Playlist cargada con ", playlist_niveles.size(), " niveles.")
	
# Función segura para ir al final
func terminar_juego():
	print("Global: Llevando al jugador a la pantalla final...")
	get_tree().change_scene_to_file("res://NIVELES Y MENU/fin.tscn")
