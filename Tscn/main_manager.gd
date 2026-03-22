# res://Tscn/main_manager.gd
extends Node

@onready var splash_godot = preload("res://Tscn/Start/SplashGodot.tscn")

var is_skipped: bool = false 

func _ready():
	# 언어 선택 창 팝업용 세팅 삭제 코드
	# DirAccess.remove_absolute("user://settings.cfg")
	start_sequence()
#로고창 스킵하기 
func _unhandled_input(event):
	#스페이스바 or 마우스 클릭 시 이벤트 스킵
	if event is InputEventMouseButton or event.is_action_pressed("ui_accept"):
		if not is_skipped: 
			#스킵드의 기본 상태는 폴스 not flase=true 
			#지금 스킵 중이 아니라면 
			skip_to_main_menu() #스킵 시퀀스 실행

func start_sequence():
	var godot_node = splash_godot.instantiate() #로고 화면 찍어내기 스플래시 고도를 불러온다
	add_child(godot_node) #화면에 자식으로 고도 노드를 불러와라 
	
	var anim = godot_node.get_node_or_null("AnimationPlayer")
	if anim: await anim.animation_finished  #애니메이션 재생해라
	if is_skipped: return #스킵이 true면 넘길거고
	determine_next_scene()

func skip_to_main_menu():
	is_skipped = true #지금 스킵중입니다.
	for child in get_children(): #
		if "SplashGodot" in child.name:
			child.queue_free()
	determine_next_scene()


func determine_next_scene():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	
	if err != OK:
		print("로그: 설정 파일 없음. [언어 선택 화면]으로 이동.")
		get_tree().change_scene_to_file("res://Tscn/Start/LanguageSelect.tscn")
	else:
		var saved_locale = config.get_value("general", "locale", "ko")
		print("로그: 설정 기록 발견! 적용된 로케일: ", saved_locale)
		
		# 💡 엔진 번역 서버에 즉시 적용 (매우 중요)
		TranslationServer.set_locale(saved_locale)
		
		get_tree().change_scene_to_file("res://Tscn/Start/MainMenu.tscn")
	
	set_process_unhandled_input(false)
