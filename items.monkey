Import engine

Class DItem Extends TAttributes
	Const TYPE_EQUIP:Int = 0, TYPE_USABLE:Int = 1, TYPE_QUEST:Int = 2
	Const ITEM_SCARF:Int = 1, ITEM_BOMBS:Int = 2, ITEM_CAP:Int = 3, ITEM_CLOAK:Int = 4, ITEM_LONGSWORD:Int = 5
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
			Case ITEM_SCARF
				item.Set("Ninja Scarf", id, 50)
				item.AddBuff("attack", 1)
			Case ITEM_BOMBS
				item.Set("Smoke Bombs", id, 150)
				item.AddBuff("evasion", 25)
			Case ITEM_CAP
				item.Set("Sage Cap", id, 100)
				item.AddBuff("knowledge", 1)
			Case ITEM_CLOAK
				item.Set("Shadow Cloak", id, 150)
				item.AddBuff("evasion", 15)
				item.AddBuff("luck", 1)
				item.AddBuff("endurance", -1)
				item.AddWeakness("fire", 1)
			Case ITEM_LONGSWORD
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