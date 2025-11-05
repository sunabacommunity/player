extends App
class_name DesktopApp

func _errord(msg: String, title: String) -> void:
	var nativeDialog = NativeAcceptDialog.new()
	nativeDialog.dialog_icon = NativeAcceptDialog.ICON_ERROR
	nativeDialog.dialog_text = msg
	nativeDialog.title = title
	add_child(nativeDialog)
	nativeDialog.hide()
	nativeDialog.show()

func _warnd(msg: String, title: String) -> void:
	var nativeDialog = NativeAcceptDialog.new()
	nativeDialog.dialog_icon = NativeAcceptDialog.ICON_WARNING
	nativeDialog.dialog_text = msg
	nativeDialog.title = title
	add_child(nativeDialog)
	nativeDialog.hide()
	nativeDialog.show()

func _infod(msg: String, title: String) -> void:
	var nativeDialog = NativeAcceptDialog.new()
	nativeDialog.dialog_icon = NativeAcceptDialog.ICON_INFO
	nativeDialog.dialog_text = msg
	nativeDialog.title = title
	add_child(nativeDialog)
	nativeDialog.hide()
	nativeDialog.show()
