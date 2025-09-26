# class_name EventBus
extends Node

signal trait_added(component_name: String, node: Node)
signal trait_removed(component_name: String, node: Node)
signal component_added(component_name: String, node: Node)
signal component_removed(component_name: String, node: Node)
signal component_enabled(component_name: String)
signal component_disabled(component_name: String)