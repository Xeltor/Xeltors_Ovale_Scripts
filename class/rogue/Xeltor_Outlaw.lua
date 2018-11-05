local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_pokey"
	local desc = "[Xel][7.3.5] Blush: Outlaw edition"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_rogue_spells)

# Outlaw
AddIcon specialization=outlaw help=main
{
	# Precombat
	if not InCombat() and not target.IsDead() and not target.IsFriend() and not mounted() and not PlayerIsResting() and not IsDead()
	{
		if not Stealthed() and { not target.InRange(saber_slash) and target.InRange(marked_for_death) or CheckBoxOn(auto_st) } Spell(stealth)
		if Boss() and BuffPresent(blade_flurry_buff) Spell(blade_flurry)
		#roll_the_bones,if=!talent.slice_and_dice.enabled
		if not Talent(slice_and_dice_talent) and not ss_useable() and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } Spell(roll_the_bones)
		
		unless not Talent(slice_and_dice_talent) and not ss_useable() and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() }
		{
			#marked_for_death
			if target.InRange(marked_for_death) Spell(marked_for_death)
		}
	}
	
	if InCombat() InterruptActions()
	if HealthPercent() <= 25 and HealthPercent() > 0 or HealthPercent() <= 58 and HealthPercent() > 0 and not InCombat() and not mounted() Spell(crimson_vial)
	
	if target.InRange(saber_slash) and HasFullControl()
	{
		# Cooldowns
		if Boss() OutlawDefaultCdActions()
		
		# Short Cooldowns
		OutlawDefaultShortCdActions()
		
		# Default Actions
		# BladeFlurryManager()
		OutlawDefaultMainActions()
	}
	if InCombat() and not target.InRange(saber_slash) and target.InRange(pistol_shot) and not Stealthed()
	{
		if ComboPointsDeficit() >= 1 or TimeToMaxEnergy() <= GCD() or BuffPresent(opportunity_buff) Spell(pistol_shot)
	}
}
AddCheckBox(auto_st "Stealth")

AddFunction BladeFlurryManager
{
	if InCombat() and BuffPresent(blade_flurry_buff) and Enemies(tagged=1) < 2 Spell(blade_flurry)
	if InCombat() and not BuffPresent(blade_flurry_buff) and Enemies(tagged=1) >= 2 Spell(blade_flurry)
}

AddFunction InterruptActions
{
	if not target.IsFriend()
	{
		if target.InRange(kick) and target.IsInterruptible() and target.MustBeInterrupted() and not Stealthed() Spell(kick)
		if not target.Classification(worldboss)
		{
			if target.InRange(gouge) and not Stealthed() and target.MustBeInterrupted() Spell(gouge)
			if target.InRange(blind) and not Stealthed() and target.MustBeInterrupted() Spell(blind)
			if target.InRange(cheap_shot) and Stealthed() and target.MustBeInterrupted() Spell(cheap_shot)
			if target.InRange(cheap_shot) and not Stealthed() and target.IsInterruptible() and target.MustBeInterrupted() Spell(arcane_torrent_energy)
			if target.InRange(quaking_palm) and not Stealthed() and target.MustBeInterrupted() Spell(quaking_palm)
		}
	}
}

AddFunction rtb_reroll
{
 BuffCount(roll_the_bones_buff) < 2 and { BuffPresent(loaded_dice_buff) or not BuffPresent(grand_melee_buff) and not BuffPresent(ruthless_precision_buff) }
}

AddFunction blade_flurry_sync
{
 Enemies() < 2 and 600 > 20 or BuffPresent(blade_flurry_buff)
}

AddFunction ambush_condition
{
 ComboPointsDeficit() >= 2 + 2 * { Talent(ghostly_strike_talent) and SpellCooldown(ghostly_strike) < 1 } + BuffPresent(broadside_buff) and Energy() > 60 and not BuffPresent(skull_and_crossbones_buff)
}

AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=outlaw)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=outlaw)
AddCheckBox(opt_blade_flurry SpellName(blade_flurry) default specialization=outlaw)

AddFunction OutlawGetInMeleeRange
{
 if CheckBoxOn(opt_melee_range) and not target.InRange(kick)
 {
  Spell(shadowstep)
  Texture(misc_arrowlup help=L(not_in_melee_range))
 }
}

### actions.default

AddFunction OutlawDefaultMainActions
{
 #variable,name=rtb_reroll,value=rtb_buffs<2&(buff.loaded_dice.up|!buff.grand_melee.up&!buff.ruthless_precision.up)
 #variable,name=ambush_condition,value=combo_points.deficit>=2+2*(talent.ghostly_strike.enabled&cooldown.ghostly_strike.remains<1)+buff.broadside.up&energy>60&!buff.skull_and_crossbones.up
 #variable,name=blade_flurry_sync,value=spell_targets.blade_flurry<2&raid_event.adds.in>20|buff.blade_flurry.up
 #call_action_list,name=stealth,if=stealthed.all
 if Stealthed() OutlawStealthMainActions()

 unless Stealthed() and OutlawStealthMainPostConditions()
 {
  #call_action_list,name=cds
  OutlawCdsMainActions()

  unless OutlawCdsMainPostConditions()
  {
   #call_action_list,name=finish,if=combo_points>=cp_max_spend-(buff.broadside.up+buff.opportunity.up)*(talent.quick_draw.enabled&(!talent.marked_for_death.enabled|cooldown.marked_for_death.remains>1))
   if ComboPoints() >= MaxComboPoints() - { BuffPresent(broadside_buff) + BuffPresent(opportunity_buff) } * { Talent(quick_draw_talent) and { not Talent(marked_for_death_talent) or SpellCooldown(marked_for_death) > 1 } } OutlawFinishMainActions()

   unless ComboPoints() >= MaxComboPoints() - { BuffPresent(broadside_buff) + BuffPresent(opportunity_buff) } * { Talent(quick_draw_talent) and { not Talent(marked_for_death_talent) or SpellCooldown(marked_for_death) > 1 } } and OutlawFinishMainPostConditions()
   {
    #call_action_list,name=build
    OutlawBuildMainActions()
   }
  }
 }
}

AddFunction OutlawDefaultMainPostConditions
{
 Stealthed() and OutlawStealthMainPostConditions() or OutlawCdsMainPostConditions() or ComboPoints() >= MaxComboPoints() - { BuffPresent(broadside_buff) + BuffPresent(opportunity_buff) } * { Talent(quick_draw_talent) and { not Talent(marked_for_death_talent) or SpellCooldown(marked_for_death) > 1 } } and OutlawFinishMainPostConditions() or OutlawBuildMainPostConditions()
}

AddFunction OutlawDefaultShortCdActions
{
 #variable,name=rtb_reroll,value=rtb_buffs<2&(buff.loaded_dice.up|!buff.grand_melee.up&!buff.ruthless_precision.up)
 #variable,name=ambush_condition,value=combo_points.deficit>=2+2*(talent.ghostly_strike.enabled&cooldown.ghostly_strike.remains<1)+buff.broadside.up&energy>60&!buff.skull_and_crossbones.up
 #variable,name=blade_flurry_sync,value=spell_targets.blade_flurry<2&raid_event.adds.in>20|buff.blade_flurry.up
 #call_action_list,name=stealth,if=stealthed.all
 if Stealthed() OutlawStealthShortCdActions()

 unless Stealthed() and OutlawStealthShortCdPostConditions()
 {
  #call_action_list,name=cds
  OutlawCdsShortCdActions()

  unless OutlawCdsShortCdPostConditions()
  {
   #call_action_list,name=finish,if=combo_points>=cp_max_spend-(buff.broadside.up+buff.opportunity.up)*(talent.quick_draw.enabled&(!talent.marked_for_death.enabled|cooldown.marked_for_death.remains>1))
   if ComboPoints() >= MaxComboPoints() - { BuffPresent(broadside_buff) + BuffPresent(opportunity_buff) } * { Talent(quick_draw_talent) and { not Talent(marked_for_death_talent) or SpellCooldown(marked_for_death) > 1 } } OutlawFinishShortCdActions()

   unless ComboPoints() >= MaxComboPoints() - { BuffPresent(broadside_buff) + BuffPresent(opportunity_buff) } * { Talent(quick_draw_talent) and { not Talent(marked_for_death_talent) or SpellCooldown(marked_for_death) > 1 } } and OutlawFinishShortCdPostConditions()
   {
    #call_action_list,name=build
    OutlawBuildShortCdActions()
   }
  }
 }
}

AddFunction OutlawDefaultShortCdPostConditions
{
 Stealthed() and OutlawStealthShortCdPostConditions() or OutlawCdsShortCdPostConditions() or ComboPoints() >= MaxComboPoints() - { BuffPresent(broadside_buff) + BuffPresent(opportunity_buff) } * { Talent(quick_draw_talent) and { not Talent(marked_for_death_talent) or SpellCooldown(marked_for_death) > 1 } } and OutlawFinishShortCdPostConditions() or OutlawBuildShortCdPostConditions()
}

AddFunction OutlawDefaultCdActions
{
 #variable,name=rtb_reroll,value=rtb_buffs<2&(buff.loaded_dice.up|!buff.grand_melee.up&!buff.ruthless_precision.up)
 #variable,name=ambush_condition,value=combo_points.deficit>=2+2*(talent.ghostly_strike.enabled&cooldown.ghostly_strike.remains<1)+buff.broadside.up&energy>60&!buff.skull_and_crossbones.up
 #variable,name=blade_flurry_sync,value=spell_targets.blade_flurry<2&raid_event.adds.in>20|buff.blade_flurry.up
 #call_action_list,name=stealth,if=stealthed.all
 if Stealthed() OutlawStealthCdActions()

 unless Stealthed() and OutlawStealthCdPostConditions()
 {
  #call_action_list,name=cds
  OutlawCdsCdActions()

  unless OutlawCdsCdPostConditions()
  {
   #call_action_list,name=finish,if=combo_points>=cp_max_spend-(buff.broadside.up+buff.opportunity.up)*(talent.quick_draw.enabled&(!talent.marked_for_death.enabled|cooldown.marked_for_death.remains>1))
   if ComboPoints() >= MaxComboPoints() - { BuffPresent(broadside_buff) + BuffPresent(opportunity_buff) } * { Talent(quick_draw_talent) and { not Talent(marked_for_death_talent) or SpellCooldown(marked_for_death) > 1 } } OutlawFinishCdActions()

   unless ComboPoints() >= MaxComboPoints() - { BuffPresent(broadside_buff) + BuffPresent(opportunity_buff) } * { Talent(quick_draw_talent) and { not Talent(marked_for_death_talent) or SpellCooldown(marked_for_death) > 1 } } and OutlawFinishCdPostConditions()
   {
    #call_action_list,name=build
    OutlawBuildCdActions()

    unless OutlawBuildCdPostConditions()
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

AddFunction OutlawDefaultCdPostConditions
{
 Stealthed() and OutlawStealthCdPostConditions() or OutlawCdsCdPostConditions() or ComboPoints() >= MaxComboPoints() - { BuffPresent(broadside_buff) + BuffPresent(opportunity_buff) } * { Talent(quick_draw_talent) and { not Talent(marked_for_death_talent) or SpellCooldown(marked_for_death) > 1 } } and OutlawFinishCdPostConditions() or OutlawBuildCdPostConditions()
}

### actions.build

AddFunction OutlawBuildMainActions
{
 #pistol_shot,if=combo_points.deficit>=1+buff.broadside.up+talent.quick_draw.enabled&buff.opportunity.up
 if ComboPointsDeficit() >= 1 + BuffPresent(broadside_buff) + TalentPoints(quick_draw_talent) and BuffPresent(opportunity_buff) Spell(pistol_shot text=PS)
 #sinister_strike
 Spell(sinister_strike)
}

AddFunction OutlawBuildMainPostConditions
{
}

AddFunction OutlawBuildShortCdActions
{
}

AddFunction OutlawBuildShortCdPostConditions
{
 ComboPointsDeficit() >= 1 + BuffPresent(broadside_buff) + TalentPoints(quick_draw_talent) and BuffPresent(opportunity_buff) and Spell(pistol_shot text=PS) or Spell(sinister_strike)
}

AddFunction OutlawBuildCdActions
{
}

AddFunction OutlawBuildCdPostConditions
{
 ComboPointsDeficit() >= 1 + BuffPresent(broadside_buff) + TalentPoints(quick_draw_talent) and BuffPresent(opportunity_buff) and Spell(pistol_shot text=PS) or Spell(sinister_strike)
}

### actions.cds

AddFunction OutlawCdsMainActions
{
 #blade_flurry,if=spell_targets>=2&!buff.blade_flurry.up&(!raid_event.adds.exists|raid_event.adds.remains>8|cooldown.blade_flurry.charges=1&raid_event.adds.in>(2-cooldown.blade_flurry.charges_fractional)*25)
 if Enemies() >= 2 and not BuffPresent(blade_flurry_buff) and { not False(raid_event_adds_exists) or 0 > 8 or SpellCharges(blade_flurry) == 1 and 600 > { 2 - SpellCharges(blade_flurry count=0) } * 25 } and CheckBoxOn(opt_blade_flurry) Spell(blade_flurry)
 #ghostly_strike,if=variable.blade_flurry_sync&combo_points.deficit>=1+buff.broadside.up
 if blade_flurry_sync() and ComboPointsDeficit() >= 1 + BuffPresent(broadside_buff) Spell(ghostly_strike)
}

AddFunction OutlawCdsMainPostConditions
{
}

AddFunction OutlawCdsShortCdActions
{
 #marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit|((raid_event.adds.in>40|buff.true_bearing.remains>15-buff.adrenaline_rush.up*5)&!stealthed.rogue&combo_points.deficit>=cp_max_spend-1)
 if target.TimeToDie() < ComboPointsDeficit() or { 600 > 40 or BuffRemaining(true_bearing_buff) > 15 - BuffPresent(adrenaline_rush_buff) * 5 } and not Stealthed() and ComboPointsDeficit() >= MaxComboPoints() - 1 Spell(marked_for_death)

 unless Enemies() >= 2 and not BuffPresent(blade_flurry_buff) and { not False(raid_event_adds_exists) or 0 > 8 or SpellCharges(blade_flurry) == 1 and 600 > { 2 - SpellCharges(blade_flurry count=0) } * 25 } and CheckBoxOn(opt_blade_flurry) and Spell(blade_flurry) or blade_flurry_sync() and ComboPointsDeficit() >= 1 + BuffPresent(broadside_buff) and Spell(ghostly_strike)
 {
  #blade_rush,if=variable.blade_flurry_sync&energy.time_to_max>1
  if blade_flurry_sync() and TimeToMaxEnergy() > 1 Spell(blade_rush)
  #vanish,if=!stealthed.all&variable.ambush_condition
  if not Stealthed() and ambush_condition() Spell(vanish)
 }
}

AddFunction OutlawCdsShortCdPostConditions
{
 Enemies() >= 2 and not BuffPresent(blade_flurry_buff) and { not False(raid_event_adds_exists) or 0 > 8 or SpellCharges(blade_flurry) == 1 and 600 > { 2 - SpellCharges(blade_flurry count=0) } * 25 } and CheckBoxOn(opt_blade_flurry) and Spell(blade_flurry) or blade_flurry_sync() and ComboPointsDeficit() >= 1 + BuffPresent(broadside_buff) and Spell(ghostly_strike)
}

AddFunction OutlawCdsCdActions
{
 #potion,if=buff.bloodlust.react|target.time_to_die<=60|buff.adrenaline_rush.up
 if { BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 60 or BuffPresent(adrenaline_rush_buff) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(unbending_potion usable=1)
 #blood_fury
 Spell(blood_fury_ap)
 #berserking
 Spell(berserking)
 #adrenaline_rush,if=!buff.adrenaline_rush.up&energy.time_to_max>1
 if not BuffPresent(adrenaline_rush_buff) and TimeToMaxEnergy() > 1 and EnergyDeficit() > 1 Spell(adrenaline_rush)

 unless Enemies() >= 2 and not BuffPresent(blade_flurry_buff) and { not False(raid_event_adds_exists) or 0 > 8 or SpellCharges(blade_flurry) == 1 and 600 > { 2 - SpellCharges(blade_flurry count=0) } * 25 } and CheckBoxOn(opt_blade_flurry) and Spell(blade_flurry) or blade_flurry_sync() and ComboPointsDeficit() >= 1 + BuffPresent(broadside_buff) and Spell(ghostly_strike)
 {
  #killing_spree,if=variable.blade_flurry_sync&(energy.time_to_max>5|energy<15)
  if blade_flurry_sync() and { TimeToMaxEnergy() > 5 or Energy() < 15 } Spell(killing_spree)

  unless blade_flurry_sync() and TimeToMaxEnergy() > 1 and Spell(blade_rush)
  {
   #shadowmeld,if=!stealthed.all&variable.ambush_condition
   if not Stealthed() and ambush_condition() Spell(shadowmeld)
  }
 }
}

AddFunction OutlawCdsCdPostConditions
{
 Enemies() >= 2 and not BuffPresent(blade_flurry_buff) and { not False(raid_event_adds_exists) or 0 > 8 or SpellCharges(blade_flurry) == 1 and 600 > { 2 - SpellCharges(blade_flurry count=0) } * 25 } and CheckBoxOn(opt_blade_flurry) and Spell(blade_flurry) or blade_flurry_sync() and ComboPointsDeficit() >= 1 + BuffPresent(broadside_buff) and Spell(ghostly_strike) or blade_flurry_sync() and TimeToMaxEnergy() > 1 and Spell(blade_rush)
}

### actions.finish

AddFunction OutlawFinishMainActions
{
 #slice_and_dice,if=buff.slice_and_dice.remains<target.time_to_die&buff.slice_and_dice.remains<(1+combo_points)*1.8
 if BuffRemaining(slice_and_dice_buff) < target.TimeToDie() and BuffRemaining(slice_and_dice_buff) < { 1 + ComboPoints() } * 1.8 Spell(slice_and_dice)
 #roll_the_bones,if=(buff.roll_the_bones.remains<=3|variable.rtb_reroll)&(target.time_to_die>20|buff.roll_the_bones.remains<target.time_to_die)
 if { DebuffRemaining(roll_the_bones) <= 3 or rtb_reroll() } and { target.TimeToDie() > 20 or DebuffRemaining(roll_the_bones) < target.TimeToDie() } Spell(roll_the_bones)
 #dispatch
 Spell(dispatch)
}

AddFunction OutlawFinishMainPostConditions
{
}

AddFunction OutlawFinishShortCdActions
{
 unless BuffRemaining(slice_and_dice_buff) < target.TimeToDie() and BuffRemaining(slice_and_dice_buff) < { 1 + ComboPoints() } * 1.8 and Spell(slice_and_dice) or { DebuffRemaining(roll_the_bones) <= 3 or rtb_reroll() } and { target.TimeToDie() > 20 or DebuffRemaining(roll_the_bones) < target.TimeToDie() } and Spell(roll_the_bones)
 {
  #between_the_eyes,if=buff.ruthless_precision.up
  if BuffPresent(ruthless_precision_buff) Spell(between_the_eyes text=BTE)
 }
}

AddFunction OutlawFinishShortCdPostConditions
{
 BuffRemaining(slice_and_dice_buff) < target.TimeToDie() and BuffRemaining(slice_and_dice_buff) < { 1 + ComboPoints() } * 1.8 and Spell(slice_and_dice) or { DebuffRemaining(roll_the_bones) <= 3 or rtb_reroll() } and { target.TimeToDie() > 20 or DebuffRemaining(roll_the_bones) < target.TimeToDie() } and Spell(roll_the_bones) or Spell(dispatch)
}

AddFunction OutlawFinishCdActions
{
}

AddFunction OutlawFinishCdPostConditions
{
 BuffRemaining(slice_and_dice_buff) < target.TimeToDie() and BuffRemaining(slice_and_dice_buff) < { 1 + ComboPoints() } * 1.8 and Spell(slice_and_dice) or { DebuffRemaining(roll_the_bones) <= 3 or rtb_reroll() } and { target.TimeToDie() > 20 or DebuffRemaining(roll_the_bones) < target.TimeToDie() } and Spell(roll_the_bones) or BuffPresent(ruthless_precision_buff) and Spell(between_the_eyes text=BTE) or Spell(dispatch)
}

### actions.precombat

AddFunction OutlawPrecombatMainActions
{
 #flask
 #augmentation
 #food
 #snapshot_stats
 #stealth
 Spell(stealth)
 #roll_the_bones
 Spell(roll_the_bones)
 #slice_and_dice
 Spell(slice_and_dice)
}

AddFunction OutlawPrecombatMainPostConditions
{
}

AddFunction OutlawPrecombatShortCdActions
{
 unless Spell(stealth)
 {
  #marked_for_death
  Spell(marked_for_death)
 }
}

AddFunction OutlawPrecombatShortCdPostConditions
{
 Spell(stealth) or Spell(roll_the_bones) or Spell(slice_and_dice)
}

AddFunction OutlawPrecombatCdActions
{
 unless Spell(stealth)
 {
  #potion
  if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(unbending_potion usable=1)

  unless Spell(roll_the_bones) or Spell(slice_and_dice)
  {
   #adrenaline_rush
   if EnergyDeficit() > 1 Spell(adrenaline_rush)
  }
 }
}

AddFunction OutlawPrecombatCdPostConditions
{
 Spell(stealth) or Spell(roll_the_bones) or Spell(slice_and_dice)
}

### actions.stealth

AddFunction OutlawStealthMainActions
{
 #ambush
 Spell(ambush)
}

AddFunction OutlawStealthMainPostConditions
{
}

AddFunction OutlawStealthShortCdActions
{
}

AddFunction OutlawStealthShortCdPostConditions
{
 Spell(ambush)
}

AddFunction OutlawStealthCdActions
{
}

AddFunction OutlawStealthCdPostConditions
{
 Spell(ambush)
}

]]

	OvaleScripts:RegisterScript("ROGUE", "outlaw", name, desc, code, "script")
end
