local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_beast_mastery"
	local desc = "[Xel][7.3] Hunter: Beast Mastery"
	local code = [[
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
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
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
    #kill_command,target_if=min:bestial_ferocity.remains,if=equipped.qapla_eredun_war_order
    if HasEquippedItem(qapla_eredun_war_order) and pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() Spell(kill_command)
    #dire_beast,if=((!equipped.qapla_eredun_war_order|cooldown.kill_command.remains>=1)&(set_bonus.tier19_2pc|!buff.bestial_wrath.up))|full_recharge_time<gcd.max|cooldown.titans_thunder.up|spell_targets>1
    if { not HasEquippedItem(qapla_eredun_war_order) or SpellCooldown(kill_command) >= 1 } and { ArmorSetBonus(T19 2) or not BuffPresent(bestial_wrath_buff) } or SpellCharges(dire_frenzy) >= SpellMaxCharges(dire_frenzy) or not SpellCooldown(titans_thunder) > 0 or Enemies(tagged=1) > 1 Spell(dire_beast)
    #dire_frenzy,if=(pet.cat.buff.dire_frenzy.remains<=gcd.max*1.2)|full_recharge_time<gcd.max|target.time_to_die<9
    if pet.BuffRemaining(pet_dire_frenzy_buff) <= GCD() * 1.2 or SpellCharges(dire_frenzy) >= SpellMaxCharges(dire_frenzy) or target.TimeToDie() < 9 Spell(dire_frenzy)
    #multishot,if=spell_targets>4&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
    if Enemies(tagged=1) > 4 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } Spell(multishot)
    #kill_command
    if pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() Spell(kill_command)
    #multishot,if=spell_targets>1&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
    if Enemies(tagged=1) > 1 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } Spell(multishot)
    #chimaera_shot,if=focus<90
    if Focus() < 90 Spell(chimaera_shot)
    #cobra_shot,if=(cooldown.kill_command.remains>focus.time_to_max&cooldown.bestial_wrath.remains>focus.time_to_max)|(buff.bestial_wrath.up&(spell_targets.multishot=1|focus.regen*cooldown.kill_command.remains>action.kill_command.cost))|target.time_to_die<cooldown.kill_command.remains|(equipped.parsels_tongue&buff.parsels_tongue.remains<=gcd.max*2)
    if SpellCooldown(kill_command) > TimeToMaxFocus() and SpellCooldown(bestial_wrath) > TimeToMaxFocus() or BuffPresent(bestial_wrath_buff) and { Enemies(tagged=1) == 1 or FocusRegenRate() * SpellCooldown(kill_command) > PowerCost(kill_command) } or target.TimeToDie() < SpellCooldown(kill_command) or HasEquippedItem(parsels_tongue) and BuffRemaining(parsels_tongue_buff) <= GCD() * 2 Spell(cobra_shot)
    #dire_beast,if=buff.bestial_wrath.up
    if BuffPresent(bestial_wrath_buff) Spell(dire_beast)
}

AddFunction BeastMasteryDefaultMainPostConditions
{
}

AddFunction BeastMasteryDefaultShortCdActions
{
	#a_murder_of_crows,if=cooldown.bestial_wrath.remains<3|cooldown.bestial_wrath.remains>30|target.time_to_die<16
	if SpellCooldown(bestial_wrath) < 3 or SpellCooldown(bestial_wrath) > 30 or target.TimeToDie() < 16 Spell(a_murder_of_crows)
	#bestial_wrath,if=!buff.bestial_wrath.up
	if not BuffPresent(bestial_wrath_buff) Spell(bestial_wrath)

	unless HasEquippedItem(qapla_eredun_war_order) and pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() and Spell(kill_command) or { { not HasEquippedItem(qapla_eredun_war_order) or SpellCooldown(kill_command) >= 1 } and { ArmorSetBonus(T19 2) or not BuffPresent(bestial_wrath_buff) } or SpellCharges(dire_frenzy) >= SpellMaxCharges(dire_frenzy) or not SpellCooldown(titans_thunder) > 0 or Enemies(tagged=1) > 1 } and Spell(dire_beast) or { pet.BuffRemaining(pet_dire_frenzy_buff) <= GCD() * 1.2 or SpellCharges(dire_frenzy) >= SpellMaxCharges(dire_frenzy) or target.TimeToDie() < 9 } and Spell(dire_frenzy)
	{
		#barrage,if=spell_targets.barrage>1
		if Enemies(tagged=1) > 1 Spell(barrage)
		#titans_thunder,if=(talent.dire_frenzy.enabled&(buff.bestial_wrath.up|cooldown.bestial_wrath.remains>35))|buff.bestial_wrath.up
		if Talent(dire_frenzy_talent) and { BuffPresent(bestial_wrath_buff) or SpellCooldown(bestial_wrath) > 35 } or BuffPresent(bestial_wrath_buff) Spell(titans_thunder)
	}
}

AddFunction BeastMasteryDefaultShortCdPostConditions
{
    HasEquippedItem(qapla_eredun_war_order) and pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() and Spell(kill_command) or { { not HasEquippedItem(qapla_eredun_war_order) or SpellCooldown(kill_command) >= 1 } and { ArmorSetBonus(T19 2) or not BuffPresent(bestial_wrath_buff) } or SpellCharges(dire_frenzy) >= SpellMaxCharges(dire_frenzy) or not SpellCooldown(titans_thunder) > 0 or Enemies(tagged=1) > 1 } and Spell(dire_beast) or { pet.BuffRemaining(pet_dire_frenzy_buff) <= GCD() * 1.2 or SpellCharges(dire_frenzy) >= SpellMaxCharges(dire_frenzy) or target.TimeToDie() < 9 } and Spell(dire_frenzy) or Enemies(tagged=1) > 4 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multishot) or pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() and Spell(kill_command) or Enemies(tagged=1) > 1 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multishot) or Focus() < 90 and Spell(chimaera_shot) or { SpellCooldown(kill_command) > TimeToMaxFocus() and SpellCooldown(bestial_wrath) > TimeToMaxFocus() or BuffPresent(bestial_wrath_buff) and { Enemies(tagged=1) == 1 or FocusRegenRate() * SpellCooldown(kill_command) > PowerCost(kill_command) } or target.TimeToDie() < SpellCooldown(kill_command) or HasEquippedItem(parsels_tongue) and BuffRemaining(parsels_tongue_buff) <= GCD() * 2 } and Spell(cobra_shot) or BuffPresent(bestial_wrath_buff) and Spell(dire_beast)
}

AddFunction BeastMasteryDefaultCdActions
{
    #auto_shot
    #counter_shot,if=target.debuff.casting.react
    # if target.IsInterruptible() BeastMasteryInterruptActions()
    #use_items
    # BeastMasteryUseItemActions()
    #arcane_torrent,if=focus.deficit>=30
    if FocusDeficit() >= 30 Spell(arcane_torrent_focus)
    #berserking,if=buff.bestial_wrath.remains>7
    if BuffRemaining(bestial_wrath_buff) > 7 Spell(berserking)
    #blood_fury,if=buff.bestial_wrath.remains>7
    if BuffRemaining(bestial_wrath_buff) > 7 Spell(blood_fury_ap)

	#potion,if=buff.bestial_wrath.up&buff.aspect_of_the_wild.up
	# if BuffPresent(bestial_wrath_buff) and BuffPresent(aspect_of_the_wild_buff) and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)

	unless { SpellCooldown(bestial_wrath) < 3 or SpellCooldown(bestial_wrath) > 30 or target.TimeToDie() < 16 } and Spell(a_murder_of_crows)
	{
		#stampede,if=buff.bloodlust.up|buff.bestial_wrath.up|cooldown.bestial_wrath.remains<=2|target.time_to_die<=14
		if BuffPresent(burst_haste_buff any=1) or BuffPresent(bestial_wrath_buff) or SpellCooldown(bestial_wrath) <= 2 or target.TimeToDie() <= 14 Spell(stampede)
		#aspect_of_the_wild,if=(equipped.call_of_the_wild&equipped.convergence_of_fates&talent.one_with_the_pack.enabled)|buff.bestial_wrath.remains>7|target.time_to_die<12
		if HasEquippedItem(call_of_the_wild) and HasEquippedItem(convergence_of_fates) and Talent(one_with_the_pack_talent) or BuffRemaining(bestial_wrath_buff) > 7 or target.TimeToDie() < 12 Spell(aspect_of_the_wild)
	}
}

AddFunction BeastMasteryDefaultCdPostConditions
{
    { SpellCooldown(bestial_wrath) < 3 or SpellCooldown(bestial_wrath) > 30 or target.TimeToDie() < 16 } and Spell(a_murder_of_crows) or HasEquippedItem(qapla_eredun_war_order) and pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() and Spell(kill_command) or { { not HasEquippedItem(qapla_eredun_war_order) or SpellCooldown(kill_command) >= 1 } and { ArmorSetBonus(T19 2) or not BuffPresent(bestial_wrath_buff) } or SpellCharges(dire_frenzy) >= SpellMaxCharges(dire_frenzy) or not SpellCooldown(titans_thunder) > 0 or Enemies(tagged=1) > 1 } and Spell(dire_beast) or { pet.BuffRemaining(pet_dire_frenzy_buff) <= GCD() * 1.2 or SpellCharges(dire_frenzy) >= SpellMaxCharges(dire_frenzy) or target.TimeToDie() < 9 } and Spell(dire_frenzy) or Enemies(tagged=1) > 1 and Spell(barrage) or { Talent(dire_frenzy_talent) and { BuffPresent(bestial_wrath_buff) or SpellCooldown(bestial_wrath) > 35 } or BuffPresent(bestial_wrath_buff) } and Spell(titans_thunder) or Enemies(tagged=1) > 4 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multishot) or pet.Present() and not pet.IsIncapacitated() and not pet.IsFeared() and not pet.IsStunned() and Spell(kill_command) or Enemies(tagged=1) > 1 and { pet.BuffRemaining(pet_beast_cleave_buff) < GCD() or pet.BuffExpires(pet_beast_cleave_buff) } and Spell(multishot) or Focus() < 90 and Spell(chimaera_shot) or { SpellCooldown(kill_command) > TimeToMaxFocus() and SpellCooldown(bestial_wrath) > TimeToMaxFocus() or BuffPresent(bestial_wrath_buff) and { Enemies(tagged=1) == 1 or FocusRegenRate() * SpellCooldown(kill_command) > PowerCost(kill_command) } or target.TimeToDie() < SpellCooldown(kill_command) or HasEquippedItem(parsels_tongue) and BuffRemaining(parsels_tongue_buff) <= GCD() * 2 } and Spell(cobra_shot) or BuffPresent(bestial_wrath_buff) and Spell(dire_beast)
}

### actions.precombat

AddFunction BeastMasteryPrecombatMainActions
{
}

AddFunction BeastMasteryPrecombatMainPostConditions
{
}

AddFunction BeastMasteryPrecombatShortCdActions
{
    #flask
    #augmentation
    #food
    #summon_pet
    # BeastMasterySummonPet()
}

AddFunction BeastMasteryPrecombatShortCdPostConditions
{
}

AddFunction BeastMasteryPrecombatCdActions
{
    #snapshot_stats
    #potion
    # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
}

AddFunction BeastMasteryPrecombatCdPostConditions
{
}
]]

	OvaleScripts:RegisterScript("HUNTER", "beast_mastery", name, desc, code, "script")
end
