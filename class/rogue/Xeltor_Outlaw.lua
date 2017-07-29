local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_pokey"
	local desc = "[Xel][7.1.5] Blush: Outlaw edition"
	local code = [[
# Based on SimulationCraft profile "Rogue_Outlaw_T18M".
#	class=rogue
#	spec=outlaw
#	talents=3010022

Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_rogue_spells)

Define(crimson_vial 185311)
	SpellInfo(crimson_vial cd=30 gcd=0 energy=30)

# Outlaw
AddIcon specialization=outlaw help=main
{
	# PvE Stuff
	if not InCombat() and target.Present() and target.Exists() and not target.IsFriend() and not mounted()
	{
		if BuffExpires(stealthed_buff any=1) Spell(stealth)
		#marked_for_death
		if target.InRange(marked_for_death) Spell(marked_for_death)
		#roll_the_bones,if=!talent.slice_and_dice.enabled
		if not Talent(slice_and_dice_talent) and not ss_useable() and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } Spell(roll_the_bones)
	}
	
	if InCombat() and target.Casting(interrupt) InterruptActions()
	if HealthPercent() <= 40 and not Boss() Spell(crimson_vial)
	
	if target.InRange(saber_slash) and HasFullControl()
	{
		# Cooldowns
		# if Boss() 
		OutlawDefaultCdActions()
		
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

AddFunction position_front
{
	target.istargetingplayer()
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

AddFunction stealth_condition
{
	ComboPointsDeficit() >= 2 + 2 * { Talent(ghostly_strike_talent) and not target.DebuffPresent(ghostly_strike_debuff) } + BuffPresent(broadsides_buff) and Energy() > 60 and not BuffPresent(jolly_roger_buff) and not BuffPresent(hidden_blade_buff) and not BuffPresent(curse_of_the_dreadblades_buff)
}

AddFunction ss_useable
{
	Talent(anticipation_talent) and ComboPoints() < 4 or not Talent(anticipation_talent) and { rtb_reroll() and ComboPoints() < 4 + TalentPoints(deeper_stratagem_talent) or not rtb_reroll() and ss_useable_noreroll() }
}

AddFunction ss_useable_noreroll
{
	ComboPoints() < 5 + TalentPoints(deeper_stratagem_talent) - { BuffPresent(broadsides_buff) or BuffPresent(jolly_roger_buff) } - { Talent(alacrity_talent) and BuffStacks(alacrity_buff) <= 4 }
}

AddFunction rtb_reroll
{
	not Talent(slice_and_dice_talent) and BuffCount(roll_the_bones_buff) <= 2 and not BuffCount(roll_the_bones_buff more 5)
}

### actions.default

AddFunction OutlawDefaultMainActions
{
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
				#slice_and_dice,if=!variable.ss_useable&buff.slice_and_dice.remains<target.time_to_die&buff.slice_and_dice.remains<(1+combo_points)*1.8
				if not ss_useable() and BuffRemaining(slice_and_dice_buff) < target.TimeToDie() and BuffRemaining(slice_and_dice_buff) < { 1 + ComboPoints() } * 1.8 Spell(slice_and_dice)
				#roll_the_bones,if=!variable.ss_useable&buff.roll_the_bones.remains<target.time_to_die&(buff.roll_the_bones.remains<=3|variable.rtb_reroll)
				if not ss_useable() and BuffRemaining(roll_the_bones_buff) < target.TimeToDie() and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } Spell(roll_the_bones)
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

			unless { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthShortCdPostConditions() or TimeToMaxEnergy() > 2 and not ss_useable_noreroll() and Spell(death_from_above) or not ss_useable() and BuffRemaining(slice_and_dice_buff) < target.TimeToDie() and BuffRemaining(slice_and_dice_buff) < { 1 + ComboPoints() } * 1.8 and Spell(slice_and_dice) or not ss_useable() and BuffRemaining(roll_the_bones_buff) < target.TimeToDie() and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } and Spell(roll_the_bones)
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
	OutlawBfShortCdPostConditions() or OutlawCdsShortCdPostConditions() or { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthShortCdPostConditions() or TimeToMaxEnergy() > 2 and not ss_useable_noreroll() and Spell(death_from_above) or not ss_useable() and BuffRemaining(slice_and_dice_buff) < target.TimeToDie() and BuffRemaining(slice_and_dice_buff) < { 1 + ComboPoints() } * 1.8 and Spell(slice_and_dice) or not ss_useable() and BuffRemaining(roll_the_bones_buff) < target.TimeToDie() and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } and Spell(roll_the_bones) or OutlawBuildShortCdPostConditions() or not ss_useable() and OutlawFinishShortCdPostConditions() or Talent(dirty_tricks_talent) and ComboPointsDeficit() >= 1 and Spell(gouge)
}

AddFunction OutlawDefaultCdActions
{
	#variable,name=rtb_reroll,value=!talent.slice_and_dice.enabled&(rtb_buffs<=2&!rtb_list.any.6)
	#variable,name=ss_useable_noreroll,value=(combo_points<5+talent.deeper_stratagem.enabled-(buff.broadsides.up|buff.jolly_roger.up)-(talent.alacrity.enabled&buff.alacrity.stack<=4))
	#variable,name=ss_useable,value=(talent.anticipation.enabled&combo_points<4)|(!talent.anticipation.enabled&((variable.rtb_reroll&combo_points<4+talent.deeper_stratagem.enabled)|(!variable.rtb_reroll&variable.ss_useable_noreroll)))
	#kick
	# OutlawInterruptActions()
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

			unless { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthCdPostConditions() or TimeToMaxEnergy() > 2 and not ss_useable_noreroll() and Spell(death_from_above) or not ss_useable() and BuffRemaining(slice_and_dice_buff) < target.TimeToDie() and BuffRemaining(slice_and_dice_buff) < { 1 + ComboPoints() } * 1.8 and Spell(slice_and_dice) or not ss_useable() and BuffRemaining(roll_the_bones_buff) < target.TimeToDie() and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } and Spell(roll_the_bones)
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
	OutlawBfCdPostConditions() or OutlawCdsCdPostConditions() or { Stealthed() or not SpellCooldown(vanish) > 0 or not SpellCooldown(shadowmeld) > 0 } and OutlawStealthCdPostConditions() or TimeToMaxEnergy() > 2 and not ss_useable_noreroll() and Spell(death_from_above) or not ss_useable() and BuffRemaining(slice_and_dice_buff) < target.TimeToDie() and BuffRemaining(slice_and_dice_buff) < { 1 + ComboPoints() } * 1.8 and Spell(slice_and_dice) or not ss_useable() and BuffRemaining(roll_the_bones_buff) < target.TimeToDie() and { BuffRemaining(roll_the_bones_buff) <= 3 or rtb_reroll() } and Spell(roll_the_bones) or OutlawBuildCdPostConditions() or not ss_useable() and OutlawFinishCdPostConditions() or Talent(dirty_tricks_talent) and ComboPointsDeficit() >= 1 and Spell(gouge)
}

### actions.bf

AddFunction OutlawBfMainActions
{
	#cancel_buff,name=blade_flurry,if=equipped.shivarran_symmetry&cooldown.blade_flurry.up&buff.blade_flurry.up&spell_targets.blade_flurry>=2|spell_targets.blade_flurry<2&buff.blade_flurry.up
	if { HasEquippedItem(shivarran_symmetry) and not SpellCooldown(blade_flurry) > 0 and BuffPresent(blade_flurry_buff) and Enemies(tagged=1) >= 2 or Enemies(tagged=1) < 2 and BuffPresent(blade_flurry_buff) } and BuffPresent(blade_flurry_buff) Texture(blade_flurry text=cancel)
}

AddFunction OutlawBfMainPostConditions
{
}

AddFunction OutlawBfShortCdActions
{
	unless { HasEquippedItem(shivarran_symmetry) and not SpellCooldown(blade_flurry) > 0 and BuffPresent(blade_flurry_buff) and Enemies(tagged=1) >= 2 or Enemies(tagged=1) < 2 and BuffPresent(blade_flurry_buff) } and BuffPresent(blade_flurry_buff) and Texture(blade_flurry text=cancel)
	{
		#blade_flurry,if=spell_targets.blade_flurry>=2&!buff.blade_flurry.up
		if Enemies(tagged=1) >= 2 and not BuffPresent(blade_flurry_buff) and CheckBoxOn(opt_blade_flurry) Spell(blade_flurry)
	}
}

AddFunction OutlawBfShortCdPostConditions
{
	{ HasEquippedItem(shivarran_symmetry) and not SpellCooldown(blade_flurry) > 0 and BuffPresent(blade_flurry_buff) and Enemies(tagged=1) >= 2 or Enemies(tagged=1) < 2 and BuffPresent(blade_flurry_buff) } and BuffPresent(blade_flurry_buff) and Texture(blade_flurry text=cancel)
}

AddFunction OutlawBfCdActions
{
}

AddFunction OutlawBfCdPostConditions
{
	{ HasEquippedItem(shivarran_symmetry) and not SpellCooldown(blade_flurry) > 0 and BuffPresent(blade_flurry_buff) and Enemies(tagged=1) >= 2 or Enemies(tagged=1) < 2 and BuffPresent(blade_flurry_buff) } and BuffPresent(blade_flurry_buff) and Texture(blade_flurry text=cancel)
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
	#marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit|((raid_event.adds.in>40|buff.true_bearing.remains>15)&combo_points.deficit>=4+talent.deeper_stratagem.enabled+talent.anticipation.enabled)
	if target.TimeToDie() < ComboPointsDeficit() or { 600 > 40 or BuffRemaining(true_bearing_buff) > 15 } and ComboPointsDeficit() >= 4 + TalentPoints(deeper_stratagem_talent) + TalentPoints(anticipation_talent) Spell(marked_for_death)
	#sprint,if=equipped.thraxis_tricksy_treads&!variable.ss_useable
	if HasEquippedItem(thraxis_tricksy_treads) and not ss_useable() Spell(sprint)
	#curse_of_the_dreadblades,if=combo_points.deficit>=4&(!talent.ghostly_strike.enabled|debuff.ghostly_strike.up)
	if ComboPointsDeficit() >= 4 and { not Talent(ghostly_strike_talent) or target.DebuffPresent(ghostly_strike_debuff) } Spell(curse_of_the_dreadblades)
}

AddFunction OutlawCdsShortCdPostConditions
{
}

AddFunction OutlawCdsCdActions
{
	#potion,name=prolonged_power,if=buff.bloodlust.react|target.time_to_die<=25|buff.adrenaline_rush.up
	#use_item,slot=trinket2,if=buff.bloodlust.react|target.time_to_die<=20|combo_points.deficit<=2
	# if BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 20 or ComboPointsDeficit() <= 2 OutlawUseItemActions()
	#blood_fury
	Spell(blood_fury_ap)
	#berserking
	Spell(berserking)
	#arcane_torrent,if=energy.deficit>40
	if EnergyDeficit() > 40 Spell(arcane_torrent_energy)

	unless Enemies(tagged=1) >= 1 and Spell(cannonball_barrage)
	{
		#adrenaline_rush,if=!buff.adrenaline_rush.up&energy.deficit>0
		if not BuffPresent(adrenaline_rush_buff) and EnergyDeficit() > 0 Spell(adrenaline_rush)

		unless HasEquippedItem(thraxis_tricksy_treads) and not ss_useable() and Spell(sprint)
		{
			#darkflight,if=equipped.thraxis_tricksy_treads&!variable.ss_useable&buff.sprint.down
			if HasEquippedItem(thraxis_tricksy_treads) and not ss_useable() and BuffExpires(sprint_buff) Spell(darkflight)
		}
	}
}

AddFunction OutlawCdsCdPostConditions
{
	Enemies(tagged=1) >= 1 and Spell(cannonball_barrage) or HasEquippedItem(thraxis_tricksy_treads) and not ss_useable() and Spell(sprint) or ComboPointsDeficit() >= 4 and { not Talent(ghostly_strike_talent) or target.DebuffPresent(ghostly_strike_debuff) } and Spell(curse_of_the_dreadblades)
}

### actions.finish

AddFunction OutlawFinishMainActions
{
	#between_the_eyes,if=equipped.greenskins_waterlogged_wristcuffs&!buff.greenskins_waterlogged_wristcuffs.up
	if HasEquippedItem(greenskins_waterlogged_wristcuffs) and not BuffPresent(greenskins_waterlogged_wristcuffs_buff) Spell(between_the_eyes)
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
	HasEquippedItem(greenskins_waterlogged_wristcuffs) and not BuffPresent(greenskins_waterlogged_wristcuffs_buff) and Spell(between_the_eyes) or { not Talent(death_from_above_talent) or TimeToMaxEnergy() < SpellCooldown(death_from_above) + 3.5 } and Spell(run_through)
}

AddFunction OutlawFinishCdActions
{
}

AddFunction OutlawFinishCdPostConditions
{
	HasEquippedItem(greenskins_waterlogged_wristcuffs) and not BuffPresent(greenskins_waterlogged_wristcuffs_buff) and Spell(between_the_eyes) or { not Talent(death_from_above_talent) or TimeToMaxEnergy() < SpellCooldown(death_from_above) + 3.5 } and Spell(run_through)
}

### actions.precombat

AddFunction OutlawPrecombatMainActions
{
	#flask,name=flask_of_the_seventh_demon
	#augmentation,name=defiled
	Spell(augmentation)
	#food,name=seedbattered_fish_plate
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
	unless Spell(augmentation) or Spell(stealth)
	{
		#potion,name=prolonged_power
		#marked_for_death,if=raid_event.adds.in>40
		if 600 > 40 Spell(marked_for_death)
	}
}

AddFunction OutlawPrecombatShortCdPostConditions
{
	Spell(augmentation) or Spell(stealth) or not Talent(slice_and_dice_talent) and Spell(roll_the_bones)
}

AddFunction OutlawPrecombatCdActions
{
}

AddFunction OutlawPrecombatCdPostConditions
{
	Spell(augmentation) or Spell(stealth) or not Talent(slice_and_dice_talent) and Spell(roll_the_bones)
}

### actions.stealth

AddFunction OutlawStealthMainActions
{
	#variable,name=stealth_condition,value=combo_points.deficit>=2+2*(talent.ghostly_strike.enabled&!debuff.ghostly_strike.up)+buff.broadsides.up&energy>60&!buff.jolly_roger.up&!buff.hidden_blade.up&!buff.curse_of_the_dreadblades.up
	#ambush
	Spell(ambush)
}

AddFunction OutlawStealthMainPostConditions
{
}

AddFunction OutlawStealthShortCdActions
{
	unless Spell(ambush)
	{
		#vanish,if=(equipped.mantle_of_the_master_assassin&buff.true_bearing.up)|variable.stealth_condition
		if HasEquippedItem(mantle_of_the_master_assassin) and BuffPresent(true_bearing_buff) or stealth_condition() Spell(vanish)
	}
}

AddFunction OutlawStealthShortCdPostConditions
{
	Spell(ambush)
}

AddFunction OutlawStealthCdActions
{
	unless Spell(ambush)
	{
		#shadowmeld,if=variable.stealth_condition
		if stealth_condition() Spell(shadowmeld)
	}
}

AddFunction OutlawStealthCdPostConditions
{
	Spell(ambush)
}
]]

	OvaleScripts:RegisterScript("ROGUE", "outlaw", name, desc, code, "script")
end
