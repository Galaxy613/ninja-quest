Strict
#Rem
	Engine
	
	This file is to make OOP designers cry. This is the glue and global functions
	that everything requires to run.
	
	Takes care of the generic game classes and the current game state.
#END
''' TScreen - Formerly NinScreen - Template for screens.
''' DBoundingBox - A class for maps to easily store zones where stuff can happen.
Import mojo
Import json.json
Import gui
Import character
Import monsters
Import input
Import lang
'Import saveandload

''' TODO: Move ALL of this into NinjaQuest which extends T_Game.

Global vScnWidth:Float = 160.0, vScnHeight:Float = 144.0 ''' Virtual screen size.

Global currentScreen:TScreen, lastScreen:TScreen
	Global combatScreen:TScreen = Null
	Global characterScreen:TScreen = Null
	Global townMapScreen:TScreen = Null
	Global titleScreen:TScreen = Null
	Global chatScreen:TScreen = Null

Global imageMap:StringMap<Image> = New StringMap<Image>()
Global game:TGame

Global ninja:DCharacter
Global archer:DCharacter
Global sage:DCharacter
Global warrior:DCharacter
Global playerCharacters:List<DCharacter> = New List<DCharacter>()
Global playerItems:List<DItem> = New List<DItem>()

Global playerGold:Int = 0, currentLocation:Int = 0, lastTown:Int = 128
Global gameTriggers:StringMap<String> = New StringMap<String>()

Global hasGoneNuclear:Bool = False, nukeMessage:String = ""

Function Reset:Void()
	playerGold = 0
	currentLocation = 0
	lastTown = 128 ''' TODO: Check if this is depcrecated by just saving the X and Y coordinates.
	gameTriggers.Clear()
	playerCharacters.Clear()
End

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Function SwitchScreenTo:Void(newScn:TScreen, autoInit:Bool = True)
''' Switches to next screen while also keeping track of last screen and allowing for init to be called.
	lastScreen = currentScreen
	currentScreen = newScn
	If autoInit Then currentScreen.OnInit()
End

Function GoNuclear:Void(msg:String)
''' Creates a fatal error, requires the main loop to check 'hasGoneNuclear'
	hasGoneNuclear = True
	nukeMessage = msg
	Print "[FATAL ERROR] " + nukeMessage
End

Function NLog:Void(msg:String, pri:Int = 0)
''' N stands for Ninja. This is just an improved console outputter to allow for more context.
	If pri = 0 Then
		Print "[NQ] " + msg
	ElseIf pri = 1 Then
		Print "[NQ_WARNING] " + msg
	End
End

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Class TGame
	Method LoadTriggers:Void() Abstract
	Method NewGame:Void() Abstract
End

Class TScreen
	Method OnInit:Int()
		Return 0
	End
	
	Method OnUpdate:Int()
		Return 0
	End
	
	Method OnRender:Int()
		Return 0
	End
	
	Method OnResize:Int()
		'
		Return 0
	End
	
	Method UpDownMenu:Void(upperLimit:Int, lowerLimit:Int = 0)
		If NInput.IsHit(N_UP) Then menuIndex -= 1 '; PlaySound(menuSelect)
		If NInput.IsHit(N_DOWN) Then menuIndex += 1 '; PlaySound(menuSelect)
		
		If menuIndex < lowerLimit Then menuIndex = upperLimit - 1
		If menuIndex = upperLimit Then menuIndex = lowerLimit
	End
	
	Method LeftRightMenu:Void(upperLimit:Int, lowerLimit:Int = 0)
		If NInput.IsHit(N_LEFT) Then menuColumn -= 1 '; PlaySound(menuSelect)
		If NInput.IsHit(N_RIGHT) Then menuColumn += 1 '; PlaySound(menuSelect)
		
		If menuColumn < lowerLimit Then menuColumn = upperLimit - 1
		If menuColumn = upperLimit Then menuColumn = lowerLimit
	End
	
	
	Method AllIndexMenu:Void(upperLimit:Int, lowerLimit:Int = 0)
		If NInput.IsHit(N_UP) Then menuIndex -= 1 '; PlaySound(menuSelect)
		If NInput.IsHit(N_DOWN) Then menuIndex += 1 '; PlaySound(menuSelect)
		If NInput.IsHit(N_LEFT) Then menuIndex -= 1 '; PlaySound(menuSelect)
		If NInput.IsHit(N_RIGHT) Then menuIndex += 1 '; PlaySound(menuSelect)
		
		If menuIndex < lowerLimit Then menuIndex = upperLimit - 1
		If menuIndex = upperLimit Then menuIndex = lowerLimit
	End
	
	Field menuIndex:Int = 0
	Field menuColumn:Int = 0
End

Class DBoundingBox Extends GRect
	Field name:String
End

Function CheckEvent:Void(eN:String, data:String)
	Select eN.ToLower()
		Case "m129"
			'
	End
End

Function ClearActiveEvents:Void() '' Clear map events that are in progress
	For Local i:Int = 0 To 16
		Print("m" + (i + 128) + " = " + gameTriggers.Get("m" + (128 + i)))
		If gameTriggers.Get("m" + (128 + i)) = "1" Then
			gameTriggers.Set("m" + (128 + i), "0")
			Print "Set to 0!"
		End
	Next
End

''' Game Trigger helper Functions
''' Convert 128 to 1
Function ConvertFromSpecialID:Int(ID:Int, type:Int = 0)
	Return (ID - 128 + 1 + (type * 16))
End
''' Convert 1 to 128
Function ConvertToSpecialID:Int(ID:Int, type:Int = 0)
	Return (ID + 128 - 1 + (type * 16))
End