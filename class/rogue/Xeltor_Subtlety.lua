local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_shanky"
	local desc = "[Xel][8.0] Blush: Shanky"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_rogue_spells)

# Subtlety (Shanky)
AddIcon specialization=3 help=main
{
	if not mounted() and not Stealthed() and not InCombat() and not IsDead() and not PlayerIsResting() Spell(stealth)
	if not InCombat() and target.Present() and target.Exists() and not target.IsFriend() and not mounted()
	{
		#marked_for_death
		if target.InRange(marked_for_death) Spell(marked_for_death)
		#symbols_of_death
		if not Talent(death_from_above_talent) and not BuffPresent(symbols_of_death_buff) Spell(symbols_of_death)
	}
	
	if InCombat() InterruptActions()
	if HealthPercent() <= 25 and HealthPercent() > 0 or HealthPercent() < 100 and HealthPercent() > 0 and not InCombat() and not mounted() Spell(crimson_vial)
	
	if target.InRange(backstab) and HasFullControl()
	{
		# Cooldowns
		if Boss() SubtletyDefaultCdActions()
		
		# Short Cooldowns
		SubtletyDefaultShortCdActions()
	
		# Default Actions
		SubtletyDefaultMainActions()
	}
	
	if InCombat() and not target.IsDead() and not target.IsFriend() and { TimeInCombat() < 6 or Falling() } GetInMeleeRange()
}

AddFunction Boss
{
	IsBossFight() or target.Classification(worldboss) or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction GetInMeleeRange
{
	if not target.InRange(kick)
	{
		if target.InRange(shadowstep) and Stealthed() Spell(shadowstrike)
		if target.InRange(shadowstep) Spell(shadowstep)
		# Texture(misc_arrowlup help=L(not_in_melee_range))
	}
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		if target.InRange(kick) and not Stealthed() Spell(kick)
		if not target.Classification(worldboss)
		{
			if target.InRange(cheap_shot) and Stealthed() Spell(cheap_shot)
			if target.InRange(kidney_shot) and not Stealthed() Spell(kidney_shot)
			if target.InRange(quaking_palm) and not Stealthed() Spell(quaking_palm)
		}
	}
}

AddFunction shd_threshold
{
 SpellCharges(shadow_dance count=0) >= 1.75
}

AddFunction stealth_threshold
{
 60 + TalentPoints(vigor_talent) * 35 + TalentPoints(master_of_shadows_talent) * 10
}

### actions.default

AddFunction SubtletyDefaultMainActions
{
 #call_action_list,name=cds
 SubtletyCdsMainActions()

 unless SubtletyCdsMainPostConditions()
 {
  #run_action_list,name=stealthed,if=stealthed.all
  if Stealthed() SubtletyStealthedMainActions()

  unless Stealthed() and SubtletyStealthedMainPostConditions()
  {
   #nightblade,if=target.time_to_die>6&remains<gcd.max&combo_points>=4-(time<10)*2
   if target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 Spell(nightblade)
   #call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold&combo_points.deficit>=4
   if EnergyDeficit() <= stealth_threshold() and ComboPointsDeficit() >= 4 SubtletyStealthCdsMainActions()

   unless EnergyDeficit() <= stealth_threshold() and ComboPointsDeficit() >= 4 and SubtletyStealthCdsMainPostConditions()
   {
    #call_action_list,name=finish,if=combo_points>=4+talent.deeper_stratagem.enabled|target.time_to_die<=1&combo_points>=3
    if ComboPoints() >= 4 + TalentPoints(deeper_stratagem_talent) or target.TimeToDie() <= 1 and ComboPoints() >= 3 SubtletyFinishMainActions()

    unless { ComboPoints() >= 4 + TalentPoints(deeper_stratagem_talent) or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishMainPostConditions()
    {
     #call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold-40*!(talent.alacrity.enabled|talent.shadow_focus.enabled|talent.master_of_shadows.enabled)
     if EnergyDeficit() <= stealth_threshold() - 40 * { not { Talent(alacrity_talent) or Talent(shadow_focus_talent) or Talent(master_of_shadows_talent) } } SubtletyBuildMainActions()
    }
   }
  }
 }
}

AddFunction SubtletyDefaultMainPostConditions
{
 SubtletyCdsMainPostConditions() or Stealthed() and SubtletyStealthedMainPostConditions() or EnergyDeficit() <= stealth_threshold() and ComboPointsDeficit() >= 4 and SubtletyStealthCdsMainPostConditions() or { ComboPoints() >= 4 + TalentPoints(deeper_stratagem_talent) or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishMainPostConditions() or EnergyDeficit() <= stealth_threshold() - 40 * { not { Talent(alacrity_talent) or Talent(shadow_focus_talent) or Talent(master_of_shadows_talent) } } and SubtletyBuildMainPostConditions()
}

AddFunction SubtletyDefaultShortCdActions
{
 #call_action_list,name=cds
 SubtletyCdsShortCdActions()

 unless SubtletyCdsShortCdPostConditions()
 {
  #run_action_list,name=stealthed,if=stealthed.all
  if Stealthed() SubtletyStealthedShortCdActions()

  unless Stealthed() and SubtletyStealthedShortCdPostConditions() or target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 and Spell(nightblade)
  {
   #call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold&combo_points.deficit>=4
   if EnergyDeficit() <= stealth_threshold() and ComboPointsDeficit() >= 4 SubtletyStealthCdsShortCdActions()

   unless EnergyDeficit() <= stealth_threshold() and ComboPointsDeficit() >= 4 and SubtletyStealthCdsShortCdPostConditions()
   {
    #call_action_list,name=finish,if=combo_points>=4+talent.deeper_stratagem.enabled|target.time_to_die<=1&combo_points>=3
    if ComboPoints() >= 4 + TalentPoints(deeper_stratagem_talent) or target.TimeToDie() <= 1 and ComboPoints() >= 3 SubtletyFinishShortCdActions()

    unless { ComboPoints() >= 4 + TalentPoints(deeper_stratagem_talent) or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishShortCdPostConditions()
    {
     #call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold-40*!(talent.alacrity.enabled|talent.shadow_focus.enabled|talent.master_of_shadows.enabled)
     if EnergyDeficit() <= stealth_threshold() - 40 * { not { Talent(alacrity_talent) or Talent(shadow_focus_talent) or Talent(master_of_shadows_talent) } } SubtletyBuildShortCdActions()
    }
   }
  }
 }
}

AddFunction SubtletyDefaultShortCdPostConditions
{
 SubtletyCdsShortCdPostConditions() or Stealthed() and SubtletyStealthedShortCdPostConditions() or target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 and Spell(nightblade) or EnergyDeficit() <= stealth_threshold() and ComboPointsDeficit() >= 4 and SubtletyStealthCdsShortCdPostConditions() or { ComboPoints() >= 4 + TalentPoints(deeper_stratagem_talent) or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishShortCdPostConditions() or EnergyDeficit() <= stealth_threshold() - 40 * { not { Talent(alacrity_talent) or Talent(shadow_focus_talent) or Talent(master_of_shadows_talent) } } and SubtletyBuildShortCdPostConditions()
}

AddFunction SubtletyDefaultCdActions
{
 #call_action_list,name=cds
 SubtletyCdsCdActions()

 unless SubtletyCdsCdPostConditions()
 {
  #run_action_list,name=stealthed,if=stealthed.all
  if Stealthed() SubtletyStealthedCdActions()

  unless Stealthed() and SubtletyStealthedCdPostConditions() or target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 and Spell(nightblade)
  {
   #call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold&combo_points.deficit>=4
   if EnergyDeficit() <= stealth_threshold() and ComboPointsDeficit() >= 4 SubtletyStealthCdsCdActions()

   unless EnergyDeficit() <= stealth_threshold() and ComboPointsDeficit() >= 4 and SubtletyStealthCdsCdPostConditions()
   {
    #call_action_list,name=finish,if=combo_points>=4+talent.deeper_stratagem.enabled|target.time_to_die<=1&combo_points>=3
    if ComboPoints() >= 4 + TalentPoints(deeper_stratagem_talent) or target.TimeToDie() <= 1 and ComboPoints() >= 3 SubtletyFinishCdActions()

    unless { ComboPoints() >= 4 + TalentPoints(deeper_stratagem_talent) or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishCdPostConditions()
    {
     #call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold-40*!(talent.alacrity.enabled|talent.shadow_focus.enabled|talent.master_of_shadows.enabled)
     if EnergyDeficit() <= stealth_threshold() - 40 * { not { Talent(alacrity_talent) or Talent(shadow_focus_talent) or Talent(master_of_shadows_talent) } } SubtletyBuildCdActions()

     unless EnergyDeficit() <= stealth_threshold() - 40 * { not { Talent(alacrity_talent) or Talent(shadow_focus_talent) or Talent(master_of_shadows_talent) } } and SubtletyBuildCdPostConditions()
     {
      #arcane_torrent,if=energy.deficit>=15+energy.regen
      if EnergyDeficit() >= 15 + EnergyRegenRate() Spell(arcane_torrent_energy)
      #arcane_pulse
      Spell(arcane_pulse)
      #lights_judgment
      Spell(lights_judgment)
     }
    }
   }
  }
 }
}

AddFunction SubtletyDefaultCdPostConditions
{
 SubtletyCdsCdPostConditions() or Stealthed() and SubtletyStealthedCdPostConditions() or target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 and Spell(nightblade) or EnergyDeficit() <= stealth_threshold() and ComboPointsDeficit() >= 4 and SubtletyStealthCdsCdPostConditions() or { ComboPoints() >= 4 + TalentPoints(deeper_stratagem_talent) or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishCdPostConditions() or EnergyDeficit() <= stealth_threshold() - 40 * { not { Talent(alacrity_talent) or Talent(shadow_focus_talent) or Talent(master_of_shadows_talent) } } and SubtletyBuildCdPostConditions()
}

### actions.build

AddFunction SubtletyBuildMainActions
{
 #shuriken_toss,if=buff.sharpened_blades.stack>=29&spell_targets.shuriken_storm<=1+3*azerite.sharpened_blades.rank=2+4*azerite.sharpened_blades.rank=3
 if BuffStacks(sharpened_blades_buff) >= 29 and Enemies(tagged=1) <= 1 + 3 * AzeriteTraitRank(sharpened_blades_trait) == 2 + 4 * AzeriteTraitRank(sharpened_blades_trait) == 3 Spell(shuriken_toss)
 #shuriken_storm,if=spell_targets.shuriken_storm>=2|buff.the_dreadlords_deceit.stack>=29
 if Enemies(tagged=1) >= 2 or BuffStacks(the_dreadlords_deceit_subtlety_buff) >= 29 Spell(shuriken_storm)
 #gloomblade
 Spell(gloomblade)
 #backstab
 Spell(backstab)
}

AddFunction SubtletyBuildMainPostConditions
{
}

AddFunction SubtletyBuildShortCdActions
{
}

AddFunction SubtletyBuildShortCdPostConditions
{
 BuffStacks(sharpened_blades_buff) >= 29 and Enemies(tagged=1) <= 1 + 3 * AzeriteTraitRank(sharpened_blades_trait) == 2 + 4 * AzeriteTraitRank(sharpened_blades_trait) == 3 and Spell(shuriken_toss) or { Enemies(tagged=1) >= 2 or BuffStacks(the_dreadlords_deceit_subtlety_buff) >= 29 } and Spell(shuriken_storm) or Spell(gloomblade) or Spell(backstab)
}

AddFunction SubtletyBuildCdActions
{
}

AddFunction SubtletyBuildCdPostConditions
{
 BuffStacks(sharpened_blades_buff) >= 29 and Enemies(tagged=1) <= 1 + 3 * AzeriteTraitRank(sharpened_blades_trait) == 2 + 4 * AzeriteTraitRank(sharpened_blades_trait) == 3 and Spell(shuriken_toss) or { Enemies(tagged=1) >= 2 or BuffStacks(the_dreadlords_deceit_subtlety_buff) >= 29 } and Spell(shuriken_storm) or Spell(gloomblade) or Spell(backstab)
}

### actions.cds

AddFunction SubtletyCdsMainActions
{
}

AddFunction SubtletyCdsMainPostConditions
{
}

AddFunction SubtletyCdsShortCdActions
{
 #symbols_of_death,if=dot.nightblade.ticking
 if target.DebuffPresent(nightblade_debuff) Spell(symbols_of_death)
 #marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit
 if target.TimeToDie() < ComboPointsDeficit() Spell(marked_for_death)
 #marked_for_death,if=raid_event.adds.in>30&!stealthed.all&combo_points.deficit>=cp_max_spend
 if 600 > 30 and not Stealthed() and ComboPointsDeficit() >= MaxComboPoints() Spell(marked_for_death)
 #shuriken_tornado,if=spell_targets>=3&dot.nightblade.ticking&buff.symbols_of_death.up&buff.shadow_dance.up
 if Enemies(tagged=1) >= 3 and target.DebuffPresent(nightblade_debuff) and BuffPresent(symbols_of_death_buff) and BuffPresent(shadow_dance_buff) Spell(shuriken_tornado)
 #shadow_dance,if=!buff.shadow_dance.up&target.time_to_die<=5+talent.subterfuge.enabled
 if not BuffPresent(shadow_dance_buff) and target.TimeToDie() <= 5 + TalentPoints(subterfuge_talent) Spell(shadow_dance)
}

AddFunction SubtletyCdsShortCdPostConditions
{
}

AddFunction SubtletyCdsCdActions
{
 #potion,if=buff.bloodlust.react|target.time_to_die<=60|(buff.vanish.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=30))
 # if { BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 60 or BuffPresent(vanish_buff) and { BuffPresent(shadow_blades_buff) or SpellCooldown(shadow_blades) <= 30 } } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_agility usable=1)
 #blood_fury,if=stealthed.rogue
 if Stealthed() Spell(blood_fury_ap)
 #berserking,if=stealthed.rogue
 if Stealthed() Spell(berserking)
 #fireblood,if=stealthed.rogue
 if Stealthed() Spell(fireblood)
 #ancestral_call,if=stealthed.rogue
 if Stealthed() Spell(ancestral_call)

 unless target.DebuffPresent(nightblade_debuff) and Spell(symbols_of_death)
 {
  #shadow_blades,if=combo_points.deficit>=2+stealthed.all
  if ComboPointsDeficit() >= 2 + Stealthed() Spell(shadow_blades)
 }
}

AddFunction SubtletyCdsCdPostConditions
{
 target.DebuffPresent(nightblade_debuff) and Spell(symbols_of_death) or Enemies(tagged=1) >= 3 and target.DebuffPresent(nightblade_debuff) and BuffPresent(symbols_of_death_buff) and BuffPresent(shadow_dance_buff) and Spell(shuriken_tornado)
}

### actions.finish

AddFunction SubtletyFinishMainActions
{
 #nightblade,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>6&remains<tick_time*2&(spell_targets.shuriken_storm<4|!buff.symbols_of_death.up)
 if { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 6 and target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 and { Enemies(tagged=1) < 4 or not BuffPresent(symbols_of_death_buff) } Spell(nightblade)
 #nightblade,cycle_targets=1,if=spell_targets.shuriken_storm>=2&(spell_targets.shuriken_storm<=5|talent.secret_technique.enabled)&!buff.shadow_dance.up&target.time_to_die>=(5+(2*combo_points))&refreshable
 if Enemies(tagged=1) >= 2 and { Enemies(tagged=1) <= 5 or Talent(secret_technique_talent) } and not BuffPresent(shadow_dance_buff) and target.TimeToDie() >= 5 + 2 * ComboPoints() and target.Refreshable(nightblade_debuff) Spell(nightblade)
 #nightblade,if=remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5&target.time_to_die-remains>cooldown.symbols_of_death.remains+5
 if target.DebuffRemaining(nightblade_debuff) < SpellCooldown(symbols_of_death) + 10 and SpellCooldown(symbols_of_death) <= 5 and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > SpellCooldown(symbols_of_death) + 5 Spell(nightblade)
 #eviscerate
 Spell(eviscerate)
}

AddFunction SubtletyFinishMainPostConditions
{
}

AddFunction SubtletyFinishShortCdActions
{
 unless { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 6 and target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 and { Enemies(tagged=1) < 4 or not BuffPresent(symbols_of_death_buff) } and Spell(nightblade) or Enemies(tagged=1) >= 2 and { Enemies(tagged=1) <= 5 or Talent(secret_technique_talent) } and not BuffPresent(shadow_dance_buff) and target.TimeToDie() >= 5 + 2 * ComboPoints() and target.Refreshable(nightblade_debuff) and Spell(nightblade) or target.DebuffRemaining(nightblade_debuff) < SpellCooldown(symbols_of_death) + 10 and SpellCooldown(symbols_of_death) <= 5 and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > SpellCooldown(symbols_of_death) + 5 and Spell(nightblade)
 {
  #secret_technique,if=buff.symbols_of_death.up&(!talent.dark_shadow.enabled|spell_targets.shuriken_storm<2|buff.shadow_dance.up)
  if BuffPresent(symbols_of_death_buff) and { not Talent(dark_shadow_talent) or Enemies(tagged=1) < 2 or BuffPresent(shadow_dance_buff) } Spell(secret_technique)
  #secret_technique,if=spell_targets.shuriken_storm>=2+talent.dark_shadow.enabled+talent.nightstalker.enabled
  if Enemies(tagged=1) >= 2 + TalentPoints(dark_shadow_talent) + TalentPoints(nightstalker_talent) Spell(secret_technique)
 }
}

AddFunction SubtletyFinishShortCdPostConditions
{
 { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 6 and target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 and { Enemies(tagged=1) < 4 or not BuffPresent(symbols_of_death_buff) } and Spell(nightblade) or Enemies(tagged=1) >= 2 and { Enemies(tagged=1) <= 5 or Talent(secret_technique_talent) } and not BuffPresent(shadow_dance_buff) and target.TimeToDie() >= 5 + 2 * ComboPoints() and target.Refreshable(nightblade_debuff) and Spell(nightblade) or target.DebuffRemaining(nightblade_debuff) < SpellCooldown(symbols_of_death) + 10 and SpellCooldown(symbols_of_death) <= 5 and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > SpellCooldown(symbols_of_death) + 5 and Spell(nightblade) or Spell(eviscerate)
}

AddFunction SubtletyFinishCdActions
{
}

AddFunction SubtletyFinishCdPostConditions
{
 { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 6 and target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 and { Enemies(tagged=1) < 4 or not BuffPresent(symbols_of_death_buff) } and Spell(nightblade) or Enemies(tagged=1) >= 2 and { Enemies(tagged=1) <= 5 or Talent(secret_technique_talent) } and not BuffPresent(shadow_dance_buff) and target.TimeToDie() >= 5 + 2 * ComboPoints() and target.Refreshable(nightblade_debuff) and Spell(nightblade) or target.DebuffRemaining(nightblade_debuff) < SpellCooldown(symbols_of_death) + 10 and SpellCooldown(symbols_of_death) <= 5 and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > SpellCooldown(symbols_of_death) + 5 and Spell(nightblade) or BuffPresent(symbols_of_death_buff) and { not Talent(dark_shadow_talent) or Enemies(tagged=1) < 2 or BuffPresent(shadow_dance_buff) } and Spell(secret_technique) or Enemies(tagged=1) >= 2 + TalentPoints(dark_shadow_talent) + TalentPoints(nightstalker_talent) and Spell(secret_technique) or Spell(eviscerate)
}

### actions.precombat

AddFunction SubtletyPrecombatMainActions
{
 #flask
 #augmentation
 #food
 #snapshot_stats
 #variable,name=stealth_threshold,value=60+talent.vigor.enabled*35+talent.master_of_shadows.enabled*10
 #stealth
 Spell(stealth)
}

AddFunction SubtletyPrecombatMainPostConditions
{
}

AddFunction SubtletyPrecombatShortCdActions
{
 unless Spell(stealth)
 {
  #marked_for_death,precombat_seconds=15
  Spell(marked_for_death)
 }
}

AddFunction SubtletyPrecombatShortCdPostConditions
{
 Spell(stealth)
}

AddFunction SubtletyPrecombatCdActions
{
 unless Spell(stealth)
 {
  #shadow_blades,precombat_seconds=1
  Spell(shadow_blades)
  #potion
  # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_agility usable=1)
 }
}

AddFunction SubtletyPrecombatCdPostConditions
{
 Spell(stealth)
}

### actions.stealth_cds

AddFunction SubtletyStealthCdsMainActions
{
}

AddFunction SubtletyStealthCdsMainPostConditions
{
}

AddFunction SubtletyStealthCdsShortCdActions
{
 #variable,name=shd_threshold,value=cooldown.shadow_dance.charges_fractional>=1.75
 #vanish,if=!variable.shd_threshold&debuff.find_weakness.remains<1
 if not shd_threshold() and target.DebuffRemaining(find_weakness_debuff) < 1 Spell(vanish)
 #pool_resource,for_next=1,extra_amount=40
 #shadowmeld,if=energy>=40&energy.deficit>=10&!variable.shd_threshold&debuff.find_weakness.remains<1
 unless True(pool_energy 40) and EnergyDeficit() >= 10 and not shd_threshold() and target.DebuffRemaining(find_weakness_debuff) < 1 and SpellUsable(shadowmeld) and SpellCooldown(shadowmeld) < TimeToEnergy(40)
 {
  #shadow_dance,if=(!talent.dark_shadow.enabled|dot.nightblade.remains>=5+talent.subterfuge.enabled)&(variable.shd_threshold|buff.symbols_of_death.remains>=1.2|spell_targets>=4&cooldown.symbols_of_death.remains>10)
  if { not Talent(dark_shadow_talent) or target.DebuffRemaining(nightblade_debuff) >= 5 + TalentPoints(subterfuge_talent) } and { shd_threshold() or BuffRemaining(symbols_of_death_buff) >= 1.2 or Enemies(tagged=1) >= 4 and SpellCooldown(symbols_of_death) > 10 } Spell(shadow_dance)
  #shadow_dance,if=target.time_to_die<cooldown.symbols_of_death.remains
  if target.TimeToDie() < SpellCooldown(symbols_of_death) Spell(shadow_dance)
 }
}

AddFunction SubtletyStealthCdsShortCdPostConditions
{
}

AddFunction SubtletyStealthCdsCdActions
{
 #pool_resource,for_next=1,extra_amount=40
 #shadowmeld,if=energy>=40&energy.deficit>=10&!variable.shd_threshold&debuff.find_weakness.remains<1
 if Energy() >= 40 and EnergyDeficit() >= 10 and not shd_threshold() and target.DebuffRemaining(find_weakness_debuff) < 1 Spell(shadowmeld)
}

AddFunction SubtletyStealthCdsCdPostConditions
{
}

### actions.stealthed

AddFunction SubtletyStealthedMainActions
{
 #shadowstrike,if=buff.stealth.up
 if BuffPresent(shot_in_the_dark_buff) and not InCombat() Spell(cheap_shot)
 if BuffPresent(stealthed_buff any=1) Spell(shadowstrike)
 if BuffPresent(shot_in_the_dark_buff) Spell(cheap_shot)
 #call_action_list,name=finish,if=combo_points.deficit<=1-(talent.deeper_stratagem.enabled&buff.vanish.up)
 if ComboPointsDeficit() <= 1 - { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } SubtletyFinishMainActions()

 unless ComboPointsDeficit() <= 1 - { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and SubtletyFinishMainPostConditions()
 {
  #shadowstrike,cycle_targets=1,if=talent.secret_technique.enabled&talent.find_weakness.enabled&debuff.find_weakness.remains<1&spell_targets.shuriken_storm=2&target.time_to_die-remains>6
  if Talent(secret_technique_talent) and Talent(find_weakness_talent) and target.DebuffRemaining(find_weakness_debuff) < 1 and Enemies(tagged=1) == 2 and target.TimeToDie() - target.DebuffRemaining(shadowstrike) > 6 Spell(shadowstrike)
  #shuriken_storm,if=spell_targets.shuriken_storm>=3
  if Enemies(tagged=1) >= 3 Spell(shuriken_storm)
  #shadowstrike
  Spell(shadowstrike)
 }
}

AddFunction SubtletyStealthedMainPostConditions
{
 ComboPointsDeficit() <= 1 - { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and SubtletyFinishMainPostConditions()
}

AddFunction SubtletyStealthedShortCdActions
{
 unless BuffPresent(stealthed_buff any=1) and Spell(shadowstrike)
 {
  #call_action_list,name=finish,if=combo_points.deficit<=1-(talent.deeper_stratagem.enabled&buff.vanish.up)
  if ComboPointsDeficit() <= 1 - { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } SubtletyFinishShortCdActions()
 }
}

AddFunction SubtletyStealthedShortCdPostConditions
{
 BuffPresent(stealthed_buff any=1) and Spell(shadowstrike) or ComboPointsDeficit() <= 1 - { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and SubtletyFinishShortCdPostConditions() or Talent(secret_technique_talent) and Talent(find_weakness_talent) and target.DebuffRemaining(find_weakness_debuff) < 1 and Enemies(tagged=1) == 2 and target.TimeToDie() - target.DebuffRemaining(shadowstrike) > 6 and Spell(shadowstrike) or Enemies(tagged=1) >= 3 and Spell(shuriken_storm) or Spell(shadowstrike)
}

AddFunction SubtletyStealthedCdActions
{
 unless BuffPresent(stealthed_buff any=1) and Spell(shadowstrike)
 {
  #call_action_list,name=finish,if=combo_points.deficit<=1-(talent.deeper_stratagem.enabled&buff.vanish.up)
  if ComboPointsDeficit() <= 1 - { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } SubtletyFinishCdActions()
 }
}

AddFunction SubtletyStealthedCdPostConditions
{
 BuffPresent(stealthed_buff any=1) and Spell(shadowstrike) or ComboPointsDeficit() <= 1 - { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and SubtletyFinishCdPostConditions() or Talent(secret_technique_talent) and Talent(find_weakness_talent) and target.DebuffRemaining(find_weakness_debuff) < 1 and Enemies(tagged=1) == 2 and target.TimeToDie() - target.DebuffRemaining(shadowstrike) > 6 and Spell(shadowstrike) or Enemies(tagged=1) >= 3 and Spell(shuriken_storm) or Spell(shadowstrike)
}
]]

	OvaleScripts:RegisterScript("ROGUE", "subtlety", name, desc, code, "script")
end
