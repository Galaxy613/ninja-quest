Import mojo
''' GClearScreen -- Helps maintain the background color.
''' GRect -- Basic rectangle data function
''' GButton -- Basic rectangle button.
''' GWindowDrawer -- A convient wrapper that handles drawing the edges of a window.
''' GHealthDrawer --A convient wrapper that handles drawing vertical health bars.
''' GEffect --
''' GMessageTicker -- A globally available way to display information during combat or the map screen.

	Global lWidth:Int = 0
	Global g_scale:Float = 1.0, g_x_offset:Int = 0
	
	Function GDrawTextPreserveBlend:Void(txt:String, x:Int, y:Int)
		Local tmp:Int = GetBlend()
		SetBlend AlphaBlend
		DrawText txt, x, y
		SetBlend tmp
	End

Function BoolToString:String(var:Bool)
	If var Then Return "True"
	Return "False"
End
	
Class GClearScreen
	Global Red = 110, Green = 167, Blue = 92
	
	Function ClearScreen:Void()
		Cls Red, Green, Blue
	End
	
	Function ResetColors:Void()
		Red = 110
		Green = 167
		Blue = 92
	End
	
	Function ToGrey:Void()
		SetColor Red / 2, Green / 2, Blue / 2
	End
	
	Function ToBG:Void()
		SetColor Red, Green, Blue
	End
End

Class GRect
	Field x:Int, y:Int, w:Int, h:Int
	
	Method New(xx:Int, yy:Int, ww:Int, hh:Int)
		x = xx
		y = yy
		w = ww
		h = hh
	End
	
	Method Set:Void(xx:Int, yy:Int)
		x = xx
		y = yy
	End
	
	Method Set:Void(xx:Int, yy:Int, ww:Int, hh:Int)
		x = xx
		y = yy
		w = ww
		h = hh
	End
End

Class GButton Extends GRect
	Field isDown:Bool = False, isHover:Bool = False, isHit:Bool = False, text:String = "", justify:Int = 0
	Field nominalDown:Bool = False
	
	Method New(xx:Int, yy:Int, ww:Int, hh:Int)
		x = xx
		y = yy
		w = ww
		h = hh
	End
	
	Method Draw:Void()
		If isDown Then
			GClearScreen.ToGrey
			DrawRect x, y, w, h
			SetColor 255, 255, 255
		End
		GWindowDrawer.Draw(x, y, w, h)
		If justify < 0 Then
			GDrawTextPreserveBlend(text, x + 3, y + (h / 2) - 4)
		ElseIf justify > 0
			GDrawTextPreserveBlend(text, x - (text.Length * 6) - 3, y + (h / 2) - 4)
		Else
			GDrawTextPreserveBlend(text, x + ( (w / 2) - (text.Length * 3)), y + (h / 2) - 4)
		End
	End
	
	Method Update:Void()
		isHit = False
		isHover = False
		nominalDown = False
		
		For Local count:Int = 0 To 5
			Check(count)
		Next
		
	'	If isDown And Not isHover Then isDown = False
		If Not nominalDown Then isDown = False
	End
	
	Method Check:Void(input:Int)
		If TouchX(input) / g_scale < x Then Return
		If TouchX(input) / g_scale > x + w Then Return
		If TouchY(input) / g_scale < y Then Return
		If TouchY(input) / g_scale > y + h Then Return
		
		isHover = True
		If TouchDown(input) Then '' Using this instead of this AND TouchHit, this MAY mean there could be a one cycle lag... hopefully not.
			If isDown = False Then isHit = True
			isDown = True
			nominalDown = True
		End
	End
End

Class GWindowDrawer
	Global __Image:Image
	
	Function Init:Void(img:Image)
		__Image = img
	End
	
	Function Init:Void(img:String, width:Int, height:Int, frames:Int)
		__Image = LoadImage(img, width, height, frames)
	End
	
	Function Draw:Void(x:Int, y:Int, w:Int, h:Int)
		If __Image = Null Then Return
		
		GClearScreen.ToBG
		DrawRect x, y, w, h
		SetColor 255, 255, 255
		
		'Edges
		DrawImage(__Image, x, y, 0)
		DrawImage(__Image, x + w - 4, y, 2)
		DrawImage(__Image, x + w - 4, y + h - 4, 4)
		DrawImage(__Image, x, y + h - 4, 6)
		
		'Borders
		DrawImage(__Image, x + 4, y, 0, (w / 4.0) - 2, 1.0, 1)
		DrawImage(__Image, x + 4, y + h - 4, 0, (w / 4.0) - 2, 1.0, 5)
		
		DrawImage(__Image, x + w - 4, y + 4, 0, 1, (h / 4.0) - 2, 3)
		DrawImage(__Image, x, y + 4, 0, 1, (h / 4.0) - 2, 7)
		
		GClearScreen.ToBG
	End
End

Class GHealthDrawer
	Global __Image:Image
	
	Function Init:Void(img:Image)
		__Image = img
	End
	
	Function Init:Void(img:String, width:Int, height:Int, frames:Int)
		__Image = LoadImage(img, width, height, frames)
	End
	
	Function Draw:Void(x:Int, y:Int, perc:Float, h:Int)
		If __Image = Null Then Return
		If h < 6 Then h = 6
		
		'Edges
		DrawImage(__Image, x, y, 0)
		DrawImage(__Image, x, y + h - 2, 1)
		
		'Middle
		DrawImage(__Image, x, y + h - 2, 0, 1, -perc * (h - 4) / 2, 2)
		
	End
End

Class GEffect
	Global effectList:List<GEffect> = New List<GEffect>()
	
	Function DrawAll()
		For Local eft:GEffect = EachIn effectList
			eft.Draw()
		Next
	End
	
	Function UpdateAll()
		For Local eft:GEffect = EachIn effectList
			eft.Update()
		Next
	End
	
	Function Create:GEffect(img:Image, x:Int, y:Int, speed:Int = 250)
		Local eft:GEffect = New GEffect
		eft.speed = speed
		eft.img = img
		eft.x = x
		eft.y = y
		effectList.AddLast(eft)
		Return eft
	End
	
	''''
	''''
	Field x:Int, y:Int, img:Image, frame:Int = 0, lastMS:Int, speed:Int = 250
	
	Method Update:Void()
		If Not img Then effectList.RemoveEach(Self); Return
		
		If Millisecs() > lastMS Then
			lastMS = Millisecs() +speed
			frame += 1
			If frame = img.Frames() Then effectList.RemoveEach(Self)
		End
	End
	
	Method Draw:Void()
		If Not img Then Return
		
		DrawImage(img, x, y, frame)
	End
End

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Class GMessageTicker
	Global curMsg:String = "", lastMsgMs:Int = 0, msgSpeed:Int = 140'80
	Global msgList:List<String> = New List<String>()
	
	Function Set:Void(newMessage:String = "")
		curMsg = newMessage
	End
	
	Function isBlank:Bool()
		If curMsg = "" Then Return True
		Return False
	End
	
	Function Add:Void(msg:String)
		If msg.Length > 25 Then
			Print "[" + msg[ .. 24] + "..]"
			msgList.AddLast(msg[ .. 24] + "~~")
			Add(msg[24 ..])
		Else
			Print "[" + msg + "]"
			msgList.AddLast(msg)
		End
	End
	
	Function Update:Void()
	'	If KeyDown(KEY_H) Then Print "UpdateMsg() "
		If lastMsgMs = -1 Then Return
	'	If KeyDown(KEY_H) Then Print "UpdateMsg() Not neg"
		If Millisecs() > lastMsgMs Then
			Skip
		End
	End
	
	Function Skip:Void()
		If lastMsgMs = -1 Then Return
		If msgList.Count() = 0 and curMsg <> "" Then
			lastMsgMs = 0
			curMsg = ""
		ElseIf msgList.Count() > 0
			curMsg = msgList.RemoveFirst()
			lastMsgMs = (curMsg.Length * msgSpeed)
			If lastMsgMs < msgSpeed * 10 Then lastMsgMs = msgSpeed * 10
			lastMsgMs = Millisecs() +lastMsgMs
		End
	End
	
	Function Draw:Void()
		If curMsg <> "" Then
			'GWindowDrawer.Draw(80 - (curMsg.Length * 3) - 4, -4, (curMsg.Length * 6) + 8, 16)
			GWindowDrawer.Draw(-4, -4, 164, 16)
			GDrawTextPreserveBlend(curMsg, 80 - (curMsg.Length * 3), 0)
		End
	End
End