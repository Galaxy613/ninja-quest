Import mojo
Import gui

Const N_UP:Int = 0
Const N_DOWN:Int = 1
Const N_RIGHT:Int = 2
Const N_LEFT:Int = 3

Const N_A:Int = 5
Const N_B:Int = 6

Const N_Start:Int = 8

Class NInput '' Formerly NinInput
	
	Global VirtualX:Int = 0, VirtualY:Int = 0
	Global lastJoyX:Int = 0, lastJoyY:Int = 0
	
	Global V_A:GButton = Null, V_B:GButton = Null
	Global V_UP:GButton = Null, V_DOWN:GButton = Null, V_LEFT:GButton = Null, V_RIGHT:GButton = Null
	Global V_Start:GButton = Null
	
	Global currentPoll:Int = 0, pollSpeed:Int = 5
	
	Function CreateVirtualControls(type:Int = 0)
		Local height:Int = (DeviceHeight() / g_scale) - 144.0
		
		Local difference:Int = height / 4'64
		
		Select type
			Case 0
				V_A = New GButton(160 - 56, 144 + difference + 32 + (difference / 8), 30, 30)
				V_A.text = "A"
				V_B = New GButton(160 - 56 + 16, 144 + difference + 2 - (difference / 8), 30, 30)
				V_B.text = "B"
				
				V_Start = New GButton( (DeviceWidth() / g_scale / 2) - 32, DeviceHeight() / g_scale - (6 + 8), 32 + 6, 8 + 8)
				V_Start.text = "START"
				
				V_UP = New GButton(4 + 20, 144 + (difference + 24) - 21, 20, 24)
				V_DOWN = New GButton(4 + 20, 144 + (difference + 24) + 17, 20, 24)
				
				V_LEFT = New GButton(4, 144 + difference + 24, 24, 20)
				V_RIGHT = New GButton(4 + 36, 144 + difference + 24, 24, 20)
				
		End
		
		UpdateVirtualControls()
	End
	
	Function UpdateVirtualControls()
		If V_Start = Null Then Return
		
		Local height:Int = (DeviceHeight() / g_scale) - 144.0
		
		Local difference:Int = height / 4'64
		
		V_A.Set(160 - 56, 144 + difference + 32 + (difference / 8), 30, 30)
		V_B.Set(160 - 56 + 16, 144 + difference + 2 - (difference / 8), 30, 30)
		
		V_Start.Set( (DeviceWidth() / g_scale / 2) - 32, (DeviceHeight() / g_scale - (6 + 8)) - difference / 3, 32 + 6, 8 + 8)
		
		V_UP.Set(4 + 20, 144 + (difference + 24) - 21, 20, 24)
		V_DOWN.Set(4 + 20, 144 + (difference + 24) + 17, 20, 24)
		
		V_LEFT.Set(4, 144 + difference + 24, 24, 20)
		V_RIGHT.Set(4 + 36, 144 + difference + 24, 24, 20)
		
	End
	
	Function IsHit:Bool(keycode:Int)
		Select keycode
			Case N_UP
				If VirtualY > 0 Then Return True
				If KeyHit(KEY_UP) Then Return True
				If JoyHit(JOY_UP) Then Return True
				If V_UP Then If V_UP.isHit Then Return True
				If JoyY() > 0.5 And lastJoyY < 1 Then lastJoyY = 1; Return True
				lastJoyY = 0
			Case N_DOWN
				If VirtualY < 0 Then Return True
				If KeyHit(KEY_DOWN) Then Return True
				If JoyHit(JOY_DOWN) Then Return True
				If V_DOWN Then If V_DOWN.isHit Then Return True
				If JoyY() < -0.5 And lastJoyY > - 1 Then lastJoyY = -1; Return True
				lastJoyY = 0
			Case N_RIGHT
				If VirtualX > 0 Then Return True
				If KeyHit(KEY_RIGHT) Then Return True
				If JoyHit(JOY_RIGHT) Then Return True
				If V_RIGHT Then If V_RIGHT.isHit Then Return True
				If JoyX() > 0.5 And lastJoyX > 1 Then lastJoyX = 1; Return True
				lastJoyY = 0
			Case N_LEFT
				If VirtualX < 0 Then Return True
				If KeyHit(KEY_LEFT) Then Return True
				If JoyHit(JOY_LEFT) Then Return True
				If V_LEFT Then If V_LEFT.isHit Then Return True
				If JoyX() < -0.5 And lastJoyX > - 1 Then lastJoyX = -1; Return True
				lastJoyY = 0
				
			Case N_A
				If KeyHit(KEY_Z) Then Return True
				If JoyHit(JOY_A) Then Return True
				If V_A Then If V_A.isHit Then Return True
				
			Case N_B
				If KeyHit(KEY_X) Then Return True
				If JoyHit(JOY_B) Then Return True
				If V_B Then If V_B.isHit Then Return True
				
			Case N_Start
				If KeyHit(KEY_ENTER) Then Return True
				If KeyHit(KEY_SPACE) Then Return True
				If JoyHit(JOY_START) Then Return True
				If V_Start Then If V_Start.isHit Then Return True
				
		End
		Return False
	End
	
	Function IsDown:Bool(keycode:Int)
		Select keycode
			Case N_UP
				If VirtualY > 0 Then Return True
				If KeyDown(KEY_UP) Then Return True
				If JoyDown(JOY_UP) Then Return True
				If V_UP Then If V_UP.isDown Then Return True
				If JoyY() > 0.5 Then Return True
				lastJoyY = 0
			Case N_DOWN
				If VirtualY < 0 Then Return True
				If KeyDown(KEY_DOWN) Then Return True
				If JoyDown(JOY_DOWN) Then Return True
				If V_DOWN Then If V_DOWN.isDown Then Return True
				If JoyY() < -0.5 Then Return True
				lastJoyY = 0
			Case N_RIGHT
				If VirtualX > 0 Then Return True
				If KeyDown(KEY_RIGHT) Then Return True
				If JoyDown(JOY_RIGHT) Then Return True
				If V_RIGHT Then If V_RIGHT.isDown Then Return True
				If JoyX() > 0.5 Then Return True
				lastJoyY = 0
			Case N_LEFT
				If VirtualX < 0 Then Return True
				If KeyDown(KEY_LEFT) Then Return True
				If JoyDown(JOY_LEFT) Then Return True
				If V_LEFT Then If V_LEFT.isDown Then Return True
				If JoyX() < -0.5 Then Return True
				lastJoyY = 0
				
			Case N_A
				If KeyDown(KEY_Z) Then Return True
				If JoyDown(JOY_A) Then Return True
				If V_A Then If V_A.isDown Then Return True
				
			Case N_B
				If KeyDown(KEY_X) Then Return True
				If JoyDown(JOY_B) Then Return True
				If V_B Then If V_B.isDown Then Return True
				
			Case N_Start
				If KeyDown(KEY_ENTER) Then Return True
				If KeyDown(KEY_SPACE) Then Return True
				If JoyDown(JOY_START) Then Return True
				If V_Start Then If V_Start.isDown Then Return True
				
		End
		Return False
	End
	
	Function GetXAxis:Int()
		Local result:Int = 0
		If IsHit(N_RIGHT) Then result = 1
		If IsHit(N_LEFT) Then result = -1
		''' Move forward if key down, or reset the poll if we have moved.
		If currentPoll = 0 Then
			If IsDown(N_RIGHT) Then result = 1
			If IsDown(N_LEFT) Then result = -1
		ElseIf result <> 0
			currentPoll = 0
		EndIf
		
		Return result
	End
	
	Function GetYAxis:Int()
		Local result:Int = 0
		If IsHit(N_DOWN) Then result += 1
		If IsHit(N_UP) Then result -= 1
		''' Move forward if key down, or reset the poll if we have moved.
		If currentPoll = 0 Then
			If IsDown(N_DOWN) Then result += 1
			If IsDown(N_UP) Then result -= 1
		ElseIf result <> 0
			currentPoll = 0
		EndIf
		Return result
	End
	
	Function GetXAxisDown:Int()
		Local result:Int = 0
		
		If currentPoll = 0 Then
			If IsDown(N_RIGHT) Then result = 1
			If IsDown(N_LEFT) Then result = -1
		ElseIf result <> 0
			currentPoll = 0
		EndIf
		
		Return result
	End
	
	Function GetYAxisDown:Int()
		Local result:Int = 0
		
		If currentPoll = 0 Then
			If IsDown(N_DOWN) Then result += 1
			If IsDown(N_UP) Then result -= 1
		ElseIf result <> 0
			currentPoll = 0
		EndIf
		
		Return result
	End
	
	Function Update:Void()
		VirtualX = 0'IsHit(N_RIGHT) - IsHit(N_LEFT)
		VirtualY = 0'IsHit(N_UP) - IsHit(N_DOWN)
		
		If V_A Then
			V_A.Update()
			V_B.Update()
			
			V_UP.Update()
			V_DOWN.Update()
			V_LEFT.Update()
			V_RIGHT.Update()
			
			V_Start.Update()
		End
		
		currentPoll = (currentPoll + 1) Mod pollSpeed
	End
	
	Function Draw:Void()
	'	SetColorToBG
	'	DrawRect(0, (144.0), DeviceWidth / g_scale, (DeviceHeight() -DeviceWidth()) / g_scale)
	'	SetColor 255, 255, 255
		GWindowDrawer.Draw(0, (144), 160, (DeviceHeight() / g_scale) - 140)
		
		If V_A Then
			V_A.Draw()
			V_B.Draw()
			
			V_UP.Draw()
			V_DOWN.Draw()
			V_LEFT.Draw()
			V_RIGHT.Draw()
			
			V_Start.Draw()
		End
	End
End