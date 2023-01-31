// /////////////////////////////////////////////////////////////////////////// /
// Copyright © 2018-2022 Paul Joannon
// Copyright © 2019-2022 Frédéric Maquin <fred@ephread.com>
// Licensed under the MIT License.
// See LICENSE in the project root for license information.
// /////////////////////////////////////////////////////////////////////////// /

[Tool]

public partial class InkPlayer : Node
{
	#region Signals
	[Signal] public delegate void exception_raisedEventHandler(string message, GCol.Array<string> stack_trace);
	[Signal] public delegate void error_encounteredEventHandler(string message, int type);
	[Signal] public delegate void loadedEventHandler(bool successfully);
	[Signal] public delegate void continuedEventHandler(string text, GCol.Array<string> tags);
	[Signal] public delegate void interruptedEventHandler();
	[Signal] public delegate void prompt_choicesEventHandler(GCol.Array<string> choices);
	[Signal] public delegate void choice_madeEventHandler(string choice);
	[Signal] public delegate void function_evaluatingEventHandler(GCol.Array<string> function_name, GCol.Array arguments);
	[Signal] public delegate void function_evaluatedEventHandler(GCol.Array<string> function_name, GCol.Array arguments, GObject function_result);
	[Signal] public delegate void path_choosenEventHandler(string path, GCol.Array arguments);
	[Signal] public delegate void endedEventHandler();
	#endregion

	#region Exported properties
	[Export]
	public Godot.Resource ink_file = null;

	[Export]
	public bool loads_in_background = false;
	#endregion

	#region Properties
	// These properties aren't exported because they depend on the runtime or
	// the story to be set. The runtime insn't always available upon
	// instantiation, and the story is only available after calling
	// 'create_story' so rather than losing the values and confusing everybody,
	// those properties are code-only.
	public bool allow_external_function_fallbacks
	{
		get {
			if (story == null)
			{
				PushNullStoryError();
				return false;
			}

			return story.allowExternalFunctionFallbacks;
		}

		set {
			if (story == null)
			{
				PushNullStoryError();
				return;
			}

			story.allowExternalFunctionFallbacks = value;
		}
	}

	public bool do_not_save_default_values
	{
		get { return Ink.Runtime.VariablesState.dontSaveDefaultValues; }

		set { Ink.Runtime.VariablesState.dontSaveDefaultValues = value; }
	}

	public bool stop_execution_on_exception = false;

	public bool stop_execution_on_error = false;
	#endregion

	#region Read-only Properties
	public bool can_continue
	{
		get {
			if (story == null)
			{
				PushNullStoryError();
				return false;
			}

			return story.canContinue;
		}
		set {} // TODO: Remove
		// godot bug: readonly property cannot be accessed from GDScript
		// https://github.com/godotengine/godot/pull/67304
	}

	public bool async_continue_complete
	{
		get {
			if (story == null)
			{
				PushNullStoryError();
				return false;
			}

			return story.asyncContinueComplete;
		}
		set {} // TODO: Remove
	}

	public string current_text
	{
		get {
			if (story == null)
			{
				PushNullStoryError();
				return "";
			}

			if (story.currentText == null)
			{
				PushNullStateError("current_choices");
				return "";
			}


			return story.currentText ?? "";
		}
		set {} // TODO: Remove
	}

	public GCol.Array<string> current_choices
	{
		get {
			if (story == null)
			{
				PushNullStoryError();
				return new GCol.Array<string>();
			}

			if (story.currentChoices == null)
			{
				PushNullStateError("current_choices");
				return new GCol.Array<string>();
			}

			var choices = story.currentChoices?.ConvertAll(choice => choice.text).ToArray();

			if (choices != null) {
				return new GCol.Array<string>(choices);
			} else {
				return new GCol.Array<string>();
			}
		}
		set {} // TODO: Remove
	}

	public GCol.Array<string> current_tags
	{
		get {
			if (story == null)
			{
				PushNullStoryError();
				return new GCol.Array<string>();
			}

			if (story.currentTags == null)
			{
				PushNullStateError("current_tags");
				return new GCol.Array<string>();
			}

			if (story.currentTags != null) {
				return new GCol.Array<string>(story.currentTags);
			} else {
				return new GCol.Array<string>();
			}
		}
		set {} // TODO: Remove
	}

	public GCol.Array<string> global_tags
	{
		get {
			if (story == null)
			{
				PushNullStoryError();
				return new GCol.Array<string>();
			}

			if (story.globalTags != null) {
				return new GCol.Array<string>(story.globalTags);
			} else {
				return new GCol.Array<string>();
			}
		}
		set {} // TODO: Remove
	}

	public bool has_choices
	{
		get { return current_choices.Count > 0; }
		set {} // TODO: Remove
	}

	public string current_flow_name
	{
		get {
			if (story == null)
			{
				PushNullStoryError();
				return "";
			}

			return story.state.currentFlowName;
		}
		set {} // TODO: Remove
	}

	public string current_path
	{
		get {
			if (story == null)
			{
				PushNullStoryError();
				return "";
			}

			return story.state.currentPathString;
		}
		set {} // TODO: Remove
	}
	#endregion

	#region Private Properties
	private Ink.Runtime.Story story = null;
	private GodotThread thread = null;

	private readonly InkBridger inkBridger = new InkBridger();
	private Dictionary<string, List<FunctionReference>> observers =
		new Dictionary<string, List<FunctionReference>>();
	#endregion

	#region Private Properties
	public InkPlayer() {
		this.Set("name", "InkPlayer");
	}
	#endregion

	#region Methods
	public void create_story()
	{
		if (ink_file == null) {
			PushError("'ink_file' is 'Nil', did Godot import the resource correctly?");
			CallDeferred("emit_signal", "loaded", false);
			return;
		}

		if (!IsValidResource(ink_file))
		{
			PushError(
				"'ink_file' doesn't have the appropriate resource type. Are you sure you imported a JSON file?"
			);
			CallDeferred("emit_signal", "loaded", false);
			return;
		}

		if (loads_in_background && CurrentPlatformSupportsThreads())
		{
			thread = new GodotThread();
			var error = thread.Start(Callable.From(() => AsyncCreateStory((string)ink_file.Get("json"))));
			if (error != Error.Ok)
			{
				GD.PrintErr($"[inkgd] [ERROR] Could not start the thread: error code {error}.");
				EmitSignal("loaded", false);
			}
		}
		else
		{
			CreateStory((string)ink_file.Get("json"));
			FinaliseStoryCreation();
		}
	}

	public void reset()
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			story.ResetState();
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}

	public void destroy()
	{
		story = null;
	}
	#endregion

	#region Methods | Story Flow
	public string continue_story()
	{
		if (story == null)
		{
			PushNullStoryError();
			return "";
		}

		var text = "";

		try
		{
			if (can_continue)
			{
				story.Continue();
				text = current_text;
			}
			else if (has_choices)
			{
				EmitSignal("prompt_choices",  current_choices);
			}
			else
			{
				EmitSignal("ended");
			}

			return text;
		}
		catch (Exception e)
		{
			HandleException(e);
			return text;
		}
	}

	public void continue_story_async(float millisecs_limit_async)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			if (can_continue)
			{
				story.ContinueAsync(millisecs_limit_async);

				if (!async_continue_complete) {
					EmitSignal("interrupted");
					return;
				}
			}
			else if (has_choices)
			{
				EmitSignal("prompt_choices", current_choices);
			}
			else
			{
				EmitSignal("ended");
			}

			return;
		}
		catch (Exception e)
		{
			HandleException(e);
			return;
		}
	}

	public string continue_story_maximally()
	{
		if (story == null)
		{
			PushNullStoryError();
			return "";
		}

		var text = "";

		try
		{
			if (can_continue)
			{
				story.ContinueMaximally();
				text = current_text;
			}
			else if (has_choices)
			{
				EmitSignal("prompt_choices", current_choices);
			}
			else
			{
				EmitSignal("ended");
			}

			return text;
		}
		catch (Exception e)
		{
			HandleException(e);
			return text;
		}
	}

	public void choose_choice_index(int index)
	{
		try
		{
			if (index >= 0 && index < current_choices.Count)
			{
				story.ChooseChoiceIndex(index);
			}
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}

	public void choose_path(string path)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			story.ChoosePathString(path);
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}

	public void switch_flow(string flow_name)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			story.SwitchFlow(flow_name);
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}

	public void switch_to_default_flow()
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			story.SwitchToDefaultFlow();
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}

	public void remove_flow(string flow_name)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			story.RemoveFlow(flow_name);
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}
	#endregion

	#region Methods | Tags
	public GCol.Array<string> tags_for_content_at_path(string path)
	{
		if (story == null)
		{
			PushNullStoryError();
			return new GCol.Array<string>();
		}

		try
		{
			var tags = story.TagsForContentAtPath(path);
			if (tags != null) {
				return new GCol.Array<string>(tags);
			} else {
				return new GCol.Array<string>();
			}
		}
		catch (Exception e)
		{
			HandleException(e);
			return new GCol.Array<string>();
		}
	}

	public int visit_count_at_path(string path)
	{
		if (story == null)
		{
			PushNullStoryError();
			return 0;
		}

		try
		{
			return story.state.VisitCountAtPathString(path);
		}
		catch (Exception e)
		{
			HandleException(e);
			return 0;
		}
	}
	#endregion

	#region Methods | State Management
	public string get_state()
	{
		if (story == null)
		{
			PushNullStoryError();
			return "";
		}

		try
		{
			return story.state.ToJson();
		}
		catch (Exception e)
		{
			HandleException(e);
			return "";
		}
	}

	public string copy_state_for_background_thread_save()
	{
		if (story == null)
		{
			PushNullStoryError();
			return "";
		}

		return story.CopyStateForBackgroundThreadSave().ToJson();
	}

	public void background_save_complete()
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		story.BackgroundSaveComplete();
	}

	public void set_state(string state)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			story.state.LoadJson(state);
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}

	public void save_state_to_path(string path)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		string sanitizedPath;
		if (!path.StartsWith("res://") && !path.StartsWith("user://"))
		{
			sanitizedPath = $"user://{path}";
		}
		else
		{
			sanitizedPath = path;
		}

		var file = FileAccess.Open(sanitizedPath, FileAccess.ModeFlags.Write);
		save_state_to_file(file);
	}

	public void save_state_to_file(Godot.FileAccess file)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		if (file.IsOpen())
		{
			file.StoreString(get_state());
		}
	}

	public void load_state_from_path(string path)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		string sanitizedPath;
		if (!path.StartsWith("res://") && !path.StartsWith("user://"))
		{
			sanitizedPath = $"user://{path}";
		}
		else
		{
			sanitizedPath = path;
		}

		var file = FileAccess.Open(sanitizedPath, FileAccess.ModeFlags.Read);
		load_state_from_file(file);
	}

	public void load_state_from_file(Godot.FileAccess file)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		if (!file.IsOpen()) {
			return;
		}

		file.Seek(0);
		if (file.GetLength() > 0) {
			story.state.LoadJson(file.GetAsText());
		}
	}
	#endregion

	#region Methods | Variables
	public GObject get_variable(string name)
	{
		if (story == null)
		{
			PushNullStoryError();
			return null;
		}

		try
		{
			var variable = story.variablesState[name];

			if (variable is Ink.Runtime.InkList inkList)
			{
				return inkBridger.MakeGDInkList(inkList);
			}

			if (variable is Ink.Runtime.Path path)
			{
				return inkBridger.MakeGDInkPath(path);
			}
		}
		catch(Exception e)
		{
			HandleException(e);
			return null;
		}

		return (GObject)story.variablesState[name]; // TODO CHECK
	}

	public void set_variable(string name, object value)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			if (value is GObject gdObject)
			{
				if (IsInkObject(gdObject, "InkList"))
				{
					story.variablesState[name] = inkBridger.MakeSharpInkList(gdObject, story);
					return;
				}

				if (IsInkObject(gdObject, "InkPath"))
				{
					story.variablesState[name] = inkBridger.MakeSharpInkPath(gdObject);
					return;
				}
			}
			story.variablesState[name] = value;
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}
	#endregion

	#region Methods | Variable Observers
	public void observe_variables(GCol.Array<string> variable_names, GObject gd_object, string method_name)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			foreach(string variable_name in variable_names)
			{
				observe_variable(variable_name, gd_object, method_name);
			}
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}

	public void observe_variable(string variable_name, GObject gd_object, string method_name)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			var instanceId = (int)gd_object.Call("get_instance_id");
			var callable = new Callable(gd_object, method_name);

			var functionReference = new FunctionReference(
				variable_name,
				instanceId,
				method_name,
				(string variableName, object value) => {
					callable.Call(new Variant[] { variableName, (Variant)value });
				}
			);

			if (observers.TryGetValue(variable_name, out List<FunctionReference> referenceList))
			{
				referenceList.Append(functionReference);
			}
			else
			{
				observers[variable_name] = new List<FunctionReference> () { functionReference };
			}

			story.ObserveVariable(variable_name, functionReference.observer);
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}

	public void remove_variable_observer(GObject gd_object, string method_name, string specific_variable_name)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			if (observers.TryGetValue(specific_variable_name, out List<FunctionReference> references))
			{
				var validReferences =
					references.FindAll(reference => reference.Matches(specific_variable_name, gd_object, method_name));

				foreach(FunctionReference reference in validReferences) {
					story.RemoveVariableObserver(reference.observer, specific_variable_name);
					references.Remove(reference);
				}
			}
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}

	public void remove_variable_observer_for_all_variables(GObject gd_object, string method_name)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			List<string> observersToRemove = new List<string>();

			foreach(KeyValuePair<string, List<FunctionReference>> kv in observers)
			{
				var validReferences =
					kv.Value.FindAll(reference => reference.Matches(gd_object, method_name));

				foreach(FunctionReference reference in validReferences) {
					story.RemoveVariableObserver(reference.observer);
					kv.Value.Remove(reference);
				}
			}
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}

	public void remove_all_variable_observers(string specific_variable_name)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			story.RemoveVariableObserver(null, specific_variable_name);
			observers.Remove(specific_variable_name);
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}
	#endregion

	#region Methods | External Functions
	public void bind_external_function(
		string func_name,
		GObject gd_object,
		string method_name)
	{
		bind_external_function(func_name, gd_object, method_name, false);
	}

	public void bind_external_function(
		string func_name,
		GObject gd_object,
		string method_name,
		bool lookahead_safe)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			story.BindExternalFunctionGeneral(
				func_name,
				(object[] args) => {
					return gd_object.Call(method_name, ConvertToGDArray(args));
				},
				lookahead_safe);
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}

	public void unbind_external_function(string func_name)
	{
		if (story == null)
		{
			PushNullStoryError();
			return;
		}

		try
		{
			story.UnbindExternalFunction(func_name);
		}
		catch (Exception e)
		{
			HandleException(e);
		}
	}
	#endregion

	#region Methods | Functions

	public bool has_function(string function_name)
	{
		if (story == null)
		{
			PushNullStoryError();
			return false;
		}

		return story.HasFunction(function_name);
	}

	public GObject evaluate_function(string function_name, GCol.Array arguments)
	{
		if (story == null)
		{
			PushNullStoryError();
			return null;
		}

		// Prevents sending `null` to EvaluateFunction, which would
		// otherwise raise an exception.
		object[] sanitizedArguments;
		if (arguments != null) {
			sanitizedArguments = ConvertToObjArray(arguments);
		} else {
			sanitizedArguments = new object[] { };
		}

		try
		{
			object returnValue = story.EvaluateFunction(function_name, out string textOutput, sanitizedArguments);
			return inkBridger.MakeFunctionResult(textOutput, returnValue);
		}
		catch (Exception e)
		{
			HandleException(e);
			return null;
		}
	}
	#endregion

	#region Methods | Ink List Creation
	public GObject create_ink_list_with_origin(string single_origin_list_name)
	{
		if (story == null)
		{
			PushNullStoryError();
			return null;
		}

		try
		{
			var inkList = new Ink.Runtime.InkList(single_origin_list_name, story);
			return inkBridger.MakeGDInkList(inkList);
		}
		catch (Exception e)
		{
			HandleException(e);
			return null;
		}
	}

	public GObject create_ink_list_from_item_name(string item_name)
	{
		if (story == null)
		{
			PushNullStoryError();
			return null;
		}

		try
		{
			var inkList = Ink.Runtime.InkList.FromString(item_name, story);
			return inkBridger.MakeGDInkList(inkList);
		}
		catch (Exception e)
		{
			HandleException(e);
			return null;
		}
	}
	#endregion

	#region Event Handlers
	private object[] ConvertToObjArray(GCol.Array array)
	{
		var outArray = new object[array.Count];
		for (int i=0; i<array.Count; i++)
		{	
			var e = array[i];
			if (e.Obj is long) {outArray[i] = Convert.ToInt32(e.Obj);}
			else outArray[i] = e.Obj;
		}
		return outArray;
	}

	private GCol.Array ConvertToGDArray(object[] objArray)
	{	
		return new GCol.Array( (from obj in objArray select (Variant)(dynamic)obj) );
	}

	private void onError(string message, Ink.ErrorType type)
	{
		if (stop_execution_on_error)
		{
			PushStoryError(message, type);
			Debug.Assert(false, "Error encountered, check the debugger tab for more information.");
			return;
		}

		if (GetSignalConnectionList("error_encountered").Count == 0)
		{
			PushStoryError(message, type);
		}
		else
		{
			EmitSignal("error_encountered", message, (int)type);
		}
	}

	private void onDidContinue()
	{
		EmitSignal("continued", current_text, current_tags);
	}

	private void onMakeChoice(Ink.Runtime.Choice choice)
	{
		EmitSignal("choice_made", choice.text);
	}

	private void onEvaluateFunction(string functionName, object[] arguments)
	{
		EmitSignal("function_evaluating", functionName, ConvertToGDArray(arguments));
	}

	private void onCompleteEvaluateFunction(
		string functionName,
		object[] arguments,
		string textOuput,
		object returnValue)
	{
		var functionResult = inkBridger.MakeFunctionResult(textOuput, returnValue);
		var parameters = new Variant[] { 
			functionName, 
			ConvertToGDArray(arguments),
			functionResult 
		};

		EmitSignal("function_evaluated", parameters);
	}

	private void onChoosePathString(string path, object[] arguments)
	{
		EmitSignal("path_choosen", path, ConvertToGDArray(arguments));
	}
	#endregion

	#region Private Methods
	private void CreateStory(string json_story)
	{
		story = new Ink.Runtime.Story(json_story);
	}

	private void AsyncCreateStory(string json_story)
	{
		CreateStory(json_story);
		CallDeferred("AsyncCreationCompleted");
	}

	private void AsyncCreationCompleted()
	{
		thread.WaitToFinish();
		thread = null;

		FinaliseStoryCreation();
	}

	private void FinaliseStoryCreation()
	{
		story.onError += onError;
		story.onDidContinue += onDidContinue;
		story.onMakeChoice += onMakeChoice;
		story.onEvaluateFunction += onEvaluateFunction;
		story.onCompleteEvaluateFunction += onCompleteEvaluateFunction;
		story.onChoosePathString += onChoosePathString;

		EmitSignal("loaded", true);
	}

	private bool CurrentPlatformSupportsThreads()
	{
		return OS.GetName() != "HTML5";
	}

	private void PushNullStoryError()
	{
		PushError("The story is 'null', was it loaded properly?");
	}

	private void PushNullStateError(string variable)
	{
		var message =
			$"'{variable}' is 'null', the internal state is corrupted or missing, this is an unrecoverable error.";

		PushError(message);
	}

	private void PushStoryError(string message, Ink.ErrorType type)
	{
		if (Engine.IsEditorHint())
		{
			switch (type)
			{
				case Ink.ErrorType.Error:
					GD.PrintErr(message);
					break;
				case Ink.ErrorType.Warning:
				case Ink.ErrorType.Author:
					GD.Print(message);
					break;
			}
		}
		else
		{
			switch (type)
			{
				case Ink.ErrorType.Error:
					GD.PushError(message);
					break;
				case Ink.ErrorType.Warning:
				case Ink.ErrorType.Author:
					GD.PushWarning(message);
					break;
			}
		}
	}

	private void PushError(string message)
	{
		if (Engine.IsEditorHint())
		{
			GD.PrintErr(message);
			foreach(string line in System.Environment.StackTrace.Split("\n"))
			{
				GD.PrintErr(line);
			}
		}
		else
		{
			GD.PushError(message);
		}
	}

	private bool IsValidResource(Resource resource)
	{

		var properties = resource.GetPropertyList().Cast<GCol.Dictionary>().ToList();
		return (
			properties.Exists(element => "json" == element["name"].AsString()) &&
			resource.Get("json").VariantType == Variant.Type.String
		);
	}

	private bool IsInkObject(GObject inkObject, string name)
	{
		return inkObject.HasMethod("is_class") && (bool)inkObject.Call("is_class", new Variant[] { name });
	}

	private void HandleException(Exception e)
	{
		var message = $"{GetExceptionType(e)}: {e.Message}";

		if (ShouldStopExecution(e))
		{
			GD.PrintErr(message);

			foreach(string line in e.StackTrace.Split("\n"))
			{
				GD.PrintErr(line);
			}

			Debug.Assert(false, "Exception encountered, check the output tab for more information.");
		}
		else
		{
			EmitSignal("exception_raised", message, e.StackTrace.Split("\n"));
		}
	}

	private bool ShouldStopExecution(Exception e)
	{
		return (
			(e is Ink.Runtime.StoryException && stop_execution_on_error) ||
			(!(e is Ink.Runtime.StoryException) && stop_execution_on_exception)
		);
	}

	private string GetExceptionType(Exception e)
	{
		if (e is Ink.Runtime.StoryException)
		{
			return "STORY EXCEPTION";
		}
		else if (e is System.ArgumentException)
		{
			return "ARGUMENT EXCEPTION";
		}
		else
		{
			return "EXCEPTION";
		}

	}
	#endregion

	#region Private Structures
	private readonly struct FunctionReference
	{
		public readonly string variableName;

		public readonly int objectReferenceId;
		public readonly string methodName;

		public readonly Ink.Runtime.Story.VariableObserver observer;

		public FunctionReference(
			string variableName,
			int objectReferenceId,
			string methodName,
			Ink.Runtime.Story.VariableObserver observer)
		{
			this.variableName = variableName;
			this.objectReferenceId = objectReferenceId;
			this.methodName = methodName;
			this.observer = observer;
		}

		public bool Matches(string variableName, GObject gdObject, string methodName)
		{
			return this.variableName.Equals(variableName) && Matches(gdObject, methodName);
		}

		public bool Matches(GObject gdObject, string methodName)
		{
			return (
				(int)gdObject.Call("get_instance_id") == objectReferenceId &&
				this.methodName.Equals(methodName)
			);
		}

		public override string ToString()
		{
			return $"FunctionReference[{variableName}, {objectReferenceId}, {methodName}]";
		}
	}
	#endregion
}
