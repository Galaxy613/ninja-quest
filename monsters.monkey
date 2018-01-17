#Rem
	Monsters
	
	Holds the monster-specific data for the combat screen, prefix on all mosters is 'Frog'
	the only reason for this prefix is for stupid flavor reasons.
#END
''' FrogBug - Basic low-level enemy
''' FrogCockroach - Tougher but still weak enemy
''' FrogWasp - Powerful, mini-boss worthy enemy.
''' FrogFly - Slightly tougher flying enemy (aka weak to aero)
''' FrogShambler - Players should not ever encounter this guy.
Import engine
''' 
'''''''''''''''''''''''''''''''''''
'''''''''''''''''''''''''''''''''''

Function GetMonsterType_Basic:DMonster(level:Int)
	Local randomNumber:Int = Rnd(100) + Level
	
	NLog "Getting Monster of Level " + level
	If randomNumber = 6 Then Return New FrogShambler(level)
	If randomNumber < 40 Then
		Return New FrogBug(level)
	ElseIf randomNumber < 65
		Return New FrogCockroach(level)
	ElseIf randomNumber < 85
		Return New FrogFly(level)
	Else
		Return New FrogWasp(level)
	End
End

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

Class FrogBug Extends DMonster
	Method New(level:Int); InitLevel(level); End
	
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("monsters")
		frame = 4
'		If lvl > 3 Then
'			lvl = 2 + ( (lvl - 2) / 2)
'		End
				
		Strength = 1
		Endurance = 2
		Knowledge = 1
		Luck = 2
		LevelToLevel(lvl)
		UpdateBuffs()
		
		HP = maxHP
		Name = "BUG"'nme
		AddWeakness("fire")
		AddWeakness("ice")
		AddWeakness("rock")
		AddWeakness("attack", -1)
		
		Level = lvl
		XPNextLevel = 0
	End
End

Class FrogSpider Extends DMonster
	Method New(level:Int); InitLevel(level); End
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("monsters")
		frame = 1
		
		Strength = 2
		Endurance = 3
		Knowledge = 3
		Luck = 1
		LevelToLevel(lvl)
		UpdateBuffs()
		
		HP = maxHP
		Name = "SPIDR"
		AddSkill("posion")
		AddSkill("posion")
		AddWeakness("ice")
		AddWeakness("aero")
		
		Level = lvl
		XPNextLevel = 0
	End
End

Class FrogCROW Extends DMonster
	Method New(level:Int); InitLevel(level); End
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("monsters")
		frame = 8
		
		Strength = 1
		Endurance = 8
		Knowledge = 1
		Luck = 1
		LevelToLevel(lvl)
		UpdateBuffs()
		
		HP = maxHP
		Name = "CROH"
		AddSkill("posion")
		AddSkill("posion")
		AddWeakness("attack", 1)
		AddWeakness("aero")
		
		Level = lvl
		XPNextLevel = 0
	End
End

Class FrogSkeleton Extends DMonster
	Method New(level:Int); InitLevel(level); End
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("monsters")
		frame = 17
		
		Strength = 3
		Endurance = 3
		Knowledge = 0
		Luck = 0
		LevelToLevel(lvl)
		UpdateBuffs()
		
		HP = maxHP
		Name = "SKELE"
		AddWeakness("aero")
		AddWeakness("attack", 2)
		
		Level = lvl
		XPNextLevel = 0
	End
End

Class FrogSkeletonArcher Extends DMonster
	Method New(level:Int); InitLevel(level); End
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("monsters")
		frame = 16
		
		Strength = 2
		Endurance = 3
		Knowledge = 0
		Luck = 5
		LevelToLevel(lvl)
		UpdateBuffs()
		
		HP = maxHP
		Name = "SKARC"
		AddWeakness("aero")
		AddWeakness("attack", 2)
		
		Level = lvl
		XPNextLevel = 0
	End
End

Class FrogSlime Extends DMonster
	Method New(level:Int); InitLevel(level); End
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("monsters")
		frame = 3
		
		Strength = 1
		Endurance = 1
		Knowledge = 1
		Luck = 1
		LevelToLevel(lvl)
		UpdateBuffs()
		
		HP = maxHP
		Name = "SLIME"
		AddWeakness("ice")
		AddWeakness("aero")
		
		Level = lvl
		XPNextLevel = 0
	End
End

Class FrogFly Extends DMonster
	Method New(level:Int); InitLevel(level); End
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("monsters")
		frame = 0
		
		'		If lvl > 4 Then
		'			lvl = 3 + ( (lvl - 3) / 2)
		'		End
		
		'	Strength = lvl
		'	Endurance = lvl / 2
		'	Knowledge = lvl / 2
		'	Luck = lvl + 2
		Strength = 1
		Endurance = 1
		Knowledge = 1
		Luck = 3
		LevelToLevel(lvl)
		UpdateBuffs()
		
		HP = maxHP
		Name = "FLY"
		AddSkill("focus")
		AddWeakness("rock")
		AddWeakness("aero")
		
		Level = lvl
		XPNextLevel = 0
	End
End

Class FrogWasp Extends DMonster
	Method New(level:Int); InitLevel(level); End
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("monsters")
		frame = 2
'		If lvl > 8 Then
'			lvl = 7 + ( (lvl - 7) / 2)
'		End
		
	'	Strength = lvl + 3
	'	Endurance = lvl
	'	Knowledge = lvl / 2
	'	Luck = lvl + 3
		Strength = 2
		Endurance = 4
		Knowledge = 1
		Luck = 2
		LevelToLevel(lvl)
		UpdateBuffs()
		
		HP = maxHP
		Name = "WASP"
		AddSkill("boost")
		AddSkill("aero")
		AddSkill("posion")
		AddWeakness("aero")
		
	'	Level = lvl
		XPNextLevel = 0
	End
End

Class FrogCockroach Extends DMonster
	Method New(level:Int); InitLevel(level); End
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("monsters")
		frame = 6
		'		If lvl > 6 Then
		'			lvl = 5 + ( (lvl - 5) / 2)
		'		End
		
		'	Strength = Rnd(lvl / 2, lvl * 1.5)
		'	Endurance = lvl
		'	Knowledge = lvl / 2
		'	Luck = lvl
		Strength = 1
		Endurance = 1
		Knowledge = 1
		Luck = 1
		LevelToLevel(lvl)
		UpdateBuffs()
		
		HP = maxHP
		Name = "CKRCH"'nme
		AddSkill("focus")
		AddWeakness("aero")
		AddWeakness("attack", -1)
		AddWeakness("rock")
		AddWeakness("fire")
		
		Level = lvl
		XPNextLevel = 0
	End
End

Class FrogEngima Extends DMonster
	Method New(level:Int); InitLevel(level); End
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("monsters")
		frame = 10
		
		Strength = 0
		Endurance = 0
		Knowledge = 0
		Luck = 5
		LevelToLevel(lvl)
		UpdateBuffs()
		
		HP = maxHP + Rnd(-5, 5)
		Name = "ENGM"'nme
		
		AddSkill("focus")
		Select Rnd(0, 3)
			Case 1
				AddSkill("terror")
				AddWeakness("fire", 1)
			Case 2
				AddSkill("fire")
				AddWeakness("ice", 1)
			Default
				AddSkill("aero")
				AddWeakness("rock", 1)
		End
		AddWeakness("attack", -1)
		
		Level = lvl
		XPNextLevel = 0
	End
End


Class FrogShambler Extends DMonster
	Method New(level:Int); InitLevel(level); End
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("monsters")
		frame = 7
		
		Strength = 1
		Endurance = 2
		Knowledge = 3
		Luck = 20
		LevelToLevel(lvl)
		UpdateBuffs()
		
		HP = maxHP
		Name = "SHMBR"'nme
		
		AddSkill("focus")
		AddSkill("terror")
		AddSkill("aero")
		If lvl > 10 Then
			AddSkill("fire")
		End
		AddWeakness("ice", -1)
		AddWeakness("fire", -1)
		AddWeakness("aero", -1)
		AddWeakness("rock", -1)
		AddWeakness("attack", -1)
		
		Level = lvl
		XPNextLevel = 0
	End
End

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Bosses
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


Class BossGolem Extends DMonster
	Method New(level:Int); InitLevel(level); End
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("monsters")
		frame = 5
		
		Strength = 4
		Endurance = 9
		Knowledge = 1
		Luck = 1
		LevelToLevel(lvl)
		UpdateBuffs()
		
		HP = maxHP
		Name = "GOLEM"'nme
		
		AddSkill("focus")
		AddSkill("terror")
		AddSkill("rock")
		AddWeakness("fire", -1)
		AddWeakness("aero", -1)
		AddWeakness("attack", -1)
		
		Level = lvl
		XPNextLevel = 0
	End
End

Class BossBahamaut Extends DMonster
	Method New(level:Int); InitLevel(level); End
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("monsters")
		frame = 2
		'		If lvl > 8 Then
		'			lvl = 7 + ( (lvl - 7) / 2)
		'		End
		
		'	Strength = lvl + 3
		'	Endurance = lvl
		'	Knowledge = lvl / 2
		'	Luck = lvl + 3
		Strength = 2
		Endurance = 8
		Knowledge = 4
		Luck = 15
		LevelToLevel(lvl)
		UpdateBuffs()
		
		HP = maxHP
		Name = "BAHAMAUT"
		AddSkill("fire")
		AddSkill("fire")
		AddSkill("fire")
		AddSkill("boost")
		AddSkill("aero")
		AddWeakness("aero", -1)
		
		'	Level = lvl
		XPNextLevel = 0
	End
End

Class CharArcher Extends DMonster
	Method New(level:Int); InitLevel(level); End
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("archer")
		frame = 1
		
		Strength = 10
		Endurance = 3
		Knowledge = 5
		Luck = 15
		LevelToLevel(10)
		UpdateBuffs()
		
		HP = maxHP
		Name = "ARCHER"
		AddSkill("ice")
		
		Level = 10'lvl
		XPNextLevel = 0
	End
End