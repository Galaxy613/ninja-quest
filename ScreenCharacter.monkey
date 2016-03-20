#Rem
	Character Inventory Screen
	
	n/a
	
	Verbs:
		n/a
#END
''' SCharacter - In-game menu screen, do stuff with your characters.
''Private
''' modes - Fake enum
Import engine
Import map_file
Import combat

Class SCharacter Extends TScreen '' Inventory Screen
	
	Method OnInit:Int()
		BackToMenu()
		NLog "ON INIT"
		GMessageTicker.Set("")
		If currentMap = Null Then
			currentMap = New GameMap()
			currentMap.Setup_Wizard()
		End
	End
	
	Method OnUpdate:Int()
		GMessageTicker.Update()
		Select modes.current
			Case modes.menu
				MENU_Update
			Case modes.info
				INFO_Update
			Case modes.skill
				SKILL_Update
			Case modes.equip
				EQUIP_Update
			Case modes.items
				ITEMS_Update
			Case modes.map
				MAP_Update
			Case modes.save
				SAVE_Update
			Case modes.load
				LOAD_Update
			Case modes.quit
				QUIT_Update
		End
	End
	
	Method OnRender:Int()
		Select modes.current
			Case modes.menu
				MENU_Draw
			Case modes.info
				INFO_Draw
			Case modes.skill
				SKILL_Draw
			Case modes.equip
				EQUIP_Draw
			Case modes.items
				ITEMS_Draw
			Case modes.map
				MAP_Draw
			Case modes.save
				SAVE_Draw
			Case modes.load
				LOAD_Draw
			Case modes.quit
				QUIT_Draw
		End
		
		GMessageTicker.Draw
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method BackToMenu:Void()
		modes.current = modes.menu
		
		menuIndex = 0
		menuColumn = 0
	End
	
	Method MENU_Update:Void()
		UpDownMenu(8)
		
		If NInput.IsHit(N_A) Then
			Select menuIndex
				Case 0
					modes.current = modes.info
				Case 1
					modes.current = modes.skill
					SKILL_mode = 0
					menuIndex = 0
					menuColumn = 0
				Case 2
					modes.current = modes.equip
				Case 3
					modes.current = modes.items
				Case 4
					modes.current = modes.map
					menuIndex = currentLocation
				Case 5
					'modes.current = modes.save
					SAVE_Update
				Case 6
					'modes.current = modes.load
					LOAD_Update
				Case 7
					modes.current = modes.quit
			End
			menuIndex = 0
			menuColumn = 0
		End
		If NInput.IsHit(N_B) Then
			SwitchScreenTo lastScreen
		End
	End
	Method MENU_Draw:Void()
		GWindowDrawer.Draw(160 - 42, 0, 42, 144 - 24)
		GWindowDrawer.Draw(0, 144 - 24, 160, 24)
		GDrawTextPreserveBlend("GOLD: " + playerGold, 4, 144 - 8 - 8 - 4)
	'	GDrawTextPreserveBlend("A: Select, B: Back", 4, vScnHeight - 8 - 4)
		
		GDrawTextPreserveBlend(" INFO", 120, 4 + (0 * 8))
		GDrawTextPreserveBlend(" SKILL", 120, 4 + (1 * 8))
		GDrawTextPreserveBlend(" EQUIP", 120, 4 + (2 * 8))
		GDrawTextPreserveBlend(" ITEMS", 120, 4 + (3 * 8))
		GDrawTextPreserveBlend(" MAP", 120, 4 + (4 * 8))
		GDrawTextPreserveBlend(" SAVE", 120, 4 + (5 * 8))
		GDrawTextPreserveBlend(" LOAD", 120, 4 + (6 * 8))
		GDrawTextPreserveBlend(" QUIT", 120, 4 + (7 * 8))
		
		GDrawTextPreserveBlend(">", 120, 4 + (menuIndex * 8))
		
		Local i = 0
		For Local char:DCharacter = EachIn playerCharacters
			char.Draw(2, 4 + (i * 24))
			GDrawTextPreserveBlend(char.Name + " LVL:" + char.Level, 24, 6 + (i * 24))
			GDrawTextPreserveBlend(char.HP + "/" + char.maxHP + "HP", 24, 6 + (i * 24) + 8)
			i += 1
		Next
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method _Update:Void()
		If NInput.IsHit(N_B) Then BackToMenu()
	End
	Method _Draw:Void()
		'
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method INFO_Update:Void()
		If NInput.IsHit(N_B) Then BackToMenu()
		
		UpDownMenu(playerCharacters.Count())
	End
	Method INFO_Draw:Void()
		GWindowDrawer.Draw(0, 32, 160, 144 - 32)
		
		Local i = 0
		For Local char:DCharacter = EachIn playerCharacters
			If i = menuIndex
				char.Draw(2, 4)
				GDrawTextPreserveBlend(char.Name, 28, 6)
				GDrawTextPreserveBlend("LVL:" + char.Level, 24 + 64, 6)
				GDrawTextPreserveBlend(char.HP + "/" + char.maxHP + " HP", 28, 6 + 8)
				GDrawTextPreserveBlend("Next:" + char.XPNextLevel, 24 + 64, 6 + 8)
				
				GDrawTextPreserveBlend("Strength:  " + char.StrengthBuffed, 6, 6 + 8 * 4)
				GDrawTextPreserveBlend("Endurance: " + char.EnduranceBuffed, 6, 6 + 8 * 5)
				GDrawTextPreserveBlend("Knowledge: " + char.KnowledgeBuffed, 6, 6 + 8 * 6)
				GDrawTextPreserveBlend("Luck:      " + char.LuckBuffed, 6, 6 + 8 * 7)
				GDrawTextPreserveBlend("XP: " + char.XP, 6, 6 + 8 * 9) '// Why no XP!?
				
				GDrawTextPreserveBlend("Attack: " + char.Fight(-1) + " - " + char.Fight(1), 6, 6 + 8 * 11)
				
				If char.accessory <> Null Then
					GDrawTextPreserveBlend("Equip: " + char.accessory.Name, 6, 6 + 8 * 12)
				Else
					GDrawTextPreserveBlend("Equip: n/a", 6, 6 + 8 * 12)
				End
				
			End
			i += 1
		Next
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Field SelectedSkill:String = "", curCharData:DCharacter, SKILL_mode:Int = 0, curSkillTxt:String = ""
	
	Method SKILL_Update:Void()
		
		If SKILL_mode = 0 Then
			UpDownMenu(playerCharacters.Count())
			curCharData = playerCharacters.ToArray[menuIndex]
			
			If NInput.IsHit(N_A) Then
				SKILL_mode = 1
				menuColumn = 0
				menuIndex = 0
			End
			If NInput.IsHit(N_B) Then BackToMenu()
		Else
			UpDownMenu(4)
			LeftRightMenu(3)
			
			If NInput.IsHit(N_A) And SelectedSkill.ToUpper() = "HEAL" Then
				For Local char:DCharacter = EachIn playerCharacters
					char.HP = char.maxHP
					'PlaySound MagicSound
				Next
			End
			
			If NInput.IsHit(N_B) Then
				SKILL_mode = 0
				
				Local i:Int = 0
				For Local char:DCharacter = EachIn playerCharacters
					If char = curCharData Then
						menuIndex = i
					End
					i += 1
				Next
			End
		End
	End
	Method SKILL_Draw:Void()
		Local skillY:Int = 12
		GWindowDrawer.Draw(0, skillY, 160, 38 + 4)
		
		curSkillTxt = ""
		SelectedSkill = ""
		
		If Not curCharData Then Return
		
		If SKILL_mode = 1 Then
			GDrawTextPreserveBlend(">", 2 + (50 * menuColumn), skillY + 4 + (menuIndex * 8))
			GDrawTextPreserveBlend(curCharData.Name, 2, 2)
		'	GDrawTextPreserveBlend("B: Back", 2, vScnHeight - 8)
		Else
	'		GDrawTextPreserveBlend(">", 2 + (50 * 0), skillY + 4 + (0 * 8))
			GDrawTextPreserveBlend(">" + curCharData.Name, 2, 2)
		'	GDrawTextPreserveBlend("A: Select, B: Back", 2, vScnHeight - 8)
		End
		
		GDrawTextPreserveBlend("LVL: " + curCharData.Level, 2 + 64, 2)
		
		__SKILLS(skillY)
		If SKILL_mode = 0 Then
			GDrawTextPreserveBlend("Select Character", 2, skillY + 38 + 6)
		Else
			Local tmp:Int = 0
			
			GDrawTextPreserveBlend(curSkillTxt, 2, skillY + 38 + 6)
			
			Select SelectedSkill.ToLower()
				''''
				'' BUFFS
				Case "smoke"
					GDrawTextPreserveBlend("Power: " + GetSpellPower(SelectedSkill, Null, curCharData, True), 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Duration: " + GetSpellDuration(SelectedSkill, curCharData), 6, skillY + 38 + 6 + 16)
				Case "ensnare"
					GDrawTextPreserveBlend("Power: " + GetSpellPower(SelectedSkill, Null, curCharData, True), 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Duration: " + GetSpellDuration(SelectedSkill, curCharData), 6, skillY + 38 + 6 + 16)
				Case "focus"
					GDrawTextPreserveBlend("Power: " + GetSpellPower(SelectedSkill, Null, curCharData, True), 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Duration: " + GetSpellDuration(SelectedSkill, curCharData), 6, skillY + 38 + 6 + 16)
				Case "terror"
					GDrawTextPreserveBlend("Power: " + GetSpellPower(SelectedSkill, Null, curCharData, True), 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Duration: " + GetSpellDuration(SelectedSkill, curCharData), 6, skillY + 38 + 6 + 16)
					
				Case "boost"
					GDrawTextPreserveBlend("Power: " + GetSpellPower(SelectedSkill, Null, curCharData, True), 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Duration: " + GetSpellDuration(SelectedSkill, curCharData), 6, skillY + 38 + 6 + 16)
				Case "posion"
					GDrawTextPreserveBlend("Power: " + GetSpellPower(SelectedSkill, Null, curCharData, True), 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Duration: " + GetSpellDuration(SelectedSkill, curCharData), 6, skillY + 38 + 6 + 16)
					
					
				''''
				'' ATTACKS
				Case "heal"
					GDrawTextPreserveBlend("Power: " + GetSpellPower(SelectedSkill, Null, curCharData, True), 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Duration: n/a", 6, skillY + 38 + 6 + 16)
					GDrawTextPreserveBlend("Press A to heal your party", 2, skillY + 38 + 6 + (8 * 3))
				Case "cure"
					GDrawTextPreserveBlend("Power: n/a", 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Duration: n/a", 6, skillY + 38 + 6 + 16)
					
				Case "aero"
					tmp = GetSpellPower(SelectedSkill, Null, curCharData, True)
					'GDrawTextPreserveBlend("Power: " + tmp, 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Power: " + (tmp - (curCharData.LuckBuffed / 3)) + "-" + tmp, 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Duration: n/a", 6, skillY + 38 + 6 + 16)
					GDrawTextPreserveBlend(" vs. Weak: " + (tmp * 2), 6, skillY + 38 + 6 + (8 * 3))
					GDrawTextPreserveBlend(" vs. Strong: " + (tmp / 2), 6, skillY + 38 + 6 + (8 * 4))
					
				Case "fire"
					tmp = GetSpellPower(SelectedSkill, Null, curCharData, True)
					'GDrawTextPreserveBlend("Power: " + tmp, 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Power: " + (tmp - (curCharData.LuckBuffed / 3)) + "-" + tmp, 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Duration: n/a", 6, skillY + 38 + 6 + 16)
					GDrawTextPreserveBlend(" vs. Weak: " + (tmp * 2), 6, skillY + 38 + 6 + (8 * 3))
					GDrawTextPreserveBlend(" vs. Strong: " + (tmp / 2), 6, skillY + 38 + 6 + (8 * 4))
					
				Case "ice"
					tmp = GetSpellPower(SelectedSkill, Null, curCharData, True)
					'GDrawTextPreserveBlend("Power: " + tmp, 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Power: " + (tmp - (curCharData.LuckBuffed / 3)) + "-" + tmp, 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Duration: n/a", 6, skillY + 38 + 6 + 16)
					GDrawTextPreserveBlend(" vs. Weak: " + (tmp * 2), 6, skillY + 38 + 6 + (8 * 3))
					GDrawTextPreserveBlend(" vs. Strong: " + (tmp / 2), 6, skillY + 38 + 6 + (8 * 4))
					
				Case "rock"
					tmp = GetSpellPower(SelectedSkill, Null, curCharData, True)
					'GDrawTextPreserveBlend("Power: " + tmp, 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Power: " + (tmp - (curCharData.LuckBuffed / 3)) + "-" + tmp, 6, skillY + 38 + 6 + 8)
					GDrawTextPreserveBlend("Duration: n/a", 6, skillY + 38 + 6 + 16)
					GDrawTextPreserveBlend(" vs. Weak: " + (tmp * 2), 6, skillY + 38 + 6 + (8 * 3))
					GDrawTextPreserveBlend(" vs. Strong: " + (tmp / 2), 6, skillY + 38 + 6 + (8 * 4))
					
				Default
					GDrawTextPreserveBlend("Select Skill", 2, skillY + 38 + 6)
			End
		End
	End
	
	Method __SKILLS:Void(skillY:Int = 0)
		
		If SKILL_mode = 0 Then SetAlpha 0.5
		
		If curCharData.Skills.Contains("fire") Then
			GDrawTextPreserveBlend("FIRE", 8 + (50 * 0), skillY + 4 + (0 * 8))
			If menuColumn = 0 And menuIndex = 0 Then curSkillTxt = "Does Fire Damage"; SelectedSkill = "fire"
		End
		If curCharData.Skills.Contains("ensnare") Then
			GDrawTextPreserveBlend("ENSNARE", 8 + (50 * 1), skillY + 4 + (0 * 8))
			If menuColumn = 1 And menuIndex = 0 Then curSkillTxt = "Lowers Enemy Evasion"; SelectedSkill = "ensnare"
		End
		If curCharData.Skills.Contains("smoke") Then
			GDrawTextPreserveBlend("SMOKE", 8 + (50 * 2), skillY + 4 + (0 * 8))
			If menuColumn = 2 And menuIndex = 0 Then curSkillTxt = "Raises Target Evasion"; SelectedSkill = "smoke"
		End
		'''''''''''''''''''''''''
		If curCharData.Skills.Contains("ice") Then
			GDrawTextPreserveBlend("ICE", 8 + (50 * 0), skillY + 4 + (1 * 8))
			If menuColumn = 0 And menuIndex = 1 Then curSkillTxt = "Does Ice Damage"; SelectedSkill = "ice"
		End
		If curCharData.Skills.Contains("terror") Then
			GDrawTextPreserveBlend("TERROR", 8 + (50 * 1), skillY + 4 + (1 * 8))
			If menuColumn = 1 And menuIndex = 1 Then curSkillTxt = "Lowers Enemy Luck"; SelectedSkill = "terror"
		End
		If curCharData.Skills.Contains("boost") Then
			GDrawTextPreserveBlend("BOOST", 8 + (50 * 2), skillY + 4 + (1 * 8))
			If menuColumn = 2 And menuIndex = 1 Then curSkillTxt = "Raises Target Strength"; SelectedSkill = "boost"
		End
		'''''''''''''''''''''''''
		If curCharData.Skills.Contains("aero") Then
			GDrawTextPreserveBlend("AERO1", 8 + (50 * 0), skillY + 4 + (2 * 8))
			If menuColumn = 0 And menuIndex = 2 Then curSkillTxt = "Does Aero Damage"; SelectedSkill = "aero"
		End
		If curCharData.Skills.Contains("cure") Then
			GDrawTextPreserveBlend("CURE", 8 + (50 * 1), skillY + 4 + (2 * 8))
			If menuColumn = 1 And menuIndex = 2 Then curSkillTxt = "Cures Target debuffs"; SelectedSkill = "cure"
		End
		If curCharData.Skills.Contains("poison") Then
			GDrawTextPreserveBlend("POISON", 8 + (50 * 2), skillY + 4 + (2 * 8))
			If menuColumn = 2 And menuIndex = 2 Then curSkillTxt = "Lowers Enemy Strength"; SelectedSkill = "posion"
		End
		'''''''''''''''''''''''''
		If curCharData.Skills.Contains("rock") Then
			GDrawTextPreserveBlend("ROCK", 8 + (50 * 0), skillY + 4 + (3 * 8))
			If menuColumn = 0 And menuIndex = 3 Then curSkillTxt = "Does Rock Damage"; SelectedSkill = "rock"
		End
		If curCharData.Skills.Contains("heal") Then
			GDrawTextPreserveBlend("HEAL", 8 + (50 * 1), skillY + 4 + (3 * 8))
			If menuColumn = 1 And menuIndex = 3 Then curSkillTxt = "Heals Target HP"; SelectedSkill = "heal"
		End
		If curCharData.Skills.Contains("focus") Then
			GDrawTextPreserveBlend("FOCUS", 8 + (50 * 2), skillY + 4 + (3 * 8))
			If menuColumn = 2 And menuIndex = 3 Then curSkillTxt = "Raises Target Luck"; SelectedSkill = "focus"
		End
		
		SetAlpha 1.0
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Field EQUIP_character:Int = 0
	Field EQUIP_mode:Int = 0 '' Mainly to denote when you are looking for equipable weapons or not.
	'Field EQUIP_ables:List<> = '''Temporary list to store equipable items
	
	Method EQUIP_Update:Void()
		
		Select EQUIP_mode
			Case 1 '' Looking at equipable weapons
				'UpDownMenu(equipableWeapons.Count())
			
				If NInput.IsHit(N_A) Then
					''' TODO: Equip selected weapon
				End
				If NInput.IsHit(N_B) Then
					menuIndex = EQUIP_character
					EQUIP_mode = 0
				End
				
			Default '' Looking at characters&equipment
				UpDownMenu(playerCharacters.Count())
				LeftRightMenu(2)
				
				If NInput.IsHit(N_A) Then
					If menuColumn = 0 Then
						''' Uneqip
						Local i = 0
						For Local char:DCharacter = EachIn playerCharacters
							If i = menuIndex
								playerItems.AddLast(char.accessory)
								char.accessory = Null
							End
							i += 1
						End
					Else
						''' Equip
						EQUIP_character = menuIndex
						EQUIP_mode = 1
						'EQUIP_generateEquipList
					End
				End
				If NInput.IsHit(N_B) Then BackToMenu()
		End
	End
	
	Method EQUIP_Draw:Void()
		GWindowDrawer.Draw(0, 32, 160, 144 - 32 - 8)
		
		If menuColumn = 0 Then
			GDrawTextPreserveBlend("[Unequip]  Equip ", 2, vScnHeight - 8)
		Else
			GDrawTextPreserveBlend(" Unequip  [Equip]", 2, vScnHeight - 8)
		End
		
		Local i = 0
		For Local char:DCharacter = EachIn playerCharacters
			If i = menuIndex
				char.Draw(2, 4)
				GDrawTextPreserveBlend(char.Name, 28, 6)
				GDrawTextPreserveBlend("LVL:" + char.Level, 24 + 64, 6)
				GDrawTextPreserveBlend(char.HP + "/" + char.maxHP + " HP", 28, 6 + 8)
				
				GDrawTextPreserveBlend("STR: " + char.Strength + " +" + (char.StrengthBuffed - char.Strength), 6, 6 + 8 * 4)
				GDrawTextPreserveBlend("END: " + char.Endurance + " +" + (char.EnduranceBuffed - char.Endurance), 6, 6 + 8 * 5)
				
				GDrawTextPreserveBlend("KNW: " + char.Knowledge + " +" + (char.KnowledgeBuffed - char.Knowledge), 6 + 72, 6 + 8 * 4)
				GDrawTextPreserveBlend("LUC: " + char.Luck + " +" + (char.LuckBuffed - char.Luck), 6 + 72, 6 + 8 * 5)
				
				GDrawTextPreserveBlend("Attack: " + (char.Fight(-1) - (char.AtkBuffed / 2)) + "-" + (char.Fight(1) - char.AtkBuffed) + " +" + char.AtkBuffed, 6, 6 + 8 * 6)
				
				If char.accessory <> Null Then
					GDrawTextPreserveBlend("Equip: " + char.accessory.Name, 6, 6 + 8 * 8)
				
					Local i:Int = 9
					For Local tmpBuff:DBuff = EachIn char.accessory.Buffs
						GDrawTextPreserveBlend(tmpBuff.type.ToUpper() + ": " + tmpBuff.amt, 6, 6 + 8 * i)
						i += 1
					Next
					i += 1
					
					For Local weakness:String = EachIn char.accessory.Weaknesses.Keys()
						Local weaknessAmt:int = Int(char.accessory.Weaknesses.Get(weakness))
						If weaknessAmt > 0 Then
							GDrawTextPreserveBlend("WEAK to" + weakness.ToUpper(), 6, 6 + 8 * i)
						ElseIf weaknessAmt < 0
							GDrawTextPreserveBlend("STRONG to" + weakness.ToUpper(), 6, 6 + 8 * i)
						End
						i += 1
					Next
				Else
					GDrawTextPreserveBlend("Equip: n/a", 6, 6 + 8 * 8)
				End
			End
			i += 1
		Next
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method ITEMS_Update:Void()
		If NInput.IsHit(N_B) Then modes.current = modes.menu
		
		Select playerItems.Count()
			Case 0
				menuIndex = 0
			Case 1
				menuIndex = 0
			Default
				UpDownMenu(playerItems.Count())
		End
	End
	Method ITEMS_Draw:Void()
		GWindowDrawer.Draw(0, 0, 160, 144 - 32)
		Local i = 0
		For Local item:DItem = EachIn playerItems
			If i = menuIndex
				GDrawTextPreserveBlend(">", 6, 6 + 8 * i)
			End
			GDrawTextPreserveBlend(item.Name, 12, 6 + 8 * i)
			GDrawTextPreserveBlend(item.type, 6, 144 - 32)
			i += 1
		End
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
'	Field map_select:Int = 0
	
	Method MAP_Update:Void()
		If NInput.IsHit(N_B) Then BackToMenu()
		AllIndexMenu(9)
	End
	Method MAP_Draw:Void()
		
		DrawImage(imageMap.Get("map"), 0, 0)
		
		If menuIndex <> currentLocation Then
			SetAlpha 0.5
			DrawImage(imageMap.Get("map_selector"), currentMap.location_array[currentLocation].x - 3, currentMap.location_array[currentLocation].y - 2)
			SetAlpha 1.0
		End
		If Millisecs() mod 1000 < 500 Then DrawImage(imageMap.Get("map_selector"), currentMap.location_array[menuIndex].x - 3, currentMap.location_array[menuIndex].y - 2)
		
		GWindowDrawer.Draw(0, 144 - 32, 160, 32)
		
		GDrawTextPreserveBlend(currentMap.location_array[menuIndex].name, 4, 144 - 32 + 4)
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method SAVE_Update:Void()
		'If NinInput.IsHit(N_B) Then BackToMenu()
		SaveState SaveGame()
		GMessageTicker.Add("Game Saved")
	End
	Method SAVE_Draw:Void()
		'
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method LOAD_Update:Void()
		If LoadState() <> "" Then
			LoadGame(JSONObject(JSONData.ReadJSON(LoadState())))
			SwitchScreenTo(townMapScreen)
			GMessageTicker.Add("Game Loaded")
		End
		'BackToMenu()
		'
	End
	Method LOAD_Draw:Void()
		
	End
	
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method QUIT_Update:Void()
		LeftRightMenu(2)
		
		If NInput.IsHit(N_A) Then
			If menuColumn = 1 Then
				SwitchScreenTo titleScreen
			Else
				BackToMenu()
			End
		End
		If menuColumn = 1 And NInput.IsHit(N_A) Then SwitchScreenTo titleScreen
	'	If NInput.IsHit(N_B) Then BackToMenu()
		
	End
	Method QUIT_Draw:Void()
		MENU_Draw()
		
		GWindowDrawer.Draw(0, 144 - 24, 160, 24)
		If menuColumn = 0 Then
			GDrawTextPreserveBlend("Are you sure?  YES  [NO]", 4, 144 - 8 - 8 - 4)
		ElseIf menuColumn = 1 Then
			GDrawTextPreserveBlend("Are you sure? [YES]  NO", 4, 144 - 8 - 8 - 4)
		End
	'	GDrawTextPreserveBlend("A: Select", 4, vScnHeight - 8 - 4)
	End
	
	
End

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private

Class modes
	Global current:Int
	
	Const menu:Int = 0
	Const info:Int = 1
	Const skill:Int = 2
	Const equip:Int = 3
	Const items:Int = 4
	Const map:Int = 5
	Const save:Int = 6
	Const load:Int = 7
	Const quit:Int = 10
	
End