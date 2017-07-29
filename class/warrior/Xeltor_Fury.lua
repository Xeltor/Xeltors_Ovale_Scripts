local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_fury"
	local desc = "[Xel][7.1] Warrior: Fury"
	local code = [[
# Based on SimulationCraft profile "Warrior_Fury_T19M".
#    class=warrior
#    spec=fury
#    talents=2232133

Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_warrior_spells)

# Fury
AddIcon specialization=2 help=main
{
	if InCombat() and target.Casting(interrupt) InterruptActions()
	
    if target.InRange(rampage) and HasFullControl()
	{
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

### actions.default

AddFunction FuryDefaultMainActions
{
    #run_action_list,name=movement,if=movement.distance>5
    # if 0 > 5 FuryMovementMainActions()

	#call_action_list,name=two_targets,if=spell_targets.whirlwind=2|spell_targets.whirlwind=3
	if Enemies(tagged=1) == 2 or Enemies(tagged=1) == 3 FuryTwoTargetsMainActions()

	unless { Enemies(tagged=1) == 2 or Enemies(tagged=1) == 3 } and FuryTwoTargetsMainPostConditions()
	{
		#call_action_list,name=aoe,if=spell_targets.whirlwind>3
		if Enemies(tagged=1) > 3 FuryAoeMainActions()

		unless Enemies(tagged=1) > 3 and FuryAoeMainPostConditions()
		{
			#call_action_list,name=single_target
			FurySingleTargetMainActions()
		}
	}
}

AddFunction FuryDefaultMainPostConditions
{
    0 > 5 and FuryMovementMainPostConditions() or { Enemies(tagged=1) == 2 or Enemies(tagged=1) == 3 } and FuryTwoTargetsMainPostConditions() or Enemies(tagged=1) > 3 and FuryAoeMainPostConditions() or FurySingleTargetMainPostConditions()
}

AddFunction FuryDefaultShortCdActions
{
    #auto_attack
    # FuryGetInMeleeRange()
    #charge
    # if CheckBoxOn(opt_melee_range) and target.InRange(charge) Spell(charge)
    #run_action_list,name=movement,if=movement.distance>5
    # if 0 > 5 FuryMovementShortCdActions()
	#heroic_leap,if=(raid_event.movement.distance>25&raid_event.movement.in>45)|!raid_event.movement.exists
	# if { 0 > 25 and 600 > 45 or not False(raid_event_movement_exists) } and CheckBoxOn(opt_melee_range) and target.InRange(charge) Spell(heroic_leap)
	#potion,name=deadly_grace,if=(target.health.pct<20&buff.battle_cry.up)|target.time_to_die<30
	#battle_cry,if=(artifact.odyns_fury.enabled&cooldown.odyns_fury.remains=0&(cooldown.bloodthirst.remains=0|(buff.enrage.remains>cooldown.bloodthirst.remains)))|!artifact.odyns_fury.enabled
	if BuffPresent(odyns_fury_buff) and not SpellCooldown(odyns_fury) > 0 and { not SpellCooldown(bloodthirst) > 0 or EnrageRemaining() > SpellCooldown(bloodthirst) } or not BuffPresent(odyns_fury_buff) Spell(battle_cry)
	#bloodbath,if=buff.dragon_roar.up|(!talent.dragon_roar.enabled&(buff.battle_cry.up|cooldown.battle_cry.remains>10))
	if BuffPresent(dragon_roar_buff) or not Talent(dragon_roar_talent) and { BuffPresent(battle_cry_buff) or SpellCooldown(battle_cry) > 10 } Spell(bloodbath)
	#call_action_list,name=two_targets,if=spell_targets.whirlwind=2|spell_targets.whirlwind=3
	if Enemies(tagged=1) == 2 or Enemies(tagged=1) == 3 FuryTwoTargetsShortCdActions()

	unless { Enemies(tagged=1) == 2 or Enemies(tagged=1) == 3 } and FuryTwoTargetsShortCdPostConditions()
	{
		#call_action_list,name=aoe,if=spell_targets.whirlwind>3
		if Enemies(tagged=1) > 3 FuryAoeShortCdActions()

		unless Enemies(tagged=1) > 3 and FuryAoeShortCdPostConditions()
		{
			#call_action_list,name=single_target
			FurySingleTargetShortCdActions()
		}
	}
}

AddFunction FuryDefaultShortCdPostConditions
{
    { Enemies(tagged=1) == 2 or Enemies(tagged=1) == 3 } and FuryTwoTargetsShortCdPostConditions() or Enemies(tagged=1) > 3 and FuryAoeShortCdPostConditions() or FurySingleTargetShortCdPostConditions()
}

AddFunction FuryDefaultCdActions
{
    #run_action_list,name=movement,if=movement.distance>5
    # if 0 > 5 FuryMovementCdActions()

    unless { BuffPresent(odyns_fury_buff) and not SpellCooldown(odyns_fury) > 0 and { not SpellCooldown(bloodthirst) > 0 or EnrageRemaining() > SpellCooldown(bloodthirst) } or not BuffPresent(odyns_fury_buff) } and Spell(battle_cry)
    {
        #avatar,if=buff.battle_cry.up|(target.time_to_die<(cooldown.battle_cry.remains+10))
        if BuffPresent(battle_cry_buff) or target.TimeToDie() < SpellCooldown(battle_cry) + 10 Spell(avatar)
        #blood_fury,if=buff.battle_cry.up
        if BuffPresent(battle_cry_buff) Spell(blood_fury_ap)
        #berserking,if=buff.battle_cry.up
        if BuffPresent(battle_cry_buff) Spell(berserking)
        #arcane_torrent,if=rage<rage.max-40
        if Rage() < MaxRage() - 40 Spell(arcane_torrent_rage)
        #call_action_list,name=two_targets,if=spell_targets.whirlwind=2|spell_targets.whirlwind=3
        if Enemies(tagged=1) == 2 or Enemies(tagged=1) == 3 FuryTwoTargetsCdActions()

        unless { Enemies(tagged=1) == 2 or Enemies(tagged=1) == 3 } and FuryTwoTargetsCdPostConditions()
        {
            #call_action_list,name=aoe,if=spell_targets.whirlwind>3
            if Enemies(tagged=1) > 3 FuryAoeCdActions()

            unless Enemies(tagged=1) > 3 and FuryAoeCdPostConditions()
            {
                #call_action_list,name=single_target
                FurySingleTargetCdActions()
            }
        }
    }
}

AddFunction FuryDefaultCdPostConditions
{
    { BuffPresent(odyns_fury_buff) and not SpellCooldown(odyns_fury) > 0 and { not SpellCooldown(bloodthirst) > 0 or EnrageRemaining() > SpellCooldown(bloodthirst) } or not BuffPresent(odyns_fury_buff) } and Spell(battle_cry) or { Enemies(tagged=1) == 2 or Enemies(tagged=1) == 3 } and FuryTwoTargetsCdPostConditions() or Enemies(tagged=1) > 3 and FuryAoeCdPostConditions() or FurySingleTargetCdPostConditions()
}

### actions.aoe

AddFunction FuryAoeMainActions
{
    #bloodthirst,if=buff.enrage.down|rage<50
    # if not IsEnraged() or Rage() < 50 Spell(bloodthirst)
    #call_action_list,name=bladestorm
    FuryBladestormMainActions()

    unless FuryBladestormMainPostConditions()
    {
        #whirlwind,if=buff.enrage.up
        if IsEnraged() Spell(whirlwind)
        #dragon_roar
        Spell(dragon_roar)
        #rampage,if=buff.meat_cleaver.up
        if BuffPresent(meat_cleaver_buff) Spell(rampage)
        #bloodthirst
        Spell(bloodthirst)
        #whirlwind
        Spell(whirlwind)
    }
}

AddFunction FuryAoeMainPostConditions
{
    FuryBladestormMainPostConditions()
}

AddFunction FuryAoeShortCdActions
{
    unless { not IsEnraged() or Rage() < 50 } and Spell(bloodthirst)
    {
        #call_action_list,name=bladestorm
        FuryBladestormShortCdActions()
    }
}

AddFunction FuryAoeShortCdPostConditions
{
    { not IsEnraged() or Rage() < 50 } and Spell(bloodthirst) or FuryBladestormShortCdPostConditions() or IsEnraged() and Spell(whirlwind) or Spell(dragon_roar) or BuffPresent(meat_cleaver_buff) and Spell(rampage) or Spell(bloodthirst) or Spell(whirlwind)
}

AddFunction FuryAoeCdActions
{
    unless { not IsEnraged() or Rage() < 50 } and Spell(bloodthirst)
    {
        #call_action_list,name=bladestorm
        FuryBladestormCdActions()
    }
}

AddFunction FuryAoeCdPostConditions
{
    { not IsEnraged() or Rage() < 50 } and Spell(bloodthirst) or FuryBladestormCdPostConditions() or IsEnraged() and Spell(whirlwind) or Spell(dragon_roar) or BuffPresent(meat_cleaver_buff) and Spell(rampage) or Spell(bloodthirst) or Spell(whirlwind)
}

### actions.bladestorm

AddFunction FuryBladestormMainActions
{
}

AddFunction FuryBladestormMainPostConditions
{
}

AddFunction FuryBladestormShortCdActions
{
    #bladestorm,if=buff.enrage.remains>2&(raid_event.adds.in>90|!raid_event.adds.exists|spell_targets.bladestorm_mh>desired_targets)
    if EnrageRemaining() > 2 and { 600 > 90 or not False(raid_event_adds_exists) or Enemies(tagged=1) > Enemies(tagged=1) } Spell(bladestorm)
}

AddFunction FuryBladestormShortCdPostConditions
{
}

AddFunction FuryBladestormCdActions
{
}

AddFunction FuryBladestormCdPostConditions
{
    EnrageRemaining() > 2 and { 600 > 90 or not False(raid_event_adds_exists) or Enemies(tagged=1) > Enemies(tagged=1) } and Spell(bladestorm)
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
    # if CheckBoxOn(opt_melee_range) and target.InRange(charge) Spell(heroic_leap)
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
}

AddFunction FuryPrecombatCdPostConditions
{
}

### actions.single_target

AddFunction FurySingleTargetMainActions
{
    #execute,if=artifact.juggernaut.enabled&(!buff.juggernaut.up|buff.juggernaut.remains<2)
    if BuffPresent(juggernaut_buff) and { not BuffPresent(juggernaut_buff) or BuffRemaining(juggernaut_buff) < 2 } Spell(execute)
    #rampage,if=rage>95|buff.massacre.react
    if Rage() > 95 or BuffPresent(massacre_buff) Spell(rampage)
    #whirlwind,if=!talent.inner_rage.enabled&buff.wrecking_ball.react
    if not Talent(inner_rage_talent) and BuffPresent(wrecking_ball_buff) Spell(whirlwind)
    #raging_blow,if=buff.enrage.up
    if IsEnraged() Spell(raging_blow)
    #whirlwind,if=buff.wrecking_ball.react&buff.enrage.up
    if BuffPresent(wrecking_ball_buff) and IsEnraged() Spell(whirlwind)
    #execute,if=buff.enrage.up|buff.battle_cry.up|buff.stone_heart.react|(buff.juggernaut.up&buff.juggernaut.remains<3)
    if IsEnraged() or BuffPresent(battle_cry_buff) or BuffPresent(stone_heart_buff) or BuffPresent(juggernaut_buff) and BuffRemaining(juggernaut_buff) < 3 Spell(execute)
    #bloodthirst
    Spell(bloodthirst)
    #raging_blow
    Spell(raging_blow)
    #dragon_roar,if=!talent.bloodbath.enabled&(cooldown.battle_cry.remains<1|cooldown.battle_cry.remains>10)|talent.bloodbath.enabled&cooldown.bloodbath.remains=0
    if not Talent(bloodbath_talent) and { SpellCooldown(battle_cry) < 1 or SpellCooldown(battle_cry) > 10 } or Talent(bloodbath_talent) and not SpellCooldown(bloodbath) > 0 Spell(dragon_roar)
    #rampage,if=(target.health.pct>20&(cooldown.battle_cry.remains>3|buff.battle_cry.up|rage>90))
    if target.HealthPercent() > 20 and { SpellCooldown(battle_cry) > 3 or BuffPresent(battle_cry_buff) or Rage() > 90 } Spell(rampage)
    #execute,if=rage>50|buff.battle_cry.up|buff.stone_heart.react|target.time_to_die<20
    if Rage() > 50 or BuffPresent(battle_cry_buff) or BuffPresent(stone_heart_buff) or target.TimeToDie() < 20 Spell(execute)
    #furious_slash
    Spell(furious_slash)
}

AddFunction FurySingleTargetMainPostConditions
{
}

AddFunction FurySingleTargetShortCdActions
{
    #odyns_fury,if=buff.battle_cry.up|target.time_to_die<cooldown.battle_cry.remains
    if BuffPresent(battle_cry_buff) or target.TimeToDie() < SpellCooldown(battle_cry) Spell(odyns_fury)

    unless BuffPresent(juggernaut_buff) and { not BuffPresent(juggernaut_buff) or BuffRemaining(juggernaut_buff) < 2 } and Spell(execute)
    {
        #berserker_rage,if=talent.outburst.enabled&cooldown.dragon_roar.remains=0&buff.enrage.down
        if Talent(outburst_talent) and not SpellCooldown(dragon_roar) > 0 and not IsEnraged() Spell(berserker_rage)
    }
}

AddFunction FurySingleTargetShortCdPostConditions
{
    BuffPresent(juggernaut_buff) and { not BuffPresent(juggernaut_buff) or BuffRemaining(juggernaut_buff) < 2 } and Spell(execute) or { Rage() > 95 or BuffPresent(massacre_buff) } and Spell(rampage) or not Talent(inner_rage_talent) and BuffPresent(wrecking_ball_buff) and Spell(whirlwind) or IsEnraged() and Spell(raging_blow) or BuffPresent(wrecking_ball_buff) and IsEnraged() and Spell(whirlwind) or { IsEnraged() or BuffPresent(battle_cry_buff) or BuffPresent(stone_heart_buff) or BuffPresent(juggernaut_buff) and BuffRemaining(juggernaut_buff) < 3 } and Spell(execute) or Spell(bloodthirst) or Spell(raging_blow) or { not Talent(bloodbath_talent) and { SpellCooldown(battle_cry) < 1 or SpellCooldown(battle_cry) > 10 } or Talent(bloodbath_talent) and not SpellCooldown(bloodbath) > 0 } and Spell(dragon_roar) or target.HealthPercent() > 20 and { SpellCooldown(battle_cry) > 3 or BuffPresent(battle_cry_buff) or Rage() > 90 } and Spell(rampage) or { Rage() > 50 or BuffPresent(battle_cry_buff) or BuffPresent(stone_heart_buff) or target.TimeToDie() < 20 } and Spell(execute) or Spell(furious_slash)
}

AddFunction FurySingleTargetCdActions
{
}

AddFunction FurySingleTargetCdPostConditions
{
    { BuffPresent(battle_cry_buff) or target.TimeToDie() < SpellCooldown(battle_cry) } and Spell(odyns_fury) or BuffPresent(juggernaut_buff) and { not BuffPresent(juggernaut_buff) or BuffRemaining(juggernaut_buff) < 2 } and Spell(execute) or { Rage() > 95 or BuffPresent(massacre_buff) } and Spell(rampage) or not Talent(inner_rage_talent) and BuffPresent(wrecking_ball_buff) and Spell(whirlwind) or IsEnraged() and Spell(raging_blow) or BuffPresent(wrecking_ball_buff) and IsEnraged() and Spell(whirlwind) or { IsEnraged() or BuffPresent(battle_cry_buff) or BuffPresent(stone_heart_buff) or BuffPresent(juggernaut_buff) and BuffRemaining(juggernaut_buff) < 3 } and Spell(execute) or Spell(bloodthirst) or Spell(raging_blow) or { not Talent(bloodbath_talent) and { SpellCooldown(battle_cry) < 1 or SpellCooldown(battle_cry) > 10 } or Talent(bloodbath_talent) and not SpellCooldown(bloodbath) > 0 } and Spell(dragon_roar) or target.HealthPercent() > 20 and { SpellCooldown(battle_cry) > 3 or BuffPresent(battle_cry_buff) or Rage() > 90 } and Spell(rampage) or { Rage() > 50 or BuffPresent(battle_cry_buff) or BuffPresent(stone_heart_buff) or target.TimeToDie() < 20 } and Spell(execute) or Spell(furious_slash)
}

### actions.two_targets

AddFunction FuryTwoTargetsMainActions
{
    #whirlwind,if=buff.meat_cleaver.down
    if BuffExpires(meat_cleaver_buff) Spell(whirlwind)
    #call_action_list,name=bladestorm
    FuryBladestormMainActions()

    unless FuryBladestormMainPostConditions()
    {
        #rampage,if=buff.enrage.down|(rage=100&buff.juggernaut.down)|buff.massacre.up
        if not IsEnraged() or Rage() == 100 and BuffExpires(juggernaut_buff) or BuffPresent(massacre_buff) Spell(rampage)
        #bloodthirst,if=buff.enrage.down
        if not IsEnraged() Spell(bloodthirst)
        #raging_blow,if=talent.inner_rage.enabled&spell_targets.whirlwind=2
        if Talent(inner_rage_talent) and Enemies(tagged=1) == 2 Spell(raging_blow)
        #whirlwind,if=spell_targets.whirlwind>2
        if Enemies(tagged=1) > 2 Spell(whirlwind)
        #dragon_roar
        Spell(dragon_roar)
        #bloodthirst
        Spell(bloodthirst)
        #whirlwind
        Spell(whirlwind)
    }
}

AddFunction FuryTwoTargetsMainPostConditions
{
    FuryBladestormMainPostConditions()
}

AddFunction FuryTwoTargetsShortCdActions
{
    unless BuffExpires(meat_cleaver_buff) and Spell(whirlwind)
    {
        #call_action_list,name=bladestorm
        FuryBladestormShortCdActions()
    }
}

AddFunction FuryTwoTargetsShortCdPostConditions
{
    BuffExpires(meat_cleaver_buff) and Spell(whirlwind) or FuryBladestormShortCdPostConditions() or { not IsEnraged() or Rage() == 100 and BuffExpires(juggernaut_buff) or BuffPresent(massacre_buff) } and Spell(rampage) or not IsEnraged() and Spell(bloodthirst) or Talent(inner_rage_talent) and Enemies(tagged=1) == 2 and Spell(raging_blow) or Enemies(tagged=1) > 2 and Spell(whirlwind) or Spell(dragon_roar) or Spell(bloodthirst) or Spell(whirlwind)
}

AddFunction FuryTwoTargetsCdActions
{
    unless BuffExpires(meat_cleaver_buff) and Spell(whirlwind)
    {
        #call_action_list,name=bladestorm
        FuryBladestormCdActions()
    }
}

AddFunction FuryTwoTargetsCdPostConditions
{
    BuffExpires(meat_cleaver_buff) and Spell(whirlwind) or FuryBladestormCdPostConditions() or { not IsEnraged() or Rage() == 100 and BuffExpires(juggernaut_buff) or BuffPresent(massacre_buff) } and Spell(rampage) or not IsEnraged() and Spell(bloodthirst) or Talent(inner_rage_talent) and Enemies(tagged=1) == 2 and Spell(raging_blow) or Enemies(tagged=1) > 2 and Spell(whirlwind) or Spell(dragon_roar) or Spell(bloodthirst) or Spell(whirlwind)
}
]]

	OvaleScripts:RegisterScript("WARRIOR", "fury", name, desc, code, "script")
end
