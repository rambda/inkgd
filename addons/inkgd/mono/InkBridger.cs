// /////////////////////////////////////////////////////////////////////////// /
// Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
// Licensed under the MIT License.
// See LICENSE in the project root for license information.
// /////////////////////////////////////////////////////////////////////////// /

public partial class InkBridger : Node
{
	#region Imports
	private readonly GDScript InkPath =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/ink_path.gd");

	private readonly GDScript InkList =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/lists/ink_list.gd");

	private readonly GDScript InkListDefinition =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/lists/list_definition.gd");

	private readonly GDScript InkListItem =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/lists/structs/ink_list_item.gd");

	private readonly GDScript InkFunctionResult =
		(GDScript) ResourceLoader.Load("res://addons/inkgd/runtime/extra/function_result.gd");
	#endregion

	#region Methods | Helpers
	public bool IsInkObjectOfType(GObject inkObject, string name)
	{
		return inkObject.HasMethod("is_class") && (bool)inkObject.Call("is_class", new Variant[] { name });
	}

	public GObject MakeFunctionResult(string textOutput, object returnValue)
	{
		var parameters = new Variant[] { textOutput ?? "", (Variant)(dynamic)returnValue };
		return (GObject) InkFunctionResult.New(parameters);
	}
	#endregion

	#region Methods | Conversion -> (GDScript -> C#)
	public GObject MakeGDInkPath(Ink.Runtime.Path path) {
		var inkPath = (GObject) InkPath.New();
		inkPath.Call("_init_with_components_string", path.componentsString);
		return inkPath;
	}

	public GObject MakeGDInkList(Ink.Runtime.InkList list)
	{
		var inkListBase = new GCol.Dictionary<string, int>();

		foreach(KeyValuePair<Ink.Runtime.InkListItem, int> kv in list) {
			inkListBase.Add(MakeGDInkListItem(kv.Key).Call("serialized").AsString(), kv.Value);
		}
	
		GCol.Array inkListParams = new GCol.Array {
			inkListBase,
			list.originNames.ToArray(),
			MakeGDInkListOrigins(list.origins)
		};

		var inkList = (GObject) InkList.New();
		inkList.Call("_init_from_csharp", inkListParams);

		return inkList;
	}

	public Ink.Runtime.Path MakeSharpInkPath(GObject path) {
		if (!IsInkObjectOfType(path, "InkPath"))
		{
			throw new ArgumentException("Expected a 'GObject' of class 'InkPath'");
		}

		return new Ink.Runtime.Path((string)path.Get("components_string"));
	}
	#endregion

	#region Methods | Conversion (GDScript -> C#)
	public Ink.Runtime.InkList MakeSharpInkList(GObject list, Ink.Runtime.Story story)
	{
		if (!IsInkObjectOfType(list, "InkList"))
		{
			throw new ArgumentException("Expected a 'GObject' of class 'InkList'");
		}

		var underlyinDictionaryionary = new GCol.Dictionary<string, int>(
			(GCol.Dictionary)list.Get("_dictionary"));

		var originNames = new GCol.Array<string>(
			(GCol.Array)list.Get("origin_names"));

		var inkList = new Ink.Runtime.InkList();
		inkList.origins = new List<Ink.Runtime.ListDefinition>();

		inkList.SetInitialOriginNames(originNames.ToList());

		foreach(string originName in originNames)
		{
			if (story.listDefinitions.TryListGetDefinition (originName, out Ink.Runtime.ListDefinition definition))
			{
				if (!inkList.origins.Contains(definition)) {
					inkList.origins.Add(definition);
				}
			}
			else
			{
				throw new Exception (
					$"InkList origin could not be found in story when reconstructing list: {originName}"
				);
			}
		}

		foreach(KeyValuePair<string, int> kv in underlyinDictionaryionary)
		{
			inkList[MakeSharpInkListItem(kv.Key)] = kv.Value;
		}

		return inkList;
	}
	#endregion

	#region Private Methods | Conversion (C# -> GDScript)
	private GCol.Array<GObject> MakeGDInkListOrigins(
		List<Ink.Runtime.ListDefinition> listDefinitions)
	{
		var inkListDefinitions = new GCol.Array<GObject>();

		foreach(Ink.Runtime.ListDefinition listDefinition in listDefinitions) {
			var inkListDefinition = MakeGDListDefinition(listDefinition);
			inkListDefinitions.Add(inkListDefinition);
		}

		return inkListDefinitions;
	}

	private GObject MakeGDListDefinition(Ink.Runtime.ListDefinition listDefinition)
	{
		var items = new GCol.Dictionary<GObject, int>();

		foreach(KeyValuePair<Ink.Runtime.InkListItem, int> kv in listDefinition.items) {
			var inkListItem = MakeGDInkListItem(kv.Key);
			items.Add(inkListItem, kv.Value);
		}

		var definitionParams = new Variant[] { listDefinition.name, items };
		var inkListDefinition = (GObject) InkListDefinition.New(definitionParams);

		return inkListDefinition;
	}

	private GObject MakeGDInkListItem(Ink.Runtime.InkListItem listItem)
	{
		Variant[] itemParams = new Variant[] { listItem.fullName };

		var inkListItem = (GObject) InkListItem.New();
		inkListItem.Call("_init_with_full_name", itemParams);

		return inkListItem;
	}
	#endregion

	#region Private Methods | Conversion (GDScript -> C#)
	private Ink.Runtime.InkListItem MakeSharpInkListItem(string listItemKey)
	{

		var listItem = (GObject) InkListItem.Call("from_serialized_key", new Variant[] { listItemKey });

		if (!IsInkObjectOfType(listItem, "InkListItem")) {
			throw new ArgumentException("Expected a 'GObject' of class 'InkListItem'");
		}

		return new Ink.Runtime.InkListItem(
			listItem.Get("origin_name").AsString(),
			listItem.Get("item_name").AsString()
		);
	}
	#endregion
}
