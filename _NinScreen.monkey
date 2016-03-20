' Originally made for NinjaQuest! Explains the 'nin'
' Too lazy to find a working Diddy release, so I made this for my own screens
'

Class NinScreen
	Method OnInit:Int()
		'
		Return 0
	End
	
	Method OnUpdate:Int()
		'
		Return 0
	End
	
	Method OnResize:Int()
		'
		Return 0
	End
	
	Method OnRender:Int()
		'
		Return 0
	End
	
	Method UpDownMenu:Void(upperLimit:Int, lowerLimit:Int = 0)
		If NinInput.IsHit(N_UP) Then menuIndex -= 1 '; PlaySound(menuSelect)
		If NinInput.IsHit(N_DOWN) Then menuIndex += 1 '; PlaySound(menuSelect)
		
		If menuIndex < lowerLimit Then menuIndex = upperLimit - 1
		If menuIndex = upperLimit Then menuIndex = lowerLimit
	End
	
	Method LeftRightMenu:Void(upperLimit:Int, lowerLimit:Int = 0)
		If NinInput.IsHit(N_LEFT) Then menuColumn -= 1 '; PlaySound(menuSelect)
		If NinInput.IsHit(N_RIGHT) Then menuColumn += 1 '; PlaySound(menuSelect)
		
		If menuColumn < lowerLimit Then menuColumn = upperLimit - 1
		If menuColumn = upperLimit Then menuColumn = lowerLimit
	End
	
	
	Method AllIndexMenu:Void(upperLimit:Int, lowerLimit:Int = 0)
		If NinInput.IsHit(N_UP) Then menuIndex -= 1 '; PlaySound(menuSelect)
		If NinInput.IsHit(N_DOWN) Then menuIndex += 1 '; PlaySound(menuSelect)
		If NinInput.IsHit(N_LEFT) Then menuIndex -= 1 '; PlaySound(menuSelect)
		If NinInput.IsHit(N_RIGHT) Then menuIndex += 1 '; PlaySound(menuSelect)
		
		If menuIndex < lowerLimit Then menuIndex = upperLimit - 1
		If menuIndex = upperLimit Then menuIndex = lowerLimit
	End
	
	Field menuIndex:Int = 0
	Field menuColumn:Int = 0
End