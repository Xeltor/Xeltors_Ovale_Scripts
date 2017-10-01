local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_retribution"
	local desc = "[Xel][7.3] Paladin: Retribution"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_paladin_spells)

# Retribution
AddIcon specialization=3 help=main
{
	# Interrupt
	if InCombat() InterruptActions()
	
	if target.InRange(crusader_strike) and HasFullControl()
    {
		# Cooldowns
		RetributionDefaultCdActions()
		RetributionDefaultShortCdActions()
		RetributionDefaultMainActions()
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
		if target.InRange(rebuke) Spell(rebuke)
		if not target.Classification(worldboss)
		{
			if target.InRange(hammer_of_justice) Spell(hammer_of_justice)
			if target.InRange(hammer_of_justice) Spell(blinding_light)
			if target.Distance(less 8) Spell(arcane_torrent_holy)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}

AddFunction ds_castable
{
    Enemies(tagged=1) >= 2 or BuffStacks(scarlet_inquisitors_expurgation_buff) >= 29 and { BuffPresent(avenging_wrath_melee_buff) or BuffPresent(crusade_buff) and BuffStacks(crusade_buff) >= 15 or SpellCooldown(crusade) > 15 and not BuffPresent(crusade_buff) or SpellCooldown(avenging_wrath_melee) > 15 }
}

### actions.default

AddFunction RetributionDefaultMainActions
{
    #call_action_list,name=opener,if=time<2
    if TimeInCombat() < 2 RetributionOpenerMainActions()

    unless TimeInCombat() < 2 and RetributionOpenerMainPostConditions()
    {
        #call_action_list,name=cooldowns
        RetributionCooldownsMainActions()

        unless RetributionCooldownsMainPostConditions()
        {
            #call_action_list,name=priority
            RetributionPriorityMainActions()
        }
    }
}

AddFunction RetributionDefaultMainPostConditions
{
    TimeInCombat() < 2 and RetributionOpenerMainPostConditions() or RetributionCooldownsMainPostConditions() or RetributionPriorityMainPostConditions()
}

AddFunction RetributionDefaultShortCdActions
{
    #auto_attack
    # RetributionGetInMeleeRange()
    #call_action_list,name=opener,if=time<2
    if TimeInCombat() < 2 RetributionOpenerShortCdActions()

    unless TimeInCombat() < 2 and RetributionOpenerShortCdPostConditions()
    {
        #call_action_list,name=cooldowns
        RetributionCooldownsShortCdActions()

        unless RetributionCooldownsShortCdPostConditions()
        {
            #call_action_list,name=priority
            RetributionPriorityShortCdActions()
        }
    }
}

AddFunction RetributionDefaultShortCdPostConditions
{
    TimeInCombat() < 2 and RetributionOpenerShortCdPostConditions() or RetributionCooldownsShortCdPostConditions() or RetributionPriorityShortCdPostConditions()
}

AddFunction RetributionDefaultCdActions
{
    #rebuke
    # RetributionInterruptActions()
    #call_action_list,name=opener,if=time<2
    if TimeInCombat() < 2 RetributionOpenerCdActions()

    unless TimeInCombat() < 2 and RetributionOpenerCdPostConditions()
    {
        #call_action_list,name=cooldowns
        RetributionCooldownsCdActions()

        unless RetributionCooldownsCdPostConditions()
        {
            #call_action_list,name=priority
            RetributionPriorityCdActions()
        }
    }
}

AddFunction RetributionDefaultCdPostConditions
{
    TimeInCombat() < 2 and RetributionOpenerCdPostConditions() or RetributionCooldownsCdPostConditions() or RetributionPriorityCdPostConditions()
}

### actions.cooldowns

AddFunction RetributionCooldownsMainActions
{
}

AddFunction RetributionCooldownsMainPostConditions
{
}

AddFunction RetributionCooldownsShortCdActions
{
    #shield_of_vengeance
    Spell(shield_of_vengeance)
}

AddFunction RetributionCooldownsShortCdPostConditions
{
}

AddFunction RetributionCooldownsCdActions
{
    #use_item,name=specter_of_betrayal,if=(buff.crusade.up&buff.crusade.stack>=15|cooldown.crusade.remains>gcd*2)|(buff.avenging_wrath.up|cooldown.avenging_wrath.remains>gcd*2)
    # if BuffPresent(crusade_buff) and BuffStacks(crusade_buff) >= 15 or SpellCooldown(crusade) > GCD() * 2 or BuffPresent(avenging_wrath_melee_buff) or SpellCooldown(avenging_wrath_melee) > GCD() * 2 RetributionUseItemActions()
    #potion,name=old_war,if=(buff.bloodlust.react|buff.avenging_wrath.up|buff.crusade.up&buff.crusade.remains<25|target.time_to_die<=40)
    # if { BuffPresent(burst_haste_buff any=1) or BuffPresent(avenging_wrath_melee_buff) or BuffPresent(crusade_buff) and BuffRemaining(crusade_buff) < 25 or target.TimeToDie() <= 40 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(old_war_potion usable=1)
    #blood_fury
    Spell(blood_fury_apsp)
    #berserking
    Spell(berserking)
    #arcane_torrent,if=holy_power<=4
    if HolyPower() <= 4 Spell(arcane_torrent_holy)
    #holy_wrath
    Spell(holy_wrath)
    #avenging_wrath
    Spell(avenging_wrath_melee)
    #crusade,if=holy_power>=3|((equipped.137048|race.blood_elf)&holy_power>=2)
    if HolyPower() >= 3 or { HasEquippedItem(137048) or Race(BloodElf) } and HolyPower() >= 2 Spell(crusade)
}

AddFunction RetributionCooldownsCdPostConditions
{
}

### actions.opener

AddFunction RetributionOpenerMainActions
{
    #judgment
    Spell(judgment)
    #blade_of_justice,if=equipped.137048|race.blood_elf|!cooldown.wake_of_ashes.up
    if HasEquippedItem(137048) or Race(BloodElf) or not { not SpellCooldown(wake_of_ashes) > 0 } Spell(blade_of_justice)
    #divine_hammer,if=equipped.137048|race.blood_elf|!cooldown.wake_of_ashes.up
    if HasEquippedItem(137048) or Race(BloodElf) or not { not SpellCooldown(wake_of_ashes) > 0 } Spell(divine_hammer)
    #wake_of_ashes
    Spell(wake_of_ashes)
}

AddFunction RetributionOpenerMainPostConditions
{
}

AddFunction RetributionOpenerShortCdActions
{
}

AddFunction RetributionOpenerShortCdPostConditions
{
    Spell(judgment) or { HasEquippedItem(137048) or Race(BloodElf) or not { not SpellCooldown(wake_of_ashes) > 0 } } and Spell(blade_of_justice) or { HasEquippedItem(137048) or Race(BloodElf) or not { not SpellCooldown(wake_of_ashes) > 0 } } and Spell(divine_hammer) or Spell(wake_of_ashes)
}

AddFunction RetributionOpenerCdActions
{
    #blood_fury
    Spell(blood_fury_apsp)
    #berserking
    Spell(berserking)
    #arcane_torrent
    Spell(arcane_torrent_holy)
}

AddFunction RetributionOpenerCdPostConditions
{
    Spell(judgment) or { HasEquippedItem(137048) or Race(BloodElf) or not { not SpellCooldown(wake_of_ashes) > 0 } } and Spell(blade_of_justice) or { HasEquippedItem(137048) or Race(BloodElf) or not { not SpellCooldown(wake_of_ashes) > 0 } } and Spell(divine_hammer) or Spell(wake_of_ashes)
}

### actions.precombat

AddFunction RetributionPrecombatMainActions
{
}

AddFunction RetributionPrecombatMainPostConditions
{
}

AddFunction RetributionPrecombatShortCdActions
{
}

AddFunction RetributionPrecombatShortCdPostConditions
{
}

AddFunction RetributionPrecombatCdActions
{
    #flask,type=flask_of_the_countless_armies
    #food,type=azshari_salad
    #augmentation,type=defiled
    #snapshot_stats
    #potion,name=old_war
    # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(old_war_potion usable=1)
}

AddFunction RetributionPrecombatCdPostConditions
{
}

### actions.priority

AddFunction RetributionPriorityMainActions
{
    #execution_sentence,if=spell_targets.divine_storm<=3&(cooldown.judgment.remains<gcd*4.5|debuff.judgment.remains>gcd*4.5)
    if Enemies(tagged=1) <= 3 and { SpellCooldown(judgment) < GCD() * 4.5 or target.DebuffRemaining(judgment_ret_debuff) > GCD() * 4.5 } Spell(execution_sentence)
    #variable,name=ds_castable,value=spell_targets.divine_storm>=2|(buff.scarlet_inquisitors_expurgation.stack>=29&(buff.avenging_wrath.up|(buff.crusade.up&buff.crusade.stack>=15)|(cooldown.crusade.remains>15&!buff.crusade.up)|cooldown.avenging_wrath.remains>15))
    #divine_storm,if=debuff.judgment.up&variable.ds_castable&buff.divine_purpose.up&buff.divine_purpose.remains<gcd*2
    if target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 Spell(divine_storm)
    #divine_storm,if=debuff.judgment.up&variable.ds_castable&holy_power>=5&buff.divine_purpose.react
    if target.DebuffPresent(judgment_ret_debuff) and ds_castable() and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) Spell(divine_storm)
    #divine_storm,if=debuff.judgment.up&spell_targets.divine_storm>=2&holy_power>=3&(buff.crusade.up&buff.crusade.stack<15|buff.liadrins_fury_unleashed.up)
    if target.DebuffPresent(judgment_ret_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 3 and { BuffPresent(crusade_buff) and BuffStacks(crusade_buff) < 15 or BuffPresent(liadrins_fury_unleashed_buff) } Spell(divine_storm)
    #divine_storm,if=debuff.judgment.up&variable.ds_castable&holy_power>=5
    if target.DebuffPresent(judgment_ret_debuff) and ds_castable() and HolyPower() >= 5 Spell(divine_storm)
    #justicars_vengeance,if=debuff.judgment.up&buff.divine_purpose.up&buff.divine_purpose.remains<gcd*2&!equipped.137020
    if target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and not HasEquippedItem(137020) Spell(justicars_vengeance)
    #justicars_vengeance,if=debuff.judgment.up&holy_power>=5&buff.divine_purpose.react&!equipped.137020
    if target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and not HasEquippedItem(137020) Spell(justicars_vengeance)
    #templars_verdict,if=debuff.judgment.up&buff.divine_purpose.up&buff.divine_purpose.remains<gcd*2
    if target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 Spell(templars_verdict)
    #templars_verdict,if=debuff.judgment.up&holy_power>=5&buff.divine_purpose.react
    if target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) Spell(templars_verdict)
    #templars_verdict,if=debuff.judgment.up&holy_power>=3&(buff.crusade.up&buff.crusade.stack<15|buff.liadrins_fury_unleashed.up)
    if target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 3 and { BuffPresent(crusade_buff) and BuffStacks(crusade_buff) < 15 or BuffPresent(liadrins_fury_unleashed_buff) } Spell(templars_verdict)
    #templars_verdict,if=debuff.judgment.up&holy_power>=5
    if target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 5 Spell(templars_verdict)
    #divine_storm,if=debuff.judgment.up&variable.ds_castable&artifact.wake_of_ashes.enabled&cooldown.wake_of_ashes.remains<gcd*2
    if target.DebuffPresent(judgment_ret_debuff) and ds_castable() and HasArtifactTrait(wake_of_ashes) and SpellCooldown(wake_of_ashes) < GCD() * 2 Spell(divine_storm)
    #divine_storm,if=debuff.judgment.up&variable.ds_castable&buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd*1.5
    if target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() * 1.5 Spell(divine_storm)
    #templars_verdict,if=(equipped.137020|debuff.judgment.up)&artifact.wake_of_ashes.enabled&cooldown.wake_of_ashes.remains<gcd*2
    if { HasEquippedItem(137020) or target.DebuffPresent(judgment_ret_debuff) } and HasArtifactTrait(wake_of_ashes) and SpellCooldown(wake_of_ashes) < GCD() * 2 Spell(templars_verdict)
    #templars_verdict,if=debuff.judgment.up&buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd*1.5
    if target.DebuffPresent(judgment_ret_debuff) and BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() * 1.5 Spell(templars_verdict)
    #judgment,if=dot.execution_sentence.ticking&dot.execution_sentence.remains<gcd*2&debuff.judgment.remains<gcd*2
    if target.DebuffPresent(execution_sentence_debuff) and target.DebuffRemaining(execution_sentence_debuff) < GCD() * 2 and target.DebuffRemaining(judgment_ret_debuff) < GCD() * 2 Spell(judgment)
    #consecration,if=(cooldown.blade_of_justice.remains>gcd*2|cooldown.divine_hammer.remains>gcd*2)
    if SpellCooldown(blade_of_justice) > GCD() * 2 or SpellCooldown(divine_hammer) > GCD() * 2 Spell(consecration)
    #wake_of_ashes,if=(!raid_event.adds.exists|raid_event.adds.in>15)&(holy_power<=0|holy_power=1&(cooldown.blade_of_justice.remains>gcd|cooldown.divine_hammer.remains>gcd)|holy_power=2&((cooldown.zeal.charges_fractional<=0.65|cooldown.crusader_strike.charges_fractional<=0.65)))
    if { not False(raid_event_adds_exists) or 600 > 15 } and { HolyPower() <= 0 or HolyPower() == 1 and { SpellCooldown(blade_of_justice) > GCD() or SpellCooldown(divine_hammer) > GCD() } or HolyPower() == 2 and { SpellCharges(zeal count=0) <= 0.65 or SpellCharges(crusader_strike count=0) <= 0.65 } } Spell(wake_of_ashes)
    #blade_of_justice,if=holy_power<=3-set_bonus.tier20_4pc
    if HolyPower() <= 3 - ArmorSetBonus(T20 4) Spell(blade_of_justice)
    #divine_hammer,if=holy_power<=3-set_bonus.tier20_4pc
    if HolyPower() <= 3 - ArmorSetBonus(T20 4) Spell(divine_hammer)
    #judgment
    Spell(judgment)
    #zeal,if=cooldown.zeal.charges_fractional>=1.65&holy_power<=4&(cooldown.blade_of_justice.remains>gcd*2|cooldown.divine_hammer.remains>gcd*2)&debuff.judgment.remains>gcd
    if SpellCharges(zeal count=0) >= 1.65 and HolyPower() <= 4 and { SpellCooldown(blade_of_justice) > GCD() * 2 or SpellCooldown(divine_hammer) > GCD() * 2 } and target.DebuffRemaining(judgment_ret_debuff) > GCD() Spell(zeal)
    #crusader_strike,if=cooldown.crusader_strike.charges_fractional>=1.65-talent.the_fires_of_justice.enabled*0.25&holy_power<=4&(cooldown.blade_of_justice.remains>gcd*2|cooldown.divine_hammer.remains>gcd*2)&debuff.judgment.remains>gcd
    if SpellCharges(crusader_strike count=0) >= 1.65 - TalentPoints(the_fires_of_justice_talent) * 0.25 and HolyPower() <= 4 and { SpellCooldown(blade_of_justice) > GCD() * 2 or SpellCooldown(divine_hammer) > GCD() * 2 } and target.DebuffRemaining(judgment_ret_debuff) > GCD() Spell(crusader_strike)
    #consecration
    Spell(consecration)
    #divine_storm,if=debuff.judgment.up&variable.ds_castable&buff.divine_purpose.react
    if target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(divine_purpose_buff) Spell(divine_storm)
    #divine_storm,if=debuff.judgment.up&variable.ds_castable&buff.the_fires_of_justice.react
    if target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(the_fires_of_justice_buff) Spell(divine_storm)
    #divine_storm,if=debuff.judgment.up&variable.ds_castable
    if target.DebuffPresent(judgment_ret_debuff) and ds_castable() Spell(divine_storm)
    #justicars_vengeance,if=debuff.judgment.up&buff.divine_purpose.react&!equipped.137020
    if target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and not HasEquippedItem(137020) Spell(justicars_vengeance)
    #templars_verdict,if=debuff.judgment.up&buff.divine_purpose.react
    if target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) Spell(templars_verdict)
    #templars_verdict,if=debuff.judgment.up&buff.the_fires_of_justice.react
    if target.DebuffPresent(judgment_ret_debuff) and BuffPresent(the_fires_of_justice_buff) Spell(templars_verdict)
    #templars_verdict,if=debuff.judgment.up&(!talent.execution_sentence.enabled|cooldown.execution_sentence.remains>gcd*2)
    if target.DebuffPresent(judgment_ret_debuff) and { not Talent(execution_sentence_talent) or SpellCooldown(execution_sentence) > GCD() * 2 } Spell(templars_verdict)
    #zeal,if=holy_power<=4
    if HolyPower() <= 4 Spell(zeal)
    #crusader_strike,if=holy_power<=4
    if HolyPower() <= 4 Spell(crusader_strike)
}

AddFunction RetributionPriorityMainPostConditions
{
}

AddFunction RetributionPriorityShortCdActions
{
    unless Enemies(tagged=1) <= 3 and { SpellCooldown(judgment) < GCD() * 4.5 or target.DebuffRemaining(judgment_ret_debuff) > GCD() * 4.5 } and Spell(execution_sentence) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 3 and { BuffPresent(crusade_buff) and BuffStacks(crusade_buff) < 15 or BuffPresent(liadrins_fury_unleashed_buff) } and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and HolyPower() >= 5 and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and not HasEquippedItem(137020) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and not HasEquippedItem(137020) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 3 and { BuffPresent(crusade_buff) and BuffStacks(crusade_buff) < 15 or BuffPresent(liadrins_fury_unleashed_buff) } and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 5 and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and HasArtifactTrait(wake_of_ashes) and SpellCooldown(wake_of_ashes) < GCD() * 2 and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() * 1.5 and Spell(divine_storm) or { HasEquippedItem(137020) or target.DebuffPresent(judgment_ret_debuff) } and HasArtifactTrait(wake_of_ashes) and SpellCooldown(wake_of_ashes) < GCD() * 2 and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() * 1.5 and Spell(templars_verdict) or target.DebuffPresent(execution_sentence_debuff) and target.DebuffRemaining(execution_sentence_debuff) < GCD() * 2 and target.DebuffRemaining(judgment_ret_debuff) < GCD() * 2 and Spell(judgment) or { SpellCooldown(blade_of_justice) > GCD() * 2 or SpellCooldown(divine_hammer) > GCD() * 2 } and Spell(consecration) or { not False(raid_event_adds_exists) or 600 > 15 } and { HolyPower() <= 0 or HolyPower() == 1 and { SpellCooldown(blade_of_justice) > GCD() or SpellCooldown(divine_hammer) > GCD() } or HolyPower() == 2 and { SpellCharges(zeal count=0) <= 0.65 or SpellCharges(crusader_strike count=0) <= 0.65 } } and Spell(wake_of_ashes) or HolyPower() <= 3 - ArmorSetBonus(T20 4) and Spell(blade_of_justice) or HolyPower() <= 3 - ArmorSetBonus(T20 4) and Spell(divine_hammer) or Spell(judgment) or SpellCharges(zeal count=0) >= 1.65 and HolyPower() <= 4 and { SpellCooldown(blade_of_justice) > GCD() * 2 or SpellCooldown(divine_hammer) > GCD() * 2 } and target.DebuffRemaining(judgment_ret_debuff) > GCD() and Spell(zeal) or SpellCharges(crusader_strike count=0) >= 1.65 - TalentPoints(the_fires_of_justice_talent) * 0.25 and HolyPower() <= 4 and { SpellCooldown(blade_of_justice) > GCD() * 2 or SpellCooldown(divine_hammer) > GCD() * 2 } and target.DebuffRemaining(judgment_ret_debuff) > GCD() and Spell(crusader_strike) or Spell(consecration) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(divine_purpose_buff) and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(the_fires_of_justice_buff) and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and not HasEquippedItem(137020) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(the_fires_of_justice_buff) and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and { not Talent(execution_sentence_talent) or SpellCooldown(execution_sentence) > GCD() * 2 } and Spell(templars_verdict)
    {
        #hammer_of_justice,if=equipped.137065&target.health.pct>=75&holy_power<=4
        if HasEquippedItem(137065) and target.HealthPercent() >= 75 and HolyPower() <= 4 Spell(hammer_of_justice)
    }
}

AddFunction RetributionPriorityShortCdPostConditions
{
    Enemies(tagged=1) <= 3 and { SpellCooldown(judgment) < GCD() * 4.5 or target.DebuffRemaining(judgment_ret_debuff) > GCD() * 4.5 } and Spell(execution_sentence) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 3 and { BuffPresent(crusade_buff) and BuffStacks(crusade_buff) < 15 or BuffPresent(liadrins_fury_unleashed_buff) } and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and HolyPower() >= 5 and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and not HasEquippedItem(137020) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and not HasEquippedItem(137020) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 3 and { BuffPresent(crusade_buff) and BuffStacks(crusade_buff) < 15 or BuffPresent(liadrins_fury_unleashed_buff) } and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 5 and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and HasArtifactTrait(wake_of_ashes) and SpellCooldown(wake_of_ashes) < GCD() * 2 and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() * 1.5 and Spell(divine_storm) or { HasEquippedItem(137020) or target.DebuffPresent(judgment_ret_debuff) } and HasArtifactTrait(wake_of_ashes) and SpellCooldown(wake_of_ashes) < GCD() * 2 and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() * 1.5 and Spell(templars_verdict) or target.DebuffPresent(execution_sentence_debuff) and target.DebuffRemaining(execution_sentence_debuff) < GCD() * 2 and target.DebuffRemaining(judgment_ret_debuff) < GCD() * 2 and Spell(judgment) or { SpellCooldown(blade_of_justice) > GCD() * 2 or SpellCooldown(divine_hammer) > GCD() * 2 } and Spell(consecration) or { not False(raid_event_adds_exists) or 600 > 15 } and { HolyPower() <= 0 or HolyPower() == 1 and { SpellCooldown(blade_of_justice) > GCD() or SpellCooldown(divine_hammer) > GCD() } or HolyPower() == 2 and { SpellCharges(zeal count=0) <= 0.65 or SpellCharges(crusader_strike count=0) <= 0.65 } } and Spell(wake_of_ashes) or HolyPower() <= 3 - ArmorSetBonus(T20 4) and Spell(blade_of_justice) or HolyPower() <= 3 - ArmorSetBonus(T20 4) and Spell(divine_hammer) or Spell(judgment) or SpellCharges(zeal count=0) >= 1.65 and HolyPower() <= 4 and { SpellCooldown(blade_of_justice) > GCD() * 2 or SpellCooldown(divine_hammer) > GCD() * 2 } and target.DebuffRemaining(judgment_ret_debuff) > GCD() and Spell(zeal) or SpellCharges(crusader_strike count=0) >= 1.65 - TalentPoints(the_fires_of_justice_talent) * 0.25 and HolyPower() <= 4 and { SpellCooldown(blade_of_justice) > GCD() * 2 or SpellCooldown(divine_hammer) > GCD() * 2 } and target.DebuffRemaining(judgment_ret_debuff) > GCD() and Spell(crusader_strike) or Spell(consecration) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(divine_purpose_buff) and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(the_fires_of_justice_buff) and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and not HasEquippedItem(137020) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(the_fires_of_justice_buff) and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and { not Talent(execution_sentence_talent) or SpellCooldown(execution_sentence) > GCD() * 2 } and Spell(templars_verdict) or HolyPower() <= 4 and Spell(zeal) or HolyPower() <= 4 and Spell(crusader_strike)
}

AddFunction RetributionPriorityCdActions
{
}

AddFunction RetributionPriorityCdPostConditions
{
    Enemies(tagged=1) <= 3 and { SpellCooldown(judgment) < GCD() * 4.5 or target.DebuffRemaining(judgment_ret_debuff) > GCD() * 4.5 } and Spell(execution_sentence) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 3 and { BuffPresent(crusade_buff) and BuffStacks(crusade_buff) < 15 or BuffPresent(liadrins_fury_unleashed_buff) } and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and HolyPower() >= 5 and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and not HasEquippedItem(137020) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and not HasEquippedItem(137020) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 3 and { BuffPresent(crusade_buff) and BuffStacks(crusade_buff) < 15 or BuffPresent(liadrins_fury_unleashed_buff) } and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and HolyPower() >= 5 and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and HasArtifactTrait(wake_of_ashes) and SpellCooldown(wake_of_ashes) < GCD() * 2 and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() * 1.5 and Spell(divine_storm) or { HasEquippedItem(137020) or target.DebuffPresent(judgment_ret_debuff) } and HasArtifactTrait(wake_of_ashes) and SpellCooldown(wake_of_ashes) < GCD() * 2 and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() * 1.5 and Spell(templars_verdict) or target.DebuffPresent(execution_sentence_debuff) and target.DebuffRemaining(execution_sentence_debuff) < GCD() * 2 and target.DebuffRemaining(judgment_ret_debuff) < GCD() * 2 and Spell(judgment) or { SpellCooldown(blade_of_justice) > GCD() * 2 or SpellCooldown(divine_hammer) > GCD() * 2 } and Spell(consecration) or { not False(raid_event_adds_exists) or 600 > 15 } and { HolyPower() <= 0 or HolyPower() == 1 and { SpellCooldown(blade_of_justice) > GCD() or SpellCooldown(divine_hammer) > GCD() } or HolyPower() == 2 and { SpellCharges(zeal count=0) <= 0.65 or SpellCharges(crusader_strike count=0) <= 0.65 } } and Spell(wake_of_ashes) or HolyPower() <= 3 - ArmorSetBonus(T20 4) and Spell(blade_of_justice) or HolyPower() <= 3 - ArmorSetBonus(T20 4) and Spell(divine_hammer) or Spell(judgment) or SpellCharges(zeal count=0) >= 1.65 and HolyPower() <= 4 and { SpellCooldown(blade_of_justice) > GCD() * 2 or SpellCooldown(divine_hammer) > GCD() * 2 } and target.DebuffRemaining(judgment_ret_debuff) > GCD() and Spell(zeal) or SpellCharges(crusader_strike count=0) >= 1.65 - TalentPoints(the_fires_of_justice_talent) * 0.25 and HolyPower() <= 4 and { SpellCooldown(blade_of_justice) > GCD() * 2 or SpellCooldown(divine_hammer) > GCD() * 2 } and target.DebuffRemaining(judgment_ret_debuff) > GCD() and Spell(crusader_strike) or Spell(consecration) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(divine_purpose_buff) and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and BuffPresent(the_fires_of_justice_buff) and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and ds_castable() and Spell(divine_storm) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and not HasEquippedItem(137020) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(divine_purpose_buff) and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and BuffPresent(the_fires_of_justice_buff) and Spell(templars_verdict) or target.DebuffPresent(judgment_ret_debuff) and { not Talent(execution_sentence_talent) or SpellCooldown(execution_sentence) > GCD() * 2 } and Spell(templars_verdict) or HasEquippedItem(137065) and target.HealthPercent() >= 75 and HolyPower() <= 4 and Spell(hammer_of_justice) or HolyPower() <= 4 and Spell(zeal) or HolyPower() <= 4 and Spell(crusader_strike)
}
]]

	OvaleScripts:RegisterScript("PALADIN", "retribution", name, desc, code, "script")
end
