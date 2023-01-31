# ############################################################################ #
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

@tool
extends EditorScript

# ############################################################################ #
# Imports
# ############################################################################ #

const InkRuntime = preload("res://addons/inkgd/runtime.gd")

# ############################################################################ #

var ink_runtime


func _run() -> void:
	InkRuntime.init(get_scene().root, false)
	ink_runtime = get_scene().root.get_node("InkRuntime")


	InkRuntime.deinit(get_scene().root)
	ink_runtime = null

# ############################################################################ #

func load_resource(file_name: String) -> Resource:
	return load("res://test/fixture/compiled/%s/%s.ink.json" % [_prefix(), file_name])

func load_file(file_name: String) -> String:
	var path = "res://test/fixture/compiled/%s/%s.ink.json" % [_prefix(), file_name]
	var data_file = FileAccess.open(path, FileAccess.READ)

	assert(
			data_file != null,
			"Could not load '%s'" % path
	)

	var data_text = data_file.get_as_text()

	return data_text

func _prefix() -> String:
	return ""
