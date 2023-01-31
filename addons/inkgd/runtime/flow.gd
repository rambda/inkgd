# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkBase

class_name InkFlow

# ############################################################################ #
# Imports
# ############################################################################ #

var name: String # string
var callstack: InkCallStack # CallStack
var output_stream: Array[InkObject] # Array<InkObject>
var current_choices: Array[InkChoice] # Array<Choice>

# (String, Story) -> Flow
func _init_with_name(name, story):
	self.name = name
	self.callstack = InkCallStack.new(story)
	self.output_stream = []
	self.current_choices = []

# (String, Story, Dictionary<String, Variant>) -> Flow
func _init_with_name_and_jobject(name, story, jobject):
	self.name = name
	self.callstack = InkCallStack.new(story)
	self.callstack.set_json_token(jobject["callstack"], story)
	self.output_stream = Json.jarray_to_runtime_obj_list(jobject["outputStream"])
	self.current_choices = Json.jarray_to_runtime_obj_list(jobject["currentChoices"])

	# jchoice_threads_obj is null if 'choiceThreads' doesn't exist.
	var jchoice_threads_obj = jobject.get("choiceThreads");
	self.load_flow_choice_threads(jchoice_threads_obj, story)

# (SimpleJson.Writer) -> void
func write_json(writer):
	writer.write_object_start()
	writer.write_property("callstack", self.callstack.write_json)
	writer.write_property(
		"outputStream",
		self._anonymous_write_property_output_stream
	)

	var has_choice_threads = false
	for c in self.current_choices:
		c.original_thread_index = c.thread_at_generation.thread_index

		if self.callstack.thread_with_index(c.original_thread_index) == null:
			if !has_choice_threads:
				has_choice_threads = true
				writer.write_property_start("choiceThreads")
				writer.write_object_start()

			writer.write_property_start(c.original_thread_index)
			c.thread_at_generation.write_json(writer)
			writer.write_property_end()

	if has_choice_threads:
		writer.write_object_end()
		writer.write_property_end()

	writer.write_property(
		"currentChoices",
		self._anonymous_write_property_current_choices
	)

	writer.write_object_end()

# (Dictionary, Story) -> void
func load_flow_choice_threads(jchoice_threads, story):
	for choice in self.current_choices:
		var found_active_thread = self.callstack.thread_with_index(choice.original_thread_index)
		if found_active_thread != null:
			choice.thread_at_generation = found_active_thread.copy()
		else:
			var jsaved_choice_thread = jchoice_threads[str(choice.original_thread_index)]
			choice.thread_at_generation = InkCallStack.InkThread.new_with(jsaved_choice_thread, story)

# (SimpleJson.Writer) -> void
func _anonymous_write_property_output_stream(w):
	Json.write_list_runtime_objs(w, self.output_stream)

# (SimpleJson.Writer) -> void
func _anonymous_write_property_current_choices(w):
	w.write_array_start()
	for c in self.current_choices:
		Json.write_choice(w, c)
	w.write_array_end()

func equals(_ink_base) -> bool:
	return false

func _to_string() -> String:
	return str(self)

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "Flow" || super.is_class(type)

func get_class():
	return "Flow"

static func new_with_name(name, story):
	var flow = InkFlow.new()
	flow._init_with_name(name, story)
	return flow

static func new_with_name_and_jobject(name, story, jobject):
	var flow = InkFlow.new()
	flow._init_with_name_and_jobject(name, story, jobject)
	return flow
