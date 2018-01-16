Import engine
'' gameTriggers

Class NinjaQuest Extends TGame

	Method New()
		worldMapName = "worldmap"
	End
	
	Method OnCreate:Void()
		SwitchScreenTo titleScreen'townScreen'characterScreen'combatScreen
	End
	
	Method LoadTriggers:Void()
		'' Save ninja-quest game specific variable here. Lets not hard code EVERYTHING...
		If gameTriggers.Contains("game")
			GoNuclear("A game with it's triggers is already loaded!")
			Return
		Else
			gameTriggers.Add("game", "ninja quest")
		EndIf
	End

	Method NewGame:Void()
		ninja = New DCharacter()
		ninja.accessory = DItem.Generate(DItem.TYPE_EQUIP, DItem.ITEM_SCARF)
		ninja.InitStats(-1, 5, 3)
		ninja.InitLevel(4, "NINJA")
		ninja.img = imageMap.Get("ninja")
		ninja.Skills.Add("aero", "")
		'ninja.Skills.Add("slash", "")
		ninja.Skills.Add("smoke", "")
		playerCharacters.AddLast(ninja)
		'NLog ":"
		'SaveGame()
		NLog ":"
				
		SwitchScreenTo(townMapScreen)
		townMapScreen.OnInit()
		lastTown = 128
		SMap(townMapScreen).StartAt(lastTown)
				
		SConversation(chatScreen).RunCutscene("boring_exposition")
		SwitchScreenTo(chatScreen)
	End
	
	''' Map.Town.Names
	Method Town_Name:String(townID:Int)
		Select townID
			Case 1; Return "NINJA VILLAGE"
			Case 2; Return "DANGER FOREST"
			Case 3; Return "CRAZY MINES"
			Case 4; Return "WALL CITY"
			Case 5; Return "WINDY PLAINS"
			Case 6; Return "SMELLY MARCHES"
			Case 7; Return "MOUNTAINGRAD"
			Case 8; Return "MT.KRUGDOR"
			Case 9; Return "THE TOWER"
			
			Case 10; Return "*PIT"
			Case 11; Return "*FAE HOUSE"
			Case 12; Return "*VOLRATH'S CASTLE"
			Case 13; Return "*HERMIT'S CAVE"
			Case 14; Return "*ACTUAL BOSS"
			
			Case 255; Return "haX"
		End
		Return "???"
	End
	
	''' Map.Town.Actions
	Const Town_Enter_Nothing:Int = -1
	Const Town_Enter_GoToTown:Int = 1
	Const Town_Randomize_NextBattle:Int = 2
	
	Method Town_Enter:Int(townId:Int)
		Local specialID:Int = ConvertToSpecialID(townId)
		
		Select townId
			Case 1 ''' Ninja Village
				Return Town_Enter_GoToTown ' GoToTown()
				
			Case 2 ''' Danger Forest				
				If gameTriggers.Get("m" + specialID) = "2" Then
					''' HP Restored
					For Local ply:DCharacter = EachIn playerCharacters
						ply.HP = ply.maxHP
					Next
					GMessageTicker.Add("Party HP Restored!")
					Return Town_Randomize_NextBattle
				Else
					''
					GMessageTicker.Add("I can't believe you")
					GMessageTicker.Add("left the forest over")
					GMessageTicker.Add("training with the ninjas!")
					GMessageTicker.Add("Defend yourself!")
					
					''
					SwitchScreenTo combatScreen
					Local cmtScn:SCombat = SCombat(combatScreen)
					cmtScn.enemyList.AddLast(New CharArcher(10))
					cmtScn.placeMonsters()
					gameTriggers.Set("m" + specialID, "1")
				End
				
			Case 3' "CRAZY MINES"				
				If gameTriggers.Get("m" + specialID) = "2" Then
					''' HP Restored
					For Local ply:DCharacter = EachIn playerCharacters
						ply.HP = ply.maxHP
					Next
					GMessageTicker.Add("Party HP Restored!")
					Return Town_Randomize_NextBattle
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
				Return Town_Enter_GoToTown
				
			Case 5' "WINDY PLAINS"
				If gameTriggers.Get("m" + specialID) = "2" Then
					''' HP Restored
					For Local ply:DCharacter = EachIn playerCharacters
						ply.HP = ply.maxHP
					Next
					GMessageTicker.Add("Party HP Restored!")
					Return Town_Randomize_NextBattle
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
					Next
					GMessageTicker.Add("Party HP Restored!")
					Return Town_Randomize_NextBattle
				Else
					GMessageTicker.Add("Debug")
					gameTriggers.Set("m" + specialID, "2")
				EndIf
				
			Case 7' "MOUNTAINGRAD"
				Return Town_Enter_GoToTown
				
			Case 8' "MT.KRUGDOR"
				If gameTriggers.Get("m" + specialID) = "2" Then
					'GMessageTicker.Add("Nothing here.")
					''' HP Restored
					For Local ply:DCharacter = EachIn playerCharacters
						ply.HP = ply.maxHP
					Next
					GMessageTicker.Add("Party HP Restored!")
					Return Town_Randomize_NextBattle
				Else
					GMessageTicker.Add("Debug")
					gameTriggers.Set("m" + specialID, "2")
				EndIf
				
			Case 9' "THE TOWER"
				If gameTriggers.Get("m" + specialID) = "2" Then
					GMessageTicker.Add("Nothing here.")
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
					cmtScn.enemyList.AddLast(New BossBahamaut(25))
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
				Return Town_Enter_Nothing
		End
	End
	Method Town_Inn:Int(townId:Int)
		Select townId
			Case 1' "NINJA VILLAGE"
				For Local ply:DCharacter = EachIn playerCharacters
					ply.HP = ply.maxHP
				Next
				GMessageTicker.Add "Party HP restored!"
			'Case 2' "DANGER FOREST"
			'Case 3' "CRAZY MINES"
			'Case 4' "WALL CITY"
			'Case 5' "WINDY PLAINS"
			'Case 6' "SMELLY MARCHES"
			'Case 7' "MOUNTAINGRAD"
			'Case 8' "MT.KRUGDOR"
			'Case 9' "THE TOWER"
			Default
				GMessageTicker.Add "There's no inn here."
				Return 0
				' default
		End
	End
	Method Town_Shop:Int(townId:Int)
		Select townId
			Case 1' "NINJA VILLAGE"
				Return 1
			'Case 2' "DANGER FOREST"
			'Case 3' "CRAZY MINES"
			'Case 4' "WALL CITY"
			'Case 5' "WINDY PLAINS"
			'Case 6' "SMELLY MARCHES"
			'Case 7' "MOUNTAINGRAD"
			'Case 8' "MT.KRUGDOR"
			'Case 9' "THE TOWER"
			Default
				GMessageTicker.Add "There's no shop here."
				Return 0
				' default
		End
	End
	Method Town_Talk:Int(townId:Int)
		Select townId
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
	End
	
End