extends Node
# docstring 文档说明


################################################################
# Signals 信号
################################################################

################################################################
# Enums 枚举
################################################################

################################################################
# Constants 常量
################################################################

################################################################
# Exported variables 导出变量
################################################################

################################################################
# Public variables 公共变量
################################################################
var game = null
var player_index: int = -1

################################################################
# Private variables 私有变量
################################################################
var _player_class = null

################################################################
# Onready variables 自动初始化变量
################################################################
onready var _player_ui = $Player
onready var _se_player = {
	"discard": $SoundEffect/Discard,
	"chow": $SoundEffect/Chow,
	"pong": $SoundEffect/Pong,
	"kong": $SoundEffect/Kong,
	"richi": $SoundEffect/Richi,
	"win": $SoundEffect/Win,
	"tsumo": $SoundEffect/WinBySelf,
}


################################################################
# built-in virtual methods 内置的虚函数
################################################################
#func _init():
#	pass


func _ready():
	_player_ui.connect("tile_discarded", self, "_on_tile_discarded")
	_player_ui.connect("tile_called", self, "_on_tile_called")
	player_index = 0
	new_game()


#func _process(delta):
#	pass


################################################################
# Public methods 公共函数
################################################################
func new_game() -> void:
	game = MahjongGame.new()
	_player_ui.known_dora = game.get_dora(Mahjong.DORA.OUTER)
	_player_class = game.get_player(player_index)
	_player_ui.hand_tiles = _player_class.hand
	_player_ui.tiles_count = game.get_tiles_count()
	for history_node in _player_ui._output_history.get_children():
		history_node.queue_free()
	$DebugInfo/MD5.text = "MD5: " + game.sequence_md5
	$DebugConsole/Deck.bbcode_text = game.temp_debug_deck()
	$DebugConsole/WindowDialog/MarginContainer/GridContainer/KongTimes.value = 0


################################################################
# Private methods 私有函数
################################################################


################################################################
# Setter/Getter methods
################################################################


################################################################
# Callback methods 回调函数
################################################################
func _on_tile_discarded(tile_value):
	_player_class.discard(tile_value)
	_se_player["discard"].play()
	_player_ui.hand_tiles = _player_class.hand


func _on_tile_called(data: Dictionary) -> void:
	match data["type"]:
		Mahjong.CALL.WIN:
			print("玩家%d 选择 和牌" % player_index)
			if randi() % 2:
				_se_player["win"].play()
			else:
				_se_player["tsumo"].play()
		Mahjong.CALL.KONG:
			print("玩家%d 选择 杠" % player_index)
			_se_player["kong"].play()
		Mahjong.CALL.PONG:
			print("玩家%d 选择 碰" % player_index)
			_se_player["pong"].play()
		Mahjong.CALL.CHOW:
			print("玩家%d 选择 吃" % player_index)
			_se_player["chow"].play()
		Mahjong.CALL.RICHI:
			print("玩家%d 选择 立直" % player_index)
			_se_player["richi"].play()


func _on_MD5_pressed():
	OS.clipboard = game._deck_sequence
	assert(OS.shell_open("https://www.queji.tw/cardsmd5/#" + game._deck_sequence) == 0)


func _on_NewGame_pressed():
	new_game()


func _on_KongTimes_value_changed(value):
	game.kong_count = int(value)
	_player_ui.known_dora = game.get_dora(Mahjong.DORA.OUTER)
	$DebugConsole/Deck.bbcode_text = game.temp_debug_deck()


func _on_PlayerIndex_item_selected(index):
	player_index = index
	_player_class = game.get_player(player_index)
	_player_ui.hand_tiles = _player_class.hand


func _on_Draw_pressed():
	if len(_player_class.hand) < 14:
		game.deal(player_index)
		_player_ui.hand_tiles = _player_class.hand
		$DebugConsole/Deck.bbcode_text = game.temp_debug_deck()
		_player_ui.tiles_count = game.get_tiles_count()
	else:
		print("[DEBUG] 摸牌失败 手牌已经满了")