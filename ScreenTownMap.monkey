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

Class SMap Extends TScreen
	Global tilemap:Image = Null
	Global charmap:Image = Null
	
'	Field currentMap:Int[][]
'	Field currentSpecial:Int[][]
'	Field monsterZones:List<MonsterZone> = New List<MonsterZone>()
	Field map:DMap
	
	Field x:Int = 4, y:Int = 4, tx:Int, ty:Int, dir:Int = 0
	Field nextBattle:Int = 1
	
	Method OnInit:Int()
		modes.current = modes.map
		menuColumn = 0
		menuIndex = 0
		
		tilemap = imageMap.Get("tilemap")
		charmap = imageMap.Get("charmap")
		GMessageTicker.Set("")
		
		map = DMap.FindMap("worldmap")'"ninja_village_full")
		
		nextBattle = Int(Rnd(3, 10))
		
		Return 0
	End
	
	Method StartAt:Void(id:Int = 128)
		If Not map Then Return
		If map.SearchMap(map.currentSpecial, id) Then
			x = map.tmpX
			y = map.tmpY
		End
	End
	
	Method StartAt:Void(xx:Int, yy:Int)
		x = xx
		y = yy
	End
	
	Method OnUpdate:Int()
		GMessageTicker.Update
		
		Select modes.current
			Case modes.menu
				MENU_Update
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
			Case modes.menu
				MENU_Draw()
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
	
	Method BackToMenu:Void()
		modes.current = modes.menu
		
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
	
	Method MENU_Update:Void()
		UpDownMenu(4)
		
		If NInput.IsHit(N_A)
			Select menuIndex
				Case 0 '' Inn
					For Local ply:DCharacter = EachIn playerCharacters
						ply.HP = ply.maxHP
						nextBattle = Int(Rnd(3, 10))
					Next
					GMessageTicker.Add("Party HP Restored!")
					
				Case 1 '' Shoppe
					modes.current = modes.equip
					menuColumn = 0
					menuIndex = 0
				
				Case 2 '' Talk
					Select lastTown - 128 + 1
						Case 1' "NINJA VILLAGE"
							SConversation(chatScreen).RunCutscene("ThankYouNinja")
							SwitchScreenTo(chatScreen)
					'	Case 2' "DANGER FOREST"
					'	Case 3' "CRAZY MINES"
					'	Case 4' "WALL CITY"
					'	Case 5' "WINDY PLAINS"
					'	Case 6' "SMELLY MARCHES"
					'	Case 7' "MOUNTAINGRAD"
					'	Case 8' "MT.KRUGDOR"
					'	Case 9'	"THE TOWER"
						Default
							GMessageTicker.Add "No one wants to talk."
					End
				
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
	
	Method MENU_Draw:Void()
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
		UpDownMenu(4)
		
		If NInput.IsHit(N_A)
			Select menuIndex
				Case 0 ''
					
				Case 1 ''
				
				Case 2 ''
				
				Case 3 ''
					BackToMenu()
			End
		End
		
		If NInput.IsHit(N_B)
			BackToMenu()
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
		GDrawTextPreserveBlend(" ", vScnWidth - 54, 16 + (2 * 8))
		GDrawTextPreserveBlend("BACK", vScnWidth - 54, 16 + (3 * 8))
	End
	
	'''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''' Walking about
	
	Method _Update:Void()
	'	If NinInput.IsHit(N_B) Then BackToMenu()
		If NInput.IsHit(N_Start) Then SwitchScreenTo characterScreen'; NLog "To Char"
		
		'''' Do Movement
		Local moved:Bool = False
		
		If NInput.IsDown(N_B) Then '' Cheat to walk everywhere - Too Easy to use - Make sure you remove this later.
			x += NInput.GetXAxis()
			y += NInput.GetYAxis()
		Else
			
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
			
			If ( (GetSpecialTileInFrontOfYou() < 128 + 15) Or (gameTriggers.Get("m" + (GetSpecialTileInFrontOfYou() -16)) = 2)) And moved = True Then
				MoveYouForward()
				moved = CheckTileEffect(map.currentSpecial[y][x], False) '' Design change, 3/20/16 - ALWAYS check the tile after a move!
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
		
		If map.currentSpecial[y][x] > 127 Then
			GWindowDrawer.Draw(-4, 144 - 12, 168, 16)
			GDrawTextPreserveBlend(map.currentSpecial[y][x] + " " + WorldMap_Names(), 1, 144 - 9)
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
	
	Method CheckTileEffect:Bool(specialID:Int, inFront:Bool = False)
		''' Finds the function that manage's the map's trigger effects.
	'	If map.name.Contains("ninja")
	'		Return _CheckNinjaVillage(specialID)
	'	End
		Return _CheckVillage(specialID, inFront)
	End
	
	Method _CheckVillage:Bool(specialID:Int, inFront:Bool = False)
		If not gameTriggers.Contains("m" + specialID)
			gameTriggers.Add("m" + specialID, "0");
		End
		lastTown = specialID
		
		Select ConvertFromSpecialID(specialID) 'specialID - 128 + 1
			Case 1 ''' Ninja Village
				BackToMenu()
				
				
			Case 2 ''' Danger Forest
			'	lastTown = specialID
				
				If gameTriggers.Get("m" + specialID) = "2" Then
					'GMessageTicker.Add("Nothing here.")
					''' HP Restored
					For Local ply:DCharacter = EachIn playerCharacters
						ply.HP = ply.maxHP
						nextBattle = Int(Rnd(3, 10))
					Next
					GMessageTicker.Add("Party HP Restored!")
				Else
					''
					'MessageTicker.Add("you will die this day!'")
					GMessageTicker.Add("I can't believe you")
					GMessageTicker.Add("left the forest over")
					GMessageTicker.Add("training with the ninjas!")
					GMessageTicker.Add("Defend yourself!")
					
					''
					SwitchScreenTo combatScreen
					Local cmtScn:SCombat = SCombat(combatScreen)
					cmtScn.enemyList.AddLast(New CharArcher(10))
					'cmtScn.enemyList.First().Name = "BAHAMAUT"
					cmtScn.placeMonsters()
					gameTriggers.Set("m" + specialID, "1")
				End
				
			Case 3' "CRAZY MINES"
			'	lastTown = specialID
				
				If gameTriggers.Get("m" + specialID) = "2" Then
					''' HP Restored
					For Local ply:DCharacter = EachIn playerCharacters
						ply.HP = ply.maxHP
						nextBattle = Int(Rnd(3, 10))
					Next
					GMessageTicker.Add("Party HP Restored!")
				Else
					''
					SwitchScreenTo combatScreen
					Local cmtScn:SCombat = SCombat(combatScreen)
					'cmtScn.Clear
					cmtScn.enemyList.AddLast(New FrogWasp(30))
					cmtScn.enemyList.First().AddSkill("fire")
					cmtScn.placeMonsters()
					gameTriggers.Set("m" + specialID, "1")
				End
			Case 4' "WALL CITY"
				BackToMenu()
				
			Case 5' "WINDY PLAINS"				
				If gameTriggers.Get("m" + specialID) = "2" Then
					''' HP Restored
					For Local ply:DCharacter = EachIn playerCharacters
						ply.HP = ply.maxHP
						nextBattle = Int(Rnd(3, 10))
					Next
					GMessageTicker.Add("Party HP Restored!")
				Else
					''
					SwitchScreenTo combatScreen
					Local cmtScn:SCombat = SCombat(combatScreen)
					cmtScn.enemyList.AddLast(New FrogWasp(45))
					cmtScn.enemyList.AddLast(New FrogWasp(45))
					cmtScn.enemyList.First().AddSkill("fire")
					cmtScn.placeMonsters()
					gameTriggers.Set("m" + specialID, "1")
				End
				
			Case 6' "SMELLY MARCHES"
				If gameTriggers.Get("m" + specialID) = "2" Then
					'GMessageTicker.Add("Nothing here.")
					''' HP Restored
					For Local ply:DCharacter = EachIn playerCharacters
						ply.HP = ply.maxHP
						nextBattle = Int(Rnd(3, 10))
					Next
					GMessageTicker.Add("Party HP Restored!")
				Else
					GMessageTicker.Add("Debug")
					gameTriggers.Set("m" + specialID, "2")
				EndIf
				
			Case 7' "MOUNTAINGRAD"
				BackToMenu()
				
			Case 8' "MT.KRUGDOR"
				If gameTriggers.Get("m" + specialID) = "2" Then
					'GMessageTicker.Add("Nothing here.")
					''' HP Restored
					For Local ply:DCharacter = EachIn playerCharacters
						ply.HP = ply.maxHP
						nextBattle = Int(Rnd(3, 10))
					Next
					GMessageTicker.Add("Party HP Restored!")
				Else
					GMessageTicker.Add("Debug")
					gameTriggers.Set("m" + specialID, "2")
				EndIf
				
			Case 9' "THE TOWER"
				If gameTriggers.Get("m" + specialID) = "2" Then
					'GMessageTicker.Add("Nothing here.")
					''' HP Restored
					For Local ply:DCharacter = EachIn playerCharacters
						ply.HP = ply.maxHP
						nextBattle = Int(Rnd(3, 10))
					Next
					GMessageTicker.Add("Party HP Restored!")
				Else
					SwitchScreenTo combatScreen
					Local cmtScn:SCombat = SCombat(combatScreen)
					cmtScn.enemyList.AddLast(New FrogWasp(75))
					cmtScn.enemyList.AddLast(New FrogWasp(75))
					cmtScn.enemyList.AddLast(New FrogWasp(75))
					cmtScn.enemyList.First().AddSkill("fire")
					cmtScn.placeMonsters()
					gameTriggers.Set("m" + specialID, "1")
				EndIf
				
			Case 10 ''' Pit
			'	lastTown = specialID
				
				If gameTriggers.Get("m" + specialID) = "2" Then
					GMessageTicker.Add("Nothing here.")
				Else
					''
					GMessageTicker.Add("You found Bahamaut!")
					GMessageTicker.Add("'Haha puny human,")
					GMessageTicker.Add("you will die this day!'")
					
					''
					SwitchScreenTo combatScreen
					Local cmtScn:SCombat = SCombat(combatScreen)
					'cmtScn.Clear
					cmtScn.enemyList.AddLast(New FrogWasp(25))
					cmtScn.enemyList.First().Name = "BAHAMAUT"
					cmtScn.enemyList.First().AddSkill("fire")
					cmtScn.enemyList.First().AddSkill("fire")
					cmtScn.enemyList.First().AddSkill("fire")
					cmtScn.placeMonsters()
					gameTriggers.Set("m" + specialID, "1")
				End
				
			Case (16 * 1) + 0 '' YELLOW
				GMessageTicker.Add("Yellow Sign Message!")
				
			Case (16 * 2) + 0 '' GREEN
				GMessageTicker.Add("Green Sign Message!")
				
			Case (16 * 3) + 0 '' CYAN
				GMessageTicker.Add("Cyan Sign Message!")
				
			Default
				Return True
		End
		
		Return False
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method WorldMap_Names:String()
		Local txt:String = "???"
		Select map.currentSpecial[y][x] - 128 + 1
			Case 1; txt = "NINJA VILLAGE"
			Case 2; txt = "DANGER FOREST"
			Case 3; txt = "CRAZY MINES"
			Case 4; txt = "WALL CITY"
			Case 5; txt = "WINDY PLAINS"
			Case 6; txt = "SMELLY MARCHES"
			Case 7; txt = "MOUNTAINGRAD"
			Case 8; txt = "MT.KRUGDOR"
			Case 9; txt = "THE TOWER"
			
			Case 10; txt = "*PIT"
			Case 11; txt = "*FAE HOUSE"
			Case 12; txt = "*VOLRATH'S CASTLE"
			Case 13; txt = "*HERMIT'S CAVE"
			Case 14; txt = "*ACTUAL BOSS"
			
			Case 255; txt = "haX"
		End
		txt = "["+ (map.currentSpecial[y][x] - 128 + 1) + "]" + txt
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
	
	Const menu:Int = 0
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



