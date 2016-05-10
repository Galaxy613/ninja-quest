#Rem
	Conversation Screen
	
	n/a
	
	Verbs:
		n/a
#END
''' SConversation
''Private
''' modes - Fake enum for SConversation
''' chatScript -
''' chatThread - Controls a sublist of chatScriptItems
''' chatScriptItem - A data object for an event such as talking or just simply a flag.
''' chatObject - Used for displaying characters and other objects in conversations.
Import engine

Class SConversation Extends TScreen
	Global maxLines:Int = 5

	Field script:chatScript
	
	Field lines:String[] =["", ""]
	Field curLine:Int = 0, curLineChar:Int = 0, isReadingText:Bool = False, textSpeed:Int = 50, textSpeedLast:Int = 0
	Field optionNumbers:Int = 0
	
	Field treeEnded:Bool = False
	
	Method ResetLines:Void()
		lines = lines.Resize(maxLines)
		
		For Local c:Int = 0 To(maxLines - 1)
			lines[c] = ""
		Next
		
		curLine = 0
		curLineChar = 0
	End
	
	Method OnInit:Int()
		modes.current = modes.init
		menuColumn = 0
		menuIndex = 0
		ResetLines
	End
	
	Method OnUpdate:Int()
		Select modes.current
			Case modes.option_select
				UpDownMenu(optionNumbers)
				If NInput.IsHit(N_A) Then
					ExecuteScriptItem(New chatScriptItem(chatScriptItem.change_thread,[lines[menuIndex + 1][lines[menuIndex + 1].Find("`") + 1 ..]]))
				End
				_Update
'			Case modes.info
'				INFO_Update
			Default
				_Update()
		End
	End
	
	Method OnRender:Int()
		Select modes.current
			Case modes.option_select
				_Draw()
				GDrawTextPreserveBlend(">", 4, 142 - (8 * (5 - menuIndex)))'menuIndex
'			Case modes.info
'				INFO_Draw
			Default
				_Draw()
		End
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method GetNextScriptItem()
		Local csi:chatScriptItem = script.currentThread.NextScriptItem()
		If csi <> Null Then
			ExecuteScriptItem(csi)
			treeEnded = False
		Else
			If modes.current <> modes.option_select Then treeEnded = True
		End
	End
	
	Method _Update:Void()
		'If NinInput.IsHit(N_B) Then BackToMenu()
		
		''' If the converstation tree has not ended, check if next Script Item is needed
		If Not treeEnded ''' Not (modes.current = chatScriptItem.player_talk) or
			If modes.current <> 10 or ( ( Not isReadingText and textSpeedLast + 500 < Millisecs()) And NInput.IsHit(N_A)) or NInput.IsHit(N_Start) Then
			'	textSpeedLast = Millisecs() +2000
				GetNextScriptItem()
			End
		End
		
		''' Are we still reading? Then see if it's time to go forward a character.
		If isReadingText 'and textSpeedLast < Millisecs() Then
			curLineChar += 1
			If curLineChar > lines[curLine].Length Then
				curLine += 1
				curLineChar = 0
			End
			
			'' Reset the timer, if they are holding down 'A' then speed it up.
'			textSpeedLast = Millisecs()
'			If not NInput.IsDown(N_A)
'				textSpeedLast += textSpeed
'			End
			
			'' If current line is equal to max number of lines, then we are done reading this current script item.
			If curLine = maxLines Then
				isReadingText = False
			'	If KeyDown(KEY_T) Then textSpeedLast += 1000
			End
		End
		
		''' Has the conversation tree ended and timer is done? Wait for 'A'
		If treeEnded And textSpeedLast < Millisecs() Then
			If NInput.IsDown(N_A)
				'SwitchScreenTo(townMapScreen)
				SwitchScreenTo(lastScreen) '' Goes to last screen, so for boss battles, setup the battle first and set battle as lastScreen
			End
		End
		
		script.DoObjectAnimations
	End
	
	Method _Draw:Void()
		
		script.DrawObjects()
	
		GWindowDrawer.Draw(0, 136 - (8 * maxLines) - 8, 160, (8 * maxLines) + 16 + 4)

		If isReadingText Then
			For Local c:Int = 0 To curLine '+1
				If c = curLine Then
					GDrawTextPreserveBlend(lines[c][ .. curLineChar], 2, 134 - (8 * (maxLines - c)))
				Else
					GDrawTextPreserveBlend(lines[c], 2, 134 - (8 * (maxLines - c)))
				End
			Next
		'	GDrawTextPreserveBlend("iRT", 80, 2 + 3)
		Else
			For Local c:Int = 0 To(maxLines - 1)
				If lines[c].Contains("`") Then
					GDrawTextPreserveBlend(lines[c][ .. lines[c].Find("`")], 2, 134 - (8 * (maxLines - c)))
				Else
					GDrawTextPreserveBlend(lines[c], 2, 134 - (8 * (maxLines - c)))
				End
			Next
		End
		
	'	If treeEnded And textSpeedLast < Millisecs() Then
	'		GDrawTextPreserveBlend("Press A to Continue!", 2, 2)
	'	End
		If Not isReadingText Then GDrawTextPreserveBlend("Press A", 114, 144 - 8)
'		GDrawTextPreserveBlend("Txt " + BoolToString(isReadingText), 2, 2 + 8 * 1)
'		GDrawTextPreserveBlend("tree " + BoolToString(treeEnded), 2, 2 + 8 * 2)
'		GDrawTextPreserveBlend("mode " + modes.current, 2, 2 + 8 * 3)
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method RunCutscene:Void(scriptFile:String)
		script = New chatScript()
		
		script.Load(scriptFile)
		RunThread("init")
		script.currentThread = script.GetThread("main")
		
		treeEnded = False
	End
	
	Method RunThread:Void(thread:String)
		Local cthread:chatThread = script.GetThread(thread)
		
		For Local i:chatScriptItem = EachIn cthread.script
			ExecuteScriptItem i
		Next
	End
	
	Method ExecuteScriptItem:Void(cSI:chatScriptItem)
		Local header:String = "Exec[" + cSI.type + ","
		For Local k:Int = 0 To cSI.data.Length() -1
			header += cSI.data[k]
			If k < cSI.data.Length() -1 Then header += ","
		Next
		NLog header + "] "
		isReadingText = False
		
		'''''''''''''''''''''''''''''''''''''''''''''
		'' Check Script Item Type
		Select cSI.type
			Case chatScriptItem.player_talk
				'Display player's text on screen
				modes.current = modes.player_talk
				ResetLines()
				For Local c:Int = 0 To(maxLines - 1)
					If c < cSI.data.Length Then
						lines[c] = cSI.data[c]
					End
				Next
				isReadingText = True
				textSpeedLast = Millisecs()
				
		'	Case chatScriptItem.other_talk
		'		'Display other party's text on screen
		'		modes.current = modes.other_talk
				
			Case chatScriptItem.option_select
				'Provide up to 4 options
				modes.current = modes.option_select
				ResetLines()
				For Local c:Int = 0 To(maxLines - 1)
					If c < cSI.data.Length() Then
						If c > 0 Then lines[c] = "  "
						lines[c] = lines[c] + cSI.data[c]'(cSI.data[c][ .. cSI.data[c].Find("`")])' + "    " + (cSI.data[c][cSI.data[c].Find("`") ..])
					End
				Next
				optionNumbers = cSI.data.Length() -1
				_skip
				
			Case chatScriptItem.change_thread
				'Provide up to 4 options
				modes.current = 0'modes.
				'If cSI.data.Length() > 1 Then
				script.ChangeThread(cSI.data[0])
				_skip
				'End
				
			Case chatScriptItem.trigger_check
				'Check one trigger var against up to 4 options
				modes.current = 0
				'cSI.data[]
				Local trigger:String = gameTriggers.Get(cSI.data[0])
				
				
'				For Local c:Int = 1 To cSI.data.Length() -1
				Select cSI.data[1]'c][ .. cSI.data[c].Find("`")]
					Case "!empty"
						If trigger = "" Then
							script.ChangeThread(cSI.data[2])
						Else
							NLog "[SCRIPT] !empty Failed" + " " + cSI.data[0] + "=?'" + trigger + "'"
						End
					Case "!any"
						If not (trigger = "") Then
							script.ChangeThread(cSI.data[2])
						Else
							NLog "[SCRIPT] !any Failed" + " " + cSI.data[0] + "=?'" + trigger + "'"
						End
					Default
						If trigger.ToLower() = cSI.data[1].ToLower() Then
							script.ChangeThread(cSI.data[2])
						Else
							NLog "[SCRIPT] Failed" + " " + cSI.data[0] + "=?'" + trigger + "'"
						End
				End
'				Next
				_skip
				
			Case chatScriptItem.trigger_set
				'Set one trigger
				modes.current = 0
				If cSI.data.Length() > 1 Then
					gameTriggers.Set(cSI.data[0], cSI.data[1])
				Else
					gameTriggers.Set(cSI.data[0], "")
				End
				NLog "[SCRIPT] Set: " + cSI.data[0] + "='" + gameTriggers.Get(cSI.data[0]) + "'"
				_skip
				
			Case chatScriptItem.animation_change
				'Find object, change animation variables
				Local co:chatObject = script.GetObject(cSI.data[0])
				Select cSI.data.Length
					Case 2; co.SetAnimation(Int(cSI.data[1]))
					Case 3; co.SetAnimation(Int(cSI.data[1]), Int(cSI.data[2]))
					Case 4; co.SetAnimation(Int(cSI.data[1]), Int(cSI.data[2]), Int(cSI.data[3]))
				End
				_skip
				
				
			Case chatScriptItem.add_object
				NLog("Trying to add object ID: " + cSI.data[0])
				script.AddObject(cSI.data[0], Int(cSI.data[1]), Int(cSI.data[2]), cSI.data[3])
				_skip
				
			Case chatScriptItem.scale_object
				NLog("Trying to modify object ID: " + cSI.data[0])
				script.GetObject(cSI.data[0]).sx = Float(cSI.data[1])
				script.GetObject(cSI.data[0]).sy = Float(cSI.data[2])
				_skip
				
			Case chatScriptItem.place_object
				NLog("Trying to move object ID: " + cSI.data[0])
				script.GetObject(cSI.data[0]).x = int(cSI.data[1])
				script.GetObject(cSI.data[0]).y = int(cSI.data[2])
				_skip
				
			Default
				GoNuclear "Script Item Type '" + cSI.type + "' not recongized!!! Can't continue!"
		End
	End
	
	Method _skip:Void()
		textSpeedLast = Millisecs()
		isReadingText = False
	End
	
End

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private

Function _cScn_FirstCutscene:Void(chScn:SConversation)
'	_cScn_runCutscene(chScn,"boring_exposition")
	chScn.RunCutscene("boring_exposition")
End

Function _cScn_runCutscene:Void(chScn:SConversation, script:String)
	chScn.RunCutscene(script)
'	chScn.script = New chatScript()
'	
'	chScn.script.Load(script)
'	chScn.RunThread("init")
'	chScn.script.currentThread = chScn.script.GetThread("main")
'	
'	chScn.treeEnded = False
End

Class modes
	Global current:Int
	
	Const init:Int = 0
	Const player_talk:Int = 10
	Const other_talk:Int = 15
	Const option_select:Int = 20
	Const action:Int = 30
	
	Const quit:Int = -1
	
End

'''''''''''''''''''''

Class chatScript
	Field threads:List<chatThread> = New List<chatThread>()
	Field currentThread:chatThread = Null
	Field highestID:Int = 0
	
	Field cObjectList:List<chatObject> = New List<chatObject>()
	
	Method IsCurrentObjectText:Bool()
		'
	End
	
	Method Load:Void(scriptName:String)
		scriptName = "scripts/" + scriptName + ".json"
		If LoadString(scriptName) = "" Then GoNuclear "Can not find script file '" + scriptName + "'!!!" 'Return False
		Local file:JSONObject = JSONObject(JSONData.ReadJSON(LoadString(scriptName)))
		
		For Local thread:String = EachIn file.values.Keys() '' Get Thread Names
			Local t:chatThread = CreateThread(thread)
			NLog "Loading Thread: " + thread
			
			Local scriptItems:JSONArray = JSONArray(file.GetItem(thread)) '' Get Thread's Array for Commands
			Local tmpStrArr:String[]
			For Local scriptType:JSONDataItem = EachIn scriptItems.values '' Get each Command's Array of arguments
				tmpStrArr = JSONArray(scriptType).ToStringArray()
				'jObj.values.Keys
				NLog "jObj: " + tmpStrArr[0] '' [0] Will always be the command name
				t.AddScriptItem(chatScriptItem.StrToInt(tmpStrArr[0].ToLower()), tmpStrArr[1 ..])
			Next
		Next
		
	End
	
	Method CreateThread:chatThread(name:String)
		Local ct:chatThread = New chatThread()
		ct.name = name
		threads.AddLast(ct)
		Return ct
	End
	
	Method ChangeThread:Void(name:String)
		currentThread = GetThread(name)
		currentThread.currentSID = -1
		NLog "[SCRIPT] Changed to " + name
	End
	
	Method GetThread:chatThread(name:String)
		For Local co:chatThread = EachIn threads
			If co.name.ToLower().Contains(name.ToLower())
				Return co
			End
		Next
		GoNuclear "Can not find chatThread named '" + name + "'!"
		Return Null
	End
	
	Method GetNextCID:Int()
		highestID += 1
		Return highestID
	End
	
	Method DrawObjects:Void()
		For Local co:chatObject = EachIn cObjectList
			co.Draw()
		Next
	End
	
	Method DoObjectAnimations:Void()
		For Local co:chatObject = EachIn cObjectList
			co.DoAnimation()
		Next
	End
	
	Method AddObject:chatObject(name:String, x:Int, y:Int, imgName:String, frame:Int = 0)
		Local cO:chatObject = New chatObject()
		cO.scriptID = GetNextCID()
		cO.x = x
		cO.y = y
		cO.name = name
		cO.imgName = imgName
		cO.img = imageMap.Get(imgName)
		cO.frame = frame
		
		NLog "Added " + name + " with ID " + cO.scriptID
		cObjectList.AddLast(cO)
		Return cO
	End
	
	Method GetObject:chatObject(name:String)
		For Local co:chatObject = EachIn cObjectList
			If co.name.ToLower().Contains(name.ToLower())
				Return co
			End
		Next
		GoNuclear "Can not find ChatObject named '" + name + "'!"
		Return Null
	End
	
	Method GetObject:chatObject(cid:Int)
		For Local co:chatObject = EachIn cObjectList
			If co.scriptID = cid
				Return co
			End
		Next
		GoNuclear "Can not find ChatObject with the ID of '" + cid + "'!"
		Return Null
	End
End

Class chatThread
	Field name:String = "null"
	Field script:List<chatScriptItem> = New List<chatScriptItem>()
	Field currentSID:Int = -1
	
	Method NextScriptItem:chatScriptItem()
		If currentSID < script.Count() -1 Then
			currentSID += 1
		Else
			Return Null
		End
		Return script.ToArray()[currentSID] 'script.RemoveFirst()
	End
	
	Method AddScriptItem:chatScriptItem(type:Int, data:String[])
		Local si:chatScriptItem = New chatScriptItem()
		
		si.data = data
		si.type = type
		
		script.AddLast(si)
		Return si
	End
End

Class chatScriptItem
	Const player_talk:Int = 1
	Const other_talk:Int = 5
	Const option_select:Int = 10
	Const animation_change:Int = 20
	Const change_thread:Int = 30
	Const trigger_check:Int = 40
	Const trigger_set:Int = 41
	Const add_object:Int = 50
	Const scale_object:Int = 51
	Const place_object:Int = 52
	
	Function StrToInt:Int(str:String)
		Local value:Int = -1
		Select str.ToLower()
			Case "player_talk"; value = player_talk
			Case "other_talk"; value = other_talk
			Case "option_select"; value = option_select
			Case "animation_change"; value = animation_change
			Case "change_thread"; value = change_thread
			Case "trigger_check"; value = trigger_check
			Case "trigger_set"; value = trigger_set
			Case "add_object"; value = add_object
			Case "scale_object"; value = scale_object
			Case "place_object"; value = place_object
		End
		Return value
	End
	
	Function IntToStr:String(str:int)
		Local value:String = ""
		Select str
			Case player_talk; value = "player_talk"
			Case other_talk; value = "other_talk"
			Case option_select; value = "option_select"
			Case animation_change; value = "animation_change"
			Case change_thread; value = "change_thread"
			Case trigger_check; value = "trigger_check"
			Case trigger_set; value = "trigger_set"
			Case add_object; value = "add_object"
			Case scale_object; value = "scale_object"
			Case place_object; value = "place_object"
		End
		Return value
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''
	Field type:Int = 0
	Field data:String[]
	
	Method New(tt:Int, dd:String[])
		type = tt
		data = dd
	End
End

Class chatObject Extends GRect
	Field name:String, scriptID:Int
	Field img:Image, imgName:String, frame:Int = 0
	
	Field animationEffect:Int = 0, animationCounter:Int, animationSpeed:Int, animationVar:Int
	Const none:Int = 0
	Const jump:Int = 1
	Const pulse:Int = 2
	Const shake:Int = 3
	
	Field sx:Float = 1.0, sy:Float = 1.0
	
	Method Draw:Void()
		If Not img Then GoNuclear(name + " does not have a valid IMG loaded. Filename: " + imgName)
		
		Select animationEffect
			Case jump
				DrawImage(img, x, y + animationVar, 0, sx, sy, frame)
				
			Default
				DrawImage(img, x, y, 0, sx, sy, frame)
		End
	End
	
	Method DoAnimation()
		Select animationEffect
			Case jump
				If animationCounter < Millisecs() Then
					animationVar *= -1
					animationCounter = Millisecs() +animationSpeed
				End
		End
	End
	
	Method SetAnimation(type:Int = 0, animVar:Int = 0, animSpeed = 250)
		animationEffect = type
		animationSpeed = animSpeed
		Select animationEffect
			Case jump
				animationVar = animVar
				animationCounter = Millisecs()
				
			Default
				''null
		End
	End
End