local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_fury"
	local desc = "[Xel][7.2.5] Warrior: Fury"
	local code = [[
Include(ovale_common)

Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_warrior_spells)

# Fury
AddIcon specialization=2 help=main
{
	if InCombat() InterruptActions()
	
    if target.InRange(rampage) and HasFullControl()
	{
		if not target.IsFriend() and HealthPercent() < 60 and Spell(bloodthirst) Spell(enraged_regeneration)
		# Cooldowns
		if Boss()
		{
			FuryDefaultCdActions()
		}
		
		# Short Cooldowns
		FuryDefaultShortCdActions()
		
		# Default rotation
		FuryDefaultMainActions()
	
	}
	# On the move
	if not target.InRange(rampage) and InCombat() and HasFullControl()
	{
		if target.InRange(heroic_throw) Spell(heroic_throw)
		if target.InRange(charge) and { TimeInCombat() < 6 or Falling() } Spell(charge)
		if target.InRange(storm_bolt) Spell(storm_bolt)
	}
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(pummel) Spell(pummel)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_rage)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
			if target.InRange(storm_bolt) Spell(storm_bolt)
		}
	}
}

AddFunction FuryUseItemActions
{
    Item(Trinket0Slot usable=1)
    Item(Trinket1Slot usable=1)
}

### actions.default

AddFunction FuryDefaultMainActions
{
	#dragon_roar,if=(equipped.convergence_of_fates&cooldown.battle_cry.remains<2)|!equipped.convergence_of_fates&(!cooldown.battle_cry.remains<=10|cooldown.battle_cry.remains<2)
	if HasEquippedItem(convergence_of_fates) and SpellCooldown(battle_cry) < 2 or not HasEquippedItem(convergence_of_fates) and { not SpellCooldown(battle_cry) <= 10 or SpellCooldown(battle_cry) < 2 } Spell(dragon_roar)
	#rampage,if=cooldown.battle_cry.remains<4&target.health.pct>20
	if SpellCooldown(battle_cry) < 4 and target.HealthPercent() > 20 Spell(rampage)
	#bloodthirst,if=equipped.kazzalax_fujiedas_fury&buff.fujiedas_fury.down
	if HasEquippedItem(kazzalax_fujiedas_fury) and BuffExpires(fujiedas_fury_buff) Spell(bloodthirst)
	#bloodbath,if=buff.dragon_roar.up|!talent.dragon_roar.enabled&buff.battle_cry.up
	if BuffPresent(dragon_roar_buff) or not Talent(dragon_roar_talent) and BuffPresent(battle_cry_buff) Spell(bloodbath)
	#run_action_list,name=cooldowns,if=buff.battle_cry.up&spell_targets.whirlwind=1
	if BuffPresent(battle_cry_buff) and Enemies(tagged=1) == 1 FuryCooldownsMainActions()

	unless BuffPresent(battle_cry_buff) and Enemies(tagged=1) == 1 and FuryCooldownsMainPostConditions()
	{
		#call_action_list,name=three_targets,if=target.health.pct>20&(spell_targets.whirlwind=3|spell_targets.whirlwind=4)
		if target.HealthPercent() > 20 and { Enemies(tagged=1) == 3 or Enemies(tagged=1) == 4 } FuryThreeTargetsMainActions()

		unless target.HealthPercent() > 20 and { Enemies(tagged=1) == 3 or Enemies(tagged=1) == 4 } and FuryThreeTargetsMainPostConditions()
		{
			#call_action_list,name=aoe,if=spell_targets.whirlwind>4
			if Enemies(tagged=1) > 4 FuryAoeMainActions()

			unless Enemies(tagged=1) > 4 and FuryAoeMainPostConditions()
			{
				#run_action_list,name=execute,if=target.health.pct<20
				if target.HealthPercent() < 20 FuryExecuteMainActions()

				unless target.HealthPercent() < 20 and FuryExecuteMainPostConditions()
				{
					#run_action_list,name=single_target,if=target.health.pct>20
					if target.HealthPercent() > 20 FurySingleTargetMainActions()
				}
			}
		}
	}
}

AddFunction FuryDefaultMainPostConditions
{
    BuffPresent(battle_cry_buff) and Enemies(tagged=1) == 1 and FuryCooldownsMainPostConditions() or target.HealthPercent() > 20 and { Enemies(tagged=1) == 3 or Enemies(tagged=1) == 4 } and FuryThreeTargetsMainPostConditions() or Enemies(tagged=1) > 4 and FuryAoeMainPostConditions() or target.HealthPercent() < 20 and FuryExecuteMainPostConditions() or target.HealthPercent() > 20 and FurySingleTargetMainPostConditions()
}

AddFunction FuryDefaultShortCdActions
{
	unless { HasEquippedItem(convergence_of_fates) and SpellCooldown(battle_cry) < 2 or not HasEquippedItem(convergence_of_fates) and { not SpellCooldown(battle_cry) <= 10 or SpellCooldown(battle_cry) < 2 } } and Spell(dragon_roar) or SpellCooldown(battle_cry) < 4 and target.HealthPercent() > 20 and Spell(rampage) or HasEquippedItem(kazzalax_fujiedas_fury) and BuffExpires(fujiedas_fury_buff) and Spell(bloodthirst)
	{
		#run_action_list,name=cooldowns,if=buff.battle_cry.up&spell_targets.whirlwind=1
		if BuffPresent(battle_cry_buff) and Enemies(tagged=1) == 1 FuryCooldownsShortCdActions()

		unless BuffPresent(battle_cry_buff) and Enemies(tagged=1) == 1 and FuryCooldownsShortCdPostConditions()
		{
			#call_action_list,name=three_targets,if=target.health.pct>20&(spell_targets.whirlwind=3|spell_targets.whirlwind=4)
			if target.HealthPercent() > 20 and { Enemies(tagged=1) == 3 or Enemies(tagged=1) == 4 } FuryThreeTargetsShortCdActions()

			unless target.HealthPercent() > 20 and { Enemies(tagged=1) == 3 or Enemies(tagged=1) == 4 } and FuryThreeTargetsShortCdPostConditions()
			{
				#call_action_list,name=aoe,if=spell_targets.whirlwind>4
				if Enemies(tagged=1) > 4 FuryAoeShortCdActions()

				unless Enemies(tagged=1) > 4 and FuryAoeShortCdPostConditions()
				{
					#run_action_list,name=execute,if=target.health.pct<20
					if target.HealthPercent() < 20 FuryExecuteShortCdActions()

					unless target.HealthPercent() < 20 and FuryExecuteShortCdPostConditions()
					{
						#run_action_list,name=single_target,if=target.health.pct>20
						if target.HealthPercent() > 20 FurySingleTargetShortCdActions()
					}
				}
			}
		}
	}
}

AddFunction FuryDefaultShortCdPostConditions
{
    { HasEquippedItem(convergence_of_fates) and SpellCooldown(battle_cry) < 2 or not HasEquippedItem(convergence_of_fates) and { not SpellCooldown(battle_cry) <= 10 or SpellCooldown(battle_cry) < 2 } } and Spell(dragon_roar) or SpellCooldown(battle_cry) < 4 and target.HealthPercent() > 20 and Spell(rampage) or HasEquippedItem(kazzalax_fujiedas_fury) and BuffExpires(fujiedas_fury_buff) and Spell(bloodthirst) or BuffPresent(battle_cry_buff) and Enemies(tagged=1) == 1 and FuryCooldownsShortCdPostConditions() or target.HealthPercent() > 20 and { Enemies(tagged=1) == 3 or Enemies(tagged=1) == 4 } and FuryThreeTargetsShortCdPostConditions() or Enemies(tagged=1) > 4 and FuryAoeShortCdPostConditions() or target.HealthPercent() < 20 and FuryExecuteShortCdPostConditions() or target.HealthPercent() > 20 and FurySingleTargetShortCdPostConditions()
}

AddFunction FuryDefaultCdActions
{
	#potion,name=old_war,if=buff.battle_cry.up&(buff.avatar.up|!talent.avatar.enabled)
	# if BuffPresent(battle_cry_buff) and { BuffPresent(avatar_buff) or not Talent(avatar_talent) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(old_war_potion usable=1)

	unless { HasEquippedItem(convergence_of_fates) and SpellCooldown(battle_cry) < 2 or not HasEquippedItem(convergence_of_fates) and { not SpellCooldown(battle_cry) <= 10 or SpellCooldown(battle_cry) < 2 } } and Spell(dragon_roar) or SpellCooldown(battle_cry) < 4 and target.HealthPercent() > 20 and Spell(rampage) or HasEquippedItem(kazzalax_fujiedas_fury) and BuffExpires(fujiedas_fury_buff) and Spell(bloodthirst)
	{
		#avatar,if=buff.battle_cry.remains>6|cooldown.battle_cry.remains<10|(target.time_to_die<(cooldown.battle_cry.remains+10))
		if BuffRemaining(battle_cry_buff) > 6 or SpellCooldown(battle_cry) < 10 or target.TimeToDie() < SpellCooldown(battle_cry) + 10 Spell(avatar)
		#use_item,name=umbral_moonglaives,if=equipped.umbral_moonglaives&(cooldown.battle_cry.remains>gcd&cooldown.battle_cry.remains<2|cooldown.battle_cry.remains=0)
		if HasEquippedItem(umbral_moonglaives) and { SpellCooldown(battle_cry) > GCD() and SpellCooldown(battle_cry) < 2 or not SpellCooldown(battle_cry) > 0 } FuryUseItemActions()
		#battle_cry,if=gcd.remains=0&talent.reckless_abandon.enabled&(equipped.umbral_moonglaives&(prev_off_gcd.umbral_moonglaives|(trinket.cooldown.remains>3&trinket.cooldown.remains<90))|!equipped.umbral_moonglaives)
		if not 0 > 0 and Talent(reckless_abandon_talent) and { HasEquippedItem(umbral_moonglaives) and { ItemCooldown(Trinket0Slot) > 3 and ItemCooldown(Trinket1Slot) > 3 and ItemCooldown(Trinket0Slot) < 90 and ItemCooldown(Trinket1Slot) < 90 } or not HasEquippedItem(umbral_moonglaives) } Spell(battle_cry)
		#battle_cry,if=gcd.remains=0&talent.bladestorm.enabled&(raid_event.adds.in>90|!raid_event.adds.exists|spell_targets.bladestorm_mh>desired_targets)
		if not 0 > 0 and Talent(bladestorm_talent) and { 600 > 90 or not False(raid_event_adds_exists) or Enemies(tagged=1) > Enemies(tagged=1) } Spell(battle_cry)
		#battle_cry,if=gcd.remains=0&buff.dragon_roar.up&(cooldown.bloodthirst.remains=0|buff.enrage.remains>cooldown.bloodthirst.remains)
		if not 0 > 0 and BuffPresent(dragon_roar_buff) and { not SpellCooldown(bloodthirst) > 0 or EnrageRemaining() > SpellCooldown(bloodthirst) } Spell(battle_cry)
		#use_item,name=umbral_moonglaives,if=!equipped.umbral_moonglaives&buff.battle_cry.up&buff.enrage.up
		# if not HasEquippedItem(umbral_moonglaives) and BuffPresent(battle_cry_buff) and IsEnraged() FuryUseItemActions()
		#blood_fury,if=buff.battle_cry.up
		if BuffPresent(battle_cry_buff) Spell(blood_fury_ap)
		#berserking,if=buff.battle_cry.up
		if BuffPresent(battle_cry_buff) Spell(berserking)
		#arcane_torrent,if=rage<rage.max-40
		if Rage() < MaxRage() - 40 Spell(arcane_torrent_rage)
		#run_action_list,name=cooldowns,if=buff.battle_cry.up&spell_targets.whirlwind=1
		if BuffPresent(battle_cry_buff) and Enemies(tagged=1) == 1 FuryCooldownsCdActions()

		unless BuffPresent(battle_cry_buff) and Enemies(tagged=1) == 1 and FuryCooldownsCdPostConditions()
		{
			#call_action_list,name=three_targets,if=target.health.pct>20&(spell_targets.whirlwind=3|spell_targets.whirlwind=4)
			if target.HealthPercent() > 20 and { Enemies(tagged=1) == 3 or Enemies(tagged=1) == 4 } FuryThreeTargetsCdActions()

			unless target.HealthPercent() > 20 and { Enemies(tagged=1) == 3 or Enemies(tagged=1) == 4 } and FuryThreeTargetsCdPostConditions()
			{
				#call_action_list,name=aoe,if=spell_targets.whirlwind>4
				if Enemies(tagged=1) > 4 FuryAoeCdActions()

				unless Enemies(tagged=1) > 4 and FuryAoeCdPostConditions()
				{
					#run_action_list,name=execute,if=target.health.pct<20
					if target.HealthPercent() < 20 FuryExecuteCdActions()

					unless target.HealthPercent() < 20 and FuryExecuteCdPostConditions()
					{
						#run_action_list,name=single_target,if=target.health.pct>20
						if target.HealthPercent() > 20 FurySingleTargetCdActions()
					}
				}
			}
		}
	}
}

AddFunction FuryDefaultCdPostConditions
{
    { HasEquippedItem(convergence_of_fates) and SpellCooldown(battle_cry) < 2 or not HasEquippedItem(convergence_of_fates) and { not SpellCooldown(battle_cry) <= 10 or SpellCooldown(battle_cry) < 2 } } and Spell(dragon_roar) or SpellCooldown(battle_cry) < 4 and target.HealthPercent() > 20 and Spell(rampage) or HasEquippedItem(kazzalax_fujiedas_fury) and BuffExpires(fujiedas_fury_buff) and Spell(bloodthirst) or BuffPresent(battle_cry_buff) and Enemies(tagged=1) == 1 and FuryCooldownsCdPostConditions() or target.HealthPercent() > 20 and { Enemies(tagged=1) == 3 or Enemies(tagged=1) == 4 } and FuryThreeTargetsCdPostConditions() or Enemies(tagged=1) > 4 and FuryAoeCdPostConditions() or target.HealthPercent() < 20 and FuryExecuteCdPostConditions() or target.HealthPercent() > 20 and FurySingleTargetCdPostConditions()
}

### actions.aoe

AddFunction FuryAoeMainActions
{
    #bloodthirst,if=buff.enrage.down|rage<90
    if not IsEnraged() or Rage() < 90 Spell(bloodthirst)
    #whirlwind,if=buff.meat_cleaver.down
    if BuffExpires(meat_cleaver_buff) Spell(whirlwind)
    #rampage,if=buff.meat_cleaver.up&(buff.enrage.down&!talent.frothing_berserker.enabled|buff.massacre.react|rage>=100)
    if BuffPresent(meat_cleaver_buff) and { not IsEnraged() and not Talent(frothing_berserker_talent) or BuffPresent(massacre_buff) or Rage() >= 100 } Spell(rampage)
    #bloodthirst
    Spell(bloodthirst)
    #whirlwind
    Spell(whirlwind)
}

AddFunction FuryAoeMainPostConditions
{
}

AddFunction FuryAoeShortCdActions
{
    unless { not IsEnraged() or Rage() < 90 } and Spell(bloodthirst)
    {
        #bladestorm,if=buff.enrage.remains>2&(raid_event.adds.in>90|!raid_event.adds.exists|spell_targets.bladestorm_mh>desired_targets)
        if EnrageRemaining() > 2 and { 600 > 90 or not False(raid_event_adds_exists) or Enemies(tagged=1) > Enemies(tagged=1) } Spell(bladestorm_fury)
    }
}

AddFunction FuryAoeShortCdPostConditions
{
    { not IsEnraged() or Rage() < 90 } and Spell(bloodthirst) or BuffExpires(meat_cleaver_buff) and Spell(whirlwind) or BuffPresent(meat_cleaver_buff) and { not IsEnraged() and not Talent(frothing_berserker_talent) or BuffPresent(massacre_buff) or Rage() >= 100 } and Spell(rampage) or Spell(bloodthirst) or Spell(whirlwind)
}

AddFunction FuryAoeCdActions
{
}

AddFunction FuryAoeCdPostConditions
{
    { not IsEnraged() or Rage() < 90 } and Spell(bloodthirst) or EnrageRemaining() > 2 and { 600 > 90 or not False(raid_event_adds_exists) or Enemies(tagged=1) > Enemies(tagged=1) } and Spell(bladestorm_fury) or BuffExpires(meat_cleaver_buff) and Spell(whirlwind) or BuffPresent(meat_cleaver_buff) and { not IsEnraged() and not Talent(frothing_berserker_talent) or BuffPresent(massacre_buff) or Rage() >= 100 } and Spell(rampage) or Spell(bloodthirst) or Spell(whirlwind)
}

### actions.cooldowns

AddFunction FuryCooldownsMainActions
{
    #rampage,if=talent.massacre.enabled&buff.massacre.react&buff.enrage.remains<1
    if Talent(massacre_talent) and BuffPresent(massacre_buff) and EnrageRemaining() < 1 Spell(rampage)
    #bloodthirst,if=target.health.pct<20&buff.enrage.remains<1
    if target.HealthPercent() < 20 and EnrageRemaining() < 1 Spell(bloodthirst)
    #execute,if=equipped.draught_of_souls&cooldown.draught_of_souls.remains<1&buff.juggernaut.remains<3
    if HasEquippedItem(draught_of_souls) and SpellCooldown(draught_of_souls) < 1 and BuffRemaining(juggernaut_buff) < 3 Spell(execute)
    #odyns_fury,if=buff.enrage.up&cooldown.raging_blow.remains>0&target.health.pct>20
    if IsEnraged() and SpellCooldown(raging_blow) > 0 and target.HealthPercent() > 20 Spell(odyns_fury)
    #execute
    Spell(execute)
    #raging_blow,if=talent.inner_rage.enabled&buff.enrage.up
    if Talent(inner_rage_talent) and IsEnraged() Spell(raging_blow)
    #rampage,if=talent.reckless_abandon.enabled&!talent.frothing_berserker.enabled|(talent.frothing_berserker.enabled&rage>=100)
    if Talent(reckless_abandon_talent) and not Talent(frothing_berserker_talent) or Talent(frothing_berserker_talent) and Rage() >= 100 Spell(rampage)
    #bloodthirst,if=buff.enrage.remains<1&!talent.outburst.enabled
    if EnrageRemaining() < 1 and not Talent(outburst_talent) Spell(bloodthirst)
    #raging_blow
    Spell(raging_blow)
    #bloodthirst
    Spell(bloodthirst)
    #whirlwind,if=buff.wrecking_ball.react&buff.enrage.up
    if BuffPresent(wrecking_ball_buff) and IsEnraged() Spell(whirlwind)
    #furious_slash
    Spell(furious_slash)
}

AddFunction FuryCooldownsMainPostConditions
{
}

AddFunction FuryCooldownsShortCdActions
{
    unless Talent(massacre_talent) and BuffPresent(massacre_buff) and EnrageRemaining() < 1 and Spell(rampage) or target.HealthPercent() < 20 and EnrageRemaining() < 1 and Spell(bloodthirst) or HasEquippedItem(draught_of_souls) and SpellCooldown(draught_of_souls) < 1 and BuffRemaining(juggernaut_buff) < 3 and Spell(execute) or IsEnraged() and SpellCooldown(raging_blow) > 0 and target.HealthPercent() > 20 and Spell(odyns_fury) or Spell(execute) or Talent(inner_rage_talent) and IsEnraged() and Spell(raging_blow) or { Talent(reckless_abandon_talent) and not Talent(frothing_berserker_talent) or Talent(frothing_berserker_talent) and Rage() >= 100 } and Spell(rampage)
    {
        #berserker_rage,if=talent.outburst.enabled&buff.enrage.down&buff.battle_cry.up
        if Talent(outburst_talent) and not IsEnraged() and BuffPresent(battle_cry_buff) Spell(berserker_rage)
    }
}

AddFunction FuryCooldownsShortCdPostConditions
{
    Talent(massacre_talent) and BuffPresent(massacre_buff) and EnrageRemaining() < 1 and Spell(rampage) or target.HealthPercent() < 20 and EnrageRemaining() < 1 and Spell(bloodthirst) or HasEquippedItem(draught_of_souls) and SpellCooldown(draught_of_souls) < 1 and BuffRemaining(juggernaut_buff) < 3 and Spell(execute) or IsEnraged() and SpellCooldown(raging_blow) > 0 and target.HealthPercent() > 20 and Spell(odyns_fury) or Spell(execute) or Talent(inner_rage_talent) and IsEnraged() and Spell(raging_blow) or { Talent(reckless_abandon_talent) and not Talent(frothing_berserker_talent) or Talent(frothing_berserker_talent) and Rage() >= 100 } and Spell(rampage) or EnrageRemaining() < 1 and not Talent(outburst_talent) and Spell(bloodthirst) or Spell(raging_blow) or Spell(bloodthirst) or BuffPresent(wrecking_ball_buff) and IsEnraged() and Spell(whirlwind) or Spell(furious_slash)
}

AddFunction FuryCooldownsCdActions
{
}

AddFunction FuryCooldownsCdPostConditions
{
    Talent(massacre_talent) and BuffPresent(massacre_buff) and EnrageRemaining() < 1 and Spell(rampage) or target.HealthPercent() < 20 and EnrageRemaining() < 1 and Spell(bloodthirst) or HasEquippedItem(draught_of_souls) and SpellCooldown(draught_of_souls) < 1 and BuffRemaining(juggernaut_buff) < 3 and Spell(execute) or IsEnraged() and SpellCooldown(raging_blow) > 0 and target.HealthPercent() > 20 and Spell(odyns_fury) or Spell(execute) or Talent(inner_rage_talent) and IsEnraged() and Spell(raging_blow) or { Talent(reckless_abandon_talent) and not Talent(frothing_berserker_talent) or Talent(frothing_berserker_talent) and Rage() >= 100 } and Spell(rampage) or EnrageRemaining() < 1 and not Talent(outburst_talent) and Spell(bloodthirst) or Spell(raging_blow) or Spell(bloodthirst) or BuffPresent(wrecking_ball_buff) and IsEnraged() and Spell(whirlwind) or Spell(furious_slash)
}

### actions.execute

AddFunction FuryExecuteMainActions
{
    #bloodthirst,if=buff.fujiedas_fury.up&buff.fujiedas_fury.remains<2
    if BuffPresent(fujiedas_fury_buff) and BuffRemaining(fujiedas_fury_buff) < 2 Spell(bloodthirst)
    #execute,if=artifact.juggernaut.enabled&(!buff.juggernaut.up|buff.juggernaut.remains<2)|buff.stone_heart.react
    if HasArtifactTrait(juggernaut) and { not BuffPresent(juggernaut_buff) or BuffRemaining(juggernaut_buff) < 2 } or BuffPresent(stone_heart_buff) Spell(execute)
    #furious_slash,if=talent.frenzy.enabled&buff.frenzy.remains<=2
    if Talent(frenzy_talent) and BuffRemaining(frenzy_buff) <= 2 Spell(furious_slash)
    #execute,if=cooldown.battle_cry.remains<5
    if SpellCooldown(battle_cry) < 5 Spell(execute)
    #rampage,if=buff.massacre.react&buff.enrage.remains<1
    if BuffPresent(massacre_buff) and EnrageRemaining() < 1 Spell(rampage)
    #execute
    Spell(execute)
    #bloodthirst
    Spell(bloodthirst)
    #furious_slash,if=set_bonus.tier19_2pc
    if ArmorSetBonus(T19 2) Spell(furious_slash)
    #raging_blow
    Spell(raging_blow)
    #odyns_fury,if=buff.enrage.up&rage<100
    if IsEnraged() and Rage() < 100 Spell(odyns_fury)
    #furious_slash
    Spell(furious_slash)
}

AddFunction FuryExecuteMainPostConditions
{
}

AddFunction FuryExecuteShortCdActions
{
}

AddFunction FuryExecuteShortCdPostConditions
{
    BuffPresent(fujiedas_fury_buff) and BuffRemaining(fujiedas_fury_buff) < 2 and Spell(bloodthirst) or { HasArtifactTrait(juggernaut) and { not BuffPresent(juggernaut_buff) or BuffRemaining(juggernaut_buff) < 2 } or BuffPresent(stone_heart_buff) } and Spell(execute) or Talent(frenzy_talent) and BuffRemaining(frenzy_buff) <= 2 and Spell(furious_slash) or SpellCooldown(battle_cry) < 5 and Spell(execute) or BuffPresent(massacre_buff) and EnrageRemaining() < 1 and Spell(rampage) or Spell(execute) or Spell(bloodthirst) or ArmorSetBonus(T19 2) and Spell(furious_slash) or Spell(raging_blow) or IsEnraged() and Rage() < 100 and Spell(odyns_fury) or Spell(furious_slash)
}

AddFunction FuryExecuteCdActions
{
}

AddFunction FuryExecuteCdPostConditions
{
    BuffPresent(fujiedas_fury_buff) and BuffRemaining(fujiedas_fury_buff) < 2 and Spell(bloodthirst) or { HasArtifactTrait(juggernaut) and { not BuffPresent(juggernaut_buff) or BuffRemaining(juggernaut_buff) < 2 } or BuffPresent(stone_heart_buff) } and Spell(execute) or Talent(frenzy_talent) and BuffRemaining(frenzy_buff) <= 2 and Spell(furious_slash) or SpellCooldown(battle_cry) < 5 and Spell(execute) or BuffPresent(massacre_buff) and EnrageRemaining() < 1 and Spell(rampage) or Spell(execute) or Spell(bloodthirst) or ArmorSetBonus(T19 2) and Spell(furious_slash) or Spell(raging_blow) or IsEnraged() and Rage() < 100 and Spell(odyns_fury) or Spell(furious_slash)
}

### actions.movement

AddFunction FuryMovementMainActions
{
}

AddFunction FuryMovementMainPostConditions
{
}

AddFunction FuryMovementShortCdActions
{
    #heroic_leap
    # if CheckBoxOn(opt_melee_range) and target.Distance(atLeast 8) and target.Distance(atMost 40) Spell(heroic_leap)
}

AddFunction FuryMovementShortCdPostConditions
{
}

AddFunction FuryMovementCdActions
{
}

AddFunction FuryMovementCdPostConditions
{
}

### actions.precombat

AddFunction FuryPrecombatMainActions
{
}

AddFunction FuryPrecombatMainPostConditions
{
}

AddFunction FuryPrecombatShortCdActions
{
}

AddFunction FuryPrecombatShortCdPostConditions
{
}

AddFunction FuryPrecombatCdActions
{
    #flask,type=countless_armies
    #food,type=lavish_suramar_feast
    #augmentation,type=defiled
    #snapshot_stats
    #potion,name=old_war
    # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(old_war_potion usable=1)
}

AddFunction FuryPrecombatCdPostConditions
{
}

### actions.single_target

AddFunction FurySingleTargetMainActions
{
    #bloodthirst,if=buff.fujiedas_fury.up&buff.fujiedas_fury.remains<2
    if BuffPresent(fujiedas_fury_buff) and BuffRemaining(fujiedas_fury_buff) < 2 Spell(bloodthirst)
    #furious_slash,if=talent.frenzy.enabled&(buff.frenzy.down|buff.frenzy.remains<=2)
    if Talent(frenzy_talent) and { BuffExpires(frenzy_buff) or BuffRemaining(frenzy_buff) <= 2 } Spell(furious_slash)
    #raging_blow,if=buff.enrage.up&talent.inner_rage.enabled
    if IsEnraged() and Talent(inner_rage_talent) Spell(raging_blow)
    #rampage,if=target.health.pct>21&((buff.enrage.down&!talent.frothing_berserker.enabled)|buff.massacre.react|rage>=100)
    if target.HealthPercent() > 21 and { not IsEnraged() and not Talent(frothing_berserker_talent) or BuffPresent(massacre_buff) or Rage() >= 100 } Spell(rampage)
    #execute,if=buff.stone_heart.react&((talent.inner_rage.enabled&cooldown.raging_blow.remains>1)|buff.enrage.up)
    if BuffPresent(stone_heart_buff) and { Talent(inner_rage_talent) and SpellCooldown(raging_blow) > 1 or IsEnraged() } Spell(execute)
    #bloodthirst
    Spell(bloodthirst)
    #furious_slash,if=set_bonus.tier19_2pc&!talent.inner_rage.enabled
    if ArmorSetBonus(T19 2) and not Talent(inner_rage_talent) Spell(furious_slash)
    #raging_blow
    Spell(raging_blow)
    #whirlwind,if=buff.wrecking_ball.react&buff.enrage.up
    if BuffPresent(wrecking_ball_buff) and IsEnraged() Spell(whirlwind)
    #furious_slash
    Spell(furious_slash)
}

AddFunction FurySingleTargetMainPostConditions
{
}

AddFunction FurySingleTargetShortCdActions
{
}

AddFunction FurySingleTargetShortCdPostConditions
{
    BuffPresent(fujiedas_fury_buff) and BuffRemaining(fujiedas_fury_buff) < 2 and Spell(bloodthirst) or Talent(frenzy_talent) and { BuffExpires(frenzy_buff) or BuffRemaining(frenzy_buff) <= 2 } and Spell(furious_slash) or IsEnraged() and Talent(inner_rage_talent) and Spell(raging_blow) or target.HealthPercent() > 21 and { not IsEnraged() and not Talent(frothing_berserker_talent) or BuffPresent(massacre_buff) or Rage() >= 100 } and Spell(rampage) or BuffPresent(stone_heart_buff) and { Talent(inner_rage_talent) and SpellCooldown(raging_blow) > 1 or IsEnraged() } and Spell(execute) or Spell(bloodthirst) or ArmorSetBonus(T19 2) and not Talent(inner_rage_talent) and Spell(furious_slash) or Spell(raging_blow) or BuffPresent(wrecking_ball_buff) and IsEnraged() and Spell(whirlwind) or Spell(furious_slash)
}

AddFunction FurySingleTargetCdActions
{
}

AddFunction FurySingleTargetCdPostConditions
{
    BuffPresent(fujiedas_fury_buff) and BuffRemaining(fujiedas_fury_buff) < 2 and Spell(bloodthirst) or Talent(frenzy_talent) and { BuffExpires(frenzy_buff) or BuffRemaining(frenzy_buff) <= 2 } and Spell(furious_slash) or IsEnraged() and Talent(inner_rage_talent) and Spell(raging_blow) or target.HealthPercent() > 21 and { not IsEnraged() and not Talent(frothing_berserker_talent) or BuffPresent(massacre_buff) or Rage() >= 100 } and Spell(rampage) or BuffPresent(stone_heart_buff) and { Talent(inner_rage_talent) and SpellCooldown(raging_blow) > 1 or IsEnraged() } and Spell(execute) or Spell(bloodthirst) or ArmorSetBonus(T19 2) and not Talent(inner_rage_talent) and Spell(furious_slash) or Spell(raging_blow) or BuffPresent(wrecking_ball_buff) and IsEnraged() and Spell(whirlwind) or Spell(furious_slash)
}

### actions.three_targets

AddFunction FuryThreeTargetsMainActions
{
    #execute,if=buff.stone_heart.react
    if BuffPresent(stone_heart_buff) Spell(execute)
    #rampage,if=buff.meat_cleaver.up&((buff.enrage.down&!talent.frothing_berserker.enabled)|(rage>=100&talent.frothing_berserker.enabled))|buff.massacre.react
    if BuffPresent(meat_cleaver_buff) and { not IsEnraged() and not Talent(frothing_berserker_talent) or Rage() >= 100 and Talent(frothing_berserker_talent) } or BuffPresent(massacre_buff) Spell(rampage)
    #raging_blow,if=talent.inner_rage.enabled
    if Talent(inner_rage_talent) Spell(raging_blow)
    #bloodthirst
    Spell(bloodthirst)
    #whirlwind
    Spell(whirlwind)
}

AddFunction FuryThreeTargetsMainPostConditions
{
}

AddFunction FuryThreeTargetsShortCdActions
{
}

AddFunction FuryThreeTargetsShortCdPostConditions
{
    BuffPresent(stone_heart_buff) and Spell(execute) or { BuffPresent(meat_cleaver_buff) and { not IsEnraged() and not Talent(frothing_berserker_talent) or Rage() >= 100 and Talent(frothing_berserker_talent) } or BuffPresent(massacre_buff) } and Spell(rampage) or Talent(inner_rage_talent) and Spell(raging_blow) or Spell(bloodthirst) or Spell(whirlwind)
}

AddFunction FuryThreeTargetsCdActions
{
}

AddFunction FuryThreeTargetsCdPostConditions
{
    BuffPresent(stone_heart_buff) and Spell(execute) or { BuffPresent(meat_cleaver_buff) and { not IsEnraged() and not Talent(frothing_berserker_talent) or Rage() >= 100 and Talent(frothing_berserker_talent) } or BuffPresent(massacre_buff) } and Spell(rampage) or Talent(inner_rage_talent) and Spell(raging_blow) or Spell(bloodthirst) or Spell(whirlwind)
}
]]

	OvaleScripts:RegisterScript("WARRIOR", "fury", name, desc, code, "script")
end
