#Rem
	Combat Screen
	
	n/a
	
	Verbs:
		n/a
#END
''' SCombat - Takes care of all combat.
''' modes - Private class, used as a ghetto enum.
Import engine
Import combat
Import ScreenTownMap

Class SCombat Extends TScreen
	Field combatTarget:DCharacter
	Field enemyList:List<DMonster> = New List<DMonster>()
	Field blockingEffect:GEffect = Null
	
	Field currentCharTurn:Int = 0
	Field currentEnemyTurn:Int = 0
	Field curCharData:DCharacter = Null
	
	Field xpGained:Int = 0
	Field goldGained:Int = 0
	
	Field SelectedSkill:String = ""
	
	Method Clear:Void() ''' Reset the combat screen.
		combatTarget = Null
		enemyList.Clear()
		blockingEffect = Null
		currentCharTurn = 0
		currentEnemyTurn = 0
		curCharData = Null
		menuColumn = 0
		menuIndex = 0
		xpGained = 0
		goldGained = 0
		SelectedSkill = ""
	End

	Method OnInit:Int()
		Clear()
		
		currentCharTurn = -1 ' New Round
		modeNTUpdate()
		
'		AddMsg(enemyList.Count + " enemies approach!")
		modes.current = modes.intro
		
	End
	
	Method OnUpdate:Int()
		GEffect.UpdateAll()
		GMessageTicker.Update()
		
		If blockingEffect Then
			If GEffect.effectList.Contains(blockingEffect) Then
				Return
			Else
				blockingEffect = Null
			End
		End
		
		Select modes.current
			Case modes.player
				modePlayerUpdate
			Case modes.skill
				modeSkillUpdate
			Case modes.enemy
				modeEnemyUpdate
			Case modes.selectEnemyFight
				modeselectEnemyFightUpdate
			Case modes.selectEnemy
				modeselectEnemyUpdate
			Case modes.selectFriend
				modeselectFriendUpdate
			Case modes.fight
				modefightUpdate
			Case modes.nextTurn
				modeNTUpdate
			Case modes.win
				modeWinUpdate
			Case modes.run
				modeRunUpdate
			Case modes.intro
				If GMessageTicker.curMsg = "" Then modes.current = modes.player
				If GMessageTicker.curMsg <> "" and NInput.IsHit(N_A) Then GMessageTicker.Skip()
		End
	End
	
	Method OnRender:Int()
		
		DrawBattle()
		
		Select modes.current
			Case modes.player
				modePlayerDraw
			Case modes.skill
				modeSkillDraw
			Case modes.enemy
				modeEnemyDraw
			Case modes.fight
				modefightDraw
			Case modes.selectEnemyFight
				modeselectEnemyFightDraw
			Case modes.selectEnemy
				modeselectEnemyDraw
			Case modes.selectFriend
				modeselectFriendDraw
			Case modes.win
				modeWinDraw
			Case modes.run
				modeRunDraw
			Default
				GWindowDrawer.Draw(0, 106, 160, 38 + 4)
		End
		
		GEffect.DrawAll()
		GMessageTicker.Draw()
		DrawText(modes.current, 0, 0)
	End
	
	Method DrawBattle:Void()
		
		If townMapScreen Then
			Local tmp:SMap = SMap(townMapScreen)
			If tmp.map <> Null And tmp.tilemap <> Null Then
				PushMatrix
				Scale 4, 4
				Translate(160 / 12, 144 / 16)
				SetAlpha 0.5
				DrawImage(tmp.tilemap, 0, 0, tmp.map.currentMap[tmp.y][tmp.x])
				SetAlpha 1.0
				PopMatrix
			End
		End
		
		For Local ply:DCharacter = EachIn playerCharacters
			ply.Draw
			If modes.current = modes.win
				If ply.HP = 0 Then
					GDrawTextPreserveBlend("K.O.", ply.x + 24 + 4, ply.y + 4)
				Else
					If ply.LvlUp Then
						GDrawTextPreserveBlend("LEVEL UP!", ply.x + 24 + 4, ply.y + 4)
					Else
						GDrawTextPreserveBlend(ply.XPNextLevel + xpGained - menuColumn + "xp left", ply.x + 24 + 4, ply.y + 4)
					End
				End
			EndIf
		Next
		
		Local curEmyNum:Int = 0
		For Local emy:DMonster = EachIn enemyList
			emy.Draw()
			curEmyNum += 1
		Next
		
	End
	
	Method AttackCombatTarget:Void(attacker:DCharacter)
		blockingEffect = GEffect.Create(imageMap.Get("slash"), combatTarget.x + 4, combatTarget.y + 2)
		
		If Rnd(100) < combatTarget.evasion - attacker.LuckBuffed / 4 Then
			GMessageTicker.Add attacker.Name + " missed!"
		Else
			Local damage:Int = curCharData.Fight()
			
			' damage
			Select combatTarget.IsWeak("attack")
				Case 1
					damage *= 2
					GMessageTicker.Add(combatTarget.Name + " is weak!");'''spellPower *= 2
				Case -1
					damage /= 2
					GMessageTicker.Add(combatTarget.Name + " is strong!");'''spellPower /= 2
			End
			
			GMessageTicker.Add combatTarget.Name + " took " + damage + " dmg"
			combatTarget.HP -= damage
		End
	End
	
	Method UseSpellOnCombatTarget:Void(attacker:DCharacter, spellName:String, surpress:Bool = False)
		Local spellPower:Int = GetSpellPower(spellName, combatTarget, attacker)
		blockingEffect = GEffect.Create(imageMap.Get("blast"), combatTarget.x + 4, combatTarget.y + 2)
		If Not surpress Then GMessageTicker.Add(attacker.Name + " used " + spellName.ToUpper())
		
		If playerCharacters.Contains(combatTarget) And playerCharacters.Contains(attacker) Then
			''' NOTHING, you can't miss your ally
		ElseIf attacker = combatTarget
			''' NOPE
		Else
			If Rnd(200) < combatTarget.evasion - attacker.LuckBuffed / 4 Then ' Much harder to miss with a spell, put still possible
				GMessageTicker.Add attacker.Name + " missed!"
				Return
			End
		End
		
		Select spellName.ToLower()
			''''
			'' BUFFS
			Case "smoke"
				combatTarget.AddBuff("evade", spellPower, GetSpellDuration(spellName, attacker))
				If combatTarget = attacker Then
					GMessageTicker.Add(attacker.Name + " self-buffed!")' + spellPower)
				Else
					GMessageTicker.Add(attacker.Name + " buffed " + combatTarget.Name + "!")' + spellPower)
				End
			Case "ensnare"
				combatTarget.AddBuff("evade", -1 * spellPower, (2 + (attacker.KnowledgeBuffed / 20)))
				GMessageTicker.Add(attacker.Name + " debuffed " + combatTarget.Name + "!")' + spellPower)
				
			Case "focus"
				combatTarget.AddBuff("luck", spellPower, GetSpellDuration(spellName, attacker))
				If combatTarget = attacker Then
					GMessageTicker.Add(attacker.Name + " self-buffed!")' + spellPower)
				Else
					GMessageTicker.Add(attacker.Name + " buffed " + combatTarget.Name + "!")' + spellPower)
				End
			Case "terror"
				combatTarget.AddBuff("luck", -1 * spellPower, GetSpellDuration(spellName, attacker))
				GMessageTicker.Add(attacker.Name + " debuffed " + combatTarget.Name + "!")' + spellPower)
				
			Case "boost"
				combatTarget.AddBuff("strength", spellPower, GetSpellDuration(spellName, attacker))
			'	combatTarget.AddBuff("luck", spellPower, 2 + (attacker.KnowledgeBuffed / 20))
				If combatTarget = attacker Then
					GMessageTicker.Add(attacker.Name + " self-buffed!")' + spellPower)
				Else
					GMessageTicker.Add(attacker.Name + " buffed " + combatTarget.Name + "!")' + spellPower
				End
			Case "posion"
				combatTarget.AddBuff("strength", -1 * spellPower, GetSpellDuration(spellName, attacker))
				GMessageTicker.Add(attacker.Name + " debuffed " + combatTarget.Name + "!")' + spellPower)
				
			''''
			'' ATTACKS
			Case "heal"
				combatTarget.HP += spellPower
				If combatTarget.maxHP < combatTarget.HP Then combatTarget.HP = combatTarget.maxHP
				GMessageTicker.Add(combatTarget.Name + " was healed " + spellPower)
			Case "cure"
				For Local buff:DBuff = EachIn combatTarget.Buffs
					If buff.amt < 0 Then
						combatTarget.Buffs.RemoveEach(buff)
					End
				Next
				GMessageTicker.Add(combatTarget.Name + " isn't debuffed")
				
			Case "slash"
				Select combatTarget.IsWeak("attack")
					Case 1
						GMessageTicker.Add(combatTarget.Name + " is weak!");'''spellPower *= 2
					Case -1
						GMessageTicker.Add(combatTarget.Name + " is strong!");'''spellPower /= 2
				End
				
				GMessageTicker.Add combatTarget.Name + " took " + spellPower + " dmg"
				combatTarget.HP -= spellPower
				
			Case "aero"
				Select combatTarget.IsWeak("aero")
					Case 1
						GMessageTicker.Add(combatTarget.Name + " is weak!");'''spellPower *= 2
					Case -1
						GMessageTicker.Add(combatTarget.Name + " is strong!");'''spellPower /= 2
				End
				GMessageTicker.Add combatTarget.Name + " took " + spellPower + " dmg"
				combatTarget.HP -= spellPower
				
			Case "fire"
				Select combatTarget.IsWeak("fire")
					Case 1
						GMessageTicker.Add(combatTarget.Name + " is weak!");'''spellPower *= 2
					Case -1
						GMessageTicker.Add(combatTarget.Name + " is strong!");'''spellPower /= 2
				End
				
				GMessageTicker.Add combatTarget.Name + " took " + spellPower + " dmg"
				combatTarget.HP -= spellPower
				
			Case "ice"
				Select combatTarget.IsWeak("ice")
					Case 1
						GMessageTicker.Add(combatTarget.Name + " is weak!");'''spellPower *= 2
					Case -1
						GMessageTicker.Add(combatTarget.Name + " is strong!");'''spellPower /= 2
				End
				
				GMessageTicker.Add combatTarget.Name + " took " + spellPower + " dmg"
				combatTarget.HP -= spellPower
				
			Case "rock"
				Select combatTarget.IsWeak("rock")
					Case 1
						GMessageTicker.Add(combatTarget.Name + " is weak!");'''spellPower *= 2
					Case -1
						GMessageTicker.Add(combatTarget.Name + " is strong!");'''spellPower /= 2
				End
				
				GMessageTicker.Add combatTarget.Name + " took " + spellPower + " dmg"
				combatTarget.HP -= spellPower
		End
		NLog combatTarget.GetStats()
		combatTarget.CalculateBuffs()
		NLog combatTarget.GetStats()
	End
	
	'''''''''''''''''''''''''''''''''''''''
	'' MODES
	''
	Method NextRound:Void()
	
		For Local ply:DCharacter = EachIn playerCharacters
			ply.UpdateBuffs()
		Next
		
		For Local emy:DMonster = EachIn enemyList
			emy.UpdateBuffs()
		Next
	End
	
	Method IsGameOver()
		Local gameOver:Bool = True
		
		For Local ply:DCharacter = EachIn playerCharacters
			If ply.HP > 0 Then gameOver = False
		Next
		If gameOver Then
			EndCombatLose
			NLog "GAME OVER"
		End
		Return gameOver
	End
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''' MODE PLAYER
	Method modePlayerDraw:Void()
		If (curCharData = Null)
			GDrawTextPreserveBlend("No Current Character", 41 + 3, 106 + 4)
			Return
		EndIf
		
		GDrawTextPreserveBlend("<-", curCharData.x + 24, curCharData.y + 8)
		
		GWindowDrawer.Draw(0, 106, 42, 38 + 4)
		
		GDrawTextPreserveBlend(" FIGHT", 2, 106 + 4 + (0 * 8))
		GDrawTextPreserveBlend(" SKILL", 2, 106 + 4 + (1 * 8))
		GDrawTextPreserveBlend(" BLOCK", 2, 106 + 4 + (2 * 8))
		GDrawTextPreserveBlend(" RUN", 2, 106 + 4 + (3 * 8))
		
		GDrawTextPreserveBlend(">", 2, 106 + 4 + (menuIndex * 8))
		
		''
		GWindowDrawer.Draw(41, 106, 119, 38 + 4)
		
		GDrawTextPreserveBlend(curCharData.Name + "  Lvl " + curCharData.Level, 41 + 3, 106 + 4)
		GDrawTextPreserveBlend("HP " + curCharData.HP + "/" + curCharData.maxHP, 41 + 3, 106 + 4 + 8)
		GDrawTextPreserveBlend("St" + curCharData.StrengthBuffed + " En" + curCharData.EnduranceBuffed + " Kn" + curCharData.KnowledgeBuffed + " Lu" + curCharData.LuckBuffed, 41 + 3, 106 + 4 + 16)
		
		GDrawTextPreserveBlend("Next Level: " + curCharData.XPNextLevel, 41 + 3, 106 + 4 + 24)
	End
	
	Method modePlayerUpdate:Void()
		'menuIndex
		
		UpDownMenu(4)
		
		If NInput.IsHit(N_A)
			Select menuIndex
				Case 0
					combatTarget = Null
			'		If enemyList.Count() > 1 Then
						modes.current = modes.selectEnemyFight
						combatTarget = enemyList.First()
			'		Else
			'			modes.current = modes.fight
			'		End
				Case 1
					modes.current = modes.skill
					menuColumn = 0
					menuIndex = 0
				Case 2
					curCharData.evasion += 50
					modes.current = modes.nextTurn
					GMessageTicker.Add(curCharData.Name + " guarded")
				Default
					'RUN
					If Rnd(150) > (enemyList.Count() * 10) - curCharData.evasion Then
						GoToRun()
					Else
						modes.current = modes.nextTurn
						GMessageTicker.Add("Running away failed!")
					End
			End
		End
	End
	
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''' MODE SKILL
	Method modeSkillDraw:Void()
		GWindowDrawer.Draw(0, 106, 160, 38 + 4)
		GDrawTextPreserveBlend(">", 2 + (50 * menuColumn), 106 + 4 + (menuIndex * 8))
		
		GMessageTicker.curMsg = ""
		GMessageTicker.lastMsgMs = -1
		SelectedSkill = ""
		
		Local tColumn:Int = 0, tRow:Int = 0
		
		For Local key:String = EachIn curCharData.Skills.Keys()
			GDrawTextPreserveBlend(key.ToUpper(), 8 + (50 * tColumn), 106 + 4 + (tRow * 8))
			If menuColumn = tColumn And menuIndex = tRow Then
				GMessageTicker.Set(L.Get("skilldesc_" + key.ToLower()))
				SelectedSkill = key.ToLower()
			End
			
			tRow += 1
			If tRow = 4 Then
				tRow = 0
				tColumn += 1
			End
		Next
	End
	
	Method modeSkillUpdate:Void()
		
		If (NInput.IsHit(N_A)) And SelectedSkill <> ""
			NLog "Selected Skill '" + SelectedSkill + "'!"
			combatTarget = Null
			
			menuIndex = 0
			GMessageTicker.lastMsgMs = 0
			
			If combatTarget = curCharData Then
				UseSpellOnCombatTarget(curCharData, SelectedSkill)
				modes.current = modes.nextTurn
			Else
				
				Select SelectedSkill '' Are we picking an enemy or a friendly?
					Case "smoke"
						modes.current = modes.selectFriend
					Case "heal"
						modes.current = modes.selectFriend
					Case "cure"
						modes.current = modes.selectFriend
						
					Case "slash"
						modes.current = modes.nextTurn
						'UseSpellOnCombatTarget	
						For Local emy:DMonster = EachIn enemyList
							combatTarget = emy
							UseSpellOnCombatTarget(curCharData, SelectedSkill, (emy <> enemyList.First()))
							CheckIfMonsterIsDead
						Next
					
				'	Case "boost"
				'		modes.current = modes.selectFriend
					Default
						modes.current = modes.selectEnemy
				End
			End
		End
		
		If NInput.IsHit(N_B)
			menuIndex = 1
			GMessageTicker.lastMsgMs = 0
			modes.current = modes.player
		End
		
		UpDownMenu(4)
		
		LeftRightMenu(3)
	End
	
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''' MODE ENEMY SELECT
	
	Method modeselectEnemyFightDraw:Void()
		GWindowDrawer.Draw(0, 106, 160, 38 + 4)
		If combatTarget = Null Then Return
		GDrawTextPreserveBlend("->", combatTarget.x - 12, combatTarget.y + 8)
		
		GDrawTextPreserveBlend(combatTarget.Name + "  Lvl " + combatTarget.Level, 3, 106 + 4)
		GDrawTextPreserveBlend("HP " + combatTarget.HP + "/" + combatTarget.maxHP, 3, 106 + 4 + 8)
		If KeyDown(KEY_F) Then GDrawTextPreserveBlend("St" + combatTarget.StrengthBuffed + " En" + combatTarget.EnduranceBuffed + " Kn" + combatTarget.KnowledgeBuffed + " Lu" + combatTarget.LuckBuffed, 41 + 3, 106 + 4 + 16)
	End
	
	Method modeselectEnemyFightUpdate:Void()
		If enemyList.Count() = 0 Then modes.current = modes.player; Return
		
		UpDownMenu(enemyList.Count())
		
		If enemyList.Count() < menuIndex Then menuIndex = 0
		
		combatTarget = enemyList.ToArray()[menuIndex]
		
		If (NInput.IsHit(N_A)) And combatTarget <> Null
			modes.current = modes.fight
		End
		
		If NInput.IsHit(N_B)
			menuIndex = 0
			modes.current = modes.player
		End
	End
	
	Method modeselectEnemyDraw:Void() '' Use skill on enemy
		GWindowDrawer.Draw(0, 106, 160, 38 + 4)
		If combatTarget = Null Then Return
		GDrawTextPreserveBlend("->", combatTarget.x - 12, combatTarget.y + 8)
		
		GDrawTextPreserveBlend(combatTarget.Name + "  Lvl " + combatTarget.Level, 3, 106 + 4)
		GDrawTextPreserveBlend("HP " + combatTarget.HP + "/" + combatTarget.maxHP, 3, 106 + 4 + 8)
	End
	
	Method modeselectEnemyUpdate:Void()
		If enemyList.Count() = 0 Then modes.current = modes.player; Return
		
		UpDownMenu(enemyList.Count())
		
		If enemyList.Count() < menuIndex Then menuIndex = 0
		
		combatTarget = enemyList.ToArray()[menuIndex]
		
		If (NInput.IsHit(N_A)) And combatTarget <> Null
			UseSpellOnCombatTarget(curCharData, SelectedSkill)
			
			CheckIfMonsterIsDead()
		End
		
		If NInput.IsHit(N_B)
			menuIndex = 0
			modes.current = modes.player
		End
	End
	
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	
	Method modeselectFriendDraw:Void() '' Use skill on friendly
		GWindowDrawer.Draw(0, 106, 160, 38 + 4)
		If combatTarget = Null Then Return
		GDrawTextPreserveBlend("<-", combatTarget.x + 24, combatTarget.y + 8)
		
		GDrawTextPreserveBlend(combatTarget.Name + "  Lvl " + combatTarget.Level, 3, 106 + 4)
		GDrawTextPreserveBlend("HP " + combatTarget.HP + "/" + combatTarget.maxHP, 3, 106 + 4 + 8)
	End
	
	Method modeselectFriendUpdate:Void()
		
		UpDownMenu(playerCharacters.Count())
		
		combatTarget = playerCharacters.ToArray()[menuIndex]
		
		If (NInput.IsHit(N_A)) And combatTarget <> Null
			UseSpellOnCombatTarget(curCharData, SelectedSkill)
			modes.current = modes.nextTurn
		End
		
		If NInput.IsHit(N_B)
			menuIndex = 0
			menuColumn = 0
			modes.current = modes.player
		End
	End
	
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''' MODE FIGHT
	Method modefightDraw:Void()
		GWindowDrawer.Draw(0, 106, 160, 38 + 4)
	End
	
	Method modefightUpdate:Void()
		If enemyList.Count() = 0 Then GoToWin(); Return
		If combatTarget = Null Then combatTarget = enemyList.First()
		
		AttackCombatTarget(curCharData)
		
		CheckIfMonsterIsDead()
	End
	
	Method CheckIfMonsterIsDead:Void()
		If combatTarget.HP < 1 Then
			GMessageTicker.Add combatTarget.Name + " died!"
			enemyList.RemoveEach(DMonster(combatTarget))
			xpGained += combatTarget.CalcXPWorth()
			NLog "[Added " + combatTarget.CalcXPWorth() + " xp]"
			goldGained += ( (combatTarget.Level * 10) + (combatTarget.EnduranceBuffed * 10) + (combatTarget.Skills.Count() * 25)) * 0.1
			NLog "[Added " + combatTarget.CalcXPWorth() + " xp]"
		End
		
		If enemyList.Count() = 0 Then 	'' If Dead, you Win!
			GoToWin()
		Else							'' If not, decide who's turn is next.
			modes.current = modes.nextTurn
		End
	End
	
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''' MODE NEXT TURN
	Method modeNTDraw:Void()
		GWindowDrawer.Draw(0, 106, 160, 38 + 4)
	End
	
	Method modeNTUpdate:Void()
		NLog "modeNTUpdate:startCharTurn" + currentCharTurn
		If currentCharTurn = -1 Then NextRound() '' New Round, Update Buffs
		currentCharTurn += 1 '' Check if Ninja can play
		menuIndex = 0
		menuColumn = 0
		modes.current = modes.player
		
		NLog "modeNTUpdate:currentCharTurn" + currentCharTurn
		If IsGameOver() Then Return
		
		curCharData = Null
		
		If currentCharTurn = playerCharacters.Count() Then
			curCharData = Null
		Else
			curCharData = playerCharacters.ToArray()[currentCharTurn]
		End
		
		If curCharData = Null
			NLog currentCharTurn + " leads to a null character"
			EndPlayerTurn()
			Return
		Else
			NLog currentCharTurn + " does NOT lead to a null character"
			If curCharData.HP = 0 Then
				'modeNTUpdate()
				modes.current = modes.nextTurn
				Return ' Let's try to the next guy
			End
		End
		
		placePlayers()
	End
		
	Method placeMonsters:Void()
		Local emy:DMonster, emyArr:DMonster[] = enemyList.ToArray()
		Select enemyList.Count()
			Case 4 ' 14 + (0 * 22)
				emy = emyArr[0]
				emy.SetPosition(160 - 40 + 4, 14 + (0 * 22))
				
				emy = emyArr[1]
				emy.SetPosition(160 - 40 - 4, 14 + (1 * 22))
								
				emy = emyArr[2]
				emy.SetPosition(160 - 40 + 4, 14 + (2 * 22))
				
				emy = emyArr[3]
				emy.SetPosition(160 - 40 - 4, 14 + (3 * 22))
			Case 3
				emy = emyArr[0]
				emy.SetPosition(160 - 40 + 4, 48 - 24)
				
				emy = emyArr[1]
				emy.SetPosition(160 - 40 - 4, 48)
				
				emy = emyArr[2]
				emy.SetPosition(160 - 40 + 4, 48 + 24)
			Case 2
				emy = emyArr[0]
				emy.SetPosition(160 - 40 + 4, 48 - 12)
				
				emy = emyArr[1]
				emy.SetPosition(160 - 40 - 4, 48 + 12)
				
			Default
				emy = enemyList.First()
				emy.SetPosition(160 - 40, 48)
		End
	End
	
	Method placePlayers:Void()
		Local nudge:Int = 0
		Select playerCharacters.Count()
			Case 4
				nudge = 0; If currentCharTurn <> 0 Then nudge = -4
				playerCharacters.First().SetPosition(22 - 8 + nudge, 14 + (0 * 22))
				
				nudge = 0; If currentCharTurn <> 1 Then nudge = -4
				playerCharacters.ToArray()[1].SetPosition(22 + nudge, 14 + (1 * 22))
				
				nudge = 0; If currentCharTurn <> 2 Then nudge = -4
				playerCharacters.ToArray()[2].SetPosition(22 - 8 + nudge, 14 + (2 * 22))
				
				nudge = 0; If currentCharTurn <> 3 Then nudge = -4
				playerCharacters.ToArray()[3].SetPosition(22 + nudge, 14 + (3 * 22))
			
			Case 3
				nudge = 0; If currentCharTurn <> 0 Then nudge = -4
				playerCharacters.First().SetPosition(22 - 8 + nudge, 48 - 24)
				
				nudge = 0; If currentCharTurn <> 1 Then nudge = -4
				playerCharacters.ToArray()[1].SetPosition(22 + nudge, 48)
				
				nudge = 0; If currentCharTurn <> 2 Then nudge = -4
				playerCharacters.Last().SetPosition(22 - 8 + nudge, 48 + 24)
			
			Case 2
				nudge = 0; If currentCharTurn <> 0 Then nudge = -4
				playerCharacters.First().SetPosition(22 - 8 + nudge, 48 - 16)
				
				nudge = 0; If currentCharTurn <> 1 Then nudge = -4
				playerCharacters.Last().SetPosition(22 + nudge, 48 + 16)
				
			Default
				playerCharacters.First().SetPosition(20, 48)
		End
	End
	
	Method EndPlayerTurn()
		currentCharTurn = -1
		currentEnemyTurn = -1
		modes.current = modes.enemy
		curCharData = Null
		GMessageTicker.Add("Enemy is thinking!")
	End
	
	'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	''''''''''''''' MODE ENEMY	
	Method modeEnemyDraw:Void()
		GWindowDrawer.Draw(0, 106, 160, 38 + 4)
		If curCharData Then GDrawTextPreserveBlend("->", curCharData.x - 12, curCharData.y + 8)
	End
	
	Method modeEnemyUpdate:Void()
		'' Whenever we're sent to here it's always with the message "Enemy is thinking"
		'' but we only need to think in one turn, so do it now once the msg queue is clear!
		If GMessageTicker.msgList.Count() = 0 And GMessageTicker.curMsg = ""
			If currentEnemyTurn = -1 Then
				'' Start with the first enemy.
				currentEnemyTurn = 0
			End
		Else '' If there's a message, Block until there's none
			If currentEnemyTurn = -1 Then
				curCharData = DCharacter(enemyList.ToArray()[0])
			End
			If NInput.IsHit(N_A) Then GMessageTicker.Skip()
			Return
		End
		
		If IsGameOver() Then Return
		
		Local currentMonster:DMonster = enemyList.ToArray()[currentEnemyTurn]
		currentMonster.CalculateBuffs()
		
		''' Select a combat target
		combatTarget = Null
		For Local timeOut:Int = 0 To 8
			If playerCharacters.Count() = 1 Then
				combatTarget = playerCharacters.First()
			Else
				combatTarget = playerCharacters.ToArray()[Int(Rnd(playerCharacters.Count()))]
			End
			If combatTarget.HP > 0 Then Exit '' If you find an alive target, attack it.
			combatTarget = Null
		Next
		If combatTarget = Null Then
			''' Can't find a valid player character to fight
			GMessageTicker.Add currentMonster.Name + " is confused!"
			Return
		End
		
		''' Fight the combat target!
		If currentMonster.Skills.IsEmpty()
			AttackCombatTarget currentMonster
		Else
			If Rnd(100) < 10 + currentMonster.KnowledgeBuffed * 2 + currentMonster.Skills.Count() * 2
				''' Randomly pick a skill to use!
				Local t:Int = Rnd(currentMonster.Skills.Count() +1), i:Int = 0
				If t >= currentMonster.Skills.Count() Then
					t = 0
				End
				For Local skill:String = EachIn currentMonster.Skills.Keys()
					If t = i Then
						Select skill.ToLower()
							Case "smoke"; combatTarget = currentMonster
							Case "focus"; combatTarget = currentMonster
							Case "boost"; combatTarget = currentMonster
						'	Case "boost2"; combatTarget = currentMonster
							Case "heal"; combatTarget = currentMonster ' Monsters are selfish!
							Case "cure"; combatTarget = currentMonster
						End
						
						UseSpellOnCombatTarget(currentMonster, skill)
						Exit
					End
					
					i += 1
				Next
			Else
				AttackCombatTarget currentMonster
			End
			
			If currentEnemyTurn + 1 < enemyList.Count() Then
				'enemyList.ToArray()[currentEnemyTurn]
				curCharData = DCharacter(enemyList.ToArray()[currentEnemyTurn])
			End
		End
		
		''' If the combat target dies, tell everybody.
		If combatTarget.HP < 0 Then
			combatTarget.HP = 0
			GMessageTicker.Add combatTarget.Name + " died!"
		End
		
		currentEnemyTurn += 1
		If currentEnemyTurn = enemyList.Count() Then 	'' Have we done all the enemies?
			modes.current = modes.nextTurn
		End											'' If not, continue this loop
	End
	
	''''''''''''''' MODE WIN
	Method GoToWin:Void()
		For Local pc:DCharacter = EachIn playerCharacters
			If pc.HP > 0 Then
				pc.LvlUp = False ''' Does this need to be here?
				pc.AddXP(xpGained)
			End
		Next
		playerGold += goldGained
		
		'' Bastardize int variables from before to make WIN effects!
		menuColumn = 0
		menuIndex = 0
		currentEnemyTurn = 1
		currentCharTurn = 5
		
		modes.current = modes.win
		
		If gameTriggers.Get("m" + ConvertToSpecialID(10)) = "1" Then
			GMessageTicker.Add("'How? Meer mortals..'")
		End
	End
	
	Method modeWinDraw:Void()
		GWindowDrawer.Draw(0, 106, 160, 38 + 4)
		GDrawTextPreserveBlend("You gained " + menuColumn + " XP and", 12, 116 - 4)
		GDrawTextPreserveBlend("           " + menuIndex + " GP!", 12, 116 + 8 - 4)
		If GMessageTicker.isBlank() Then GDrawTextPreserveBlend("Press A to continue.", 8, 116 + 16)
	End
	
	Method modeWinUpdate:Void()
		If menuColumn < xpGained Then
			menuColumn += 1
			If menuColumn > 10 Then menuColumn += 4
			If menuColumn > 50 Then menuColumn += 5
		End
		If menuColumn > xpGained Then menuColumn = xpGained
		
		If menuIndex < goldGained Then
			menuIndex += 5
			If menuIndex > 25 Then menuIndex += 5
			If menuIndex > 100 Then menuIndex += 15
		End
		If menuIndex > goldGained Then menuIndex = goldGained
		
		If (NInput.IsHit(N_A)) Then
			If GMessageTicker.curMsg = "" And menuIndex = goldGained And menuColumn = xpGained Then EndCombatWin
			If GMessageTicker.curMsg <> "" Then GMessageTicker.Skip
		End
		
		If currentCharTurn = 0 Then
			For Local ply:DCharacter = EachIn playerCharacters
				ply.y += currentEnemyTurn * 4
			Next
			currentEnemyTurn *= -1
			currentCharTurn = 5
		Else
			currentCharTurn -= 1
		End
	'	If msgList.Count() = 0 And curMsg = "" Then EndApp()
	End
	
	Method EndCombatLose:Void()
		SwitchScreenTo townMapScreen
		Clear()
		
		For Local ply:DCharacter = EachIn playerCharacters
			If ply.HP < 1 Then ply.HP = 1
		Next
		
		ClearActiveEvents
	End
	
	Method EndCombatWin:Void()
		SwitchScreenTo townMapScreen
		Clear()
		
		For Local ply:DCharacter = EachIn playerCharacters
			If ply.HP < 1 Then ply.HP = 1
		Next
		
		If gameTriggers.Get("m" + ConvertToSpecialID(2)) = "1" Then ''' DANGER FOREST
			gameTriggers.Set("m" + ConvertToSpecialID(2), "2")
				
			If archer = Null Then
				GMessageTicker.Add("Archer joined your Party!")
				archer = New DCharacter()
				archer.accessory = DItem.Generate(DItem.TYPE_EQUIP, 4)
				archer.InitStats(4, 5, 3)
				archer.InitLevel(ninja.Level / 2, "ARCHER")
				archer.img = imageMap.Get("archer")
				archer.Skills.Add("cure", "")
				'		archer.Skills.Add("poison", "")
				'		archer.Skills.Add("ice", "")
				playerCharacters.AddLast(archer)
			End
		End
		
		If gameTriggers.Get("m" + ConvertToSpecialID(10)) = "1" Then ''' THE PIT
			gameTriggers.Set("m" + ConvertToSpecialID(10), "2")
		End
		
		ClearActiveEvents
	End
	''''''''''''''' MODE RUN
	Method GoToRun:Void()
		
		'' Bastardize int variables from before to make WIN effects!
		menuColumn = 0
		menuIndex = 0
		currentEnemyTurn = 1
		currentCharTurn = 5
		
		modes.current = modes.run
	End
	
	Method modeRunDraw:Void()
		GWindowDrawer.Draw(0, 106, 160, 38 + 4)
		GDrawTextPreserveBlend("You fled combat!", 12, 116)
		If GMessageTicker.curMsg = "" Then GDrawTextPreserveBlend("Press A to continue.", 8, 116 + 16)
	End
	
	Method modeRunUpdate:Void()
		
		If (NInput.IsHit(N_A)) Then
			If GMessageTicker.curMsg = "" Then
				EndCombatLose
			Else
				GMessageTicker.Skip
			End
		End
		
		If currentCharTurn = 0 Then
			For Local ply:DCharacter = EachIn playerCharacters
				ply.y += currentEnemyTurn * 4
				ply.x = -4
			Next
			currentEnemyTurn *= -1
			currentCharTurn = 5
		Else
			currentCharTurn -= 1
		End
	'	If msgList.Count() = 0 And curMsg = "" Then EndApp()
	End
End

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private

Class modes
	Global current:Int
	
	Const intro:Int = 0
	Const player:Int = 1
	Const skill:Int = 2
	Const enemy:Int = 3
	Const fight:Int = 4
	Const selectEnemyFight:Int = 5
	Const selectFriend:Int = 6
	Const selectEnemy:Int = 7
	
	Const win:Int = 10
	Const nextTurn:Int = 11
	Const run:Int = 12
End