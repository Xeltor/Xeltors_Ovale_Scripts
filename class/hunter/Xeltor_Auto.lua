local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_auto_hunter"
	local desc = "[Xel] Hunter"
	local code = [[
# Common functions.
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_hunter_spells)

# Class specific functions.
Include(xeltor_beast_mastery_functions)
# Include(xeltor_marksmanship_functions)
# Include(xeltor_survival_functions)

# Beast Master
AddIcon specialization=1 help=main
{
	if not Mounted() and not IsDead()
	{
		if not BuffPresent(volley_buff) Spell(volley)
	}

	if InCombat() and HasFullControl() and target.Present() and target.InRange(cobra_shot)
	{
		# Silence
		if InCombat() InterruptActions()
		
		# Survival
		SummonPet()
		if { not IsDead() and HealthPercent() < 50 } or { not pet.IsDead() and pet.HealthPercent() < 15 } Spell(exhilaration)
		
		# Cooldowns
		if Boss() BeastMasteryDefaultCdActions()
		
		# Short Cooldowns
		BeastMasteryDefaultShortCdActions()
		
		# Default Actions
		BeastMasteryDefaultMainActions()
	}
}
AddCheckBox(NoAoE "No-AoE" specialization=beastmastery)

# Marksman
AddIcon specialization=2 help=main
{
	if not Mounted() and not IsDead()
	{
		if not BuffPresent(volley_buff) Spell(volley)
	}

	if InCombat() and HasFullControl() and target.Present() and target.InRange(arcane_shot)
	{
		# Silence
		if InCombat() InterruptActions()
		
		# Tank stuff
		if CheckBoxOn(tank) Spell(black_arrow)
		if not IsDead() and HealthPercent() < 50 Spell(exhilaration)
		
		# Cooldowns
		# if Boss() MarksmanshipDefaultCdActions()
		
		# Short Cooldowns
		# MarksmanshipDefaultShortCdActions()
		
		# Rotation
		# MarksmanshipDefaultMainActions()
	}
}
AddCheckBox(tank "Tank" specialization=marksmanship)

# Survival
AddIcon specialization=3 help=main
{
	# Silence
	if InCombat() InterruptActions()
	
	if HasFullControl() and target.Present() and target.InRange(raptor_strike)
	{
		# Pet we needs it.
		SummonPet()
		if { not IsDead() and HealthPercent() < 50 } or { not pet.IsDead() and pet.HealthPercent() < 15 } Spell(exhilaration)
	
		# Cooldowns
		# if Boss() SurvivalDefaultCdActions()
		
		# Short Cooldowns
		# SurvivalDefaultShortCdActions()
		
		# Default Actions
		# SurvivalDefaultMainActions()
	}
	
	# Go forth and murder
	if InCombat() and HasFullControl() and target.Present() and not target.InRange(raptor_strike) and { TimeInCombat() < 6 or Falling() }
	{
		if target.InRange(harpoon) Spell(harpoon)
	}
}

# Common functions.
AddFunction Boss
{
	IsBossFight() or target.Classification(worldboss) or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction SummonPet
{
 if pet.IsDead()
 {
  if not DebuffPresent(heart_of_the_phoenix_debuff) Spell(heart_of_the_phoenix)
  Spell(revive_pet)
 }
 if not pet.IsDead() and pet.HealthPercent() < 85 and not pet.BuffStacks(mend_pet) and pet.InRange(mend_pet) Spell(mend_pet)
 if not pet.Present() and not pet.IsDead() and not PreviousSpell(revive_pet) Texture(icon_orangebird_toy)
}

AddFunction InterruptActions
{
	if not target.IsFriend()
	{
		if target.InRange(counter_shot) and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() } Spell(counter_shot)
		if target.InRange(muzzle) and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() } Spell(muzzle)
		if not target.Classification(worldboss) and { target.MustBeInterrupted() or Level() < 100 and target.IsInterruptible() or target.IsPVP() and target.IsInterruptible() }
		{
			if target.InRange(counter_shot) spell(intimidation)
			if target.Distance(less 8) Spell(arcane_torrent_focus)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}
]]
	OvaleScripts:RegisterScript("HUNTER", "all", name, desc, code, "script")
end
