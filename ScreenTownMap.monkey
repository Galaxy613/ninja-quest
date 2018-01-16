Strict
#Rem
	Screen Town Map
	
	Takes care of moving the player around the game.
	
	Verbs:
		Walk - Around, not through obstacles
		Talk - To Non Player Characters or to Read Signs
		Activate - To Trigger a gameTrigger from a Sign or otherwise
#END
''' SMap - Takes care of the world map.
''Private
''' modes - Fake Enum
''' NMap - 
Import engine
Import combat
Import ScreenConversation

''' Map Screen
Class SMap Extends TScreen
	
	Field tilemap:Image = Null
	Field charmap:Image = Null
	Field tileMapName:String = ""
	Field charMapName:String = ""
	
	Field map:DMap
	Field mapName:String = ""
	
	Field x:Int = 4, y:Int = 4, tx:Int, ty:Int, dir:Int = 0
	Field nextBattle:Int = 1
	
	Method New(mapN:String)
		tileMapName = "tilemap"
		charMapName = "charmap"
		mapName = mapN
	End
	
	Method New(mapN:String, tileMapN:String, charMapN:String)
		tileMapName = tileMapN
		charMapName = charMapN
		mapName = mapN
	End
	
	Method OnInit:Int()
		modes.current = modes.map
		menuColumn = 0
		menuIndex = 0
		
		tilemap = imageMap.Get(tileMapName)
		charmap = imageMap.Get(charMapName)
		GMessageTicker.Set("")
		
		map = DMap.FindMap(mapName)
		
		nextBattle = Int(Rnd(3, 10))
		
		Print("Initing player at [" + x + "," + y + "]")
		
		Return 0
	End
	
	Method PlacePlayerAt:Void(id:Int = 128)
		If Not map Then Return
		If map.SearchMap(map.currentSpecial, id) Then
			x = map.tmpX
			y = map.tmpY
			Print("Starting player at " + id + " [" + x + "," + y + "]")
		End
	End
	
	Method PlacePlayerAt:Void(xx:Int, yy:Int)
		x = xx
		y = yy
		Print("Placing player at [" + x + "," + y + "]")
	End
	
	Method OnUpdate:Int()
		GMessageTicker.Update
		
		Select modes.current
			Case modes.town
				TOWN_Update
'			Case modes.info
'				INFO_Update
'			Case modes.skill
'				SKILL_Update
			Case modes.equip
				EQUIP_Update
'			Case modes.items
'				ITEMS_Update
'			Case modes.map
'				MAP_Update
'			Case modes.save
'				SAVE_Update
'			Case modes.load
'				LOAD_Update
'			Case modes.quit
'				QUIT_Update
			Default
				_Update()
		End
		Return 0
	End
	
	Method OnRender:Int()
		Select modes.current
			Case modes.town
				TOWN_Draw()
'			Case modes.info
'				INFO_Draw
'			Case modes.skill
'				SKILL_Draw
			Case modes.equip
				EQUIP_Draw
'			Case modes.items
'				ITEMS_Draw
'			Case modes.map
'				MAP_Draw
'			Case modes.save
'				SAVE_Draw
'			Case modes.load
'				LOAD_Draw
'			Case modes.quit
'				QUIT_Draw
			Default
				_Draw()
		End
		
		GMessageTicker.Draw
		Return 0
	End
	
	Method GoToTown:Void()
		modes.current = modes.town
		
		menuIndex = 0
		menuColumn = 0
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''' Helper Functions
	
	Method GetCurrentSpecialTile:Int()
		return map.currentSpecial[y][x]
	End
	Method GetCurrentSpecialTileID:Int(type:Int = 0)
		Return ConvertFromSpecialID(map.currentSpecial[y][x], type)
	End
	
	Method GetSpecialTileInFrontOfYou:Int()
		Select dir
			Case 0
				Return map.currentSpecial[y][x + 1]
			Case 1
				Return map.currentSpecial[y + 1][x]
			Case 2
				Return map.currentSpecial[y][x - 1]
			Case 3
				Return map.currentSpecial[y - 1][x]
		End
		Return -1
	End
	
	Method MoveYouForward:Void()
		Select dir
			Case 0
				x += 1
			Case 1
				y += 1
			Case 2
				x -= 1
			Case 3
				y -= 1
		End
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''' MENU
	
	Method TOWN_Update:Void()
		UpDownMenu(4)
		
		If NInput.IsHit(N_A)
			Select menuIndex
				Case 0 '' Inn
					game.Town_Inn GetTownId(lastTown)
					
				Case 1 '' Shoppe
					If game.Town_Shop(GetTownId(lastTown)) = 1 Then
						modes.current = modes.equip
						menuColumn = 0
						menuIndex = 0
					EndIf
				
				Case 2 '' Talk
					game.Town_Talk(GetTownId(lastTown))
				
				Case 3 '' Back
					modes.current = modes.map
					menuColumn = 0
					menuIndex = 0
			End
		End
		
		If NInput.IsHit(N_B)
			modes.current = modes.map
			menuColumn = 0
			menuIndex = 0
		End
	End
	
	Method TOWN_Draw:Void()
		DrawMap( (16 * (x - 5)) + 8, (16 * (y - 4)))
	'	DrawPlayer()
		
		GWindowDrawer.Draw(vScnWidth - 64, -4, 64, vScnHeight + 8)
		
		GWindowDrawer.Draw(-4, -4, 168, 16)
		GDrawTextPreserveBlend(WorldMap_Names(), 1, 0)
		
		GDrawTextPreserveBlend(">", vScnWidth - 60, 16 + (menuIndex * 8))
		
		GDrawTextPreserveBlend("INN", vScnWidth - 54, 16)
		GDrawTextPreserveBlend("SHOP", vScnWidth - 54, 16 + (1 * 8))
		GDrawTextPreserveBlend("TALK", vScnWidth - 54, 16 + (2 * 8))
		GDrawTextPreserveBlend("BACK", vScnWidth - 54, 16 + (3 * 8))
	End
	
	'''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''' EQUIP
	
	Method EQUIP_Update:Void()
		UpDownMenu(5)
		
		If NInput.IsHit(N_A)
			Select menuIndex
				Case 0 ''
					GMessageTicker.Add("No one is selling!")
					
				Case 1 ''
					GMessageTicker.Add("No one is buying!")
				
				Case 2 ''
					GMessageTicker.Add("No one is training!")
				
				Case 4 ''
					GoToTown()
			End
		End
		
		If NInput.IsHit(N_B)
			GoToTown()
		End
	End
	
	Method EQUIP_Draw:Void()
		DrawMap( (16 * (x - 5)) + 8, (16 * (y - 4)))
	'	DrawPlayer()
		
		GWindowDrawer.Draw(vScnWidth - 64, -4, 64, vScnHeight + 8)
		
		GWindowDrawer.Draw(-4, -4, 168, 16)
		GDrawTextPreserveBlend(WorldMap_Names(), 1, 0)
		
		GDrawTextPreserveBlend(">", vScnWidth - 60, 16 + (menuIndex * 8))
		
		GDrawTextPreserveBlend("BUY", vScnWidth - 54, 16)
		GDrawTextPreserveBlend("SELL", vScnWidth - 54, 16 + (1 * 8))
		GDrawTextPreserveBlend("TRAIN", vScnWidth - 54, 16 + (2 * 8))
		GDrawTextPreserveBlend(" ", vScnWidth - 54, 16 + (3 * 8))
		GDrawTextPreserveBlend("BACK", vScnWidth - 54, 16 + (4 * 8))
	End
	
	'''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''' Walking about
	
	Method _Update:Void()
	'	If NinInput.IsHit(N_B) Then GoToTown()
		If NInput.IsHit(N_Start) Then SwitchScreenTo characterScreen'; NLog "To Char"
		
		'''' Do Movement
		Local moved:Bool = False
		
		If NInput.IsDown(N_B) Then '' Cheat to walk everywhere - Too Easy to use - Make sure you remove this later.
			x += NInput.GetXAxis() ' TODO: Remove
			y += NInput.GetYAxis()
		Else
			''' IF the player isn't cheating, check the movement correctly.
			Select NInput.GetXAxis()
				Case 1
					dir = 0; moved = True
				Case -1
					dir = 2; moved = True
			End
			Select NInput.GetYAxis()
				Case 1
					dir = 1; moved = True
				Case -1
					dir = 3; moved = True
			End
			
			''' If the player has moved
			If moved = True Then
				''' If the tile is set to a special setting that's passable
				''' OR if the tile's special trigger is set to done.
				If ( (GetSpecialTileInFrontOfYou() < 128 + 15) Or (gameTriggers.Get("m" + (GetSpecialTileInFrontOfYou() -16)) = 2)) Then
					MoveYouForward()
					moved = CheckTileEffect(map.currentSpecial[y][x]) '' Design change, 3/20/16 - ALWAYS check the tile after a move!
				EndIf
			ElseIf NInput.IsHit(N_A)
				''' If the player hasn't moved, check if the player has press A
				CheckTileEffect(map.currentSpecial[y][x])
			EndIf
		'	If moved Then CheckTileEffect(map.currentSpecial[y][x]), False '' Check to see if you triggered something.
		End
		
		'''
		If moved And map.currentSpecial[y][x] < 128 Then
			'Print("Battle check! " + nextBattle)
			If nextBattle > 0 Then
				nextBattle -= 1
			Else
				nextBattle = Int(Rnd(5, 20))
				
				If GetCurrentZoneName("safe") = "" Then '' Only proceed if there are no zones called "safe" at this position!
					If GetCurrentZoneName("monsters_") <> "" Then RandomBattle(GetCurrentZoneName("monsters_"))
				End
			End
		End
		
		''' Check if something is in the current tile, and then if there's something infront of you. ''' DESIGN CHANGE - Always check the tile after you move!
'		If NInput.IsHit(N_A) And Not moved Then
'			
'			If Not moved = True
'				CheckTileEffect(map.currentSpecial[y][x], False)
'			End
'		End
		
	End

	
	Method _Draw:Void()
		DrawMap( (16 * (x - 5)) + 8, (16 * (y - 4)))
		DrawPlayer()
		
		'	WindowDrawer.Draw(-4, -4, 168, 16)
		'	CrappyDrawText("cS[" + y + "][" + x + "] = " + map.currentSpecial[y][x], 0, 0)
	'	GDrawTextPreserveBlend(x + "," + y, 0, 0)
		
		If map.currentSpecial[y][x] > 127 Then
			GWindowDrawer.Draw(-4, 144 - 12, 168, 16)
			'GDrawTextPreserveBlend(map.currentSpecial[y][x] + " " + WorldMap_Names(), 1, 144 - 9)
			GDrawTextPreserveBlend(WorldMap_Names(), 1, 144 - 9)
		End
	End
	
	Method DrawMap:Void(offsetX:Int, offsetY:Int)
		For Local i:Int = 0 To map.currentMap.Length() -1
			For Local j:Int = 0 To map.currentMap[i].Length() -1
				If map.currentMap[i][j] > - 1 Then DrawImage(tilemap, (j * 16) - offsetX, (i * 16) - offsetY, map.currentMap[i][j])
			Next
		Next
	End
	
	Method DrawPlayer:Void()
		Local frame:int = 0
		'DrawImage(tilemap, (16 * 5) - 8, 16 * 4, 3)
		If dir = 1 or dir = 3
			If dir = 1 Then
				frame = 0
			Else
				frame = 3
			End
		Else
			If dir = 0 Then
				frame = 16 + 0
			Else
				frame = 16 + 3
			End
		End
		DrawImage(charmap, (16 * 5) - 8 + NInput.GetXAxis(), 16 * 4 + NInput.GetYAxis(), frame)
	End
	
	Method GetCurrentZoneName:String(prefix:String = "_")
		For Local r:DBoundingBox = EachIn map.monsterZones
			If Not r.name.Contains(prefix) Then Continue
			NLog r.x + "," + (r.x + r.w)+" ; "+ r.y + "," + (r.y + r.h)
			If x * 16 > r.x And x * 16 < r.x + r.w Then
				If y * 16 > r.y And y * 16 < r.y + r.h Then
					NLog "r = " + r.name
					Return r.name
				End
			End
		Next
		NLog "GetCurrentZoneName :: Failed"
		Return ""
	End
	
	Method CheckTileEffect:Bool(specialID:Int) ' formerly _CheckVillage
		If not gameTriggers.Contains("m" + specialID)
			gameTriggers.Add("m" + specialID, "0");
		End
		lastTown = specialID
		
		Select game.Town_Enter(GetTownId(lastTown))
			Case 1 ' Go to town
				GoToTown
			
			Case 2 ' Randomize Next Battle
				nextBattle = Rnd(4, 10)
				
			Case -1 ' Nothing
				Return True
		End
		
		Return False
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method WorldMap_Names:String()
		Local townId:Int = GetTownId(map.currentSpecial[y][x])
		Local txt:String = game.Town_Name(townId)
		txt = "[" + townId + "]" + txt '' TODO : Remove this inserted debug text
		Return txt
	End
	
End

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private

Class modes
	Global current:Int
	
	Const town:Int = 0
	Const info:Int = 1
	Const skill:Int = 2
	Const equip:Int = 3
	Const items:Int = 4
	Const map:Int = 5
	Const save:Int = 6
	Const load:Int = 7
	Const quit:Int = 10
	
End

Class DMap
	Global maps:StringMap<DMap> = New StringMap<DMap>()
	
	Function FindMap:DMap(mapName:String)
		If maps.Contains(mapName.ToLower()) Then
			Return maps.Get(mapName.ToLower())
		Else
			(New DMap).LoadMap(mapName)
			If maps.Contains(mapName.ToLower()) Then
				Return maps.Get(mapName.ToLower())
			End
		End
		NLog "[_MAP] Failed to find/load " + mapName + ".json !"
		Return Null
	End
	
	Field name:String = ""
	
	Field currentMap:Int[][]
	Field currentSpecial:Int[][]
	Field monsterZones:List<DBoundingBox> = New List<DBoundingBox>()
	
	Field tmpX:Int, tmpY:Int
	Method SearchMap:Bool(targetMap:Int[][], id:Int = 0)
		For Local i:Int = 0 To targetMap.Length() -1
			For Local j:Int = 0 To targetMap[i].Length() -1
				If targetMap[i][j] = id Then
					tmpX = j
					tmpY = i
					Return True
				End
			Next
		Next
		Return False
	End

	Method LoadMap:Bool(mapFilename:String)
		If LoadString("maps/" + mapFilename + ".json") = "" Then GoNuclear "Can not find map file '" + mapFilename + ".json'!!!" 'Return False
		Local file:JSONObject = JSONObject(JSONData.ReadJSON(LoadString("maps/" + mapFilename + ".json")))
		Local width:Int = file.GetItem("width").ToInt()
		Local height:Int = file.GetItem("height").ToInt()
		name = mapFilename.ToLower()
		maps.Set(name, Self)
		
		currentMap = currentMap.Resize(height)
		currentSpecial = currentSpecial.Resize(height)
		For Local i:Int = 0 To height - 1
			currentMap[i] = currentMap[i].Resize(width)
			currentSpecial[i] = currentSpecial[i].Resize(width)
		Next
		
		monsterZones.Clear()
		
		Local layers:JSONArray = JSONArray(file.GetItem("layers"))
		Local tmpIntArr:Int[]
		For Local jDI:JSONDataItem = EachIn layers
			NLog "jDI = " + JSONObject(jDI).GetItem("name")
			Local jObj:JSONObject = JSONObject(jDI)
			
			Select jObj.GetItem("name").ToString().ToLower()
				Case "background"
					tmpIntArr = JSONArray(jObj.GetItem("data")).ToIntArray()
					Local k:Int = 0
					For Local i:Int = 0 To height - 1
						For Local j:Int = 0 To width - 1
							currentMap[i][j] = tmpIntArr[k] - 1
							k += 1
						Next
					Next
					
				Case "collision"
					tmpIntArr = JSONArray(jObj.GetItem("data")).ToIntArray()
					Local k:Int = 0
					For Local i:Int = 0 To height - 1
						For Local j:Int = 0 To width - 1
							currentSpecial[i][j] = tmpIntArr[k] - 1
							k += 1
						Next
					Next
					
				Case "object"
					For Local jDI2:JSONDataItem = EachIn JSONArray(jObj.GetItem("objects"))
						Local jObj2:JSONObject = JSONObject(jDI2)
						Local tmpMZ:DBoundingBox = New DBoundingBox()
						tmpMZ.x = jObj2.GetItem("x").ToInt()
						tmpMZ.y = jObj2.GetItem("y").ToInt()
						tmpMZ.w = jObj2.GetItem("width").ToInt()
						tmpMZ.h = jObj2.GetItem("height").ToInt()
						tmpMZ.name = jObj2.GetItem("name").ToString()
				'		NLog tmpMZ.name + " : " + tmpMZ.x + "," + tmpMZ.y + " ; " + tmpMZ.w + "," + tmpMZ.h
						monsterZones.AddLast tmpMZ
					Next
			End
		Next
		
		Return True
	End
End



