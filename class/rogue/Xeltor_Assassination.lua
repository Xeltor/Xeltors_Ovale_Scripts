local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_stabby"
	local desc = "[Xel][7.3.5] Blush: Stabby"
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
   #run_action_list,name=stealthed,if=stealthed.rogue
   if Stealthed() AssassinationStealthedMainActions()

   unless Stealthed() and AssassinationStealthedMainPostConditions()
   {
    #call_action_list,name=maintain
    AssassinationMaintainMainActions()

    unless AssassinationMaintainMainPostConditions()
    {
     #call_action_list,name=finish,if=(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)
     if not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 AssassinationFinishMainActions()

     unless { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and AssassinationFinishMainPostConditions()
     {
      #call_action_list,name=build,if=combo_points.deficit>1+talent.anticipation.enabled*2|energy.deficit<=25+variable.energy_regen_combined
      if ComboPointsDeficit() > 1 + TalentPoints(anticipation_talent) * 2 or EnergyDeficit() <= 25 + energy_regen_combined() AssassinationBuildMainActions()
     }
    }
   }
  }
 }
}

AddFunction AssassinationDefaultMainPostConditions
{
 AssassinationCdsMainPostConditions() or Enemies(tagged=1) > 2 and AssassinationAoeMainPostConditions() or Stealthed() and AssassinationStealthedMainPostConditions() or AssassinationMaintainMainPostConditions() or { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and AssassinationFinishMainPostConditions() or { ComboPointsDeficit() > 1 + TalentPoints(anticipation_talent) * 2 or EnergyDeficit() <= 25 + energy_regen_combined() } and AssassinationBuildMainPostConditions()
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
   #run_action_list,name=stealthed,if=stealthed.rogue
   if Stealthed() AssassinationStealthedShortCdActions()

   unless Stealthed() and AssassinationStealthedShortCdPostConditions()
   {
    #call_action_list,name=maintain
    AssassinationMaintainShortCdActions()

    unless AssassinationMaintainShortCdPostConditions()
    {
     #call_action_list,name=finish,if=(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)
     if not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 AssassinationFinishShortCdActions()

     unless { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and AssassinationFinishShortCdPostConditions()
     {
      #call_action_list,name=build,if=combo_points.deficit>1+talent.anticipation.enabled*2|energy.deficit<=25+variable.energy_regen_combined
      if ComboPointsDeficit() > 1 + TalentPoints(anticipation_talent) * 2 or EnergyDeficit() <= 25 + energy_regen_combined() AssassinationBuildShortCdActions()
     }
    }
   }
  }
 }
}

AddFunction AssassinationDefaultShortCdPostConditions
{
 AssassinationCdsShortCdPostConditions() or Enemies(tagged=1) > 2 and AssassinationAoeShortCdPostConditions() or Stealthed() and AssassinationStealthedShortCdPostConditions() or AssassinationMaintainShortCdPostConditions() or { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and AssassinationFinishShortCdPostConditions() or { ComboPointsDeficit() > 1 + TalentPoints(anticipation_talent) * 2 or EnergyDeficit() <= 25 + energy_regen_combined() } and AssassinationBuildShortCdPostConditions()
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
   #run_action_list,name=stealthed,if=stealthed.rogue
   if Stealthed() AssassinationStealthedCdActions()

   unless Stealthed() and AssassinationStealthedCdPostConditions()
   {
    #call_action_list,name=maintain
    AssassinationMaintainCdActions()

    unless AssassinationMaintainCdPostConditions()
    {
     #call_action_list,name=finish,if=(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)
     if not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 AssassinationFinishCdActions()

     unless { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and AssassinationFinishCdPostConditions()
     {
      #call_action_list,name=build,if=combo_points.deficit>1+talent.anticipation.enabled*2|energy.deficit<=25+variable.energy_regen_combined
      if ComboPointsDeficit() > 1 + TalentPoints(anticipation_talent) * 2 or EnergyDeficit() <= 25 + energy_regen_combined() AssassinationBuildCdActions()

      unless { ComboPointsDeficit() > 1 + TalentPoints(anticipation_talent) * 2 or EnergyDeficit() <= 25 + energy_regen_combined() } and AssassinationBuildCdPostConditions()
      {
       #arcane_pulse
       Spell(arcane_pulse)
      }
     }
    }
   }
  }
 }
}

AddFunction AssassinationDefaultCdPostConditions
{
 AssassinationCdsCdPostConditions() or Enemies(tagged=1) > 2 and AssassinationAoeCdPostConditions() or Stealthed() and AssassinationStealthedCdPostConditions() or AssassinationMaintainCdPostConditions() or { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and AssassinationFinishCdPostConditions() or { ComboPointsDeficit() > 1 + TalentPoints(anticipation_talent) * 2 or EnergyDeficit() <= 25 + energy_regen_combined() } and AssassinationBuildCdPostConditions()
}

### actions.aoe

AddFunction AssassinationAoeMainActions
{
 #envenom,if=!buff.envenom.up&combo_points>=cp_max_spend
 if not BuffPresent(envenom_buff) and ComboPoints() >= MaxComboPoints() Spell(envenom)
 #rupture,cycle_targets=1,if=combo_points>=cp_max_spend&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>4
 if ComboPoints() >= MaxComboPoints() and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 Spell(rupture)
 #garrote,cycle_targets=1,if=talent.subterfuge.enabled&stealthed.rogue&refreshable&!exsanguinated
 if Talent(subterfuge_talent) and Stealthed() and target.Refreshable(garrote_debuff) and not target.DebuffPresent(exsanguinated) Spell(garrote)
 #envenom,if=combo_points>=cp_max_spend
 if ComboPoints() >= MaxComboPoints() Spell(envenom)
 #fan_of_knives
 Spell(fan_of_knives)
}

AddFunction AssassinationAoeMainPostConditions
{
}

AddFunction AssassinationAoeShortCdActions
{
}

AddFunction AssassinationAoeShortCdPostConditions
{
 not BuffPresent(envenom_buff) and ComboPoints() >= MaxComboPoints() and Spell(envenom) or ComboPoints() >= MaxComboPoints() and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 and Spell(rupture) or Talent(subterfuge_talent) and Stealthed() and target.Refreshable(garrote_debuff) and not target.DebuffPresent(exsanguinated) and Spell(garrote) or ComboPoints() >= MaxComboPoints() and Spell(envenom) or Spell(fan_of_knives)
}

AddFunction AssassinationAoeCdActions
{
}

AddFunction AssassinationAoeCdPostConditions
{
 not BuffPresent(envenom_buff) and ComboPoints() >= MaxComboPoints() and Spell(envenom) or ComboPoints() >= MaxComboPoints() and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 and Spell(rupture) or Talent(subterfuge_talent) and Stealthed() and target.Refreshable(garrote_debuff) and not target.DebuffPresent(exsanguinated) and Spell(garrote) or ComboPoints() >= MaxComboPoints() and Spell(envenom) or Spell(fan_of_knives)
}

### actions.build

AddFunction AssassinationBuildMainActions
{
 #hemorrhage,if=refreshable
 if target.Refreshable(hemorrhage_debuff) Spell(hemorrhage)
 #hemorrhage,cycle_targets=1,if=refreshable&dot.rupture.ticking&spell_targets.fan_of_knives<2+equipped.insignia_of_ravenholdt
 if target.Refreshable(hemorrhage_debuff) and target.DebuffPresent(rupture_debuff) and Enemies(tagged=1) < 2 + HasEquippedItem(insignia_of_ravenholdt) Spell(hemorrhage)
 #fan_of_knives,if=buff.the_dreadlords_deceit.stack>=29
 if BuffStacks(the_dreadlords_deceit_buff) >= 29 Spell(fan_of_knives)
 #mutilate,if=talent.exsanguinate.enabled&(debuff.vendetta.up|combo_points<=2)
 if Talent(exsanguinate_talent) and { target.DebuffPresent(vendetta_debuff) or ComboPoints() <= 2 } Spell(mutilate)
 #fan_of_knives,if=spell_targets>1+equipped.insignia_of_ravenholdt
 if Enemies(tagged=1) > 1 + HasEquippedItem(insignia_of_ravenholdt) Spell(fan_of_knives)
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
 target.Refreshable(hemorrhage_debuff) and Spell(hemorrhage) or target.Refreshable(hemorrhage_debuff) and target.DebuffPresent(rupture_debuff) and Enemies(tagged=1) < 2 + HasEquippedItem(insignia_of_ravenholdt) and Spell(hemorrhage) or BuffStacks(the_dreadlords_deceit_buff) >= 29 and Spell(fan_of_knives) or Talent(exsanguinate_talent) and { target.DebuffPresent(vendetta_debuff) or ComboPoints() <= 2 } and Spell(mutilate) or Enemies(tagged=1) > 1 + HasEquippedItem(insignia_of_ravenholdt) and Spell(fan_of_knives) or target.DebuffRefreshable(deadly_poison_dot_debuff) and Spell(mutilate) or Spell(mutilate)
}

AddFunction AssassinationBuildCdActions
{
}

AddFunction AssassinationBuildCdPostConditions
{
 target.Refreshable(hemorrhage_debuff) and Spell(hemorrhage) or target.Refreshable(hemorrhage_debuff) and target.DebuffPresent(rupture_debuff) and Enemies(tagged=1) < 2 + HasEquippedItem(insignia_of_ravenholdt) and Spell(hemorrhage) or BuffStacks(the_dreadlords_deceit_buff) >= 29 and Spell(fan_of_knives) or Talent(exsanguinate_talent) and { target.DebuffPresent(vendetta_debuff) or ComboPoints() <= 2 } and Spell(mutilate) or Enemies(tagged=1) > 1 + HasEquippedItem(insignia_of_ravenholdt) and Spell(fan_of_knives) or target.DebuffRefreshable(deadly_poison_dot_debuff) and Spell(mutilate) or Spell(mutilate)
}

### actions.cds

AddFunction AssassinationCdsMainActions
{
 #exsanguinate,if=!set_bonus.tier20_4pc&(prev_gcd.1.rupture&dot.rupture.remains>4+4*cp_max_spend&!stealthed.rogue|dot.garrote.pmultiplier>1&!cooldown.vanish.up&buff.subterfuge.up)
 if not ArmorSetBonus(T20 4) and { PreviousGCDSpell(rupture) and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and not Stealthed() or target.DebuffPersistentMultiplier(garrote_debuff) > 1 and not { not SpellCooldown(vanish) > 0 } and BuffPresent(subterfuge_buff) } Spell(exsanguinate)
 #exsanguinate,if=set_bonus.tier20_4pc&dot.garrote.remains>20&dot.rupture.remains>4+4*cp_max_spend
 if ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) > 20 and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() Spell(exsanguinate)
 #toxic_blade,if=combo_points.deficit>=1+(mantle_duration>=0.2)&dot.rupture.remains>8&cooldown.vendetta.remains>10|target.time_to_die<=6
 if ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and target.DebuffRemaining(rupture_debuff) > 8 and SpellCooldown(vendetta) > 10 or target.TimeToDie() <= 6 Spell(toxic_blade)
 #kingsbane,if=combo_points.deficit>=1+(mantle_duration>=0.2)&!stealthed.rogue&(!cooldown.toxic_blade.ready|!talent.toxic_blade.enabled&buff.envenom.up)|target.time_to_die<=15
 if ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and not Stealthed() and { not SpellCooldown(toxic_blade) == 0 or not Talent(toxic_blade_talent) and BuffPresent(envenom_buff) } or target.TimeToDie() <= 15 Spell(kingsbane)
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
  #vanish,if=target.time_to_die<=6
  if target.TimeToDie() <= 6 Spell(vanish)
  #vanish,if=talent.nightstalker.enabled&!talent.exsanguinate.enabled&combo_points>=cp_max_spend&mantle_duration=0&debuff.vendetta.up
  if Talent(nightstalker_talent) and not Talent(exsanguinate_talent) and ComboPoints() >= MaxComboPoints() and BuffRemaining(master_assassins_initiative) == 0 and target.DebuffPresent(vendetta_debuff) Spell(vanish)
  #vanish,if=talent.nightstalker.enabled&talent.exsanguinate.enabled&combo_points>=cp_max_spend&mantle_duration=0&cooldown.exsanguinate.remains<1
  if Talent(nightstalker_talent) and Talent(exsanguinate_talent) and ComboPoints() >= MaxComboPoints() and BuffRemaining(master_assassins_initiative) == 0 and SpellCooldown(exsanguinate) < 1 Spell(vanish)
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
 not ArmorSetBonus(T20 4) and { PreviousGCDSpell(rupture) and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and not Stealthed() or target.DebuffPersistentMultiplier(garrote_debuff) > 1 and not { not SpellCooldown(vanish) > 0 } and BuffPresent(subterfuge_buff) } and Spell(exsanguinate) or ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) > 20 and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and Spell(exsanguinate) or { ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and target.DebuffRemaining(rupture_debuff) > 8 and SpellCooldown(vendetta) > 10 or target.TimeToDie() <= 6 } and Spell(toxic_blade) or { ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and not Stealthed() and { not SpellCooldown(toxic_blade) == 0 or not Talent(toxic_blade_talent) and BuffPresent(envenom_buff) } or target.TimeToDie() <= 15 } and Spell(kingsbane)
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
 not ArmorSetBonus(T20 4) and { PreviousGCDSpell(rupture) and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and not Stealthed() or target.DebuffPersistentMultiplier(garrote_debuff) > 1 and not { not SpellCooldown(vanish) > 0 } and BuffPresent(subterfuge_buff) } and Spell(exsanguinate) or ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) > 20 and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and Spell(exsanguinate) or { ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and target.DebuffRemaining(rupture_debuff) > 8 and SpellCooldown(vendetta) > 10 or target.TimeToDie() <= 6 } and Spell(toxic_blade) or { ComboPointsDeficit() >= 1 + { BuffRemaining(master_assassins_initiative) >= 0.2 } and not Stealthed() and { not SpellCooldown(toxic_blade) == 0 or not Talent(toxic_blade_talent) and BuffPresent(envenom_buff) } or target.TimeToDie() <= 15 } and Spell(kingsbane)
}

### actions.finish

AddFunction AssassinationFinishMainActions
{
 #death_from_above,if=combo_points>=5
 if ComboPoints() >= 5 Spell(death_from_above)
 #envenom,if=talent.anticipation.enabled&combo_points>=5&((debuff.toxic_blade.up&buff.virulent_poisons.remains<2)|mantle_duration>=0.2|buff.virulent_poisons.remains<0.2|energy.deficit<=25+variable.energy_regen_combined)
 if Talent(anticipation_talent) and ComboPoints() >= 5 and { target.DebuffPresent(toxic_blade_debuff) and BuffRemaining(virulent_poisons_buff) < 2 or BuffRemaining(master_assassins_initiative) >= 0.2 or BuffRemaining(virulent_poisons_buff) < 0.2 or EnergyDeficit() <= 25 + energy_regen_combined() } Spell(envenom)
 #envenom,if=talent.anticipation.enabled&combo_points>=4&!buff.virulent_poisons.up
 if Talent(anticipation_talent) and ComboPoints() >= 4 and not BuffPresent(virulent_poisons_buff) Spell(envenom)
 #envenom,if=!talent.anticipation.enabled&combo_points>=4+(talent.deeper_stratagem.enabled&!set_bonus.tier19_4pc)&(debuff.vendetta.up|debuff.toxic_blade.up|mantle_duration>=0.2|debuff.surge_of_toxins.remains<0.2|energy.deficit<=25+variable.energy_regen_combined)
 if not Talent(anticipation_talent) and ComboPoints() >= 4 + { Talent(deeper_stratagem_talent) and not ArmorSetBonus(T19 4) } and { target.DebuffPresent(vendetta_debuff) or target.DebuffPresent(toxic_blade_debuff) or BuffRemaining(master_assassins_initiative) >= 0.2 or target.DebuffRemaining(surge_of_toxins_debuff) < 0.2 or EnergyDeficit() <= 25 + energy_regen_combined() } Spell(envenom)
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
 ComboPoints() >= 5 and Spell(death_from_above) or Talent(anticipation_talent) and ComboPoints() >= 5 and { target.DebuffPresent(toxic_blade_debuff) and BuffRemaining(virulent_poisons_buff) < 2 or BuffRemaining(master_assassins_initiative) >= 0.2 or BuffRemaining(virulent_poisons_buff) < 0.2 or EnergyDeficit() <= 25 + energy_regen_combined() } and Spell(envenom) or Talent(anticipation_talent) and ComboPoints() >= 4 and not BuffPresent(virulent_poisons_buff) and Spell(envenom) or not Talent(anticipation_talent) and ComboPoints() >= 4 + { Talent(deeper_stratagem_talent) and not ArmorSetBonus(T19 4) } and { target.DebuffPresent(vendetta_debuff) or target.DebuffPresent(toxic_blade_debuff) or BuffRemaining(master_assassins_initiative) >= 0.2 or target.DebuffRemaining(surge_of_toxins_debuff) < 0.2 or EnergyDeficit() <= 25 + energy_regen_combined() } and Spell(envenom) or Talent(elaborate_planning_talent) and ComboPoints() >= 3 + Talent(exsanguinate_talent no) and BuffRemaining(elaborate_planning_buff) < 0.2 and Spell(envenom)
}

AddFunction AssassinationFinishCdActions
{
}

AddFunction AssassinationFinishCdPostConditions
{
 ComboPoints() >= 5 and Spell(death_from_above) or Talent(anticipation_talent) and ComboPoints() >= 5 and { target.DebuffPresent(toxic_blade_debuff) and BuffRemaining(virulent_poisons_buff) < 2 or BuffRemaining(master_assassins_initiative) >= 0.2 or BuffRemaining(virulent_poisons_buff) < 0.2 or EnergyDeficit() <= 25 + energy_regen_combined() } and Spell(envenom) or Talent(anticipation_talent) and ComboPoints() >= 4 and not BuffPresent(virulent_poisons_buff) and Spell(envenom) or not Talent(anticipation_talent) and ComboPoints() >= 4 + { Talent(deeper_stratagem_talent) and not ArmorSetBonus(T19 4) } and { target.DebuffPresent(vendetta_debuff) or target.DebuffPresent(toxic_blade_debuff) or BuffRemaining(master_assassins_initiative) >= 0.2 or target.DebuffRemaining(surge_of_toxins_debuff) < 0.2 or EnergyDeficit() <= 25 + energy_regen_combined() } and Spell(envenom) or Talent(elaborate_planning_talent) and ComboPoints() >= 3 + Talent(exsanguinate_talent no) and BuffRemaining(elaborate_planning_buff) < 0.2 and Spell(envenom)
}

### actions.maintain

AddFunction AssassinationMaintainMainActions
{
 #rupture,if=talent.exsanguinate.enabled&((combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1)|(!ticking&(time>10|combo_points>=2+artifact.urge_to_kill.enabled)))
 if Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } Spell(rupture)
 #rupture,cycle_targets=1,if=combo_points>=4&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>6
 if ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 Spell(rupture)
 #pool_resource,for_next=1
 #garrote,cycle_targets=1,if=(!talent.subterfuge.enabled|!(cooldown.vanish.up&cooldown.vendetta.remains<=4))&combo_points.deficit>=1&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>4
 if { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 Spell(garrote)
 unless { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and SpellUsable(garrote) and SpellCooldown(garrote) < TimeToEnergyFor(garrote)
 {
  #garrote,if=set_bonus.tier20_4pc&talent.exsanguinate.enabled&prev_gcd.1.rupture&cooldown.exsanguinate.remains<1&(!cooldown.vanish.up|time>12)
  if ArmorSetBonus(T20 4) and Talent(exsanguinate_talent) and PreviousGCDSpell(rupture) and SpellCooldown(exsanguinate) < 1 and { not { not SpellCooldown(vanish) > 0 } or TimeInCombat() > 12 } Spell(garrote)
  #garrote,if=!set_bonus.tier20_4pc&talent.exsanguinate.enabled&cooldown.exsanguinate.remains<2+2*(cooldown.vanish.remains<2)&time>12
  if not ArmorSetBonus(T20 4) and Talent(exsanguinate_talent) and SpellCooldown(exsanguinate) < 2 + 2 * { SpellCooldown(vanish) < 2 } and TimeInCombat() > 12 Spell(garrote)
  #rupture,if=!talent.exsanguinate.enabled&combo_points>=3&!ticking&mantle_duration=0&target.time_to_die>6
  if not Talent(exsanguinate_talent) and ComboPoints() >= 3 and not target.DebuffPresent(rupture_debuff) and BuffRemaining(master_assassins_initiative) == 0 and target.TimeToDie() > 6 Spell(rupture)
 }
}

AddFunction AssassinationMaintainMainPostConditions
{
}

AddFunction AssassinationMaintainShortCdActions
{
}

AddFunction AssassinationMaintainShortCdPostConditions
{
 Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } and Spell(rupture) or ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 and Spell(rupture) or { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and Spell(garrote) or not { { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and SpellUsable(garrote) and SpellCooldown(garrote) < TimeToEnergyFor(garrote) } and { ArmorSetBonus(T20 4) and Talent(exsanguinate_talent) and PreviousGCDSpell(rupture) and SpellCooldown(exsanguinate) < 1 and { not { not SpellCooldown(vanish) > 0 } or TimeInCombat() > 12 } and Spell(garrote) or not ArmorSetBonus(T20 4) and Talent(exsanguinate_talent) and SpellCooldown(exsanguinate) < 2 + 2 * { SpellCooldown(vanish) < 2 } and TimeInCombat() > 12 and Spell(garrote) or not Talent(exsanguinate_talent) and ComboPoints() >= 3 and not target.DebuffPresent(rupture_debuff) and BuffRemaining(master_assassins_initiative) == 0 and target.TimeToDie() > 6 and Spell(rupture) }
}

AddFunction AssassinationMaintainCdActions
{
}

AddFunction AssassinationMaintainCdPostConditions
{
 Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } and Spell(rupture) or ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 and Spell(rupture) or { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and Spell(garrote) or not { { not Talent(subterfuge_talent) or not { not SpellCooldown(vanish) > 0 and SpellCooldown(vendetta) <= 4 } } and ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { PersistentMultiplier(garrote_debuff) <= 1 or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and SpellUsable(garrote) and SpellCooldown(garrote) < TimeToEnergyFor(garrote) } and { ArmorSetBonus(T20 4) and Talent(exsanguinate_talent) and PreviousGCDSpell(rupture) and SpellCooldown(exsanguinate) < 1 and { not { not SpellCooldown(vanish) > 0 } or TimeInCombat() > 12 } and Spell(garrote) or not ArmorSetBonus(T20 4) and Talent(exsanguinate_talent) and SpellCooldown(exsanguinate) < 2 + 2 * { SpellCooldown(vanish) < 2 } and TimeInCombat() > 12 and Spell(garrote) or not Talent(exsanguinate_talent) and ComboPoints() >= 3 and not target.DebuffPresent(rupture_debuff) and BuffRemaining(master_assassins_initiative) == 0 and target.TimeToDie() > 6 and Spell(rupture) }
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
  if 600 > 40 Spell(marked_for_death)
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

### actions.stealthed

AddFunction AssassinationStealthedMainActions
{
 #mutilate,if=talent.shadow_focus.enabled&dot.garrote.ticking
 if Talent(shadow_focus_talent) and target.DebuffPresent(garrote_debuff) Spell(mutilate)
 #garrote,cycle_targets=1,if=talent.subterfuge.enabled&combo_points.deficit>=1&set_bonus.tier20_4pc&((dot.garrote.remains<=13&!debuff.toxic_blade.up)|pmultiplier<=1)&!exsanguinated
 if Talent(subterfuge_talent) and ComboPointsDeficit() >= 1 and ArmorSetBonus(T20 4) and { target.DebuffRemaining(garrote_debuff) <= 13 and not target.DebuffPresent(toxic_blade_debuff) or PersistentMultiplier(garrote_debuff) <= 1 } and not target.DebuffPresent(exsanguinated) Spell(garrote)
 #garrote,cycle_targets=1,if=talent.subterfuge.enabled&combo_points.deficit>=1&!set_bonus.tier20_4pc&refreshable&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>2
 if Talent(subterfuge_talent) and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 Spell(garrote)
 #garrote,cycle_targets=1,if=talent.subterfuge.enabled&combo_points.deficit>=1&!set_bonus.tier20_4pc&remains<=10&pmultiplier<=1&!exsanguinated&target.time_to_die-remains>2
 if Talent(subterfuge_talent) and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) <= 10 and PersistentMultiplier(garrote_debuff) <= 1 and not target.DebuffPresent(exsanguinated) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 Spell(garrote)
 #rupture,cycle_targets=1,if=combo_points>=4&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>6
 if ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 Spell(rupture)
 #rupture,if=talent.exsanguinate.enabled&talent.nightstalker.enabled&target.time_to_die-remains>6
 if Talent(exsanguinate_talent) and Talent(nightstalker_talent) and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 Spell(rupture)
 #envenom,if=combo_points>=cp_max_spend
 if ComboPoints() >= MaxComboPoints() Spell(envenom)
 #garrote,if=!talent.subterfuge.enabled&target.time_to_die-remains>4
 if not Talent(subterfuge_talent) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 Spell(garrote)
 #mutilate
 Spell(mutilate)
}

AddFunction AssassinationStealthedMainPostConditions
{
}

AddFunction AssassinationStealthedShortCdActions
{
}

AddFunction AssassinationStealthedShortCdPostConditions
{
 Talent(shadow_focus_talent) and target.DebuffPresent(garrote_debuff) and Spell(mutilate) or Talent(subterfuge_talent) and ComboPointsDeficit() >= 1 and ArmorSetBonus(T20 4) and { target.DebuffRemaining(garrote_debuff) <= 13 and not target.DebuffPresent(toxic_blade_debuff) or PersistentMultiplier(garrote_debuff) <= 1 } and not target.DebuffPresent(exsanguinated) and Spell(garrote) or Talent(subterfuge_talent) and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or Talent(subterfuge_talent) and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) <= 10 and PersistentMultiplier(garrote_debuff) <= 1 and not target.DebuffPresent(exsanguinated) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 and Spell(rupture) or Talent(exsanguinate_talent) and Talent(nightstalker_talent) and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 and Spell(rupture) or ComboPoints() >= MaxComboPoints() and Spell(envenom) or not Talent(subterfuge_talent) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and Spell(garrote) or Spell(mutilate)
}

AddFunction AssassinationStealthedCdActions
{
}

AddFunction AssassinationStealthedCdPostConditions
{
 Talent(shadow_focus_talent) and target.DebuffPresent(garrote_debuff) and Spell(mutilate) or Talent(subterfuge_talent) and ComboPointsDeficit() >= 1 and ArmorSetBonus(T20 4) and { target.DebuffRemaining(garrote_debuff) <= 13 and not target.DebuffPresent(toxic_blade_debuff) or PersistentMultiplier(garrote_debuff) <= 1 } and not target.DebuffPresent(exsanguinated) and Spell(garrote) or Talent(subterfuge_talent) and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= target.TickTime(garrote_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or Talent(subterfuge_talent) and ComboPointsDeficit() >= 1 and not ArmorSetBonus(T20 4) and target.DebuffRemaining(garrote_debuff) <= 10 and PersistentMultiplier(garrote_debuff) <= 1 and not target.DebuffPresent(exsanguinated) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 2 and Spell(garrote) or ComboPoints() >= 4 and target.Refreshable(rupture_debuff) and { PersistentMultiplier(rupture_debuff) <= 1 or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) } and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= target.TickTime(rupture_debuff) * 2 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 and Spell(rupture) or Talent(exsanguinate_talent) and Talent(nightstalker_talent) and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 6 and Spell(rupture) or ComboPoints() >= MaxComboPoints() and Spell(envenom) or not Talent(subterfuge_talent) and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and Spell(garrote) or Spell(mutilate)
}
]]

	OvaleScripts:RegisterScript("ROGUE", "assassination", name, desc, code, "script")
end
