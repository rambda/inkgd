# ############################################################################ #
# Copyright © 2015-2021 inkle Ltd.
# Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
# All Rights Reserved
#
# This file is part of inkgd.
# inkgd is licensed under the terms of the MIT license.
# ############################################################################ #

extends InkObject

class_name InkNativeFunctionCall

# ############################################################################ #
# Imports
# ############################################################################ #

const ValueType = preload("res://addons/inkgd/runtime/values/value_type.gd").ValueType

const ADD                    = "+"
const SUBTRACT               = "-"
const DIVIDE                 = "/"
const MULTIPLY               = "*"
const MOD                    = "%"
const NEGATE                 = "_"
const EQUALS                 = "=="
const GREATER                = ">"
const LESS                   = "<"
const GREATER_THAN_OR_EQUALS = ">="
const LESS_THAN_OR_EQUALS    = "<="
const NOT_EQUALS             = "!="
const NOT                    = "!"
const AND                    = "&&"
const OR                     = "||"
const MIN                    = "MIN"
const MAX                    = "MAX"
const POW                    = "POW"
const FLOOR                  = "FLOOR"
const CEILING                = "CEILING"
const INT                    = "INT"
const FLOAT                  = "FLOAT"
const HAS                    = "?"
const HASNT                  = "!?"
const INTERSECT              = "^"
const LIST_MIN               = "LIST_MIN"
const LIST_MAX               = "LIST_MAX"
const ALL                    = "LIST_ALL"
const COUNT                  = "LIST_COUNT"
const VALUE_OF_LIST          = "LIST_VALUE"
const INVERT                 = "LIST_INVERT"

# ############################################################################ #

#var native_functions: Dictionary

const meta = "InkNativeFunctionCall_native_functions"
const static_ref: Script = InkNativeFunctionCall

static func get_native_functions() -> Dictionary:
	return static_ref.get_meta(meta) if static_ref.has_meta(meta) else {}

static func set_native_functions(key: String, value: InkNativeFunctionCall) -> void:
	if static_ref.has_meta(meta):
		static_ref.get_meta(meta)[key] = value
	else:
		static_ref.set_meta(meta, {})

# ############################################################################ #

# (String) -> Bool
static func call_exists_with_name(function_name) -> bool:
	return get_native_functions().has(function_name)

# () -> void
static func init() -> void:
	add_int_binary_op(ADD,                      "int_binary_op_add")
	add_int_binary_op(SUBTRACT,                 "int_binary_op_substract")
	add_int_binary_op(MULTIPLY,                 "int_binary_op_multiply")
	add_int_binary_op(DIVIDE,                   "int_binary_op_divide")
	add_int_binary_op(MOD,                      "int_binary_op_mod")
	add_int_unary_op (NEGATE,                   "int_unary_op_negate")

	add_int_binary_op(EQUALS,                   "int_binary_op_equals")
	add_int_binary_op(GREATER,                  "int_binary_op_greater")
	add_int_binary_op(LESS,                     "int_binary_op_less")
	add_int_binary_op(GREATER_THAN_OR_EQUALS,   "int_binary_op_greater_than_or_equals")
	add_int_binary_op(LESS_THAN_OR_EQUALS,      "int_binary_op_less_than_or_equals")
	add_int_binary_op(NOT_EQUALS,               "int_binary_op_not_equals")
	add_int_unary_op (NOT,                      "int_unary_op_not")

	add_int_binary_op(AND,                      "int_binary_op_and")
	add_int_binary_op(OR,                       "int_binary_op_or")

	add_int_binary_op(MAX,                      "int_binary_op_max")
	add_int_binary_op(MIN,                      "int_binary_op_min")

	add_int_binary_op(POW,                      "int_binary_op_pow")
	add_int_unary_op (FLOOR,                    "int_unary_op_floor")
	add_int_unary_op (CEILING,                  "int_unary_op_ceiling")
	add_int_unary_op (INT,                      "int_unary_op_int")
	add_int_unary_op (FLOAT,                    "int_unary_op_float")

	add_float_binary_op(ADD,                    "float_binary_op_add")
	add_float_binary_op(SUBTRACT,               "float_binary_op_substract")
	add_float_binary_op(MULTIPLY,               "float_binary_op_multiply")
	add_float_binary_op(DIVIDE,                 "float_binary_op_divide")
	add_float_binary_op(MOD,                    "float_binary_op_mod")
	add_float_unary_op (NEGATE,                 "float_unary_op_negate")

	add_float_binary_op(EQUALS,                 "float_binary_op_equals")
	add_float_binary_op(GREATER,                "float_binary_op_greater")
	add_float_binary_op(LESS,                   "float_binary_op_less")
	add_float_binary_op(GREATER_THAN_OR_EQUALS, "float_binary_op_greater_than_or_equals")
	add_float_binary_op(LESS_THAN_OR_EQUALS,    "float_binary_op_less_than_or_equals")
	add_float_binary_op(NOT_EQUALS,             "float_binary_op_not_equals")
	add_float_unary_op (NOT,                    "float_unary_op_not")

	add_float_binary_op(AND,                    "float_binary_op_and")
	add_float_binary_op(OR,                     "float_binary_op_or")

	add_float_binary_op(MAX,                    "float_binary_op_max")
	add_float_binary_op(MIN,                    "float_binary_op_min")

	add_float_binary_op(POW,                    "float_binary_op_pow")
	add_float_unary_op (FLOOR,                  "float_unary_op_floor")
	add_float_unary_op (CEILING,                "float_unary_op_ceiling")
	add_float_unary_op (INT,                    "float_unary_op_int")
	add_float_unary_op (FLOAT,                  "float_unary_op_float")

	add_string_binary_op(ADD,                   "string_binary_op_add")
	add_string_binary_op(EQUALS,                "string_binary_op_equals")
	add_string_binary_op(NOT_EQUALS,            "string_binary_op_not_equals")
	add_string_binary_op(HAS,                   "string_binary_op_has")
	add_string_binary_op(HASNT,                 "string_binary_op_hasnt")

	add_list_binary_op (ADD,                    "list_binary_op_add")
	add_list_binary_op (SUBTRACT,               "list_binary_op_substract")
	add_list_binary_op (HAS,                    "list_binary_op_has")
	add_list_binary_op (HASNT,                  "list_binary_op_hasnt")
	add_list_binary_op (INTERSECT,              "list_binary_op_intersect")

	add_list_binary_op (EQUALS,                 "list_binary_op_equals")
	add_list_binary_op (GREATER,                "list_binary_op_greater")
	add_list_binary_op (LESS,                   "list_binary_op_less")
	add_list_binary_op (GREATER_THAN_OR_EQUALS, "list_binary_op_greater_than_or_equals")
	add_list_binary_op (LESS_THAN_OR_EQUALS,    "list_binary_op_less_than_or_equals")
	add_list_binary_op (NOT_EQUALS,             "list_binary_op_not_equals")

	add_list_binary_op (AND,                    "list_binary_op_and")
	add_list_binary_op (OR,                     "list_binary_op_or")

	add_list_unary_op (NOT,                     "list_unary_op_not")

	add_list_unary_op (INVERT,                  "list_unary_op_invert")
	add_list_unary_op (ALL,                     "list_unary_op_all")
	add_list_unary_op (LIST_MIN,                "list_unary_op_list_min")
	add_list_unary_op (LIST_MAX,                "list_unary_op_list_max")
	add_list_unary_op (COUNT,                   "list_unary_op_count")
	add_list_unary_op (VALUE_OF_LIST,           "list_unary_op_value_of_list")

	add_op_to_native_func(EQUALS, 2, ValueType.DIVERT_TARGET,
						"native_func_divert_targets_equal")
	add_op_to_native_func(NOT_EQUALS, 2, ValueType.DIVERT_TARGET,
						"native_func_divert_targets_not_equal")

# (String, int, ValueType, Variant)
static func add_op_to_native_func(name, args, val_type, op):
	var native_func: InkNativeFunctionCall = get_native_functions().get(name, null)
	if native_func == null:
		native_func = InkNativeFunctionCall.new_with_name_and_number_of_parameters(name, args)
		set_native_functions(name, native_func)
	native_func.add_op_func_for_type(val_type, op)

static func add_int_binary_op(name, op_function_name):
	add_op_to_native_func(name, 2, ValueType.INT, op_function_name)

static func add_int_unary_op(name, op_function_name):
	add_op_to_native_func(name, 1, ValueType.INT, op_function_name)

static func add_float_binary_op(name, op_function_name):
	add_op_to_native_func(name, 2, ValueType.FLOAT, op_function_name)

static func add_float_unary_op(name, op_function_name):
	add_op_to_native_func(name, 1, ValueType.FLOAT, op_function_name)

static func add_string_binary_op(name, op_function_name):
	add_op_to_native_func(name, 2, ValueType.STRING, op_function_name)

static func add_list_binary_op(name, op_function_name):
	add_op_to_native_func(name, 2, ValueType.LIST, op_function_name)

static func add_list_unary_op(name, op_function_name):
	add_op_to_native_func(name, 1, ValueType.LIST, op_function_name)

# ############################################################################ #

static func int_binary_op_add(x, y):                      return x + y
static func int_binary_op_substract(x, y):                return x - y
static func int_binary_op_multiply(x, y):                 return x * y
static func int_binary_op_divide(x, y):                   return x / y
static func int_binary_op_mod(x, y):                      return x % y
static func int_unary_op_negate(x):                       return -x

static func int_binary_op_equals(x, y):                   return x == y
static func int_binary_op_greater(x, y):                  return x > y
static func int_binary_op_less(x, y):                     return x < y
static func int_binary_op_greater_than_or_equals(x, y):   return x >= y
static func int_binary_op_less_than_or_equals(x, y):      return x <= y
static func int_binary_op_not_equals(x, y):               return x != y
static func int_unary_op_not(x):                          return x == 0

static func int_binary_op_and(x, y):                      return x != 0 && y != 0
static func int_binary_op_or(x, y):                       return x != 0 || y != 0

static func int_binary_op_max(x, y):                      return max(x, y)
static func int_binary_op_min(x, y):                      return min(x, y)

static func int_binary_op_pow(x, y):                      return pow(float(x), float(y))
static func int_unary_op_floor(x):                        return x
static func int_unary_op_ceiling(x):                      return x
static func int_unary_op_int(x):                          return x
static func int_unary_op_float(x):                        return float(x)

static func float_binary_op_add(x, y):                    return x + y
static func float_binary_op_substract(x, y):              return x - y
static func float_binary_op_multiply(x, y):               return x * y
static func float_binary_op_divide(x, y):                 return x / y
static func float_binary_op_mod(x, y):                    return fmod(x, y)
static func float_unary_op_negate(x):                     return -x

static func float_binary_op_equals(x, y):                 return x == y
static func float_binary_op_greater(x, y):                return x > y
static func float_binary_op_less(x, y):                   return x < y
static func float_binary_op_greater_than_or_equals(x, y): return x >= y
static func float_binary_op_less_than_or_equals(x, y):    return x <= y
static func float_binary_op_not_equals(x, y):             return x != y
static func float_unary_op_not(x):                        return x == 0.0

static func float_binary_op_and(x, y):                    return x != 0.0 && y != 0.0
static func float_binary_op_or(x, y):                     return x != 0.0 || y != 0.0

static func float_binary_op_max(x, y):                    return max(x, y)
static func float_binary_op_min(x, y):                    return min(x, y)

static func float_binary_op_pow(x, y):                    return pow(x, y)
static func float_unary_op_floor(x):                      return floor(x)
static func float_unary_op_ceiling(x):                    return ceil(x)
static func float_unary_op_int(x):                        return int(x)
static func float_unary_op_float(x):                      return x

static func string_binary_op_add(x, y):                   return str(x, y)
static func string_binary_op_equals(x, y):                return x == y
static func string_binary_op_not_equals(x, y):            return x != y

# Note: The Content Test (in) operator does not returns true when testing
# against the empty string, unlike the behaviour of the original C# runtime.
static func string_binary_op_has(x, y):                   return y == "" || (y in x)
static func string_binary_op_hasnt(x, y):                 return !(y in x) && y != ""

static func list_binary_op_add(x, y):                     return x.union(y)
static func list_binary_op_substract(x, y):               return x.without(y)
static func list_binary_op_has(x, y):                     return x.contains(y)
static func list_binary_op_hasnt(x, y):                   return !x.contains(y)
static func list_binary_op_intersect(x, y):               return x.intersection(y)

static func list_binary_op_equals(x, y):                  return x.equals(y)
static func list_binary_op_greater(x, y):                 return x.greater_than(y)
static func list_binary_op_less(x, y):                    return x.less_than(y)
static func list_binary_op_greater_than_or_equals(x, y):  return x.greater_than_or_equals(y)
static func list_binary_op_less_than_or_equals(x, y):     return x.less_than_or_equals(y)
static func list_binary_op_not_equals(x, y):              return !x.equals(y)

static func list_binary_op_and(x, y):                     return x.size() > 0 && y.size() > 0
static func list_binary_op_or(x, y):                      return x.size() > 0 || y.size() > 0

static func list_unary_op_not(x):                         return 1 if x.size() == 0 else 0

static func list_unary_op_invert(x):                      return x.inverse
static func list_unary_op_all(x):                         return x.all
static func list_unary_op_list_min(x):                    return x.min_as_list()
static func list_unary_op_list_max(x):                    return x.max_as_list()
static func list_unary_op_count(x):                       return x.size()
static func list_unary_op_value_of_list(x):               return x.max_item.value

static func native_func_divert_targets_equal(d1, d2):     return d1.equals(d2)
static func native_func_divert_targets_not_equal(d1, d2): return !d1.equals(d2)


# ############################################################################ #

# (String) -> InkNativeFunctionCall
static func call_with_name(function_name) -> InkNativeFunctionCall:
	return InkNativeFunctionCall.new_with_name(function_name)

var name: String:
	get:
		return _name
	set(value):
		_name = value
		if !_is_prototype:
			_prototype = get_native_functions()[_name]
var _name: String

var number_of_parameters: int:
	get:
		if _prototype:
			return _prototype.number_of_parameters
		else:
			return _number_of_parameters
	set(value):
		_number_of_parameters = value

var _number_of_parameters = 0

# (Array<InkObject>) -> InkObject
#
# The name is different to avoid shadowing 'Object.call'
#
# The method takes a `StoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func call_with_parameters(parameters: Array[InkObject], metadata: StoryErrorMetadata) -> InkObject:
	if _prototype:
		return _prototype.call_with_parameters(parameters, metadata)

	if self.number_of_parameters != parameters.size():
		Utils.throw_exception("Unexpected number of parameters")
		return null

	var has_list = false
	for p in parameters:
		if p is InkVoid:
			Utils.throw_story_exception(
					"Attempting to perform operation checked a void value. Did you forget to " +
					"'return' a value from a function you called here?",
					false,
					metadata
			)
			return null
		if p is InkListValue:
			has_list = true

	if parameters.size() == 2 && has_list:
		return call_binary_list_operation(parameters, metadata)

	var coerced_params := coerce_values_to_single_type(parameters, metadata)

	# ValueType
	var coerced_type: ValueType = coerced_params[0].value_type

	if (
			coerced_type == ValueType.INT ||
			coerced_type == ValueType.FLOAT ||
			coerced_type == ValueType.STRING ||
			coerced_type == ValueType.DIVERT_TARGET ||
			coerced_type == ValueType.LIST
	):
		return call_coerced(coerced_params, metadata)

	return null

# (Array<Value>) -> Value # Call<T> in the original code
#
# The method takes a `StoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func call_coerced(parameters_of_single_type: Array, metadata: StoryErrorMetadata) -> InkValue:
	var param1: InkValue = parameters_of_single_type[0]
	var val_type: int = param1.value_type

	var param_count: int = parameters_of_single_type.size()

	if param_count == 2 || param_count == 1:
		var op_for_type = null
		if _operation_funcs.has(val_type):
			op_for_type = _operation_funcs[val_type]
		else:
			var type_name = Utils.value_type_name(val_type)
			Utils.throw_story_exception(
					"Cannot perform operation '%s' checked value of type (%d)" \
					% [self.name, type_name],
					false,
					metadata
			)
			return null

		if param_count == 2:
			var param2 = parameters_of_single_type[1]

			var result_val = call(op_for_type, param1.value, param2.value)

			return InkValue.create(result_val)
		else:
			var result_val = call(op_for_type, param1.value)

			return InkValue.create(result_val)
	else:
		Utils.throw_exception(
				"Unexpected number of parameters to NativeFunctionCall: %d" % \
				parameters_of_single_type.size()
		)
		return null

# (Array<InkObject>) -> Value
#
# The method takes a `StoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func call_binary_list_operation(parameters: Array, metadata) -> InkValue:
	if ((self.name == "+" || self.name == "-") &&
		(parameters[0] is InkListValue) &&
		(parameters [1] is InkIntValue)
	):
		return call_list_increment_operation(parameters)

	var v1 = parameters[0] as InkValue
	var v2 = parameters[1] as InkValue

	if ((self.name == "&&" || self.name == "||") &&
		(v1.value_type != ValueType.LIST || v2.value_type != ValueType.LIST)
	):
		var op: String = _operation_funcs[ValueType.INT]
		var result = bool(call(
			"op_for_type",
			1 if v1.is_truthy else 0,
			1 if v2.is_truthy else 0
		))

		return InkBoolValue.new(result)

	if v1.value_type == ValueType.LIST && v2.value_type == ValueType.LIST:
		return call_coerced([v1, v2], metadata)

	var v1_type_name = Utils.value_type_name(v1.value_type)
	var v2_type_name = Utils.value_type_name(v2.value_type)
	Utils.throw_story_exception(
			"Can not call use '%s' operation checked %s and %s" % \
			[self.name, v1_type_name, v2_type_name],
			false,
			metadata
	)

	return null

# (Array<InkObject>) -> Value
func call_list_increment_operation(list_int_params: Array) -> InkValue:
	var list_val: InkListValue = Utils.cast(list_int_params[0], InkListValue)
	var int_val: InkIntValue = Utils.cast(list_int_params [1], InkIntValue)

	var result_raw_list = InkList.new()

	for list_item in list_val.value.keys(): # TODO: Optimize?
		var list_item_value = list_val.value.get_item(list_item)

		var int_op: String = _operation_funcs[ValueType.INT]

		var target_int = int(
				call(
						int_op,
						list_item_value,
						int_val.value
				)
		)

		var item_origin: InkListDefinition = null
		for origin in list_val.value.origins:
			if origin.name == list_item.origin_name:
				item_origin = origin
				break

		if item_origin != null:
			var incremented_item: InkTryGetResult = item_origin.try_get_item_with_value(target_int)
			if incremented_item.exists:
				result_raw_list.set_item(incremented_item.result, target_int)

	return InkListValue.new(result_raw_list)

# (Array<InkObject>) -> Array<Value>?
#
# The method takes a `StoryErrorMetadata` object as a parameter that
# doesn't exist in upstream. The metadat are used in case an 'exception'
# is raised. For more information, see story.gd.
func coerce_values_to_single_type(
	parameters_in: Array[InkObject], metadata: StoryErrorMetadata
) -> Array[InkValue]:
	var val_type = ValueType.INT

	var special_case_list: InkListValue = null # InkListValue

	for obj in parameters_in:
		var val := obj as InkValue
		if val.value_type > val_type:
			val_type = val.value_type

		if val.value_type == ValueType.LIST:
			special_case_list = val as InkListValue

	var parameters_out: Array[InkValue] = [] # Array<Value>

	if val_type == ValueType.LIST:
		for val in parameters_in:
			if val.value_type == ValueType.LIST:
				parameters_out.append(val)
			elif val.value_type == ValueType.INT:
				var int_val = int(val.value_object)
				var list = special_case_list.value.origin_of_max_item

				var item: InkTryGetResult = list.try_get_item_with_value(int_val)
				if item.exists:
					var casted_value = InkListValue.new_with_single_item(item.result, int_val)
					parameters_out.append(casted_value)
				else:
					Utils.throw_story_exception(
							"Could not find List item with the value %d in %s" \
							% [int_val, list.name],
							false,
							metadata
					)

					return []
			else:
				var type_name = Utils.value_type_name(val.value_type)
				Utils.throw_story_exception(
						"Cannot mix Lists and %s values in this operation" % type_name,
						false,
						metadata
				)

				return []

	else:
		for val in parameters_in:
			var casted_value = val.cast(val_type)
			parameters_out.append(casted_value)

	return parameters_out


func _init_with_name(name: String):
	self.name = name

func _init_with_name_and_number_of_parameters(name: String, number_of_parameters: int):
	_is_prototype = true
	self.name = name
	self.number_of_parameters = number_of_parameters

# (ValueType, String) -> void
func add_op_func_for_type(val_type: int, op: String) -> void:
	_operation_funcs[val_type] = op

func _to_string() -> String:
	return "Native '%s'" % self.name

# InkNativeFunctionCall
var _prototype: InkNativeFunctionCall = null

var _is_prototype: bool = false

# Dictionary<ValueType, String>
var _operation_funcs: Dictionary = {}

# ############################################################################ #
# GDScript extra methods
# ############################################################################ #

func is_class(type):
	return type == "NativeFunctionCall" || super.is_class(type)

func get_class():
	return "NativeFunctionCall"

# ############################################################################ #

static func new_with_name(name: String):
	var native_function_call = InkNativeFunctionCall.new()
	native_function_call._init_with_name(name)
	return native_function_call

static func new_with_name_and_number_of_parameters(name: String, number_of_parameters: int):
	var native_function_call = InkNativeFunctionCall.new()
	native_function_call._init_with_name_and_number_of_parameters(name, number_of_parameters)
	return native_function_call
