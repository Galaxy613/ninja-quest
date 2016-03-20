Strict
Import engine
Import ScreenCombat
Import ScreenCharacter
Import ScreenTownMap
Import ScreenMainMenu
Import ScreenConversation

'' NINJA QUEST!
'160x144

Class MainClass Extends App
	Method New()
		' App is NOT Setup, do only basic data initalizing here.
		L.InitWQ()
	End
	
	Method LoadImages:Void()
		NLog("Loading Images...")
		SetFont(LoadImage("nin_font_thick.png", 96))', Image.XPadding))
		
		GWindowDrawer.Init("window_4_9.png", 4, 4, 9)
		GHealthDrawer.Init("window_2_3.png", 2, 2, 3)
		
		imageMap.Add("ninja", LoadImage("ninja.png", 24, 20, 3))
		imageMap.Add("wizard", LoadImage("wizard.png", 24, 20, 3))
		imageMap.Add("archer", LoadImage("archer.png", 24, 20, 6))
		imageMap.Add("magi", LoadImage("magi.png", 24, 20, 3))
		imageMap.Add("warrior", LoadImage("Warrior.png", 24, 20, 3))
		
		imageMap.Add("monsters", LoadImage("monsters_24x20_24.png", 24, 20, 24))
		
		imageMap.Add("blast", LoadImage("blast_16_5.png", 16, 16, 5))
		imageMap.Add("slash", LoadImage("slash_16_5.png", 16, 16, 5))
		
		imageMap.Add("tilemap", LoadImage("tile_map.png", 16, 16, 128))
		imageMap.Add("charmap", LoadImage("char_map.png", 16, 16, 128))
		
		imageMap.Add("map", LoadImage("wizard_map.png"))
		imageMap.Add("map_selector", LoadImage("map_select.png"))
		
		imageMap.Add("title", LoadImage("title.png"))
		
'		For Local imgName:String = EachIn imageMap.Keys()
'			Local img:Image = imageMap.Get(imgName)
'			NLog "img:" + img.Width() + "," + img.Height()
'		Next
	End
	
	Method OnCreate:Int()
		' App is setup and ready to load resources
		SetUpdateRate(15)
		
		UpdateScale()
		NLog LoadState()
		NLog "Start:::"
		
		LoadImages()
		
		titleScreen = New SMainMenu()
		combatScreen = New SCombat()
		characterScreen = New SCharacter()
		townMapScreen = New SMap()
		chatScreen = New SConversation()
		
		SwitchScreenTo titleScreen'townScreen'characterScreen'combatScreen
		
		Seed = Millisecs()
		
		currentScreen.OnInit()
		
		Return 0
	End
	
	Method OnLoading:Int()
		Cls 110 / 4, 167 / 4, 92 / 4
		Return 0
	End
	
	Method OnRender:Int()
		Scale(g_scale, g_scale)
		GClearScreen.ClearScreen()
		
		PushMatrix()
		
		Translate(g_x_offset, 0)
		SetBlend AlphaBlend
	'	SetAlpha 0.9
		If currentScreen <> Null And not hasGoneNuclear Then
			currentScreen.OnRender()
		Else
			If hasGoneNuclear Then
				GDrawTextPreserveBlend("[FATAL ERROR]", 2, 2 + (8 * 0))
				GDrawTextPreserveBlend(nukeMessage, 2, 2 + (8 * 1))
				If nukeMessage.Length > 26 Then GDrawTextPreserveBlend(nukeMessage[26 ..], 2, 2 + (8 * 2))
				If nukeMessage.Length > 26 * 2 Then GDrawTextPreserveBlend(nukeMessage[ (26 * 2) ..], 2, 2 + (8 * 3))
				If nukeMessage.Length > 26 * 3 Then GDrawTextPreserveBlend(nukeMessage[ (26 * 3) ..], 2, 2 + (8 * 4))
				If nukeMessage.Length > 26 * 4 Then GDrawTextPreserveBlend(nukeMessage[ (26 * 4) ..], 2, 2 + (8 * 5))
			Else
				GDrawTextPreserveBlend("No Screen Set", 2, 2)
			
				GDrawTextPreserveBlend("*PRESS START", 2, 32)
				GDrawTextPreserveBlend(" TO BATTLE AGAIN*", 2, 32 + 8)
			End
			
			GDrawTextPreserveBlend("DW " + DeviceWidth(), 2, 56 + (8 * 1))
			GDrawTextPreserveBlend("GW " + (160 * g_scale), 2, 56 + (8 * 2))
			GDrawTextPreserveBlend("LW " + lWidth, 2, 56 + (8 * 3))
			
			GDrawTextPreserveBlend("NI " + ninja.Level, 2, 56 + (8 * 5))
			GDrawTextPreserveBlend("AR " + archer.Level, 2, 56 + (8 * 6))
		End
		
		NInput.Draw()
		
		PopMatrix()
		
		SetColor 0, 0, 0
		DrawRect 0, 0, g_x_offset, 144
		DrawRect(DeviceWidth() / g_scale) - g_x_offset, 0, g_x_offset, 144
		
		Return 0
	End
	
	Method OnUpdate:Int()
		UpdateScale()
		NInput.Update()
		If currentScreen <> Null Then
			currentScreen.OnUpdate()
		Else
'			If NinInput.IsHit(N_Start) Then
'				SwitchScreenTo combatScreen
'				combatScreen.OnInit()
'			End
			If NInput.IsHit(N_A) Then lWidth = 0
		End
		
		If KeyHit(KEY_F3) Then
			If currentScreen <> Null Then
				currentScreen = Null
			Else
				SaveState("")
				NLog "Save State cleared"
			End
		End
		Return 0
	End
	
	Method OnSuspend:Int()
		'If currentScreen <> Null Then currentScreen.OnRender()
		''Draw flashing "PAUSE" text
		
		Return 0
	End
	
	Method OnResume:Int()
		'
		Return 0
	End
	
	Method UpdateScale:Void()
		If lWidth = DeviceWidth() Then Return
		
		g_x_offset = 0
		
		If DeviceWidth() > DeviceHeight() Then
			g_scale = (DeviceHeight() / vScnHeight)
			g_x_offset = ( ( (DeviceWidth() / g_scale) - 160) / 2)
		Else
			g_scale = (DeviceWidth() / vScnWidth)
		End
		
	'	NLog "(DeviceHeight() - DeviceWidth()) = " + (DeviceHeight() -DeviceWidth())
	'	#if (TARGET = "android") or (TARGET = "ios")
		If (DeviceHeight() > DeviceWidth() And (DeviceHeight() -DeviceWidth()) > 63) And NInput.V_A = Null Then
			NInput.CreateVirtualControls()
		Else
			NInput.UpdateVirtualControls()
		End
		
	'	#end		
	End
	
'	Method OnClose:Int() '' Close Window Button
'		' By Default calls EndApp
'		Return False
'	End
'	
'	Method OnBack:Int() '' Back Button
'		' By Default calls OnClose
'		Return False
'	End
End

Function Main:Int()
	New MainClass
	Return 0
End