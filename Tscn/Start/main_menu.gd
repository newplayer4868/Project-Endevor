extends Control

@onready var button_list = $CenterContainer/ButtonList
@onready var settings_panel = $SettingsPanel
@onready var lang_option_button = $SettingsPanel/PanelContainer/VBoxContainer/LangOptionButton
@onready var lbl_info = $SettingsPanel/PanelContainer/VBoxContainer/Label
# 현재 선택된 인덱스를 추적 (0: 한국어, 1: English)
var temp_selected_index = 0 

func _ready():
	# 1. 설정창 UI 초기화 (아이템을 먼저 추가해야 selected 인덱스를 잡을 수 있습니다)
	_setup_settings_ui()
	
	# 2. 저장된 설정 불러오기
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	
	var saved_locale = "ko" # 기본값
	if err == OK:
		saved_locale = config.get_value("general", "locale", "ko")
		print("로그: 저장된 언어 설정 적용 - ", saved_locale)
	
	# 3. 엔진 및 변수 동기화
	TranslationServer.set_locale(saved_locale)
	# 저장된 로케일에 따라 인덱스 변수와 옵션 버튼 상태 업데이트
	temp_selected_index = 0 if saved_locale.begins_with("ko") else 1
	lang_option_button.selected = temp_selected_index
	
	# 4. UI 텍스트 초기 갱신
	update_ui_text()
	
	# 5. 메인 버튼들 설정
	for btn in button_list.get_children():
		if btn is Button:
			setup_button_effect(btn)
			if btn.name == "BtnSettings":
				btn.pressed.connect(_on_settings_pressed)
			elif btn.name == "BtnExit":
				btn.pressed.connect(get_tree().quit)

func _setup_settings_ui():
	lang_option_button.clear()
	lang_option_button.add_item("한국어", 0)
	lang_option_button.add_item("English", 1)
	
	# 리스트 항목을 고를 때마다 실행될 함수 연결
	lang_option_button.item_selected.connect(_on_lang_item_selected)
	
	$SettingsPanel/PanelContainer/VBoxContainer/HBoxContainer/BtnConfirm.pressed.connect(_on_confirm_pressed)
	$SettingsPanel/PanelContainer/VBoxContainer/HBoxContainer/BtnCancel.pressed.connect(_on_cancel_pressed)
func _on_lang_item_selected(index: int):
	var preview_locale = "ko" if index == 0 else "en"
	
	# 엔진의 로케일을 즉시 변경 (임시 변경)
	TranslationServer.set_locale(preview_locale)
	
	# UI 텍스트 갱신 (확인, 취소 버튼 포함)
	update_ui_text()
func _on_settings_pressed():
	# 설정창을 열 때, 현재 설정된 인덱스로 다시 맞춤
	lang_option_button.selected = temp_selected_index
	settings_panel.visible = true

func _on_confirm_pressed():
	# 옵션 버튼에서 선택된 값을 변수에 저장
	temp_selected_index = lang_option_button.selected
	var new_locale = "ko" if temp_selected_index == 0 else "en"
	
	# 1. 엔진 언어 변경
	TranslationServer.set_locale(new_locale)
	
	# 2. UI 텍스트 즉시 갱신 (확인/취소 버튼 포함)
	update_ui_text()
	
	# 3. 파일에 저장
	var config = ConfigFile.new()
	config.set_value("general", "locale", new_locale)
	config.save("user://settings.cfg")
	
	settings_panel.visible = false
	print("설정이 저장되었습니다: ", new_locale)

func _on_cancel_pressed():
	# 취소를 누르면 원래 저장되어 있던 언어로 되돌려야 합니다.
	var config = ConfigFile.new()
	config.load("user://settings.cfg")
	var original_locale = config.get_value("general", "locale", "ko")
	
	TranslationServer.set_locale(original_locale)
	update_ui_text() # 다시 원래 언어로 복구
	
	settings_panel.visible = false
# --- 데이터 처리 및 연출 ---

func update_ui_text():
	for node in get_tree().get_nodes_in_group("lang_buttons"):
		if node is Button or node is Label:
			node.text = tr(node.name)

func setup_button_effect(btn: Button):
	btn.pivot_offset = btn.size / 2
	btn.mouse_entered.connect(func(): 
		create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property(btn, "scale", Vector2(1.1, 1.1), 0.2)
	)
	btn.mouse_exited.connect(func(): 
		create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2)
	)
