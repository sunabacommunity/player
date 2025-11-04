extends App


func _init() -> void:
	init(false, [])
	var asm_dir = PlayerUtils.GetAssemblyDirectory()
	if asm_dir.contains("\\"):
		asm_dir = asm_dir.replace("\\", "/")
	if not asm_dir.ends_with("/"):
		asm_dir += "/"
	var snb_path = asm_dir + "player.snb"
	load_app(snb_path)

func _ready() -> void:
	PlatformService.PlatformName = "Sunaba Player"
	var window := get_window()
	var displayScale := DisplayServer.screen_get_scale(window.current_screen)
	if (OS.get_name() != "Linux"):
		if OS.get_name() == "Windows":
			var dpi = DisplayServer.screen_get_dpi(window.current_screen)
			displayScale = dpi * 0.01
		window.content_scale_factor = displayScale
	window.size = Vector2i(1152, 648) * displayScale
	window.move_to_center()
