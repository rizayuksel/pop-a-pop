extends ParallaxBackground

@export var scroll_speed = 70.0

# Hafızada bu anahtar kelimeyle saklayacağız
const MEMORY_KEY = "bg_scroll_offset_x"

func _ready():
	# Eğer daha önce hafızada kaydedilmiş bir konum varsa oradan başlat
	if Engine.has_meta(MEMORY_KEY):
		scroll_offset.x = Engine.get_meta(MEMORY_KEY)

func _process(delta):
	scroll_offset.x -= scroll_speed * delta
	# Konumu her karede motorun geçici hafızasına kaydet
	Engine.set_meta(MEMORY_KEY, scroll_offset.x)
