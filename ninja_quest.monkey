Import engine
'' gameTriggers

Class NinjaQuest Extends TGame
	
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
		'ninja.Skills.Add("aero", "")
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
End