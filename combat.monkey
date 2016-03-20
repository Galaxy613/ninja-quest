Strict
#Rem
	Auxillary Combat Functions
	
	Take care of some auxillary Combat-Related Functions
	
	Verbs:
		Random Battles
		GetSpell Power & Duration
#END
Import engine
Import ScreenCombat

Function RandomBattle:Void(zone:String)
	SwitchScreenTo combatScreen
	Local cmtScn:SCombat = SCombat(combatScreen)
	
	NLog "zone: " + zone
	Select zone.ToLower()
		Case "monsters_forest_1"
			Select Int(Rnd(7))
				Case 1
					cmtScn.enemyList.AddLast(New FrogBug(1))
					cmtScn.enemyList.AddLast(New FrogBug(1))
				Case 2
					cmtScn.enemyList.AddLast(New FrogFly(1))
					cmtScn.enemyList.AddLast(New FrogBug(1))
				Case 4
					cmtScn.enemyList.AddLast(New FrogBug(1))
				Default
					cmtScn.enemyList.AddLast(New FrogFly(1))
			End
		Case "monsters_plain_1"
			Select Int(Rnd(7))
				Case 1
					cmtScn.enemyList.AddLast(New FrogBug(1))
					cmtScn.enemyList.AddLast(New FrogBug(1))
				Case 2
					cmtScn.enemyList.AddLast(New FrogFly(1))
					cmtScn.enemyList.AddLast(New FrogBug(1))
					cmtScn.enemyList.AddLast(New FrogFly(1))
				Case 4
					cmtScn.enemyList.AddLast(New FrogBug(2))
				Default
					cmtScn.enemyList.AddLast(New FrogFly(1))
					cmtScn.enemyList.AddLast(New FrogFly(1))
			End
		Case "monsters_forest_2"
			Select Int(Rnd(7))
				Case 1
					cmtScn.enemyList.AddLast(New FrogBug(2))
					cmtScn.enemyList.AddLast(New FrogBug(2))
				Case 2
					cmtScn.enemyList.AddLast(New FrogFly(3))
					cmtScn.enemyList.AddLast(New FrogBug(3))
				Case 4
					cmtScn.enemyList.AddLast(New FrogBug(5))
				Default
					cmtScn.enemyList.AddLast(New FrogFly(4))
			End
		Case "monsters_0"
			Select Int(Rnd(7))
				Case 1
					cmtScn.enemyList.AddLast(New FrogBug(1))
					cmtScn.enemyList.AddLast(New FrogBug(1))
				Case 2
					cmtScn.enemyList.AddLast(New FrogFly(1))
					cmtScn.enemyList.AddLast(New FrogBug(1))
				Case 4
					cmtScn.enemyList.AddLast(New FrogBug(1))
				Default
					cmtScn.enemyList.AddLast(New FrogFly(1))
			End
		Case "monsters_1"
			Select Int(Rnd(7))
				Case 1
					cmtScn.enemyList.AddLast(New FrogFly(1))
					cmtScn.enemyList.AddLast(New FrogWasp(4))
					cmtScn.enemyList.AddLast(New FrogFly(1))
				Case 2
					cmtScn.enemyList.AddLast(New FrogFly(1))
					cmtScn.enemyList.AddLast(New FrogBug(1))
					cmtScn.enemyList.AddLast(New FrogFly(1))
				Case 3
					cmtScn.enemyList.AddLast(New FrogCockroach(1))
					cmtScn.enemyList.AddLast(New FrogCockroach(1))
				Case 4
					cmtScn.enemyList.AddLast(New FrogBug(1))
					cmtScn.enemyList.AddLast(New FrogBug(1))
				Default
					cmtScn.enemyList.AddLast(New FrogBug(2))
			End
		Case "monsters_2"
			Select Int(Rnd(8))
				Case 1
					cmtScn.enemyList.AddLast(New FrogFly(2))
					cmtScn.enemyList.AddLast(New FrogWasp(10))
					cmtScn.enemyList.AddLast(New FrogFly(2))
				Case 2
					cmtScn.enemyList.AddLast(New FrogBug(4))
					cmtScn.enemyList.AddLast(New FrogBug(4))
				Case 3
					cmtScn.enemyList.AddLast(New FrogCockroach(3))
					cmtScn.enemyList.AddLast(New FrogCockroach(3))
				Case 4
					cmtScn.enemyList.AddLast(New FrogBug(2))
					cmtScn.enemyList.AddLast(New FrogBug(3))
					cmtScn.enemyList.AddLast(New FrogBug(2))
				Default
					cmtScn.enemyList.AddLast(New FrogFly(2))
					cmtScn.enemyList.AddLast(New FrogFly(4))
					cmtScn.enemyList.AddLast(New FrogFly(4))
					cmtScn.enemyList.AddLast(New FrogFly(2))
			End
		Case "safe"
			'' and sound
		Default
			cmtScn.enemyList.AddLast(New FrogShambler(ninja.Level * Int(Rnd(1, 10))))
	End
	
	GMessageTicker.Add(cmtScn.enemyList.Count() + " enemies approach!")
	cmtScn.placeMonsters()
End

	Function GetSpellPower:Int(spellName:String, combatTarget:DCharacter, attacker:DCharacter, max:Bool = False)
		Local spellPower:Int = (attacker.KnowledgeBuffed / 4) + 1
		Select spellName.ToLower()
			''''
			'' BUFFS
			Case "smoke"
				spellPower *= 5
		'		If max Then
					spellPower += attacker.LuckBuffed / 2
		'		Else
		'			spellPower += Int(Rnd(attacker.LuckBuffed)) / 3
		'		End
				
			Case "ensnare"
				spellPower *= 5
		'		If max Then
					spellPower += attacker.LuckBuffed / 2
		'		Else
		'			spellPower += Int(Rnd(attacker.LuckBuffed)) / 3
		'		End
				
			Case "focus"
				spellPower *= 2'3
		'		If max Then
					spellPower += attacker.LuckBuffed / 2
		'		Else
		'			spellPower += Int(Rnd(attacker.LuckBuffed)) / 3
		'		End
			Case "terror"
			'	spellPower *= 2
		'		If max Then
					spellPower += attacker.LuckBuffed / 2
		'		Else
		'			spellPower += Int(Rnd(attacker.LuckBuffed)) / 3
		'		End
				
			Case "boost"
				spellPower *= 2'3
		'		If max Then
					spellPower += attacker.LuckBuffed / 2
		'		Else
		'			spellPower += Int(Rnd(attacker.LuckBuffed)) / 3
		'		End
			Case "posion"
			'	spellPower *= 2
		'		If max Then
					spellPower += attacker.LuckBuffed / 2
		'		Else
		'			spellPower += Int(Rnd(attacker.LuckBuffed)) / 3
		'		End
				
			''''
			'' ATTACKS
			Case "heal"
				spellPower = (spellPower * 3) + (attacker.KnowledgeBuffed)
		'		If max Then
					spellPower += attacker.LuckBuffed / 3
		'		Else
		'			spellPower += Int(Rnd(attacker.LuckBuffed)) / 3
		'		End
			Case "cure"
				''
				
			Case "aero"
				spellPower += (attacker.KnowledgeBuffed / 1)
				If max Then
					spellPower += attacker.LuckBuffed / 3
				Else
					spellPower += Int(Rnd(attacker.LuckBuffed)) / 3
				End
				If combatTarget <> Null Then
					Select combatTarget.IsWeak("aero")
						Case 1
							spellPower *= 2
						Case -1
							 spellPower /= 2
					End
				End
				
			Case "slash"
				spellPower /= 2
				spellPower += (attacker.KnowledgeBuffed / 1)
				If max Then
					spellPower += attacker.LuckBuffed / 3
				Else
					spellPower += Int(Rnd(attacker.LuckBuffed)) / 3
				End
				If combatTarget <> Null Then
					Select combatTarget.IsWeak("attack")
						Case 1
							spellPower *= 2
						Case -1
							spellPower /= 2
					End
				End
				
			Case "fire"
				spellPower += (attacker.KnowledgeBuffed / 1)
				If max Then
					spellPower += attacker.LuckBuffed / 3
				Else
					spellPower += Int(Rnd(attacker.LuckBuffed)) / 3
				End
				If combatTarget <> Null Then
					Select combatTarget.IsWeak("fire")
						Case 1
							spellPower *= 2
						Case -1
							spellPower /= 2
					End
				End
				
			Case "ice"
				spellPower += (attacker.KnowledgeBuffed / 1)
				If max Then
					spellPower += attacker.LuckBuffed / 3
				Else
					spellPower += Int(Rnd(attacker.LuckBuffed)) / 3
				End
				If combatTarget <> Null Then
					Select combatTarget.IsWeak("ice")
						Case 1
							spellPower *= 2
						Case -1
							spellPower /= 2
					End
				End
				
			Case "rock"
				spellPower += (attacker.KnowledgeBuffed / 1)
				If max Then
					spellPower += attacker.LuckBuffed / 3
				Else
					spellPower += Int(Rnd(attacker.LuckBuffed)) / 3
				End
				If combatTarget <> Null Then
					Select combatTarget.IsWeak("rock")
						Case 1
							spellPower *= 2
						Case -1
							spellPower /= 2
					End
				End
		End
		
		Return spellPower
	End
	
	Function GetSpellDuration:Int(spellName:String, attacker:DCharacter)
		Select spellName.ToLower()
			''''
			'' BUFFS
			Case "smoke"
				Return 3 + (attacker.KnowledgeBuffed / 20)
			Case "ensnare"
				Return (3 + (attacker.KnowledgeBuffed / 20))
				
			Case "focus"
				Return 3 + (attacker.KnowledgeBuffed / 20)
			Case "terror"
				Return (3 + (attacker.KnowledgeBuffed / 20))
				
			Case "boost"
				Return 3 + (attacker.KnowledgeBuffed / 20)
				
			Case "posion"
				Return (3 + (attacker.KnowledgeBuffed / 20))
				
		End
		
		Return 0
	End
	