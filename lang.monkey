Strict

Class L'anguage
	Global __map:StringMap<String> = New StringMap<String>()
	
	Function Get:String(k:String)
		If __map.Contains(k) Then Return __map.Get(k)
		Return "'" + k + "' STRING NOT FOUND"
	End
	
	Function InitWQ:Void()
	'	__map.Set("", "")
	
		__map.Set("skilldesc_fire", "Fire damage Enemy")
		__map.Set("skilldesc_ensnare", "Lowers Enemy Evasion")
		__map.Set("skilldesc_smoke", "Raises Ally Evasion")
		__map.Set("skilldesc_ice", "Ice damage Enemy")
		__map.Set("skilldesc_terror", "Lowers Enemy Luck")
		__map.Set("skilldesc_boost", "Raises Ally Str")
		__map.Set("skilldesc_aero", "Aero damage Enemy")
		__map.Set("skilldesc_cure", "Cures Ally debuffs")
		__map.Set("skilldesc_poison", "Lowers Enemy Str")
		__map.Set("skilldesc_rock", "Rock damage Enemy")
		__map.Set("skilldesc_heal", "Heals Ally HP")
		__map.Set("skilldesc_focus", "Raises Ally Luck")
		__map.Set("skilldesc_slash", "Attack all Enemies")
		__map.Set("skilldesc_", "")
	End
End