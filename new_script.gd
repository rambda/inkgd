@tool
extends EditorScript

class Animal:
	pass


class Felis:
	extends Animal


class Cat:
	extends Felis


class FelisBieti:
	extends Felis

#
func _init() -> void:
	var cats: Array[Felis] = []
	for cat in cats:
		if cat is Cat:
			pass

	var objs: Array[InkObject] = []
	for obj in objs:
		if obj is InkListValue:
			pass


class Sorter:
	static func sort():
		pass

func _run() -> void:
	Sorter.sort()
#	Sorter.sort

#	CSScript.signal.connect() deosn't work

	#restart not work

	var a = ClassDB.instantiate("Sprite2D")
	print(a as Node3D)

	print([1,2,3] as Array[bool])

