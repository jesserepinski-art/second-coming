class_name Interactable
extends Area2D

@export var interaction_name := "Interact"

func interact():
	if get_parent().has_method("interact"):
		get_parent().interact()
