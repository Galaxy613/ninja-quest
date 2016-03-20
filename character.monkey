''' TAttributes - 
''' CharacterData - 
''' BuffData - Stores temporary buffs and debuffs during combat.
''' MonsterData - 
Import mojo
Import gui
Import saveandload
Import items

Class TAttributes
	Field Buffs:List<DBuff> = New List<DBuff>()
	Field Weaknesses:StringMap<String> = New StringMap<String>()
	
	Field Name:String
	
	'''''''''
	
	Method AddBuff:Void(buffStr:String, amt:Int, length:Int = 1, override:Bool = True)
		buffStr = buffStr.ToLower()
		Print "Adding a " + buffStr + " buff to " + Name
		If override Then
			For Local buff:DBuff = EachIn Buffs
				If buffStr = buff.type Then
					buff.amt = amt
					buff.turnsLeft = length
					Return
				End
			Next
		End
		Buffs.AddLast(New DBuff(buffStr, amt, length))
		Print "Buff Count: " + Buffs.Count()
	End
	
	Method AddWeakness:Bool(skillName:String, amt:Int = 1)
		skillName = skillName.ToLower()
		Weaknesses.Add(skillName, amt)
		Return True
	End
	
	Method GetWeakness:Int(spellType:String)
		If Not Weaknesses.Contains(spellType.ToLower()) Then Return 0
		Return Int(Weaknesses.Get(spellType.ToLower()))
	End
End

Class DCharacter Extends TAttributes
	Field XP:Int, Level:Int, XPNextLevel:Int, LvlUp:Bool = False
	Field Strength:Int, Endurance:Int, Knowledge:Int, Luck:Int
	Field StrengthBuffed:Int, EnduranceBuffed:Int, KnowledgeBuffed:Int, LuckBuffed:Int, AtkBuffed:Int
	Field accessory:DItem = Null
	
	Field Skills:StringMap<String> = New StringMap<String>()
	
	Field HP:Int, maxHP:Int, evasion:Int
	
	Field x:Int, y:Int
	Field img:Image, imgName:String, frame:Int = 0
	
	Method SaveStringJSON:JSONObject()
		Local save:JSONObject = New JSONObject()
		save.AddPrim("name", Name)
		save.AddPrim("xp", XP)
		save.AddPrim("level", Level)
		save.AddPrim("xpnext", XPNextLevel)
		save.AddPrim("str", Strength)
		save.AddPrim("end", Endurance)
		save.AddPrim("kno", Knowledge)
		save.AddPrim("luc", Luck)
		save.AddPrim("hp", HP)
		save.AddPrim("imgname", imgName)
		save.AddPrim("frame", frame)
		If accessory <> Null Then save.AddPrim("accid", accessory.id)
		
		save.AddPrim("skills", SaveStringMap(Skills))
		save.AddPrim("weaknesses", SaveStringMap(Weaknesses))
		Return save
	End
	
	Method LoadStringJSON(save:JSONObject)
		Clear()
		NLog "PC: " + save
		'save.AddPrim("name", Name)
		Name = save.GetItem("name", "")
		'save.AddPrim("xp", XP)
		XP = save.GetItem("xp", 0)
		'save.AddPrim("level", Level)
		Level = save.GetItem("level", 0)
		'save.AddPrim("xpnext", XPNextLevel)
		XPNextLevel = save.GetItem("xpnext", 0)
		'save.AddPrim("str", Strength)
		Strength = save.GetItem("str", 0)
		'save.AddPrim("end", Endurance)
		Endurance = save.GetItem("end", 0)
		'save.AddPrim("kno", Knowledge)
		Knowledge = save.GetItem("kno", 0)
		'save.AddPrim("luc", Luck)
		Luck = save.GetItem("luc", 0)
		HP = save.GetItem("hp", 0)
		'save.AddPrim("imgname", imgName)
		imgName = save.GetItem("imgname", "")
		'save.AddPrim("frame", frame)
		frame = save.GetItem("frame", 0)
		'save.AddPrim("accid", accessory.id)
		If save.Contains("accid") Then accessory = DItem.Generate(0, save.GetItem("accid", 0))
		
		'save.AddPrim("skills", SaveStringMap(Skills))
		LoadStringMap(Skills, save.GetItem("skills", ""))
		'save.AddPrim("weaknesses", SaveStringMap(Weaknesses))
		LoadStringMap(Weaknesses, save.GetItem("weaknesses", ""))
		
		CalculateBuffs()
		Return save
	End
	
	Method SaveString:String()
		Local save:String = ""
		save += Name + "|"
		save += XP + "|"
		save += Level + "|"
		save += XPNextLevel + "|"
		save += Strength + "|"
		save += Endurance + "|"
		save += Knowledge + "|"
		save += Luck + "|"
		save += imgName + "|"
		save += frame + "|"
		save += accessory.id + "|"
		save += SaveStringMap(Skills) + "|"
		save += SaveStringMap(Weaknesses) + "|"
	End
	
	Method LoadString(save:String)
		Local saveArray:String[] = save.Split("|"), index:Int = 0
		
		Clear()
		
		Name = saveArray[index]; index += 1
		XP = Int(saveArray[index]); index += 1
		Level = Int(saveArray[index]); index += 1
		XPNextLevel = Int(saveArray[index]); index += 1
		Strength = Int(saveArray[index]); index += 1
		Endurance = Int(saveArray[index]); index += 1
		Knowledge = Int(saveArray[index]); index += 1
		Luck = Int(saveArray[index]); index += 1
		Name = saveArray[index]; index += 1
		frame = Int(saveArray[index]); index += 1
		
		accessory = DItem.Generate(Int(saveArray[index]));
		index += 1
		
		LoadStringMap(Skills, saveArray[index]); index += 1
		LoadStringMap(Weaknesses, saveArray[index]); index += 1
		CalculateBuffs()
	End
	
	Method New(level:Int)
		Clear()
		If level > 0 Then InitLevel(level)
	End
	
	Method Clear:Void()
		Name = ""
		XP = 0
		Level = 0
		XPNextLevel = 0
		Strength = 0
		Endurance = 0
		Knowledge = 0
		Buffs.Clear()
		Skills.Clear()
		Weaknesses.Clear()
		HP = 0
		x = 0
		y = 0
		img = Null
		frame = 0
		CalculateBuffs()
	End
	
	Method GetStats:String()
		CalculateBuffs()
		Return Name + " " + HP + "/" + maxHP + " Lvl" + Level + " S" + StrengthBuffed + " E" + EnduranceBuffed + " K" + KnowledgeBuffed + " L" + LuckBuffed + " B" + Buffs.Count()
	End
	
	Method Draw:Void(xx:Int, yy:Int, drawXP:Bool = False)
		GHealthDrawer.Draw(xx - 4, yy, Float(HP) / maxHP, img.Height + 2)
		If drawXP Then
			If HP = 0 Then
				GDrawTextPreserveBlend("K.O.", xx + 24 + 4, yy + 4)
			Else
				If LvlUp Then
					GDrawTextPreserveBlend("LEVEL UP!", xx + 24 + 4, yy + 4)
				Else
					GDrawTextPreserveBlend(XPNextLevel + "xp left", xx + 24 + 4, yy + 4)
				End
			End
		End
		If HP = 0 Then
			DrawImage(img, xx, yy + img.Width, 90, 1, 1, frame)
		Else
			DrawImage(img, xx, yy, frame)
		End
	End
	
	Method Draw:Void(drawXP:Bool = False)
		Draw(x, y, drawXP)
	End
	
	Method SetPosition:Void(xx:Int, yy:Int)
		x = xx
		y = yy
	End
	
	Method InitStats:Void(archetype:Int, median:Int = 5, edge:Int = 1)
		Select archetype
			Case 1
				Strength = median + edge
				Endurance = median - (edge / 2)
				Knowledge = median - edge
				Luck = median - (edge / 3)
			Case 2
				Strength = median - (edge / 3)
				Endurance = median + edge
				Knowledge = median - (edge / 2)
				Luck = median - edge
			Case 3
				Strength = median - edge
				Endurance = median - (edge / 2)
				Knowledge = median + edge
				Luck = median - (edge / 3)
			Case 4
				Strength = median - (edge/2)
				Endurance = median - edge
				Knowledge = median - (edge / 3)
				Luck = median + edge
			Default
				Strength = median
				Endurance = median
				Knowledge = median - (edge / 2)
				Luck = median - (edge / 3)
		End
	End
	
	Method InitLevel:Void(lvl = 1, nme:String = "")
		If Strength = 0 Then
			InitStats(-1)
		End
		UpdateBuffs()
		HP = maxHP
		Name = nme
		
		Level = 0
		XPNextLevel = Pow(lvl, 2) / 4 * 100
		XP = 0
		If lvl > 1 Then
			For Local i = 1 To lvl
				LevelUp(True)
			Next
		End
	End
	
	Method LevelToLevel:Void(lvl%)
		If lvl > Level Then
			For Local i = Level + 1 To lvl
				LevelUp(True)
			Next
		End
	End
	
	Method InitRandomLevel:Void(nme:String, lvl = 1)
		Strength = Rnd(lvl, lvl * 3)
		Endurance = Rnd(lvl, lvl * 3)
		Knowledge = Rnd(lvl, lvl * 3)
		Luck = Rnd(lvl, lvl * 3)
		UpdateBuffs()
		HP = maxHP
		Name = nme
		
		Level = lvl
		XPNextLevel = Pow(lvl, 2) / 4 * 25'100
	End
	
	Method AddXP:Void(xpGained:Int)
		NLog Name + " gained " + xpGained
		XPNextLevel -= xpGained
		XP += xpGained
		If XPNextLevel < 0 Then
			xpGained = Abs(XPNextLevel)
			LevelUp()
			AddXP(xpGained)
		End
	End
	
	Method CalcXPWorth:Int()
		Return Strength*2 + Endurance*5 + Knowledge*2 + Luck*2 + (Skills.Count() * 10)
	End
	
	Method PickAttributeIncrease:Void(index:Int, increase:Int = 1, mute:Bool = False)
		Select index Mod 4
			Case 0
				Strength += increase
				If Not mute Then GMessageTicker.Add(Name + " has gained " + (increase) + " str!")
			Case 1
				Endurance += increase
				If Not mute Then GMessageTicker.Add(Name + " has gained " + (increase) + " end!")
			Case 2
				Knowledge += increase
				If Not mute Then GMessageTicker.Add(Name + " has gained " + (increase) + " knw!")
			Case 3
				Luck += increase
				If Not mute Then GMessageTicker.Add(Name + " has gained " + (increase) + " luck!")
		End
	End
	
	Method LevelUp:Void(mute:Bool = False)
		Local lvl:Int = Level + 1
		
		If Not mute Then GMessageTicker.Add(Name + " has leveled up!")
		
		If (lvl Mod 2) = 0 Then
			PickAttributeIncrease(lvl + Name.Length, 1, mute)
		Else
			PickAttributeIncrease(lvl + Name.Length, 1, mute)
			PickAttributeIncrease(lvl + 3 + Name.Length, 1, mute)
		End
		
		CalculateBuffs()
		HP = maxHP
		
		Level = lvl
		If XP < XPNextLevel Then XP += XPNextLevel
		XPNextLevel = (lvl * 25) + (Strength * 5 + Endurance * 3 + Knowledge * 10 + Luck)
		LvlUp = True
	End
	
	Method CalculateBuffs:Void() '' Can be called anytime
		StrengthBuffed = Strength
		EnduranceBuffed = Endurance
		KnowledgeBuffed = Knowledge
		LuckBuffed = Luck
		AtkBuffed = 0
		evasion = 5
		
		'NLog "Calcing " + Name + "'s Buffs: " + Buffs.Count()
		For Local tmp:DBuff = EachIn Buffs
			NLog "Checking... " + (tmp.type.ToLower()[ .. 3])
			Select(tmp.type.ToLower()[ .. 3])
				Case "str"
					StrengthBuffed += tmp.amt
				Case "end"
					EnduranceBuffed += tmp.amt
				Case "kno"
					KnowledgeBuffed += tmp.amt
				Case "luc"
					LuckBuffed += tmp.amt
				Case "eva"
					evasion += tmp.amt
				Case "att"
					AtkBuffed += tmp.amt
				Default
			End
		Next
		If accessory <> Null
			For Local tmp:DBuff = EachIn accessory.Buffs
				Select(tmp.type.ToLower())[ .. 3]
					Case "str"
						StrengthBuffed += tmp.amt
					Case "end"
						EnduranceBuffed += tmp.amt
					Case "kno"
						KnowledgeBuffed += tmp.amt
					Case "luc"
						LuckBuffed += tmp.amt
					Case "eva"
						evasion += tmp.amt
					Case "att"
						AtkBuffed += tmp.amt
					Default
				End
			Next
		End
		
		If StrengthBuffed < 1 Then StrengthBuffed = 1
		If EnduranceBuffed < 1 Then EnduranceBuffed = 1
		If KnowledgeBuffed < 1 Then KnowledgeBuffed = 1
		If LuckBuffed < 1 Then LuckBuffed = 1
		evasion += LuckBuffed / 4
		If evasion < 1 Then evasion = 1
		
		maxHP = (EnduranceBuffed * 5) + Level
	End
	
	Method UpdateBuffs:Void() '' CALLED ONLY ONCE PER GAME ROUND
		For Local tmp:DBuff = EachIn Buffs
			If tmp.turnsLeft > 0 Then tmp.turnsLeft -= 1
			If tmp.turnsLeft = 0 Then
				Buffs.RemoveEach(tmp)
				GMessageTicker.Add(Name + "'s " + tmp.type.ToUpper() + " buff ended")
			End
		Next
		CalculateBuffs()
	End
	
'	Method HasBuff:Bool(buffStr:String)
'		buffStr = buffStr.ToLower()
'		For Local buffName:String = EachIn Buffs
'			If buffStr = buffName Then
'				Return True
'			End
'		Next
'		Return False
'	End
	
	Method HasSkill:Bool(skillName:String)
		skillName = skillName.ToLower()
		For Local skill:String = EachIn Skills.Keys()
			If skill.ToLower() = skillName Then Return True
		Next
		Return False
	End
	
	Method AddSkill:Bool(skillName:String)
		If HasSkill(skillName) Then Return
		Skills.Add(skillName, "")
	End
	
	Method Fight:Int(bound:Int = 0)
		Local attack:Int = ( (StrengthBuffed) / 2) + Level + AtkBuffed / 2
		Local max:Int = (StrengthBuffed + LuckBuffed) + (Level * 2) + AtkBuffed
		
		If bound < 0 Then Return attack
		If bound > 0 Then Return max
		
		attack = Rnd(attack, max)
		
		Return attack
	End
	
	Method IsWeak:Int(spellType:String)
		spellType = spellType.ToLower()
		If accessory Then Return GetWeakness(spellType) + accessory.GetWeakness(spellType)
		Return GetWeakness(spellType)
	End
End

Class DBuff
	Field type:String = ""
	Field amt:Int = 0
	Field turnsLeft:Int = -1
	
	Method New(t:String, a:Int, tl:Int = 1)
		type = t
		amt = a
		turnsLeft = tl
	End
End

Class DMonster Extends DCharacter
	Method Draw:Void(xp:Bool = False)
		Super.Draw(xp)
	End
	
	Method Draw:Void(xx:Int, yy:Int, xp:Bool)
		GHealthDrawer.Draw(xx + img.Width + 4, yy, Float(HP) / maxHP, img.Height + 2)
		If HP = 0 Then
			DrawImage(img, xx, yy + img.Width, 90, 1, 1, frame)
		Else
			DrawImage(img, xx, yy, frame)
		End
	End
End