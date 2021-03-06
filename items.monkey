Import engine

Class DItem Extends TAttributes
	Const TYPE_EQUIP:Int = 0, TYPE_USABLE:Int = 1, TYPE_QUEST:Int = 2
	Field type:Int = 0, id:Int, value:Int
'	Field Buffs:List<BuffData> 			= New List<BuffData>()
'	Field Weaknesses:StringMap<String> 	= New StringMap<String>()
	
	Method ItemData(nn:String, ii:Int, vv:Int, tt:Int = 0)
		Set(nn, ii, vv, tt)
	End
	
	Method Set(nn:String, ii:Int, vv:Int, tt:Int = 0)
		Name = nn
		id = ii
		value = vv
		type = tt
	End

	Function Generate:DItem(tt:Int = 0, id:Int = -1)
		Local item:DItem = New DItem()
		Select id
			Case 1
				item.Set("Ninja Scarf", id, 50)
				item.AddBuff("attack", 1)
			Case 2
				item.Set("Smoke Bombs", id, 150)
				item.AddBuff("evasion", 25)
			Case 3
				item.Set("Sage Cap", id, 100)
				item.AddBuff("knowledge", 1)
			Case 4
				item.Set("Shadow Cloak", id, 150)
				item.AddBuff("evasion", 15)
				item.AddBuff("luck", 1)
				item.AddBuff("endurance", -1)
				item.AddWeakness("fire", 1)
			Case 5
				item.Set("Longsword", id, 175)
				item.AddBuff("attack", 5)
				item.AddBuff("luck", -1)
				item.AddWeakness("rock", -1)
			Default
				item = Null
		End
		Return item
	End
End