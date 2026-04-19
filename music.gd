extends AudioStreamPlayer


func _ready() -> void:
	var s := stream as AudioStreamOggVorbis
	if s:
		s.loop = true
	if not playing:
		play()
