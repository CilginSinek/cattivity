# res://autoload/BeatmapController.gd
extends Node

# Her note için veri yapısı
class NoteData:
	var time_ms: float      # hangi ms'de spawn olacak
	var position: Vector2   # dünya koordinatı
	var type: String        # "circle" | "wall"
	var rings: int = 3      # iç içe çember sayısı (circle için)

var notes: Array[NoteData] = []
var current_map_id: String = ""

func load_map(map_id: String) -> void:
	current_map_id = map_id
	notes.clear()

	# JSON dosyasını oku — res://maps/{map_id}.json
	var path = "res://maps/%s.json" % map_id
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("BeatmapController: harita bulunamadı: " + path)
		return

	var json = JSON.new()
	var err = json.parse(file.get_as_text())
	file.close()

	if err != OK:
		push_error("BeatmapController: JSON parse hatası")
		return

	var data = json.data
	for raw in data.get("notes", []):
		var nd = NoteData.new()
		nd.time_ms   = float(raw.get("time", 0))
		nd.position  = Vector2(float(raw.get("x", 0)), float(raw.get("y", 0)))
		nd.type      = raw.get("type", "circle")
		nd.rings     = int(raw.get("rings", 3))
		notes.append(nd)

func get_notes() -> Array[NoteData]:
	return notes
