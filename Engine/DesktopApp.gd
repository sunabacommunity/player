extends App
class_name DesktopApp


func _errord(msg: String, title: String) -> void:
	var dialog = NativeAcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = msg
	dialog.dialog_icon = NativeAcceptDialog.ICON_ERROR
	add_child(dialog)
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	dialog.confirmed.connect(func():
		dialog.queue_free()
	)
	dialog.show()

func _warnd(msg: String, title: String) -> void:
	var dialog = NativeAcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = msg
	dialog.dialog_icon = NativeAcceptDialog.ICON_WARNING
	add_child(dialog)
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	dialog.confirmed.connect(func():
		dialog.queue_free()
	)
	dialog.show()

func _infod(msg: String, title: String) -> void:
	var dialog = NativeAcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = msg
	dialog.dialog_icon = NativeAcceptDialog.ICON_INFO
	add_child(dialog)
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	dialog.confirmed.connect(func():
		dialog.queue_free()
	)
	dialog.show()
