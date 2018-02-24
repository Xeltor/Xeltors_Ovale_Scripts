local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_stabby"
	local desc = "[Xel][7.3] Blush: Stabby"
	local code = [[

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_rogue_spells)

Define(honor_among_thieves_cooldown_buff 51699)
	SpellInfo(honor_among_thieves_cooldown_buff duration=2.2)

Define(crimson_vial 185311)
	SpellInfo(crimson_vial cd=30 gcd=0 energy=30)
	
# Assassination (Stabby)
AddIcon specialization=1 help=main
{
	# Stealth
	if BuffExpires(stealthed_buff any=1) and not PlayerIsResting() and not InCombat() and not mounted() Spell(stealth)
	
	if not InCombat() and target.Present() and target.Exists() and not target.IsFriend() and not mounted()
	{
		#marked_for_death
		if target.InRange(marked_for_death) Spell(marked_for_death)
		#slice_and_dice,if=talent.marked_for_death.enabled
		# if ComboPoints() >0 and not BuffPresent(slice_and_dice_buff) Spell(slice_and_dice)
	}
	
	if HealthPercent() < 70 and not Boss() Spell(crimson_vial)
	if InCombat() InterruptActions()
	
	if target.InRange(mutilate) and HasFullControl()
	{
		# Cooldowns
		if Boss() AssassinationDefaultCdActions()
		
		# Short Cooldowns
		AssassinationDefaultShortCdActions()
		
		# Default Actions
		AssassinationDefaultMainActions()
	}
	
	if InCombat() and target.Present() and not target.IsFriend() and { TimeInCombat() < 6 or Falling() } AssassinationGetInMeleeRange()
}

AddFunction Boss
{
	IsBossFight() or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction AssassinationGetInMeleeRange
{
	if not target.InRange(kick)
	{
		Spell(shadowstep)
		# Texture(misc_arrowlup help=L(not_in_melee_range))
	}
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		if target.InRange(kick) and not {BuffPresent(stealthed_buff any=1) and BuffPresent(vanish_buff)} Spell(kick)
		if target.Classification(worldboss no)
		{
			if target.InRange(cheap_shot) and {BuffPresent(stealthed_buff any=1) or BuffPresent(vanish_buff) or BuffPresent(shadow_dance_buff)} Spell(cheap_shot)
			# if target.InRange(deadly_throw) and ComboPoints() == 5 and not {BuffPresent(stealthed_buff any=1) and BuffPresent(vanish_buff)} Spell(deadly_throw)
			if target.InRange(kidney_shot) and not {BuffPresent(stealthed_buff any=1) and BuffPresent(vanish_buff)} Spell(kidney_shot)
			if target.InRange(kidney_shot) and not {BuffPresent(stealthed_buff any=1) and BuffPresent(vanish_buff)} Spell(arcane_torrent_energy)
			if target.InRange(quaking_palm) and not {BuffPresent(stealthed_buff any=1) and BuffPresent(vanish_buff)} Spell(quaking_palm)
		}
	}
}

AddFunction energy_regen_combined
{
 EnergyRegenRate() + { DebuffCountOnAny(rupture_debuff) + DebuffCountOnAny(garrote_debuff) + Talent(internal_bleeding_talent) * DebuffCountOnAny(internal_bleeding_debuff) } * { 7 + TalentPoints(venom_rush_talent) * 3 } / 2
}

AddFunction energy_time_to_max_combined
{
 EnergyDeficit() / energy_regen_combined()
}

### actions.default

AddFunction AssassinationDefaultMainActions
{
 #variable,name=energy_regen_combined,value=energy.regen+poisoned_bleeds*(7+talent.venom_rush.enabled*3)%2
 #variable,name=energy_time_to_max_combined,value=energy.deficit%variable.energy_regen_combined
 #call_action_list,name=cds
 AssassinationCdsMainActions()

 unless AssassinationCdsMainPostConditions()
 {
  #run_action_list,name=aoe,if=spell_targets.fan_of_knives>2
  if Enemies(tagged=1) > 2 AssassinationAoeMainActions()

  unless Enemies(tagged=1) > 2 and AssassinationAoeMainPostConditions()
  {
   #call_action_list,name=maintain
   AssassinationMaintainMainActions()

   unless AssassinationMaintainMainPostConditions()
   {
    #call_action_list,name=finish,if=(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)&(!dot.rupture.refreshable|(dot.rupture.exsanguinated&dot.rupture.remains>=3.5)|target.time_to_die-dot.rupture.remains<=6)&active_dot.rupture>=spell_targets.rupture
    if { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) AssassinationFinishMainActions()

    unless { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) and AssassinationFinishMainPostConditions()
    {
     #call_action_list,name=build,if=combo_points.deficit>1|energy.deficit<=25+variable.energy_regen_combined
     if ComboPointsDeficit() > 1 or EnergyDeficit() <= 25 + energy_regen_combined() AssassinationBuildMainActions()
    }
   }
  }
 }
}

AddFunction AssassinationDefaultMainPostConditions
{
 AssassinationCdsMainPostConditions() or Enemies(tagged=1) > 2 and AssassinationAoeMainPostConditions() or AssassinationMaintainMainPostConditions() or { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) and AssassinationFinishMainPostConditions() or { ComboPointsDeficit() > 1 or EnergyDeficit() <= 25 + energy_regen_combined() } and AssassinationBuildMainPostConditions()
}

AddFunction AssassinationDefaultShortCdActions
{
 #variable,name=energy_regen_combined,value=energy.regen+poisoned_bleeds*(7+talent.venom_rush.enabled*3)%2
 #variable,name=energy_time_to_max_combined,value=energy.deficit%variable.energy_regen_combined
 #call_action_list,name=cds
 AssassinationCdsShortCdActions()

 unless AssassinationCdsShortCdPostConditions()
 {
  #run_action_list,name=aoe,if=spell_targets.fan_of_knives>2
  if Enemies(tagged=1) > 2 AssassinationAoeShortCdActions()

  unless Enemies(tagged=1) > 2 and AssassinationAoeShortCdPostConditions()
  {
   #call_action_list,name=maintain
   AssassinationMaintainShortCdActions()

   unless AssassinationMaintainShortCdPostConditions()
   {
    #call_action_list,name=finish,if=(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)&(!dot.rupture.refreshable|(dot.rupture.exsanguinated&dot.rupture.remains>=3.5)|target.time_to_die-dot.rupture.remains<=6)&active_dot.rupture>=spell_targets.rupture
    if { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) AssassinationFinishShortCdActions()

    unless { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) and AssassinationFinishShortCdPostConditions()
    {
     #call_action_list,name=build,if=combo_points.deficit>1|energy.deficit<=25+variable.energy_regen_combined
     if ComboPointsDeficit() > 1 or EnergyDeficit() <= 25 + energy_regen_combined() AssassinationBuildShortCdActions()
    }
   }
  }
 }
}

AddFunction AssassinationDefaultShortCdPostConditions
{
 AssassinationCdsShortCdPostConditions() or Enemies(tagged=1) > 2 and AssassinationAoeShortCdPostConditions() or AssassinationMaintainShortCdPostConditions() or { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) and AssassinationFinishShortCdPostConditions() or { ComboPointsDeficit() > 1 or EnergyDeficit() <= 25 + energy_regen_combined() } and AssassinationBuildShortCdPostConditions()
}

AddFunction AssassinationDefaultCdActions
{
 #variable,name=energy_regen_combined,value=energy.regen+poisoned_bleeds*(7+talent.venom_rush.enabled*3)%2
 #variable,name=energy_time_to_max_combined,value=energy.deficit%variable.energy_regen_combined
 #call_action_list,name=cds
 AssassinationCdsCdActions()

 unless AssassinationCdsCdPostConditions()
 {
  #run_action_list,name=aoe,if=spell_targets.fan_of_knives>2
  if Enemies(tagged=1) > 2 AssassinationAoeCdActions()

  unless Enemies(tagged=1) > 2 and AssassinationAoeCdPostConditions()
  {
   #call_action_list,name=maintain
   AssassinationMaintainCdActions()

   unless AssassinationMaintainCdPostConditions()
   {
    #call_action_list,name=finish,if=(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)&(!dot.rupture.refreshable|(dot.rupture.exsanguinated&dot.rupture.remains>=3.5)|target.time_to_die-dot.rupture.remains<=6)&active_dot.rupture>=spell_targets.rupture
    if { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) AssassinationFinishCdActions()

    unless { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) and AssassinationFinishCdPostConditions()
    {
     #call_action_list,name=build,if=combo_points.deficit>1|energy.deficit<=25+variable.energy_regen_combined
     if ComboPointsDeficit() > 1 or EnergyDeficit() <= 25 + energy_regen_combined() AssassinationBuildCdActions()
    }
   }
  }
 }
}

AddFunction AssassinationDefaultCdPostConditions
{
 AssassinationCdsCdPostConditions() or Enemies(tagged=1) > 2 and AssassinationAoeCdPostConditions() or AssassinationMaintainCdPostConditions() or { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 6 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) and AssassinationFinishCdPostConditions() or { ComboPointsDeficit() > 1 or EnergyDeficit() <= 25 + energy_regen_combined() } and AssassinationBuildCdPostConditions()
}

### actions.aoe

AddFunction AssassinationAoeMainActions
{
 #envenom,if=!buff.envenom.up&combo_points>=cp_max_spend
 if not BuffPresent(envenom_buff) and ComboPoints() >= MaxComboPoints() Spell(envenom)
 #call_action_list,name=kb,if=combo_points.deficit>=1+(mantle_duration>=0.2)&(!talent.exsanguinate.enabled|!cooldown.exanguinate.up|time>9)
 if ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and { not Talent(exsanguinate_talent) or not { not SpellCooldown(exsanguinate) > 0 } or TimeInCombat() > 9 } AssassinationKbMainActions()

 unless ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and { not Talent(exsanguinate_talent) or not { not SpellCooldown(exsanguinate) > 0 } or TimeInCombat() > 9 } and AssassinationKbMainPostConditions()
 {
  #rupture,cycle_targets=1,if=combo_points>=cp_max_spend&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>4
  if ComboPoints() >= MaxComboPoints() and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 Spell(rupture)
  #envenom,if=combo_points>=cp_max_spend
  if ComboPoints() >= MaxComboPoints() Spell(envenom)
  #fan_of_knives
  Spell(fan_of_knives)
 }
}

AddFunction AssassinationAoeMainPostConditions
{
 ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and { not Talent(exsanguinate_talent) or not { not SpellCooldown(exsanguinate) > 0 } or TimeInCombat() > 9 } and AssassinationKbMainPostConditions()
}

AddFunction AssassinationAoeShortCdActions
{
 unless not BuffPresent(envenom_buff) and ComboPoints() >= MaxComboPoints() and Spell(envenom)
 {
  #call_action_list,name=kb,if=combo_points.deficit>=1+(mantle_duration>=0.2)&(!talent.exsanguinate.enabled|!cooldown.exanguinate.up|time>9)
  if ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and { not Talent(exsanguinate_talent) or not { not SpellCooldown(exsanguinate) > 0 } or TimeInCombat() > 9 } AssassinationKbShortCdActions()
 }
}

AddFunction AssassinationAoeShortCdPostConditions
{
 not BuffPresent(envenom_buff) and ComboPoints() >= MaxComboPoints() and Spell(envenom) or ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and { not Talent(exsanguinate_talent) or not { not SpellCooldown(exsanguinate) > 0 } or TimeInCombat() > 9 } and AssassinationKbShortCdPostConditions() or ComboPoints() >= MaxComboPoints() and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 and Spell(rupture) or ComboPoints() >= MaxComboPoints() and Spell(envenom) or Spell(fan_of_knives)
}

AddFunction AssassinationAoeCdActions
{
 unless not BuffPresent(envenom_buff) and ComboPoints() >= MaxComboPoints() and Spell(envenom)
 {
  #call_action_list,name=kb,if=combo_points.deficit>=1+(mantle_duration>=0.2)&(!talent.exsanguinate.enabled|!cooldown.exanguinate.up|time>9)
  if ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and { not Talent(exsanguinate_talent) or not { not SpellCooldown(exsanguinate) > 0 } or TimeInCombat() > 9 } AssassinationKbCdActions()
 }
}

AddFunction AssassinationAoeCdPostConditions
{
 not BuffPresent(envenom_buff) and ComboPoints() >= MaxComboPoints() and Spell(envenom) or ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and { not Talent(exsanguinate_talent) or not { not SpellCooldown(exsanguinate) > 0 } or TimeInCombat() > 9 } and AssassinationKbCdPostConditions() or ComboPoints() >= MaxComboPoints() and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 and Spell(rupture) or ComboPoints() >= MaxComboPoints() and Spell(envenom) or Spell(fan_of_knives)
}

### actions.build

AddFunction AssassinationBuildMainActions
{
 #hemorrhage,if=refreshable
 if target.Refreshable(hemorrhage_debuff) Spell(hemorrhage)
 #hemorrhage,cycle_targets=1,if=refreshable&dot.rupture.ticking&spell_targets.fan_of_knives<2+equipped.insignia_of_ravenholdt
 if target.Refreshable(hemorrhage_debuff) and target.DebuffPresent(rupture_debuff) and Enemies(tagged=1) < 2 + HasEquippedItem(insignia_of_ravenholdt) Spell(hemorrhage)
 #fan_of_knives,if=spell_targets>1+equipped.insignia_of_ravenholdt|buff.the_dreadlords_deceit.stack>=29
 if Enemies(tagged=1) > 1 + HasEquippedItem(insignia_of_ravenholdt) or BuffStacks(the_dreadlords_deceit_buff) >= 29 Spell(fan_of_knives)
 #mutilate,cycle_targets=1,if=dot.deadly_poison_dot.refreshable
 if target.DebuffRefreshable(deadly_poison_dot_debuff) Spell(mutilate)
 #mutilate
 Spell(mutilate)
}

AddFunction AssassinationBuildMainPostConditions
{
}

AddFunction AssassinationBuildShortCdActions
{
}

AddFunction AssassinationBuildShortCdPostConditions
{
 target.Refreshable(hemorrhage_debuff) and Spell(hemorrhage) or target.Refreshable(hemorrhage_debuff) and target.DebuffPresent(rupture_debuff) and Enemies(tagged=1) < 2 + HasEquippedItem(insignia_of_ravenholdt) and Spell(hemorrhage) or { Enemies(tagged=1) > 1 + HasEquippedItem(insignia_of_ravenholdt) or BuffStacks(the_dreadlords_deceit_buff) >= 29 } and Spell(fan_of_knives) or target.DebuffRefreshable(deadly_poison_dot_debuff) and Spell(mutilate) or Spell(mutilate)
}

AddFunction AssassinationBuildCdActions
{
}

AddFunction AssassinationBuildCdPostConditions
{
 target.Refreshable(hemorrhage_debuff) and Spell(hemorrhage) or target.Refreshable(hemorrhage_debuff) and target.DebuffPresent(rupture_debuff) and Enemies(tagged=1) < 2 + HasEquippedItem(insignia_of_ravenholdt) and Spell(hemorrhage) or { Enemies(tagged=1) > 1 + HasEquippedItem(insignia_of_ravenholdt) or BuffStacks(the_dreadlords_deceit_buff) >= 29 } and Spell(fan_of_knives) or target.DebuffRefreshable(deadly_poison_dot_debuff) and Spell(mutilate) or Spell(mutilate)
}

### actions.cds

AddFunction AssassinationCdsMainActions
{
 #exsanguinate,if=!set_bonus.tier20_4pc&(prev_gcd.1.rupture&dot.rupture.remains>4+4*cp_max_spend&!stealthed.rogue|dot.garrote.pmultiplier>1&!cooldown.vanish.up&buff.subterfuge.up)
 if not ArmorSetBonus(T20 4) and { PreviousGCDSpell(rupture) and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and not Stealthed() or target.DebuffPersistentMultiplier(garrote_debuff) > 1 and not { not SpellCooldown(vanish) > 0 } and BuffPresent(subterfuge_buff) } Spell(exsanguinate)
 #exsanguinate,if=set_bonus.tier20_4pc&dot.garrote.remains>20&dot.rupture.remains>4+4*cp_max_spend
 if ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) > 20 and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() Spell(exsanguinate)
 #toxic_blade,if=combo_points.deficit>=1+(mantle_duration>=0.2)&dot.rupture.remains>8&cooldown.vendetta.remains>10
 if ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and target.DebuffRemaining(rupture_debuff) > 8 and SpellCooldown(vendetta) > 10 Spell(toxic_blade)
}

AddFunction AssassinationCdsMainPostConditions
{
}

AddFunction AssassinationCdsShortCdActions
{
 #marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit*1.5|(raid_event.adds.in>40&combo_points.deficit>=cp_max_spend)
 if target.TimeToDie() < ComboPointsDeficit() * 1.5 or 600 > 40 and ComboPointsDeficit() >= MaxComboPoints() Spell(marked_for_death)

 unless not ArmorSetBonus(T20 4) and { PreviousGCDSpell(rupture) and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and not Stealthed() or target.DebuffPersistentMultiplier(garrote_debuff) > 1 and not { not SpellCooldown(vanish) > 0 } and BuffPresent(subterfuge_buff) } and Spell(exsanguinate) or ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) > 20 and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and Spell(exsanguinate)
 {
  #vanish,if=talent.nightstalker.enabled&combo_points>=cp_max_spend&!talent.exsanguinate.enabled&mantle_duration=0&((equipped.mantle_of_the_master_assassin&set_bonus.tier19_4pc)|((!equipped.mantle_of_the_master_assassin|!set_bonus.tier19_4pc)&debuff.vendetta.up))
  if Talent(nightstalker_talent) and ComboPoints() >= MaxComboPoints() and not Talent(exsanguinate_talent) and BuffRemaining(master_assassins_initiative) == 0 and { HasEquippedItem(mantle_of_the_master_assassin) and ArmorSetBonus(T19 4) or { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } and target.DebuffPresent(vendetta_debuff) } Spell(vanish)
  #vanish,if=talent.nightstalker.enabled&combo_points>=cp_max_spend&talent.exsanguinate.enabled&cooldown.exsanguinate.remains<1&(dot.rupture.ticking|time>10)
  if Talent(nightstalker_talent) and ComboPoints() >= MaxComboPoints() and Talent(exsanguinate_talent) and SpellCooldown(exsanguinate) < 1 and { target.DebuffPresent(rupture_debuff) or TimeInCombat() > 10 } Spell(vanish)
  #vanish,if=talent.subterfuge.enabled&equipped.mantle_of_the_master_assassin&(debuff.vendetta.up|target.time_to_die<10)&mantle_duration=0
  if Talent(subterfuge_talent) and HasEquippedItem(mantle_of_the_master_assassin) and { target.DebuffPresent(vendetta_debuff) or target.TimeToDie() < 10 } and BuffRemaining(master_assassins_initiative) == 0 Spell(vanish)
  #vanish,if=talent.subterfuge.enabled&!equipped.mantle_of_the_master_assassin&!stealthed.rogue&dot.garrote.refreshable&((spell_targets.fan_of_knives<=3&combo_points.deficit>=1+spell_targets.fan_of_knives)|(spell_targets.fan_of_knives>=4&combo_points.deficit>=4))
  if Talent(subterfuge_talent) and not HasEquippedItem(mantle_of_the_master_assassin) and not Stealthed() and target.DebuffRefreshable(garrote_debuff) and { Enemies(tagged=1) <= 3 and ComboPointsDeficit() >= 1 + Enemies(tagged=1) or Enemies(tagged=1) >= 4 and ComboPointsDeficit() >= 4 } Spell(vanish)
  #vanish,if=talent.shadow_focus.enabled&variable.energy_time_to_max_combined>=2&combo_points.deficit>=4
  if Talent(shadow_focus_talent) and energy_time_to_max_combined() >= 2 and ComboPointsDeficit() >= 4 Spell(vanish)
 }
}

AddFunction AssassinationCdsShortCdPostConditions
{
 not ArmorSetBonus(T20 4) and { PreviousGCDSpell(rupture) and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and not Stealthed() or target.DebuffPersistentMultiplier(garrote_debuff) > 1 and not { not SpellCooldown(vanish) > 0 } and BuffPresent(subterfuge_buff) } and Spell(exsanguinate) or ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) > 20 and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and Spell(exsanguinate) or ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and target.DebuffRemaining(rupture_debuff) > 8 and SpellCooldown(vendetta) > 10 and Spell(toxic_blade)
}

AddFunction AssassinationCdsCdActions
{
 #potion,if=buff.bloodlust.react|target.time_to_die<=60|debuff.vendetta.up&cooldown.vanish.remains<5
 # if { BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 60 or target.DebuffPresent(vendetta_debuff) and SpellCooldown(vanish) < 5 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
 #blood_fury,if=debuff.vendetta.up
 if target.DebuffPresent(vendetta_debuff) Spell(blood_fury_ap)
 #berserking,if=debuff.vendetta.up
 if target.DebuffPresent(vendetta_debuff) Spell(berserking)
 #arcane_torrent,if=dot.kingsbane.ticking&!buff.envenom.up&energy.deficit>=15+variable.energy_regen_combined*gcd.remains*1.1
 if target.DebuffPresent(kingsbane_debuff) and not BuffPresent(envenom_buff) and EnergyDeficit() >= 15 + energy_regen_combined() * GCDRemaining() * 1.1 Spell(arcane_torrent_energy)
 #vendetta,if=!talent.exsanguinate.enabled|dot.rupture.ticking
 if not Talent(exsanguinate_talent) or target.DebuffPresent(rupture_debuff) Spell(vendetta)
}

AddFunction AssassinationCdsCdPostConditions
{
 not ArmorSetBonus(T20 4) and { PreviousGCDSpell(rupture) and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and not Stealthed() or target.DebuffPersistentMultiplier(garrote_debuff) > 1 and not { not SpellCooldown(vanish) > 0 } and BuffPresent(subterfuge_buff) } and Spell(exsanguinate) or ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) > 20 and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and Spell(exsanguinate) or ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and target.DebuffRemaining(rupture_debuff) > 8 and SpellCooldown(vendetta) > 10 and Spell(toxic_blade)
}

### actions.finish

AddFunction AssassinationFinishMainActions
{
 #death_from_above,if=combo_points>=5
 if ComboPoints() >= 5 Spell(death_from_above)
 #envenom,if=(combo_points>=cp_max_spend|!talent.anticipation.enabled&combo_points>=4+(talent.deeper_stratagem.enabled&!set_bonus.tier19_4pc))&(debuff.vendetta.up|mantle_duration>=0.2|debuff.surge_of_toxins.remains<0.2|energy.deficit<=25+variable.energy_regen_combined)
 if { ComboPoints() >= MaxComboPoints() or not Talent(anticipation_talent) and ComboPoints() >= 4 + { Talent(deeper_stratagem_talent) and not ArmorSetBonus(T19 4) } } and { target.DebuffPresent(vendetta_debuff) or BuffRemaining(master_assassins_initiative) >= 0.2 or target.DebuffRemaining(surge_of_toxins_debuff) < 0.2 or EnergyDeficit() <= 25 + energy_regen_combined() } Spell(envenom)
 #envenom,if=talent.elaborate_planning.enabled&combo_points>=3+!talent.exsanguinate.enabled&buff.elaborate_planning.remains<0.2
 if Talent(elaborate_planning_talent) and ComboPoints() >= 3 + Talent(exsanguinate_talent no) and BuffRemaining(elaborate_planning_buff) < 0.2 Spell(envenom)
}

AddFunction AssassinationFinishMainPostConditions
{
}

AddFunction AssassinationFinishShortCdActions
{
}

AddFunction AssassinationFinishShortCdPostConditions
{
 ComboPoints() >= 5 and Spell(death_from_above) or { ComboPoints() >= MaxComboPoints() or not Talent(anticipation_talent) and ComboPoints() >= 4 + { Talent(deeper_stratagem_talent) and not ArmorSetBonus(T19 4) } } and { target.DebuffPresent(vendetta_debuff) or BuffRemaining(master_assassins_initiative) >= 0.2 or target.DebuffRemaining(surge_of_toxins_debuff) < 0.2 or EnergyDeficit() <= 25 + energy_regen_combined() } and Spell(envenom) or Talent(elaborate_planning_talent) and ComboPoints() >= 3 + Talent(exsanguinate_talent no) and BuffRemaining(elaborate_planning_buff) < 0.2 and Spell(envenom)
}

AddFunction AssassinationFinishCdActions
{
}

AddFunction AssassinationFinishCdPostConditions
{
 ComboPoints() >= 5 and Spell(death_from_above) or { ComboPoints() >= MaxComboPoints() or not Talent(anticipation_talent) and ComboPoints() >= 4 + { Talent(deeper_stratagem_talent) and not ArmorSetBonus(T19 4) } } and { target.DebuffPresent(vendetta_debuff) or BuffRemaining(master_assassins_initiative) >= 0.2 or target.DebuffRemaining(surge_of_toxins_debuff) < 0.2 or EnergyDeficit() <= 25 + energy_regen_combined() } and Spell(envenom) or Talent(elaborate_planning_talent) and ComboPoints() >= 3 + Talent(exsanguinate_talent no) and BuffRemaining(elaborate_planning_buff) < 0.2 and Spell(envenom)
}

### actions.kb

AddFunction AssassinationKbMainActions
{
 #kingsbane,if=artifact.sinister_circulation.enabled&!(equipped.duskwalkers_footpads&equipped.convergence_of_fates&artifact.master_assassin.rank>=6)&(time>25|!equipped.mantle_of_the_master_assassin|(debuff.vendetta.up&debuff.surge_of_toxins.up))&(talent.subterfuge.enabled|!stealthed.rogue|(talent.nightstalker.enabled&(!equipped.mantle_of_the_master_assassin|!set_bonus.tier19_4pc)))
 if HasArtifactTrait(sinister_circulation) and not { HasEquippedItem(duskwalkers_footpads) and HasEquippedItem(convergence_of_fates) and ArtifactTraitRank(master_assassin) >= 6 } and { TimeInCombat() > 25 or not HasEquippedItem(mantle_of_the_master_assassin) or target.DebuffPresent(vendetta_debuff) and target.DebuffPresent(surge_of_toxins_debuff) } and { Talent(subterfuge_talent) or not Stealthed() or Talent(nightstalker_talent) and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } } Spell(kingsbane)
 #kingsbane,if=buff.envenom.up&((debuff.vendetta.up&debuff.surge_of_toxins.up)|cooldown.vendetta.remains<=5.8|cooldown.vendetta.remains>=10)
 if BuffPresent(envenom_buff) and { target.DebuffPresent(vendetta_debuff) and target.DebuffPresent(surge_of_toxins_debuff) or SpellCooldown(vendetta) <= 5.8 or SpellCooldown(vendetta) >= 10 } Spell(kingsbane)
}

AddFunction AssassinationKbMainPostConditions
{
}

AddFunction AssassinationKbShortCdActions
{
}

AddFunction AssassinationKbShortCdPostConditions
{
 HasArtifactTrait(sinister_circulation) and not { HasEquippedItem(duskwalkers_footpads) and HasEquippedItem(convergence_of_fates) and ArtifactTraitRank(master_assassin) >= 6 } and { TimeInCombat() > 25 or not HasEquippedItem(mantle_of_the_master_assassin) or target.DebuffPresent(vendetta_debuff) and target.DebuffPresent(surge_of_toxins_debuff) } and { Talent(subterfuge_talent) or not Stealthed() or Talent(nightstalker_talent) and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } } and Spell(kingsbane) or BuffPresent(envenom_buff) and { target.DebuffPresent(vendetta_debuff) and target.DebuffPresent(surge_of_toxins_debuff) or SpellCooldown(vendetta) <= 5.8 or SpellCooldown(vendetta) >= 10 } and Spell(kingsbane)
}

AddFunction AssassinationKbCdActions
{
}

AddFunction AssassinationKbCdPostConditions
{
 HasArtifactTrait(sinister_circulation) and not { HasEquippedItem(duskwalkers_footpads) and HasEquippedItem(convergence_of_fates) and ArtifactTraitRank(master_assassin) >= 6 } and { TimeInCombat() > 25 or not HasEquippedItem(mantle_of_the_master_assassin) or target.DebuffPresent(vendetta_debuff) and target.DebuffPresent(surge_of_toxins_debuff) } and { Talent(subterfuge_talent) or not Stealthed() or Talent(nightstalker_talent) and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } } and Spell(kingsbane) or BuffPresent(envenom_buff) and { target.DebuffPresent(vendetta_debuff) and target.DebuffPresent(surge_of_toxins_debuff) or SpellCooldown(vendetta) <= 5.8 or SpellCooldown(vendetta) >= 10 } and Spell(kingsbane)
}

### actions.maintain

AddFunction AssassinationMaintainMainActions
{
 #rupture,if=talent.nightstalker.enabled&stealthed.rogue&!set_bonus.tier21_2pc&(!equipped.mantle_of_the_master_assassin|!set_bonus.tier19_4pc)&(talent.exsanguinate.enabled|target.time_to_die-remains>4)
 if Talent(nightstalker_talent) and Stealthed() and not ArmorSetBonus(T21 2) and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } and { Talent(exsanguinate_talent) or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 } Spell(rupture)
 #garrote,cycle_targets=1,if=talent.subterfuge.enabled&stealthed.rogue&combo_points.deficit>=1&set_bonus.tier20_4pc&((dot.garrote.remains<=13&!debuff.toxic_blade.up)|pmultiplier<=1)&!exsanguinated
 if Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and ArmorSetBonus(T20 4) and { target.DebuffRemaining(garrote_debuff) <= 13 and not target.DebuffPresent(toxic_blade_debuff) or PersistentMultiplier(garrote_debuff) <= 1 } and not target.DebuffPresent(exsanguinated) Spell(garrote)
 #garrote,cycle_targets=1,if=talent.subterfuge.enabled&stealthed.rogue&combo_points.deficit>=1&!set_bonus.tier20_4pc&refreshable&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>2
 if Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 Spell(garrote)
 #garrote,cycle_targets=1,if=talent.subterfuge.enabled&stealthed.rogue&combo_points.deficit>=1&!set_bonus.tier20_4pc&remains<=10&pmultiplier<=1&!exsanguinated&target.time_to_die-remains>2
 if Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) <= 10 and PersistentMultiplier(garrote_debuff) <= 1 and not target.DebuffPresent(exsanguinated) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 Spell(garrote)
 #rupture,if=!talent.exsanguinate.enabled&combo_points>=3&!ticking&mantle_duration<=0.2&target.time_to_die>6
 if not Talent(exsanguinate_talent) and ComboPoints() >= 3 and not target.DebuffPresent(rupture_debuff) and BuffRemaining(master_assassins_initiative) <= 0.2 and target.TimeToDie() > 6 Spell(rupture)
 #rupture,if=talent.exsanguinate.enabled&((combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1)|(!ticking&(time>10|combo_points>=2+artifact.urge_to_kill.enabled)))
 if Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } Spell(rupture)
 #rupture,cycle_targets=1,if=combo_points>=4&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>6
 if ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 Spell(rupture)
 #call_action_list,name=kb,if=combo_points.deficit>=1+(mantle_duration>=0.2)&(!talent.exsanguinate.enabled|!cooldown.exanguinate.up|time>9)
 if ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and { not Talent(exsanguinate_talent) or not { not SpellCooldown(exsanguinate) > 0 } or TimeInCombat() > 9 } AssassinationKbMainActions()

 unless ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and { not Talent(exsanguinate_talent) or not { not SpellCooldown(exsanguinate) > 0 } or TimeInCombat() > 9 } and AssassinationKbMainPostConditions()
 {
  #pool_resource,for_next=1
  #garrote,cycle_targets=1,if=(!talent.subterfuge.enabled|!(cooldown.vanish.up&cooldown.vendetta.remains<=4))&combo_points.deficit>=1&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>4
  if { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 Spell(garrote)
  unless { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and SpellUsable(garrote) and SpellCooldown(garrote) < TimeToEnergyFor(garrote)
  {
   #garrote,if=set_bonus.tier20_4pc&talent.exsanguinate.enabled&prev_gcd.1.rupture&cooldown.exsanguinate.remains<1&(!cooldown.vanish.up|time>12)
   if ArmorSetBonus(T20 4) and Talent(exsanguinate_talent) and PreviousGCDSpell(rupture) and SpellCooldown(exsanguinate) < 1 and { not { not SpellCooldown(vanish) > 0 } or TimeInCombat() > 12 } Spell(garrote)
  }
 }
}

AddFunction AssassinationMaintainMainPostConditions
{
 ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and { not Talent(exsanguinate_talent) or not { not SpellCooldown(exsanguinate) > 0 } or TimeInCombat() > 9 } and AssassinationKbMainPostConditions()
}

AddFunction AssassinationMaintainShortCdActions
{
 unless Talent(nightstalker_talent) and Stealthed() and not ArmorSetBonus(T21 2) and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } and { Talent(exsanguinate_talent) or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 } and Spell(rupture) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and ArmorSetBonus(T20 4) and { target.DebuffRemaining(garrote_debuff) <= 13 and not target.DebuffPresent(toxic_blade_debuff) or PersistentMultiplier(garrote_debuff) <= 1 } and not target.DebuffPresent(exsanguinated) and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) <= 10 and PersistentMultiplier(garrote_debuff) <= 1 and not target.DebuffPresent(exsanguinated) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or not Talent(exsanguinate_talent) and ComboPoints() >= 3 and not target.DebuffPresent(rupture_debuff) and BuffRemaining(master_assassins_initiative) <= 0.2 and target.TimeToDie() > 6 and Spell(rupture) or Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } and Spell(rupture) or ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 and Spell(rupture)
 {
  #call_action_list,name=kb,if=combo_points.deficit>=1+(mantle_duration>=0.2)&(!talent.exsanguinate.enabled|!cooldown.exanguinate.up|time>9)
  if ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and { not Talent(exsanguinate_talent) or not { not SpellCooldown(exsanguinate) > 0 } or TimeInCombat() > 9 } AssassinationKbShortCdActions()
 }
}

AddFunction AssassinationMaintainShortCdPostConditions
{
 Talent(nightstalker_talent) and Stealthed() and not ArmorSetBonus(T21 2) and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } and { Talent(exsanguinate_talent) or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 } and Spell(rupture) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and ArmorSetBonus(T20 4) and { target.DebuffRemaining(garrote_debuff) <= 13 and not target.DebuffPresent(toxic_blade_debuff) or PersistentMultiplier(garrote_debuff) <= 1 } and not target.DebuffPresent(exsanguinated) and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) <= 10 and PersistentMultiplier(garrote_debuff) <= 1 and not target.DebuffPresent(exsanguinated) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or not Talent(exsanguinate_talent) and ComboPoints() >= 3 and not target.DebuffPresent(rupture_debuff) and BuffRemaining(master_assassins_initiative) <= 0.2 and target.TimeToDie() > 6 and Spell(rupture) or Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } and Spell(rupture) or ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 and Spell(rupture) or ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and { not Talent(exsanguinate_talent) or not { not SpellCooldown(exsanguinate) > 0 } or TimeInCombat() > 9 } and AssassinationKbShortCdPostConditions() or { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and Spell(garrote) or not { { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and SpellUsable(garrote) and SpellCooldown(garrote) < TimeToEnergyFor(garrote) } and ArmorSetBonus(T20 4) and Talent(exsanguinate_talent) and PreviousGCDSpell(rupture) and SpellCooldown(exsanguinate) < 1 and { not { not SpellCooldown(vanish) > 0 } or TimeInCombat() > 12 } and Spell(garrote)
}

AddFunction AssassinationMaintainCdActions
{
 unless Talent(nightstalker_talent) and Stealthed() and not ArmorSetBonus(T21 2) and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } and { Talent(exsanguinate_talent) or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 } and Spell(rupture) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and ArmorSetBonus(T20 4) and { target.DebuffRemaining(garrote_debuff) <= 13 and not target.DebuffPresent(toxic_blade_debuff) or PersistentMultiplier(garrote_debuff) <= 1 } and not target.DebuffPresent(exsanguinated) and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) <= 10 and PersistentMultiplier(garrote_debuff) <= 1 and not target.DebuffPresent(exsanguinated) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or not Talent(exsanguinate_talent) and ComboPoints() >= 3 and not target.DebuffPresent(rupture_debuff) and BuffRemaining(master_assassins_initiative) <= 0.2 and target.TimeToDie() > 6 and Spell(rupture) or Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } and Spell(rupture) or ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 and Spell(rupture)
 {
  #call_action_list,name=kb,if=combo_points.deficit>=1+(mantle_duration>=0.2)&(!talent.exsanguinate.enabled|!cooldown.exanguinate.up|time>9)
  if ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and { not Talent(exsanguinate_talent) or not { not SpellCooldown(exsanguinate) > 0 } or TimeInCombat() > 9 } AssassinationKbCdActions()
 }
}

AddFunction AssassinationMaintainCdPostConditions
{
 Talent(nightstalker_talent) and Stealthed() and not ArmorSetBonus(T21 2) and { not HasEquippedItem(mantle_of_the_master_assassin) or not ArmorSetBonus(T19 4) } and { Talent(exsanguinate_talent) or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 } and Spell(rupture) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and ArmorSetBonus(T20 4) and { target.DebuffRemaining(garrote_debuff) <= 13 and not target.DebuffPresent(toxic_blade_debuff) or PersistentMultiplier(garrote_debuff) <= 1 } and not target.DebuffPresent(exsanguinated) and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or Talent(subterfuge_talent) and Stealthed() and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) <= 10 and PersistentMultiplier(garrote_debuff) <= 1 and not target.DebuffPresent(exsanguinated) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or not Talent(exsanguinate_talent) and ComboPoints() >= 3 and not target.DebuffPresent(rupture_debuff) and BuffRemaining(master_assassins_initiative) <= 0.2 and target.TimeToDie() > 6 and Spell(rupture) or Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } and Spell(rupture) or ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 and Spell(rupture) or ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and { not Talent(exsanguinate_talent) or not { not SpellCooldown(exsanguinate) > 0 } or TimeInCombat() > 9 } and AssassinationKbCdPostConditions() or { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and Spell(garrote) or not { { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and SpellUsable(garrote) and SpellCooldown(garrote) < TimeToEnergyFor(garrote) } and ArmorSetBonus(T20 4) and Talent(exsanguinate_talent) and PreviousGCDSpell(rupture) and SpellCooldown(exsanguinate) < 1 and { not { not SpellCooldown(vanish) > 0 } or TimeInCombat() > 12 } and Spell(garrote)
}

### actions.precombat

AddFunction AssassinationPrecombatMainActions
{
 #flask
 #augmentation
 #food
 #snapshot_stats
 #apply_poison
 #stealth
 Spell(stealth)
}

AddFunction AssassinationPrecombatMainPostConditions
{
}

AddFunction AssassinationPrecombatShortCdActions
{
 unless Spell(stealth)
 {
  #marked_for_death,if=raid_event.adds.in>40
  # if 600 > 40 Spell(marked_for_death)
 }
}

AddFunction AssassinationPrecombatShortCdPostConditions
{
 Spell(stealth)
}

AddFunction AssassinationPrecombatCdActions
{
 unless Spell(stealth)
 {
  #potion
  # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
 }
}

AddFunction AssassinationPrecombatCdPostConditions
{
 Spell(stealth)
}
]]

	OvaleScripts:RegisterScript("ROGUE", "assassination", name, desc, code, "script")
end
