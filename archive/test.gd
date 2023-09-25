extends Node

var player = preload("res://archive/test_player.tscn")
var type = "none"

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	pass

func _physics_process(_delta):
	if type == "host":
		var children = get_children()
		for child in children:
			if child.name.is_valid_int():
				sync_to_clients.rpc(child.name, child.position)
	elif type == "client":
		var children = get_children()
		for child in children:
			if not child.name.is_valid_int():
				continue
			if child.is_local_player:
				sync_to_clients.rpc(child.name, child.position)

func _on_host_pressed():
	print("Host")
	hide_buttons()
	type = "host"
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(3489, 42)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	$UniquePeerId.text = str(multiplayer.get_unique_id())
	
	spawn_player(multiplayer.get_unique_id(), true)

func _on_join_pressed():
	print("Join")
	hide_buttons()
	type = "client"
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client("localhost", 3489)
	if error:
		return
	multiplayer.multiplayer_peer = peer
	$UniquePeerId.text = str(multiplayer.get_unique_id())
	
	spawn_player(multiplayer.get_unique_id(), true)

func hide_buttons():
	$Host.hide()
	$Join.hide()

func _on_peer_connected(id):
	print("Peer connected " + str(id) + " on " + type)

@rpc("any_peer", "call_remote", "unreliable", 0)
func sync_to_clients(id, position):
	var node = get_node_or_null(NodePath(id))
	if node == null:
		node = spawn_player(id, false)
	node.position = position
	
@rpc("any_peer", "call_remote", "unreliable", 0)
func sync_to_host(id, position):
	var node = get_node_or_null(NodePath(id))
	if node == null:
		node = spawn_player(id, false)
	node.position = position

func spawn_player(id, is_local_player):
	var instance = player.instantiate()
	instance.name = str(id)
	instance.is_local_player = is_local_player
	add_child(instance)
	return instance
