Strict
#Rem
	Save & Load Functions
	
	n/a
	
	Verbs:
		n/a
#END
Import mojo
Import engine
Import ScreenTownMap

Function SaveGame:String()
	Local file:JSONObject = New JSONObject()
	Local tmp:JSONObject = Null, tmpMap:SMap = SMap(townMapScreen)
	
	file.AddPrim("gold", playerGold)
	file.AddPrim("currentlocation", currentLocation)
	file.AddPrim("lasttown", lastTown)
	
	file.AddPrim("gametriggers", SaveStringMap(gameTriggers))
	For Local pc:DCharacter = EachIn playerCharacters
		file.AddItem(pc.Name.ToLower(), pc.SaveStringJSON())
	Next
	
	If townMapScreen <> Null Then
	If tmpMap.map Then
		tmp = New JSONObject()
		tmp.AddPrim("name", tmpMap.map.name)
		tmp.AddPrim("x", tmpMap.x)
		tmp.AddPrim("y", tmpMap.y)
		file.AddItem("current_map", tmp)
	End
	End
	
	Print file.ToJSONString()
	Return file.ToJSONString()
End

Function LoadGame:Void(file:JSONObject)
	Local tmp:JSONObject = Null
	Print "LoadGame: [[[" + file + "]]]"
	
	playerCharacters.Clear()
	
	ninja = Null; archer = Null; sage = Null; warrior = Null
	
	playerGold = file.GetItem("gold", 0)
	currentLocation = file.GetItem("currentlocation", 0)
	lastTown = file.GetItem("lasttown", 128)
	LoadStringMap(gameTriggers, file.GetItem("gametriggers", ""))
	
	If file.Contains("ninja") Then
		ninja = New DCharacter(0)
		ninja.LoadStringJSON(JSONObject(file.GetItem("ninja")))
		playerCharacters.AddLast(ninja)
		ninja.img = imageMap.Get("ninja")
	End
	If file.Contains("archer") Then
		archer = New DCharacter(0)
		archer.LoadStringJSON(JSONObject(file.GetItem("archer")))
		playerCharacters.AddLast(archer)
		archer.img = imageMap.Get("archer")
	End
	If file.Contains("sage") Then
		sage = New DCharacter(0)
		sage.LoadStringJSON(JSONObject(file.GetItem("sage")))
		playerCharacters.AddLast(sage)
		sage.img = imageMap.Get("magi")
	End
	If file.Contains("warrior") Then
		warrior = New DCharacter(0)
		warrior.LoadStringJSON(JSONObject(file.GetItem("warrior")))
		playerCharacters.AddLast(warrior)
		sage.img = imageMap.Get("warrior")
	End
	
	If file.Contains("current_map") Then
		tmp = JSONObject(file.GetItem("current_map"))
		'tmp.GetItem("name", "")
		SMap(townMapScreen).StartAt(tmp.GetItem("x", 18), tmp.GetItem("y", 39))
	End
End

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Function SaveStringMap:String(map:StringMap<String>, delimiter:String = "`")
	Local output:String = ""
	For Local key:String = EachIn map.Keys()
		If output <> "" Then output += "~~"
		output += key + delimiter + map.Get(key)
	Next
	Return "[" + output + "]"
End

Function LoadStringMap:Void(map:StringMap<String>, loading:String)
	loading = loading.Replace("[", "").Replace("]", "")
	map.Clear()
	If loading = "" Then Return
	If not loading.Contains("~~") Then
		_SplitPair map, loading
	End
	
	Local pairs:String[] = loading.Split("~~")
	For Local pair:String = EachIn pairs
		If Not pair.Contains("`") Then
			GoNuclear "[" + pair + "] Does not contain token! " + loading
			Continue
		End
		_SplitPair map, pair
	Next
End

Private

Function _SplitPair:Void(map:StringMap<String>, pair:String)
	map.Set(pair[ .. pair.Find("`")], pair[pair.Find("`") + 1 ..])
End