local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_stabby"
	local desc = "[Xel][7.1.5] Blush: Stabby"
	local code = [[

Include(ovale_common)
Include(ovale_interrupt)
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
	if not InCombat() and target.Present() and target.Exists() and not target.IsFriend() and not mounted()
	{
		if BuffExpires(stealthed_buff any=1) Spell(stealth)
		#marked_for_death
		if target.InRange(marked_for_death) Spell(marked_for_death)
		#slice_and_dice,if=talent.marked_for_death.enabled
		# if ComboPoints() >0 and not BuffPresent(slice_and_dice_buff) Spell(slice_and_dice)
	}
	
	if HealthPercent() < 70 and { not Boss() or not InCombat() } Spell(crimson_vial)
	if InCombat() and target.Casting(interrupt) InterruptActions()
	
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
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
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
	if target.IsFriend(no) and target.IsInterruptible()
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

### actions.default

AddFunction AssassinationDefaultMainActions
{
	#call_action_list,name=cds
	AssassinationCdsMainActions()

	unless AssassinationCdsMainPostConditions()
	{
		#call_action_list,name=maintain
		AssassinationMaintainMainActions()

		unless AssassinationMaintainMainPostConditions()
		{
			#call_action_list,name=finish,if=(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)&(!dot.rupture.refreshable|(dot.rupture.exsanguinated&dot.rupture.remains>=3.5)|target.time_to_die-dot.rupture.remains<=4)&active_dot.rupture>=spell_targets.rupture
			if { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 4 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) AssassinationFinishMainActions()

			unless { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 4 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) and AssassinationFinishMainPostConditions()
			{
				#call_action_list,name=build,if=combo_points.deficit>0|energy.time_to_max<1
				if ComboPointsDeficit() > 0 or TimeToMaxEnergy() < 1 AssassinationBuildMainActions()
			}
		}
	}
}

AddFunction AssassinationDefaultMainPostConditions
{
	AssassinationCdsMainPostConditions() or AssassinationMaintainMainPostConditions() or { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 4 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) and AssassinationFinishMainPostConditions() or { ComboPointsDeficit() > 0 or TimeToMaxEnergy() < 1 } and AssassinationBuildMainPostConditions()
}

AddFunction AssassinationDefaultShortCdActions
{
	#call_action_list,name=cds
	AssassinationCdsShortCdActions()

	unless AssassinationCdsShortCdPostConditions()
	{
		#call_action_list,name=maintain
		AssassinationMaintainShortCdActions()

		unless AssassinationMaintainShortCdPostConditions()
		{
			#call_action_list,name=finish,if=(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)&(!dot.rupture.refreshable|(dot.rupture.exsanguinated&dot.rupture.remains>=3.5)|target.time_to_die-dot.rupture.remains<=4)&active_dot.rupture>=spell_targets.rupture
			if { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 4 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) AssassinationFinishShortCdActions()

			unless { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 4 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) and AssassinationFinishShortCdPostConditions()
			{
				#call_action_list,name=build,if=combo_points.deficit>0|energy.time_to_max<1
				if ComboPointsDeficit() > 0 or TimeToMaxEnergy() < 1 AssassinationBuildShortCdActions()
			}
		}
	}
}

AddFunction AssassinationDefaultShortCdPostConditions
{
	AssassinationCdsShortCdPostConditions() or AssassinationMaintainShortCdPostConditions() or { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 4 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) and AssassinationFinishShortCdPostConditions() or { ComboPointsDeficit() > 0 or TimeToMaxEnergy() < 1 } and AssassinationBuildShortCdPostConditions()
}

AddFunction AssassinationDefaultCdActions
{
	#kick
	# AssassinationInterruptActions()
	#call_action_list,name=cds
	AssassinationCdsCdActions()

	unless AssassinationCdsCdPostConditions()
	{
		#call_action_list,name=maintain
		AssassinationMaintainCdActions()

		unless AssassinationMaintainCdPostConditions()
		{
			#call_action_list,name=finish,if=(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)&(!dot.rupture.refreshable|(dot.rupture.exsanguinated&dot.rupture.remains>=3.5)|target.time_to_die-dot.rupture.remains<=4)&active_dot.rupture>=spell_targets.rupture
			if { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 4 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) AssassinationFinishCdActions()

			unless { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 4 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) and AssassinationFinishCdPostConditions()
			{
				#call_action_list,name=build,if=combo_points.deficit>0|energy.time_to_max<1
				if ComboPointsDeficit() > 0 or TimeToMaxEnergy() < 1 AssassinationBuildCdActions()
			}
		}
	}
}

AddFunction AssassinationDefaultCdPostConditions
{
	AssassinationCdsCdPostConditions() or AssassinationMaintainCdPostConditions() or { not Talent(exsanguinate_talent) or SpellCooldown(exsanguinate) > 2 } and { not target.DebuffRefreshable(rupture_debuff) or target.DebuffRemaining(rupture_debuff_exsanguinated) and target.DebuffRemaining(rupture_debuff) >= 3.5 or target.TimeToDie() - target.DebuffRemaining(rupture_debuff) <= 4 } and DebuffCountOnAny(rupture_debuff) >= Enemies(tagged=1) and AssassinationFinishCdPostConditions() or { ComboPointsDeficit() > 0 or TimeToMaxEnergy() < 1 } and AssassinationBuildCdPostConditions()
}

### actions.build

AddFunction AssassinationBuildMainActions
{
	#hemorrhage,if=refreshable
	if target.Refreshable(hemorrhage_debuff) Spell(hemorrhage)
	#hemorrhage,cycle_targets=1,if=refreshable&dot.rupture.ticking&spell_targets.fan_of_knives<2+talent.agonizing_poison.enabled+(talent.agonizing_poison.enabled&equipped.insignia_of_ravenholdt)
	if target.Refreshable(hemorrhage_debuff) and target.DebuffPresent(rupture_debuff) and Enemies(tagged=1) < 2 + TalentPoints(agonizing_poison_talent) + { Talent(agonizing_poison_talent) and HasEquippedItem(insignia_of_ravenholdt) } Spell(hemorrhage)
	#fan_of_knives,if=spell_targets>=2+talent.agonizing_poison.enabled+(talent.agonizing_poison.enabled&equipped.insignia_of_ravenholdt)|buff.the_dreadlords_deceit.stack>=29
	if Enemies(tagged=1) >= 2 + TalentPoints(agonizing_poison_talent) + { Talent(agonizing_poison_talent) and HasEquippedItem(insignia_of_ravenholdt) } or BuffStacks(the_dreadlords_deceit_buff) >= 29 Spell(fan_of_knives)
	#mutilate,cycle_targets=1,if=(!talent.agonizing_poison.enabled&dot.deadly_poison_dot.refreshable)|(talent.agonizing_poison.enabled&debuff.agonizing_poison.remains<debuff.agonizing_poison.duration*0.3)
	if not Talent(agonizing_poison_talent) and target.DebuffRefreshable(deadly_poison_dot_debuff) or Talent(agonizing_poison_talent) and target.DebuffRemaining(agonizing_poison_debuff) < BaseDuration(agonizing_poison_debuff) * 0.3 Spell(mutilate)
	#mutilate,if=cooldown.vendetta.remains<7|debuff.vendetta.up|debuff.kingsbane.up|energy.deficit<=22|target.time_to_die<6
	if SpellCooldown(vendetta) < 7 or target.DebuffPresent(vendetta_debuff) or target.DebuffPresent(kingsbane_debuff) or EnergyDeficit() <= 22 or target.TimeToDie() < 6 Spell(mutilate)
}

AddFunction AssassinationBuildMainPostConditions
{
}

AddFunction AssassinationBuildShortCdActions
{
}

AddFunction AssassinationBuildShortCdPostConditions
{
	target.Refreshable(hemorrhage_debuff) and Spell(hemorrhage) or target.Refreshable(hemorrhage_debuff) and target.DebuffPresent(rupture_debuff) and Enemies(tagged=1) < 2 + TalentPoints(agonizing_poison_talent) + { Talent(agonizing_poison_talent) and HasEquippedItem(insignia_of_ravenholdt) } and Spell(hemorrhage) or { Enemies(tagged=1) >= 2 + TalentPoints(agonizing_poison_talent) + { Talent(agonizing_poison_talent) and HasEquippedItem(insignia_of_ravenholdt) } or BuffStacks(the_dreadlords_deceit_buff) >= 29 } and Spell(fan_of_knives) or { not Talent(agonizing_poison_talent) and target.DebuffRefreshable(deadly_poison_dot_debuff) or Talent(agonizing_poison_talent) and target.DebuffRemaining(agonizing_poison_debuff) < BaseDuration(agonizing_poison_debuff) * 0.3 } and Spell(mutilate) or { SpellCooldown(vendetta) < 7 or target.DebuffPresent(vendetta_debuff) or target.DebuffPresent(kingsbane_debuff) or EnergyDeficit() <= 22 or target.TimeToDie() < 6 } and Spell(mutilate)
}

AddFunction AssassinationBuildCdActions
{
}

AddFunction AssassinationBuildCdPostConditions
{
	target.Refreshable(hemorrhage_debuff) and Spell(hemorrhage) or target.Refreshable(hemorrhage_debuff) and target.DebuffPresent(rupture_debuff) and Enemies(tagged=1) < 2 + TalentPoints(agonizing_poison_talent) + { Talent(agonizing_poison_talent) and HasEquippedItem(insignia_of_ravenholdt) } and Spell(hemorrhage) or { Enemies(tagged=1) >= 2 + TalentPoints(agonizing_poison_talent) + { Talent(agonizing_poison_talent) and HasEquippedItem(insignia_of_ravenholdt) } or BuffStacks(the_dreadlords_deceit_buff) >= 29 } and Spell(fan_of_knives) or { not Talent(agonizing_poison_talent) and target.DebuffRefreshable(deadly_poison_dot_debuff) or Talent(agonizing_poison_talent) and target.DebuffRemaining(agonizing_poison_debuff) < BaseDuration(agonizing_poison_debuff) * 0.3 } and Spell(mutilate) or { SpellCooldown(vendetta) < 7 or target.DebuffPresent(vendetta_debuff) or target.DebuffPresent(kingsbane_debuff) or EnergyDeficit() <= 22 or target.TimeToDie() < 6 } and Spell(mutilate)
}

### actions.cds

AddFunction AssassinationCdsMainActions
{
}

AddFunction AssassinationCdsMainPostConditions
{
}

AddFunction AssassinationCdsShortCdActions
{
	#marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit*1.5|(raid_event.adds.in>40&combo_points.deficit>=cp_max_spend)
	if target.TimeToDie() < ComboPointsDeficit() * 1.5 or 600 > 40 and ComboPointsDeficit() >= MaxComboPoints() Spell(marked_for_death)
	#vanish,if=talent.nightstalker.enabled&combo_points>=cp_max_spend&((talent.exsanguinate.enabled&cooldown.exsanguinate.remains<1&(dot.rupture.ticking|time>10))|(!talent.exsanguinate.enabled&dot.rupture.refreshable))
	if Talent(nightstalker_talent) and ComboPoints() >= MaxComboPoints() and { Talent(exsanguinate_talent) and SpellCooldown(exsanguinate) < 1 and { target.DebuffPresent(rupture_debuff) or TimeInCombat() > 10 } or not Talent(exsanguinate_talent) and target.DebuffRefreshable(rupture_debuff) } and CheckBoxOn(opt_vanish) Spell(vanish)
	#vanish,if=talent.subterfuge.enabled&dot.garrote.refreshable&((spell_targets.fan_of_knives<=3&combo_points.deficit>=1+spell_targets.fan_of_knives)|(spell_targets.fan_of_knives>=4&combo_points.deficit>=4))
	if Talent(subterfuge_talent) and target.DebuffRefreshable(garrote_debuff) and { Enemies(tagged=1) <= 3 and ComboPointsDeficit() >= 1 + Enemies(tagged=1) or Enemies(tagged=1) >= 4 and ComboPointsDeficit() >= 4 } and CheckBoxOn(opt_vanish) Spell(vanish)
	#vanish,if=talent.shadow_focus.enabled&energy.time_to_max>=2&combo_points.deficit>=4
	if Talent(shadow_focus_talent) and TimeToMaxEnergy() >= 2 and ComboPointsDeficit() >= 4 and CheckBoxOn(opt_vanish) Spell(vanish)
	#exsanguinate,if=prev_gcd.1.rupture&dot.rupture.remains>4+4*cp_max_spend
	if PreviousGCDSpell(rupture) and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() Spell(exsanguinate)
}

AddFunction AssassinationCdsShortCdPostConditions
{
}

AddFunction AssassinationCdsCdActions
{
	#potion,name=old_war,if=buff.bloodlust.react|target.time_to_die<=25|debuff.vendetta.up&cooldown.vanish.remains<5
	#use_item,slot=trinket1,if=buff.bloodlust.react|target.time_to_die<=20|debuff.vendetta.up
	# if BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 20 or target.DebuffPresent(vendetta_debuff) AssassinationUseItemActions()
	#use_item,slot=trinket2,if=buff.bloodlust.react|target.time_to_die<=20|debuff.vendetta.up
	# if BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 20 or target.DebuffPresent(vendetta_debuff) AssassinationUseItemActions()
	#blood_fury,if=debuff.vendetta.up
	if target.DebuffPresent(vendetta_debuff) Spell(blood_fury_ap)
	#berserking,if=debuff.vendetta.up
	if target.DebuffPresent(vendetta_debuff) Spell(berserking)
	#arcane_torrent,if=debuff.vendetta.up&energy.deficit>30
	if target.DebuffPresent(vendetta_debuff) and EnergyDeficit() > 30 Spell(arcane_torrent_energy)
	#vendetta,if=talent.exsanguinate.enabled&(!artifact.urge_to_kill.enabled|energy.deficit>=75+talent.vigor.enabled*50)
	if Talent(exsanguinate_talent) and { not HasArtifactTrait(urge_to_kill) or EnergyDeficit() >= 75 + TalentPoints(vigor_talent) * 50 } Spell(vendetta)
	#vendetta,if=!talent.exsanguinate.enabled&(!artifact.urge_to_kill.enabled|energy.deficit>=85+talent.vigor.enabled*40)
	if not Talent(exsanguinate_talent) and { not HasArtifactTrait(urge_to_kill) or EnergyDeficit() >= 85 + TalentPoints(vigor_talent) * 40 } Spell(vendetta)
}

AddFunction AssassinationCdsCdPostConditions
{
	PreviousGCDSpell(rupture) and target.DebuffRemaining(rupture_debuff) > 4 + 4 * MaxComboPoints() and Spell(exsanguinate)
}

### actions.finish

AddFunction AssassinationFinishMainActions
{
	#death_from_above,if=combo_points>=cp_max_spend
	if ComboPoints() >= MaxComboPoints() Spell(death_from_above)
	#envenom,if=combo_points>=4|(talent.elaborate_planning.enabled&combo_points>=3+!talent.exsanguinate.enabled&buff.elaborate_planning.remains<0.3)
	if ComboPoints() >= 4 or Talent(elaborate_planning_talent) and ComboPoints() >= 3 + Talent(exsanguinate_talent no) and BuffRemaining(elaborate_planning_buff) < 0.3 Spell(envenom)
}

AddFunction AssassinationFinishMainPostConditions
{
}

AddFunction AssassinationFinishShortCdActions
{
}

AddFunction AssassinationFinishShortCdPostConditions
{
	ComboPoints() >= MaxComboPoints() and Spell(death_from_above) or { ComboPoints() >= 4 or Talent(elaborate_planning_talent) and ComboPoints() >= 3 + Talent(exsanguinate_talent no) and BuffRemaining(elaborate_planning_buff) < 0.3 } and Spell(envenom)
}

AddFunction AssassinationFinishCdActions
{
}

AddFunction AssassinationFinishCdPostConditions
{
	ComboPoints() >= MaxComboPoints() and Spell(death_from_above) or { ComboPoints() >= 4 or Talent(elaborate_planning_talent) and ComboPoints() >= 3 + Talent(exsanguinate_talent no) and BuffRemaining(elaborate_planning_buff) < 0.3 } and Spell(envenom)
}

### actions.maintain

AddFunction AssassinationMaintainMainActions
{
	#rupture,if=talent.nightstalker.enabled&stealthed.rogue
	if Talent(nightstalker_talent) and Stealthed() Spell(rupture)
	#rupture,if=talent.exsanguinate.enabled&((combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1)|(!ticking&(time>10|combo_points>=2+artifact.urge_to_kill.enabled)))
	if Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } Spell(rupture)
	#rupture,if=!talent.exsanguinate.enabled&!ticking
	if not Talent(exsanguinate_talent) and not target.DebuffPresent(rupture_debuff) Spell(rupture)
	#rupture,cycle_targets=1,if=combo_points>=cp_max_spend-talent.exsanguinate.enabled&refreshable&(!exsanguinated|remains<=1.5)&target.time_to_die-remains>4
	if ComboPoints() >= MaxComboPoints() - TalentPoints(exsanguinate_talent) and target.Refreshable(rupture_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= 1.5 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 Spell(rupture)
	#kingsbane,if=(talent.exsanguinate.enabled&dot.rupture.exsanguinated)|(!talent.exsanguinate.enabled&buff.envenom.up&(debuff.vendetta.up|cooldown.vendetta.remains>10))
	if Talent(exsanguinate_talent) and target.DebuffRemaining(rupture_debuff_exsanguinated) or not Talent(exsanguinate_talent) and BuffPresent(envenom_buff) and { target.DebuffPresent(vendetta_debuff) or SpellCooldown(vendetta) > 10 } Spell(kingsbane)
	#pool_resource,for_next=1
	#garrote,cycle_targets=1,if=combo_points.deficit>=1&refreshable&(!exsanguinated|remains<=1.5)&target.time_to_die-remains>4
	if ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= 1.5 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 Spell(garrote)
}

AddFunction AssassinationMaintainMainPostConditions
{
}

AddFunction AssassinationMaintainShortCdActions
{
}

AddFunction AssassinationMaintainShortCdPostConditions
{
	Talent(nightstalker_talent) and Stealthed() and Spell(rupture) or Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } and Spell(rupture) or not Talent(exsanguinate_talent) and not target.DebuffPresent(rupture_debuff) and Spell(rupture) or ComboPoints() >= MaxComboPoints() - TalentPoints(exsanguinate_talent) and target.Refreshable(rupture_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= 1.5 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 and Spell(rupture) or { Talent(exsanguinate_talent) and target.DebuffRemaining(rupture_debuff_exsanguinated) or not Talent(exsanguinate_talent) and BuffPresent(envenom_buff) and { target.DebuffPresent(vendetta_debuff) or SpellCooldown(vendetta) > 10 } } and Spell(kingsbane) or ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= 1.5 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and Spell(garrote)
}

AddFunction AssassinationMaintainCdActions
{
}

AddFunction AssassinationMaintainCdPostConditions
{
	Talent(nightstalker_talent) and Stealthed() and Spell(rupture) or Talent(exsanguinate_talent) and { ComboPoints() >= MaxComboPoints() and SpellCooldown(exsanguinate) < 1 or not target.DebuffPresent(rupture_debuff) and { TimeInCombat() > 10 or ComboPoints() >= 2 + HasArtifactTrait(urge_to_kill) } } and Spell(rupture) or not Talent(exsanguinate_talent) and not target.DebuffPresent(rupture_debuff) and Spell(rupture) or ComboPoints() >= MaxComboPoints() - TalentPoints(exsanguinate_talent) and target.Refreshable(rupture_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(rupture_debuff) <= 1.5 } and target.TimeToDie() - target.DebuffRemaining(rupture_debuff) > 4 and Spell(rupture) or { Talent(exsanguinate_talent) and target.DebuffRemaining(rupture_debuff_exsanguinated) or not Talent(exsanguinate_talent) and BuffPresent(envenom_buff) and { target.DebuffPresent(vendetta_debuff) or SpellCooldown(vendetta) > 10 } } and Spell(kingsbane) or ComboPointsDeficit() >= 1 and target.Refreshable(garrote_debuff) and { not target.DebuffPresent(exsanguinated) or target.DebuffRemaining(garrote_debuff) <= 1.5 } and target.TimeToDie() - target.DebuffRemaining(garrote_debuff) > 4 and Spell(garrote)
}

### actions.precombat

AddFunction AssassinationPrecombatMainActions
{
	#flask,name=flask_of_the_seventh_demon
	#augmentation,name=defiled
	# Spell(augmentation)
	#food,name=seedbattered_fish_plate,if=talent.exsanguinate.enabled
	#food,name=nightborne_delicacy_platter,if=!talent.exsanguinate.enabled
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
	unless Spell(augmentation) or Spell(stealth)
	{
		#potion,name=old_war
		#marked_for_death,if=raid_event.adds.in>40
		if 600 > 40 Spell(marked_for_death)
	}
}

AddFunction AssassinationPrecombatShortCdPostConditions
{
	Spell(augmentation) or Spell(stealth)
}

AddFunction AssassinationPrecombatCdActions
{
}

AddFunction AssassinationPrecombatCdPostConditions
{
	Spell(augmentation) or Spell(stealth)
}
]]

	OvaleScripts:RegisterScript("ROGUE", "assassination", name, desc, code, "script")
end
