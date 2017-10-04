local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_pokey"
	local desc = "[Xel][7.2.5] Blush: Outlaw edition"
	local code = [[
Include(ovale_common)

Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_rogue_spells)

Define(crimson_vial 185311)
	SpellInfo(crimson_vial cd=30 gcd=0 energy=30)

# Outlaw
AddIcon specialization=outlaw help=main
{
	# Precombat
	if not InCombat() and target.Present() and target.Exists() and not target.IsFriend() and not mounted()
	{
		if BuffExpires(stealthed_buff any=1) Spell(stealth)
		#marked_for_death
		if target.InRange(marked_for_death) Spell(marked_for_death)
		#roll_the_bones,if=!talent.slice_and_dice.enabled
		if not Talent(slice_and_dice_talent) and not ss_useable() and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } Spell(roll_the_bones)
	}
	
	if InCombat() InterruptActions()
	if HealthPercent() <= 40 and not Boss() Spell(crimson_vial)
	
	if target.InRange(saber_slash) and HasFullControl()
	{
		# Cooldowns
		if Boss() OutlawDefaultCdActions()
		
		# Short Cooldowns
		OutlawDefaultShortCdActions()
		
		# Default Actions
		OutlawDefaultMainActions()
	}
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction InterruptActions
{
	if target.IsFriend(no) and target.IsInterruptible()
	{
		if target.InRange(kick) and not Stealthed() Spell(kick)
		if target.Classification(worldboss no)
		{
			# if target.InRange(cheap_shot) and Stealthed() Spell(cheap_shot)
			# if target.InRange(deadly_throw) and ComboPoints() == 5 and not {BuffPresent(stealthed_buff any=1) and BuffPresent(vanish_buff)} Spell(deadly_throw)
			if target.InRange(kidney_shot) and not Stealthed() Spell(kidney_shot)
			if target.InRange(kidney_shot) and not Stealthed() Spell(arcane_torrent_energy)
			if target.InRange(quaking_palm) and not Stealthed() Spell(quaking_palm)
		}
	}
}

AddFunction ambush_condition
{
    ComboPointsDeficit() >= 2 + 2 * { Talent(ghostly_strike_talent) and not target.DebuffPresent(ghostly_strike_debuff) } + BuffPresent(broadsides_buff) and Energy() > 60 and not BuffPresent(jolly_roger_buff) and not BuffPresent(hidden_blade_buff)
}

AddFunction ss_useable
{
    Talent(anticipation_talent) and ComboPoints() < 5 or not Talent(anticipation_talent) and { rtb_reroll() and ComboPoints() < 4 + TalentPoints(deeper_stratagem_talent) or not rtb_reroll() and ss_useable_noreroll() }
}

AddFunction ss_useable_noreroll
{
    ComboPoints() < 5 + TalentPoints(deeper_stratagem_talent) - { BuffPresent(broadsides_buff) or BuffPresent(jolly_roger_buff) } - { Talent(alacrity_talent) and BuffStacks(alacrity_buff) <= 4 }
}

AddFunction rtb_reroll
{
    not Talent(slice_and_dice_talent) and BuffPresent(loaded_dice_buff) and { BuffCount(roll_the_bones_buff) < 2 or BuffCount(roll_the_bones_buff) == 2 and not BuffPresent(true_bearing_buff) }
}

### actions.default

AddFunction OutlawDefaultMainActions
{
    #variable,name=rtb_reroll,value=!talent.slice_and_dice.enabled&buff.loaded_dice.up&(rtb_buffs<2|rtb_buffs=2&!buff.true_bearing.up)
    #variable,name=ss_useable_noreroll,value=(combo_points<5+talent.deeper_stratagem.enabled-(buff.broadsides.up|buff.jolly_roger.up)-(talent.alacrity.enabled&buff.alacrity.stack<=4))
    #variable,name=ss_useable,value=(talent.anticipation.enabled&combo_points<5)|(!talent.anticipation.enabled&((variable.rtb_reroll&combo_points<4+talent.deeper_stratagem.enabled)|(!variable.rtb_reroll&variable.ss_useable_noreroll)))
    #call_action_list,name=bf
    OutlawBfMainActions()

    unless OutlawBfMainPostConditions()
    {
        #call_action_list,name=cds
        OutlawCdsMainActions()

        unless OutlawCdsMainPostConditions()
        {
            #call_action_list,name=stealth,if=stealthed.rogue|cooldown.vanish.up|cooldown.shadowmeld.up
            if Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 OutlawStealthMainActions()

            unless { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthMainPostConditions()
            {
                #death_from_above,if=energy.time_to_max>2&!variable.ss_useable_noreroll
                if TimeToMaxEnergy() > 2 and not ss_useable_noreroll() Spell(death_from_above)
                #roll_the_bones,if=!variable.ss_useable&(target.time_to_die>20|buff.roll_the_bones.remains<target.time_to_die)&(buff.roll_the_bones.remains<=3|variable.rtb_reroll)
                if not ss_useable() and { target.TimeToDie() > 20 or BuffRemaining(roll_the_bones_buff) < target.TimeToDie() } and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } Spell(roll_the_bones)
                #call_action_list,name=build
                OutlawBuildMainActions()

                unless OutlawBuildMainPostConditions()
                {
                    #call_action_list,name=finish,if=!variable.ss_useable
                    if not ss_useable() OutlawFinishMainActions()

                    unless not ss_useable() and OutlawFinishMainPostConditions()
                    {
                        #gouge,if=talent.dirty_tricks.enabled&combo_points.deficit>=1
                        if Talent(dirty_tricks_talent) and ComboPointsDeficit() >= 1 Spell(gouge)
                    }
                }
            }
        }
    }
}

AddFunction OutlawDefaultMainPostConditions
{
    OutlawBfMainPostConditions() or OutlawCdsMainPostConditions() or { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthMainPostConditions() or OutlawBuildMainPostConditions() or not ss_useable() and OutlawFinishMainPostConditions()
}

AddFunction OutlawDefaultShortCdActions
{
    #variable,name=rtb_reroll,value=!talent.slice_and_dice.enabled&buff.loaded_dice.up&(rtb_buffs<2|rtb_buffs=2&!buff.true_bearing.up)
    #variable,name=ss_useable_noreroll,value=(combo_points<5+talent.deeper_stratagem.enabled-(buff.broadsides.up|buff.jolly_roger.up)-(talent.alacrity.enabled&buff.alacrity.stack<=4))
    #variable,name=ss_useable,value=(talent.anticipation.enabled&combo_points<5)|(!talent.anticipation.enabled&((variable.rtb_reroll&combo_points<4+talent.deeper_stratagem.enabled)|(!variable.rtb_reroll&variable.ss_useable_noreroll)))
    #call_action_list,name=bf
    OutlawBfShortCdActions()

    unless OutlawBfShortCdPostConditions()
    {
        #call_action_list,name=cds
        OutlawCdsShortCdActions()

        unless OutlawCdsShortCdPostConditions()
        {
            #call_action_list,name=stealth,if=stealthed.rogue|cooldown.vanish.up|cooldown.shadowmeld.up
            if Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 OutlawStealthShortCdActions()

            unless { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthShortCdPostConditions() or TimeToMaxEnergy() > 2 and not ss_useable_noreroll() and Spell(death_from_above) or not ss_useable() and { target.TimeToDie() > 20 or BuffRemaining(roll_the_bones_buff) < target.TimeToDie() } and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } and Spell(roll_the_bones)
            {
                #call_action_list,name=build
                OutlawBuildShortCdActions()

                unless OutlawBuildShortCdPostConditions()
                {
                    #call_action_list,name=finish,if=!variable.ss_useable
                    if not ss_useable() OutlawFinishShortCdActions()
                }
            }
        }
    }
}

AddFunction OutlawDefaultShortCdPostConditions
{
    OutlawBfShortCdPostConditions() or OutlawCdsShortCdPostConditions() or { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthShortCdPostConditions() or TimeToMaxEnergy() > 2 and not ss_useable_noreroll() and Spell(death_from_above) or not ss_useable() and { target.TimeToDie() > 20 or BuffRemaining(roll_the_bones_buff) < target.TimeToDie() } and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } and Spell(roll_the_bones) or OutlawBuildShortCdPostConditions() or not ss_useable() and OutlawFinishShortCdPostConditions() or Talent(dirty_tricks_talent) and ComboPointsDeficit() >= 1 and Spell(gouge)
}

AddFunction OutlawDefaultCdActions
{
    #variable,name=rtb_reroll,value=!talent.slice_and_dice.enabled&buff.loaded_dice.up&(rtb_buffs<2|rtb_buffs=2&!buff.true_bearing.up)
    #variable,name=ss_useable_noreroll,value=(combo_points<5+talent.deeper_stratagem.enabled-(buff.broadsides.up|buff.jolly_roger.up)-(talent.alacrity.enabled&buff.alacrity.stack<=4))
    #variable,name=ss_useable,value=(talent.anticipation.enabled&combo_points<5)|(!talent.anticipation.enabled&((variable.rtb_reroll&combo_points<4+talent.deeper_stratagem.enabled)|(!variable.rtb_reroll&variable.ss_useable_noreroll)))
    #call_action_list,name=bf
    OutlawBfCdActions()

    unless OutlawBfCdPostConditions()
    {
        #call_action_list,name=cds
        OutlawCdsCdActions()

        unless OutlawCdsCdPostConditions()
        {
            #call_action_list,name=stealth,if=stealthed.rogue|cooldown.vanish.up|cooldown.shadowmeld.up
            if Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 OutlawStealthCdActions()

            unless { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthCdPostConditions() or TimeToMaxEnergy() > 2 and not ss_useable_noreroll() and Spell(death_from_above) or not ss_useable() and { target.TimeToDie() > 20 or BuffRemaining(roll_the_bones_buff) < target.TimeToDie() } and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } and Spell(roll_the_bones)
            {
                #killing_spree,if=energy.time_to_max>5|energy<15
                if TimeToMaxEnergy() > 5 or Energy() < 15 Spell(killing_spree)
                #call_action_list,name=build
                OutlawBuildCdActions()

                unless OutlawBuildCdPostConditions()
                {
                    #call_action_list,name=finish,if=!variable.ss_useable
                    if not ss_useable() OutlawFinishCdActions()
                }
            }
        }
    }
}

AddFunction OutlawDefaultCdPostConditions
{
    OutlawBfCdPostConditions() or OutlawCdsCdPostConditions() or { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthCdPostConditions() or TimeToMaxEnergy() > 2 and not ss_useable_noreroll() and Spell(death_from_above) or not ss_useable() and { target.TimeToDie() > 20 or BuffRemaining(roll_the_bones_buff) < target.TimeToDie() } and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } and Spell(roll_the_bones) or OutlawBuildCdPostConditions() or not ss_useable() and OutlawFinishCdPostConditions() or Talent(dirty_tricks_talent) and ComboPointsDeficit() >= 1 and Spell(gouge)
}

### actions.bf

AddFunction OutlawBfMainActions
{
}

AddFunction OutlawBfMainPostConditions
{
}

AddFunction OutlawBfShortCdActions
{
    #cancel_buff,name=blade_flurry,if=spell_targets.blade_flurry<2&buff.blade_flurry.up
    if Enemies(tagged=1) < 2 and BuffPresent(blade_flurry_buff) and Boss() Texture(blade_flurry)
    #cancel_buff,name=blade_flurry,if=equipped.shivarran_symmetry&cooldown.blade_flurry.up&buff.blade_flurry.up&spell_targets.blade_flurry>=2
    if HasEquippedItem(shivarran_symmetry) and not SpellCooldown(blade_flurry) > 0 and BuffPresent(blade_flurry_buff) and Enemies(tagged=1) >= 2 and BuffPresent(blade_flurry_buff) Texture(blade_flurry)
    #blade_flurry,if=spell_targets.blade_flurry>=2&!buff.blade_flurry.up
    if Enemies(tagged=1) >= 2 and not BuffPresent(blade_flurry_buff) Spell(blade_flurry)
}

AddFunction OutlawBfShortCdPostConditions
{
}

AddFunction OutlawBfCdActions
{
}

AddFunction OutlawBfCdPostConditions
{
}

### actions.build

AddFunction OutlawBuildMainActions
{
    #ghostly_strike,if=combo_points.deficit>=1+buff.broadsides.up&!buff.curse_of_the_dreadblades.up&(debuff.ghostly_strike.remains<debuff.ghostly_strike.duration*0.3|(cooldown.curse_of_the_dreadblades.remains<3&debuff.ghostly_strike.remains<14))&(combo_points>=3|(variable.rtb_reroll&time>=10))
    if ComboPointsDeficit() >= 1 + BuffPresent(broadsides_buff) and not BuffPresent(curse_of_the_dreadblades_buff) and { target.DebuffRemaining(ghostly_strike_debuff) < BaseDuration(ghostly_strike_debuff) * 0.3 or SpellCooldown(curse_of_the_dreadblades) < 3 and target.DebuffRemaining(ghostly_strike_debuff) < 14 } and { ComboPoints() >= 3 or rtb_reroll() and TimeInCombat() >= 10 } Spell(ghostly_strike)
    #pistol_shot,if=combo_points.deficit>=1+buff.broadsides.up&buff.opportunity.up&(energy.time_to_max>2-talent.quick_draw.enabled|(buff.blunderbuss.up&buff.greenskins_waterlogged_wristcuffs.up))
    if ComboPointsDeficit() >= 1 + BuffPresent(broadsides_buff) and BuffPresent(opportunity_buff) and { TimeToMaxEnergy() > 2 - TalentPoints(quick_draw_talent) or BuffPresent(blunderbuss_buff) and BuffPresent(greenskins_waterlogged_wristcuffs_buff) } Spell(pistol_shot)
    #saber_slash,if=variable.ss_useable
    if ss_useable() Spell(saber_slash)
}

AddFunction OutlawBuildMainPostConditions
{
}

AddFunction OutlawBuildShortCdActions
{
}

AddFunction OutlawBuildShortCdPostConditions
{
    ComboPointsDeficit() >= 1 + BuffPresent(broadsides_buff) and not BuffPresent(curse_of_the_dreadblades_buff) and { target.DebuffRemaining(ghostly_strike_debuff) < BaseDuration(ghostly_strike_debuff) * 0.3 or SpellCooldown(curse_of_the_dreadblades) < 3 and target.DebuffRemaining(ghostly_strike_debuff) < 14 } and { ComboPoints() >= 3 or rtb_reroll() and TimeInCombat() >= 10 } and Spell(ghostly_strike) or ComboPointsDeficit() >= 1 + BuffPresent(broadsides_buff) and BuffPresent(opportunity_buff) and { TimeToMaxEnergy() > 2 - TalentPoints(quick_draw_talent) or BuffPresent(blunderbuss_buff) and BuffPresent(greenskins_waterlogged_wristcuffs_buff) } and Spell(pistol_shot) or ss_useable() and Spell(saber_slash)
}

AddFunction OutlawBuildCdActions
{
}

AddFunction OutlawBuildCdPostConditions
{
    ComboPointsDeficit() >= 1 + BuffPresent(broadsides_buff) and not BuffPresent(curse_of_the_dreadblades_buff) and { target.DebuffRemaining(ghostly_strike_debuff) < BaseDuration(ghostly_strike_debuff) * 0.3 or SpellCooldown(curse_of_the_dreadblades) < 3 and target.DebuffRemaining(ghostly_strike_debuff) < 14 } and { ComboPoints() >= 3 or rtb_reroll() and TimeInCombat() >= 10 } and Spell(ghostly_strike) or ComboPointsDeficit() >= 1 + BuffPresent(broadsides_buff) and BuffPresent(opportunity_buff) and { TimeToMaxEnergy() > 2 - TalentPoints(quick_draw_talent) or BuffPresent(blunderbuss_buff) and BuffPresent(greenskins_waterlogged_wristcuffs_buff) } and Spell(pistol_shot) or ss_useable() and Spell(saber_slash)
}

### actions.cds

AddFunction OutlawCdsMainActions
{
}

AddFunction OutlawCdsMainPostConditions
{
}

AddFunction OutlawCdsShortCdActions
{
    #cannonball_barrage,if=spell_targets.cannonball_barrage>=1
    if Enemies(tagged=1) >= 1 Spell(cannonball_barrage)
    #marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit|((raid_event.adds.in>40|buff.true_bearing.remains>15-buff.adrenaline_rush.up*5)&!stealthed.rogue&combo_points.deficit>=cp_max_spend-1)
    if target.TimeToDie() < ComboPointsDeficit() or { 600 > 40 or BuffRemaining(true_bearing_buff) > 15 - BuffPresent(adrenaline_rush_buff) * 5 } and not Stealthed() and ComboPointsDeficit() >= MaxComboPoints() - 1 Spell(marked_for_death)
    #sprint,if=equipped.thraxis_tricksy_treads&!variable.ss_useable
    # if HasEquippedItem(thraxis_tricksy_treads) and not ss_useable() Spell(sprint)
}

AddFunction OutlawCdsShortCdPostConditions
{
}

AddFunction OutlawCdsCdActions
{
    #potion,if=buff.bloodlust.react|target.time_to_die<=60|buff.adrenaline_rush.up
    # if { BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 60 or BuffPresent(adrenaline_rush_buff) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
    #use_item,name=specter_of_betrayal,if=(mantle_duration>0|buff.curse_of_the_dreadblades.up|(cooldown.vanish.remains>11&cooldown.curse_of_the_dreadblades.remains>11))
    # if BuffRemaining(master_assassins_initiative) > 0 or BuffPresent(curse_of_the_dreadblades_buff) or SpellCooldown(vanish) > 11 and SpellCooldown(curse_of_the_dreadblades) > 11 OutlawUseItemActions()
    #blood_fury
    Spell(blood_fury_ap)
    #berserking
    Spell(berserking)
    #arcane_torrent,if=energy.deficit>40
    if EnergyDeficit() > 40 Spell(arcane_torrent_energy)

    unless Enemies(tagged=1) >= 1 and Spell(cannonball_barrage)
    {
        #adrenaline_rush,if=!buff.adrenaline_rush.up&energy.deficit>0
        if not BuffPresent(adrenaline_rush_buff) and EnergyDeficit() > 0 and EnergyDeficit() > 1 Spell(adrenaline_rush)

        unless HasEquippedItem(thraxis_tricksy_treads) and not ss_useable() and Spell(sprint)
        {
            #darkflight,if=equipped.thraxis_tricksy_treads&!variable.ss_useable&buff.sprint.down
            if HasEquippedItem(thraxis_tricksy_treads) and not ss_useable() and BuffExpires(sprint_buff) Spell(darkflight)
            #curse_of_the_dreadblades,if=combo_points.deficit>=4&(!talent.ghostly_strike.enabled|debuff.ghostly_strike.up)
            if ComboPointsDeficit() >= 4 and { not Talent(ghostly_strike_talent) or target.DebuffPresent(ghostly_strike_debuff) } Spell(curse_of_the_dreadblades)
        }
    }
}

AddFunction OutlawCdsCdPostConditions
{
    Enemies(tagged=1) >= 1 and Spell(cannonball_barrage) or HasEquippedItem(thraxis_tricksy_treads) and not ss_useable() and Spell(sprint)
}

### actions.finish

AddFunction OutlawFinishMainActions
{
    #between_the_eyes,if=(mantle_duration>=gcd.remains+0.2&!equipped.thraxis_tricksy_treads)|(equipped.greenskins_waterlogged_wristcuffs&!buff.greenskins_waterlogged_wristcuffs.up)
    if BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 and not HasEquippedItem(thraxis_tricksy_treads) or HasEquippedItem(greenskins_waterlogged_wristcuffs) and not BuffPresent(greenskins_waterlogged_wristcuffs_buff) Spell(between_the_eyes)
    #run_through,if=!talent.death_from_above.enabled|energy.time_to_max<cooldown.death_from_above.remains+3.5
    if not Talent(death_from_above_talent) or TimeToMaxEnergy() < SpellCooldown(death_from_above) + 3.5 Spell(run_through)
}

AddFunction OutlawFinishMainPostConditions
{
}

AddFunction OutlawFinishShortCdActions
{
}

AddFunction OutlawFinishShortCdPostConditions
{
    { BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 and not HasEquippedItem(thraxis_tricksy_treads) or HasEquippedItem(greenskins_waterlogged_wristcuffs) and not BuffPresent(greenskins_waterlogged_wristcuffs_buff) } and Spell(between_the_eyes) or { not Talent(death_from_above_talent) or TimeToMaxEnergy() < SpellCooldown(death_from_above) + 3.5 } and Spell(run_through)
}

AddFunction OutlawFinishCdActions
{
}

AddFunction OutlawFinishCdPostConditions
{
    { BuffRemaining(master_assassins_initiative) >= GCDRemaining() + 0.2 and not HasEquippedItem(thraxis_tricksy_treads) or HasEquippedItem(greenskins_waterlogged_wristcuffs) and not BuffPresent(greenskins_waterlogged_wristcuffs_buff) } and Spell(between_the_eyes) or { not Talent(death_from_above_talent) or TimeToMaxEnergy() < SpellCooldown(death_from_above) + 3.5 } and Spell(run_through)
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
    #roll_the_bones,if=!talent.slice_and_dice.enabled
    if not Talent(slice_and_dice_talent) Spell(roll_the_bones)
}

AddFunction OutlawPrecombatMainPostConditions
{
}

AddFunction OutlawPrecombatShortCdActions
{
    unless Spell(stealth)
    {
        #marked_for_death,if=raid_event.adds.in>40
        if 600 > 40 Spell(marked_for_death)
    }
}

AddFunction OutlawPrecombatShortCdPostConditions
{
    Spell(stealth) or not Talent(slice_and_dice_talent) and Spell(roll_the_bones)
}

AddFunction OutlawPrecombatCdActions
{
    unless Spell(stealth)
    {
        #potion
        # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)

        unless not Talent(slice_and_dice_talent) and Spell(roll_the_bones)
        {
            #curse_of_the_dreadblades,if=combo_points.deficit>=4
            if ComboPointsDeficit() >= 4 Spell(curse_of_the_dreadblades)
        }
    }
}

AddFunction OutlawPrecombatCdPostConditions
{
    Spell(stealth) or not Talent(slice_and_dice_talent) and Spell(roll_the_bones)
}

### actions.stealth

AddFunction OutlawStealthMainActions
{
    #variable,name=ambush_condition,value=combo_points.deficit>=2+2*(talent.ghostly_strike.enabled&!debuff.ghostly_strike.up)+buff.broadsides.up&energy>60&!buff.jolly_roger.up&!buff.hidden_blade.up
    #ambush,if=variable.ambush_condition
    if ambush_condition() Spell(ambush)
}

AddFunction OutlawStealthMainPostConditions
{
}

AddFunction OutlawStealthShortCdActions
{
    unless ambush_condition() and Spell(ambush)
    {
        #vanish,if=variable.ambush_condition|(equipped.mantle_of_the_master_assassin&mantle_duration=0&!variable.rtb_reroll&!variable.ss_useable)
        if ambush_condition() or HasEquippedItem(mantle_of_the_master_assassin) and BuffRemaining(master_assassins_initiative) == 0 and not rtb_reroll() and not ss_useable() Spell(vanish)
    }
}

AddFunction OutlawStealthShortCdPostConditions
{
    ambush_condition() and Spell(ambush)
}

AddFunction OutlawStealthCdActions
{
    unless ambush_condition() and Spell(ambush)
    {
        #shadowmeld,if=variable.ambush_condition
        if ambush_condition() Spell(shadowmeld)
    }
}

AddFunction OutlawStealthCdPostConditions
{
    ambush_condition() and Spell(ambush)
}
]]

	OvaleScripts:RegisterScript("ROGUE", "outlaw", name, desc, code, "script")
end
