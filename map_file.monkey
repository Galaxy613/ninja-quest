Strict
Import engine

Global currentMap:GameMap = Null

Class GameMap
	Field locations:List<map_point> = New List<map_point>()
	Field location_array:map_point[]
	
	Method Setup_Wizard:Void()
		
		locations.AddLast New map_point(44, 99, "Ninja Village")
		locations.AddLast New map_point(68, 83, "Danger Forest")
		locations.AddLast New map_point(50, 79, "Crazy Mines")
		locations.AddLast New map_point(41, 58, "Wall City")
		locations.AddLast New map_point(52, 41, "Windy Plains")
		locations.AddLast New map_point(75, 50, "Smelly Marshes")
		locations.AddLast New map_point(87, 29, "Mountaingrad")
		locations.AddLast New map_point(95, 57, "Krugdor")
		locations.AddLast New map_point(122, 36, "The Tower")
		location_array = locations.ToArray()
		
		Print location_array[0].x + ", " + location_array[0].y + ", " + location_array[0].name
	End
End

Class map_point
	Field x:Int, y:Int, name:String
	Field status:StringMap<String> = New StringMap<String>()
	
	Method New(xx:Int, yy:Int, nn:String)
		x = xx
		y = yy
		name = nn
	End
End