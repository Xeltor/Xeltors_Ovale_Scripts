local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_beast_mastery"
	local desc = "[Xel][7.1.5] Hunter: Beast Mastery"
	local code = [[
# Based on SimulationCraft profile "Hunter_BM_T18M".
#	class=hunter
#	spec=beast_mastery
#	talents=2102021

Include(ovale_common)

Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_hunter_spells)

Define(counter_shot 147362)
Define(weakened_heart 55711)
Define(heart_of_the_phoenix 55709)
Define(mend_pet 136)
	SpellInfo(mend_pet duration=10)
	SpellAddBuff(mend_pet mend_pet=1)
Define(PETGROWL 2649)
Define(misdirection 34477)
	SpellAddBuff(mend_pet misdirection_buff=1)
SpellList(misdirection_buff 34477 35079)

# Beast Master
AddIcon specialization=1 help=main
{

	if InCombat() and HasFullControl() and target.Present() and target.InRange(cobra_shot)
	{
		# Silence
		if InCombat() InterruptActions()
		
		# Survival
		HunterTankStuff()
		
		# Cooldowns
		if Boss()
		{
			BeastMasteryDefaultCdActions()
		}
		
		# Short Cooldowns
		BeastMasteryDefaultShortCdActions()
		
		if {Enemies(tagged=1) > 1 and not BuffPresent(volley_buff)} or {Enemies(tagged=1) < 2 and BuffPresent(volley_buff)} Spell(volley)
		# Default Actions
		BeastMasteryDefaultMainActions()
	}
}

# AddCheckBox(aoe "Genocide mode")
AddCheckBox(tonk "Tank mode")

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction HunterTankStuff
{
	if not pet.Present() and pet.Exists() and not DeBuffStacks(weakened_heart) and SpellKnown(heart_of_the_phoenix) and CanCast(heart_of_the_phoenix) Spell(heart_of_the_phoenix usable=1)
	if not pet.Present() and pet.Exists() and Focus() >=35 and Speed() ==0 Spell(revive_pet)
	if pet.Present() and pet.Exists() and pet.LifePercent() <85 and not pet.BuffStacks(mend_pet) and pet.InRange(mend_pet) Spell(mend_pet)
	if CheckBoxOn(tonk)
	{
		if not BuffStacks(misdirection_buff) and {focus.Present() or {pet.Present() and pet.Exists()}} Spell(misdirection)
		if not focus.Present()
		{
			if pet.Present() and pet.Exists() Spell(PETGROWL)
		}
	}
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(counter_shot) Spell(counter_shot)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_focus)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}

### actions.default

AddFunction BeastMasteryDefaultMainActions
{
	#volley,toggle=on
	# if CheckBoxOn(opt_volley) Spell(volley)
	#dire_beast,if=cooldown.bestial_wrath.remains>3
	if SpellCooldown(bestial_wrath) > 3 Spell(dire_beast)
	#dire_frenzy,if=cooldown.bestial_wrath.remains>6|target.time_to_die<9
	if SpellCooldown(bestial_wrath) > 6 or target.TimeToDie() < 9 Spell(dire_frenzy)
	#multi_shot,if=spell_targets>4&(pet.buff.beast_cleave.remains<gcd.max|pet.buff.beast_cleave.down)
	if Enemies(tagged=1) > 4 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } Spell(multi_shot)
	#kill_command
	if pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() Spell(kill_command)
	#multi_shot,if=spell_targets>1&(pet.buff.beast_cleave.remains<gcd.max*2|pet.buff.beast_cleave.down)
	if Enemies(tagged=1) > 1 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() * 2 or pet.BuffExpires(pet_beast_cleave_buff) } Spell(multi_shot)
	#chimaera_shot,if=focus<90
	if Focus() < 90 Spell(chimaera_shot)
	#cobra_shot,if=cooldown.kill_command.remains>focus.time_to_max&cooldown.bestial_wrath.remains>focus.time_to_max|(buff.bestial_wrath.up&focus.regen*cooldown.kill_command.remains>30)|target.time_to_die<cooldown.kill_command.remains
	if SpellCooldown(kill_command) > TimeToMaxFocus() and SpellCooldown(bestial_wrath) > TimeToMaxFocus() or BuffPresent(bestial_wrath_buff) and FocusRegenRate() * SpellCooldown(kill_command) > 30 or target.TimeToDie() < SpellCooldown(kill_command) Spell(cobra_shot)
}

AddFunction BeastMasteryDefaultMainPostConditions
{
}

AddFunction BeastMasteryDefaultShortCdActions
{
	unless BuffPresent(volley_buff)
	{
		#potion,name=prolonged_power,if=buff.bestial_wrath.remains|!cooldown.beastial_wrath.remains
		#a_murder_of_crows
		Spell(a_murder_of_crows)

		unless SpellCooldown(bestial_wrath) > 3 and Spell(dire_beast) or { SpellCooldown(bestial_wrath) > 6 or target.TimeToDie() < 9 } and Spell(dire_frenzy)
		{
			#barrage,if=spell_targets.barrage>1
			if Enemies(tagged=1) > 1 Spell(barrage)
			#titans_thunder,if=talent.dire_frenzy.enabled|cooldown.dire_beast.remains>=3|buff.bestial_wrath.up&pet.dire_beast.active
			if Talent(dire_frenzy_talent) or SpellCooldown(dire_beast) >= 3 or BuffPresent(bestial_wrath_buff) and pet.Present() Spell(titans_thunder)
			#bestial_wrath
			Spell(bestial_wrath)
		}
	}
}

AddFunction BeastMasteryDefaultShortCdPostConditions
{
	BuffPresent(volley_buff) or SpellCooldown(bestial_wrath) > 3 and Spell(dire_beast) or { SpellCooldown(bestial_wrath) > 6 or target.TimeToDie() < 9 } and Spell(dire_frenzy) or Enemies(tagged=1) > 4 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multi_shot) or pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() and Spell(kill_command) or Enemies(tagged=1) > 1 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() * 2 or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multi_shot) or Focus() < 90 and Spell(chimaera_shot) or { SpellCooldown(kill_command) > TimeToMaxFocus() and SpellCooldown(bestial_wrath) > TimeToMaxFocus() or BuffPresent(bestial_wrath_buff) and FocusRegenRate() * SpellCooldown(kill_command) > 30 or target.TimeToDie() < SpellCooldown(kill_command) } and Spell(cobra_shot)
}

AddFunction BeastMasteryDefaultCdActions
{
	#auto_shot
	#counter_shot
	# BeastMasteryInterruptActions()
	#arcane_torrent,if=focus.deficit>=30
	if FocusDeficit() >= 30 Spell(arcane_torrent_focus)
	#berserking
	Spell(berserking)
	#blood_fury
	Spell(blood_fury_ap)

	unless BuffPresent(volley_buff) or Spell(a_murder_of_crows)
	{
		#stampede,if=buff.bloodlust.up|buff.bestial_wrath.up|cooldown.bestial_wrath.remains<=2|target.time_to_die<=14
		if BuffPresent(burst_haste_buff any=1) or BuffPresent(bestial_wrath_buff) or SpellCooldown(bestial_wrath) <= 2 or target.TimeToDie() <= 14 Spell(stampede)

		unless SpellCooldown(bestial_wrath) > 3 and Spell(dire_beast) or { SpellCooldown(bestial_wrath) > 6 or target.TimeToDie() < 9 } and Spell(dire_frenzy)
		{
			#aspect_of_the_wild,if=buff.bestial_wrath.up|target.time_to_die<12
			if BuffPresent(bestial_wrath_buff) or target.TimeToDie() < 12 Spell(aspect_of_the_wild)
		}
	}
}

AddFunction BeastMasteryDefaultCdPostConditions
{
	BuffPresent(volley_buff) or Spell(a_murder_of_crows) or SpellCooldown(bestial_wrath) > 3 and Spell(dire_beast) or { SpellCooldown(bestial_wrath) > 6 or target.TimeToDie() < 9 } and Spell(dire_frenzy) or Enemies(tagged=1) > 1 and Spell(barrage) or { Talent(dire_frenzy_talent) or SpellCooldown(dire_beast) >= 3 or BuffPresent(bestial_wrath_buff) and pet.Present() } and Spell(titans_thunder) or Enemies(tagged=1) > 4 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multi_shot) or pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() and Spell(kill_command) or Enemies(tagged=1) > 1 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() * 2 or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multi_shot) or Focus() < 90 and Spell(chimaera_shot) or { SpellCooldown(kill_command) > TimeToMaxFocus() and SpellCooldown(bestial_wrath) > TimeToMaxFocus() or BuffPresent(bestial_wrath_buff) and FocusRegenRate() * SpellCooldown(kill_command) > 30 or target.TimeToDie() < SpellCooldown(kill_command) } and Spell(cobra_shot)
}

### actions.precombat

AddFunction BeastMasteryPrecombatMainActions
{
	#snapshot_stats
	#potion,name=prolonged_power
	#augmentation,type=defiled
	Spell(augmentation)
}

AddFunction BeastMasteryPrecombatMainPostConditions
{
}

AddFunction BeastMasteryPrecombatShortCdActions
{
	#flask,type=flask_of_the_seventh_demon
	#food,type=nightborne_delicacy_platter
	#summon_pet
	# BeastMasterySummonPet()
}

AddFunction BeastMasteryPrecombatShortCdPostConditions
{
	Spell(augmentation)
}

AddFunction BeastMasteryPrecombatCdActions
{
}

AddFunction BeastMasteryPrecombatCdPostConditions
{
	Spell(augmentation)
}
]]

	OvaleScripts:RegisterScript("HUNTER", "beast_mastery", name, desc, code, "script")
end
