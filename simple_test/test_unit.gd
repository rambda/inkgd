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

const Utils = preload("res://addons/inkgd/runtime/extra/utils.gd")

func _run() -> void:
	var path1 := InkPath.new_with_components_string("hello.1.world")
	var path2 := InkPath.new_with_components_string("hello.1.world")

	var path3 := InkPath.new_with_components_string(".hello.1.world")
	var path4 := InkPath.new_with_components_string(".hello.1.world")

	assert(path1.equals(path2))
	assert(path3.equals(path4))
	assert(!path1.equals(path3))


	var list_item = InkListItem.new_with_origin_name("foo", "bar")
	var serialized_list_item = list_item.serialized()

	var deserialized_list_item = InkListItem.from_serialized_key(serialized_list_item)

	assert(deserialized_list_item.origin_name == "foo")
	assert(deserialized_list_item.item_name == "bar")

	var name_content_like = INamedContentLike.new()
	assert(Utils.as_INamedContent_or_null(name_content_like) == name_content_like)

	var node = Node.new()
	assert(Utils.as_INamedContent_or_null(node) == null)
	node.free()

	assert(Utils.trim("       This is Ink    ") == "This is Ink")

	assert(Utils.trim("\t\t\t    This is Ink \t \t  ", ["\t", " "]) == "This is Ink")


	var joined_array = Utils.join(" . ", ["Ink"])
	assert(joined_array == "Ink")


	var joined_array2 = Utils.join(" . ", ["Ink", "Divert"])
	assert(joined_array2 == "Ink . Divert")


	var joined_array3 = Utils.join(" . ", ["Ink", "Divert", "Gather"])
	assert(joined_array3 == "Ink . Divert . Gather")


	var joined_array4 = Utils.join("", [3, 67, 239])
	assert(joined_array4 == "367239")


	var joined_array5 = Utils.join(" - ", [InkBaseObject.new("Ink"), InkBaseObject.new(42)])
	assert(joined_array5 == "Ink - 42")


	var array = ["Ink", "Divert", "Gather", "Choice", "Tunnel"]
	var array_range = Utils.get_range(array, 1, 3)
	assert(array_range == ["Divert", "Gather", "Choice"])

	var array_range_2 = Utils.get_range(array, 1, 4)
	assert(array_range_2 == ["Divert", "Gather", "Choice", "Tunnel"])

	var array_range_3 = Utils.get_range(array, 0, 5)
	assert(array_range_3 == ["Ink", "Divert", "Gather", "Choice", "Tunnel"])


	array = ["Ink", "Divert", "Gather", "Choice", "Tunnel"]

	array_range = Utils.get_range(array, -3, 3)
	assert(array_range == ["Ink", "Divert", "Gather", "Choice", "Tunnel"])

	array_range_2 = Utils.get_range(array, 1, 10)
	assert(array_range_2 == ["Ink", "Divert", "Gather", "Choice", "Tunnel"])


	array = ["Ink", "Divert", "Gather", "Choice", "Tunnel"]
	Utils.remove_range(array, 1, 3)
	assert(array == ["Ink", "Tunnel"])


	array = ["Ink", "Divert", "Gather", "Choice", "Tunnel"]

	Utils.remove_range(array, -3, 3)
	assert(array == ["Ink", "Divert", "Gather", "Choice", "Tunnel"])

	Utils.remove_range(array, 1, 10)
	assert(array == ["Ink", "Divert", "Gather", "Choice", "Tunnel"])

# ############################################################################ #

class InkBaseObject extends InkBase:
	var value

	func _init(new_value):
		self.value = new_value

	func _to_string() -> String:
		return str(value)


class INamedContentLike extends InkBase:
	var has_valid_name = ""
	var name = ""
