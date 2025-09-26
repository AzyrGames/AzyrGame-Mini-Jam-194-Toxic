extends Node

const SceneManager := preload("uid://c2x646a2anddk")


func instance_node(_file_path: String) -> Node:
	return SceneManager.instance_node(_file_path)