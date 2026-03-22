extends Control

@onready var lang_option = $VBoxContainer/LangOptionButton
@onready var lbl_info = $VBoxContainer/Label 
@onready var btn_confirm = $VBoxContainer/BtnConfirm 

func _ready():
	lang_option.clear()
	lang_option.add_item("한국어", 0)
	lang_option.add_item("English", 1)
	
	lang_option.item_selected.connect(_on_lang_selected)
	update_ui_text()

func _on_lang_selected(index: int):
	# 로케일 즉시 변경
	var new_locale = "ko" if index == 0 else "en"
	TranslationServer.set_locale(new_locale)
	update_ui_text()

func update_ui_text():
	lbl_info.text = tr("LBL_SELECT")
	btn_confirm.text = tr("BtnConfirm")

func _on_btn_confirm_pressed():
	# 💡 핵심: 'locale' 코드를 저장합니다.
	var config = ConfigFile.new()
	config.set_value("general", "locale", TranslationServer.get_locale())
	config.save("user://settings.cfg")
	
	get_tree().call_deferred("change_scene_to_file", "res://Tscn/Start/MainMenu.tscn")
