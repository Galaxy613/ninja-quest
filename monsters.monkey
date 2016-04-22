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
	Local randomNumber:Int = Rnd(100)
	
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

'''''''''''''''''''''''''''''''''''

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
		AddWeakness("rock")
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


Class FrogShambler Extends DMonster
	Method New(level:Int); InitLevel(level); End
	Method InitLevel:Void(lvl = 1, nme:String = "")
		img = imageMap.Get("monsters")
		frame = 7
		
		Strength = 1
		Endurance = 2
		Knowledge = 3
		Luck = 2
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