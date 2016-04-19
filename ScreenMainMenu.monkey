#Rem
	Main Menu Screen
	
	Shows the main menu and lets the player start a new game, load an old game,
	or change some settings.
	
	Verbs:
		New Game
		Load Game
		Settings Menu
			Text Speed
			Button Layout
			Button Size
#END
''' STitle - Title screen aka main menu
'''P modes - fake enum
Import engine
Import ScreenTownMap
Import ScreenConversation

Class SMainMenu Extends TScreen
	
	Field title:Image = Null
	Field img1:Image = Null
	Field img2:Image = Null
	Field monsterFrame:Int = 0

	Method OnInit:Int()
		modes.current = modes.welcome
		menuColumn = 0
		menuIndex = 0
		monsterFrame = 0
		
		NLog "Yay"
		title = imageMap.Get("title")
		img1 = imageMap.Get("ninja")
		img2 = imageMap.Get("monsters")
		NLog "Yay"
	End
	
	Method OnUpdate:Int()
		Select modes.current
			Case modes.welcome
				INFO_Update
			Case modes.menu
				MENU_Update
			Case modes.newgame
				'
			Default
				_Update()
		End
	End
	
	Method OnRender:Int()
		Select modes.current
			Case modes.welcome
				INFO_Draw
				_Draw()
			Case modes.menu
				MENU_Draw
				_Draw()
			Case modes.newgame
				Reset()
				ninja = New DCharacter()
					ninja.accessory = DItem.Generate(DItem.TYPE_EQUIP, 1)
					ninja.InitStats(-1, 5, 3)
					ninja.InitLevel(4, "NINJA")
					ninja.img = imageMap.Get("ninja")
				'	ninja.Skills.Add("aero", "")
				'	ninja.Skills.Add("slash", "")
					ninja.Skills.Add("smoke", "")
				playerCharacters.AddLast(ninja)
		'		NLog ":"
		'		SaveGame()
				NLog ":"
				
				SwitchScreenTo(townMapScreen)
				townMapScreen.OnInit()
				lastTown = 128
				SMap(townMapScreen).StartAt(lastTown)
				
				SConversation(chatScreen).RunCutscene("boring_exposition")
				SwitchScreenTo(chatScreen)
	'		Default
	'			_Draw()
		End
	End
	
	Method GoTo:Void(mode:Int)
		modes.current = mode
		
		menuIndex = 0
		menuColumn = 0
		monsterFrame = 0
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method INFO_Update:Void()
		If NInput.IsHit(N_Start) Then GoTo(modes.menu)
		
		If menuColumn < 22 Then
			menuColumn += 1
		Else
			menuColumn = 22
			If menuIndex = 0 Then menuIndex = 3
			If menuIndex > 0 Then
				menuIndex -= 1
				If menuIndex = 0 Then menuIndex = -5
			Else
				menuIndex += 1
				If menuIndex = 0 Then
					menuIndex = 5
					monsterFrame += 1
					If img2.Frames() -1 < monsterFrame Then monsterFrame = 0
				End
			End
		End
	End
	Method INFO_Draw:Void()
		DrawImage(title, 80 - (title.Width / 2), 16 - 144 * (1 + Cos(menuColumn * 180 / 20)))
		
		DrawImage(img1, 32 - 2 * (22 - menuColumn), 72)
		
		If menuColumn = 22 Then
			DrawImage(img2, 160 - img2.Width - 32, 72, monsterFrame)
		End
		
		If menuIndex > 0 Then GDrawTextPreserveBlend("Press Start to Play!", 24, 104)
	End
	
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method MENU_Update:Void()
		If NInput.IsHit(N_B) Then GoTo(modes.welcome)
		
		UpDownMenu(3)
		
		If NInput.IsHit(N_A)
			Select menuIndex
				Case 0
					modes.current = modes.newgame
				
				Case 1
					If LoadState() <> "" Then
						LoadGame(JSONObject(JSONData.ReadJSON(LoadState())))
						SwitchScreenTo(townMapScreen)
						SMap(townMapScreen).StartAt(lastTown)
					End
				
				Case 2
					'
			End
		End
	End
	Method MENU_Draw:Void()
		DrawImage(title, 80 - (title.Width / 2), 16 - 144 * (1 + Cos(22 * 180 / 20)))
		
'		GWindowDrawer.Draw(0, 48 + 4 + 8, 160, 48)
'		
'		GDrawTextPreserveBlend("New Game", 40, 72)
'		If LoadState() = "" Then SetAlpha 0.5
'		GDrawTextPreserveBlend("Load Game", 40, 72 + 8)
'		SetAlpha 1.0
'		GDrawTextPreserveBlend("Settings", 40, 72 + 16)
'		GDrawTextPreserveBlend(">", 40 - 6, 72 + (8 * menuIndex))
		
		GWindowDrawer.Draw(80, 48 + 4 + 8, 80, 48)
		DrawImage(img1, 32, 72)
		
		GDrawTextPreserveBlend("New Game", 90, 72)
		If LoadState() = "" Then SetAlpha 0.5
		GDrawTextPreserveBlend("Load Game", 90, 72 + 8)
		SetAlpha 1.0
		GDrawTextPreserveBlend("Settings", 90, 72 + 16)
		GDrawTextPreserveBlend(">", 90 - 6, 72 + (8 * menuIndex))
	End
	
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method _Update:Void()
	'	If NinInput.IsHit(N_B) Then BackToMenu()
	End
	Method _Draw:Void()
		GDrawTextPreserveBlend("Made by Karl Nyborg", 0, 144 - 16)
		GDrawTextPreserveBlend("Battle Art by Yokomeshi", 0, 144 - 24)
		GDrawTextPreserveBlend("2013-16 - Alpha v5", 0, 144 - 8)
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
End

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private

Class modes
	Global current:Int
	
	Const welcome:Int = 0
	Const menu:Int = 1
	Const newgame:Int = 2
	
End