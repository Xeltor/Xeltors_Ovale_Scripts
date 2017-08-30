local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_retribution"
	local desc = "[Xel][7.1] Paladin: Retribution"
	local code = [[
Include(ovale_common)

Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_paladin_spells)

Define(greater_blessing_of_kings 203538)
	SpellInfo(greater_blessing_of_kings duration=3600)
Define(greater_blessing_of_might 203528)
	SpellInfo(greater_blessing_of_might duration=3600)
Define(greater_blessing_of_wisdom 203539)
	SpellInfo(greater_blessing_of_wisdom duration=3600)

# Retribution
AddIcon specialization=3 help=main
{
	if not mounted() and not target.Present() and not target.Exists()
	{
		# if not BuffPresent(greater_blessing_of_kings) Spell(greater_blessing_of_kings)
		if not BuffPresent(greater_blessing_of_might) Spell(greater_blessing_of_might)
		# if not BuffPresent(greater_blessing_of_wisdom) Spell(greater_blessing_of_wisdom)
	}
	
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
			if target.InRange(avengers_shield) Spell(avengers_shield)
			if not InFlightToTarget(avengers_shield)
			{
				if target.InRange(fist_of_justice) Spell(fist_of_justice)
				if target.InRange(hammer_of_justice) Spell(hammer_of_justice)
				if target.InRange(hammer_of_justice) Spell(blinding_light)
				if target.Distance(less 8) Spell(arcane_torrent_holy)
				if target.InRange(quaking_palm) Spell(quaking_palm)
				if target.Distance(less 8) Spell(war_stomp)
			}
		}
	}
}

### actions.default

AddFunction RetributionDefaultMainActions
{
	#execution_sentence,if=spell_targets.divine_storm<=3&(cooldown.judgment.remains<gcd*4.5|debuff.judgment.remains>gcd*4.67)&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*2)
	if Enemies(tagged=1) <= 3 and { SpellCooldown(judgment) < GCD() * 4.5 or target.DebuffRemaining(judgment_debuff) > GCD() * 4.67 } and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 2 } Spell(execution_sentence)
	#divine_storm,if=debuff.judgment.up&spell_targets.divine_storm>=2&buff.divine_purpose.up&buff.divine_purpose.remains<gcd*2
	if target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 Spell(divine_storm)
	#divine_storm,if=debuff.judgment.up&spell_targets.divine_storm>=2&holy_power>=5&buff.divine_purpose.react
	if target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) Spell(divine_storm)
	#divine_storm,if=debuff.judgment.up&spell_targets.divine_storm>=2&holy_power>=5&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*3)
	if target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 5 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 3 } Spell(divine_storm)
	#justicars_vengeance,if=debuff.judgment.up&buff.divine_purpose.up&buff.divine_purpose.remains<gcd*2&!equipped.whisper_of_the_nathrezim
	if target.DebuffPresent(judgment_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and not HasEquippedItem(whisper_of_the_nathrezim) Spell(justicars_vengeance)
	#justicars_vengeance,if=debuff.judgment.up&holy_power>=5&buff.divine_purpose.react&!equipped.whisper_of_the_nathrezim
	if target.DebuffPresent(judgment_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and not HasEquippedItem(whisper_of_the_nathrezim) Spell(justicars_vengeance)
	#templars_verdict,if=debuff.judgment.up&buff.divine_purpose.up&buff.divine_purpose.remains<gcd*2
	if target.DebuffPresent(judgment_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 Spell(templars_verdict)
	#templars_verdict,if=debuff.judgment.up&holy_power>=5&buff.divine_purpose.react
	if target.DebuffPresent(judgment_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) Spell(templars_verdict)
	#templars_verdict,if=debuff.judgment.up&holy_power>=5&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*3)
	if target.DebuffPresent(judgment_debuff) and HolyPower() >= 5 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 3 } Spell(templars_verdict)
	#divine_storm,if=debuff.judgment.up&holy_power>=3&spell_targets.divine_storm>=2&(cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled|buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd)&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*4)
	if target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and Enemies(tagged=1) >= 2 and { SpellCooldown(wake_of_ashes) < GCD() * 2 and HasArtifactTrait(wake_of_ashes) or BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() } and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 4 } Spell(divine_storm)
	#justicars_vengeance,if=debuff.judgment.up&holy_power>=3&buff.divine_purpose.up&cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled&!equipped.whisper_of_the_nathrezim
	if target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and BuffPresent(divine_purpose_buff) and SpellCooldown(wake_of_ashes) < GCD() * 2 and HasArtifactTrait(wake_of_ashes) and not HasEquippedItem(whisper_of_the_nathrezim) Spell(justicars_vengeance)
	#templars_verdict,if=debuff.judgment.up&holy_power>=3&(cooldown.wake_of_ashes.remains<gcd*2&artifact.wake_of_ashes.enabled|buff.whisper_of_the_nathrezim.up&buff.whisper_of_the_nathrezim.remains<gcd)&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*4)
	if target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and { SpellCooldown(wake_of_ashes) < GCD() * 2 and HasArtifactTrait(wake_of_ashes) or BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() } and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 4 } Spell(templars_verdict)
	#zeal,if=charges=2&holy_power<=4
	if Charges(zeal) == 2 and HolyPower() <= 4 Spell(zeal)
	#crusader_strike,if=charges=2&holy_power<=4
	if Charges(crusader_strike) == 2 and HolyPower() <= 4 Spell(crusader_strike)
	#blade_of_justice,if=holy_power<=2|(holy_power<=3&(cooldown.zeal.charges_fractional<=1.34|cooldown.crusader_strike.charges_fractional<=1.34))
	if HolyPower() <= 2 or HolyPower() <= 3 and { SpellCharges(zeal) <= 1.34 or SpellCharges(crusader_strike) <= 1.34 } Spell(blade_of_justice)
	#divine_hammer,if=holy_power<=2|(holy_power<=3&(cooldown.zeal.charges_fractional<=1.34|cooldown.crusader_strike.charges_fractional<=1.34))
	if HolyPower() <= 2 or HolyPower() <= 3 and { SpellCharges(zeal) <= 1.34 or SpellCharges(crusader_strike) <= 1.34 } Spell(divine_hammer)
	#judgment,if=holy_power>=3|((cooldown.zeal.charges_fractional<=1.67|cooldown.crusader_strike.charges_fractional<=1.67)&(cooldown.divine_hammer.remains>gcd|cooldown.blade_of_justice.remains>gcd))|(talent.greater_judgment.enabled&target.health.pct>50)
	if HolyPower() >= 3 or { SpellCharges(zeal) <= 1.67 or SpellCharges(crusader_strike) <= 1.67 } and { SpellCooldown(divine_hammer) > GCD() or SpellCooldown(blade_of_justice) > GCD() } or Talent(greater_judgment_talent) and target.HealthPercent() > 50 Spell(judgment)
	#divine_storm,if=debuff.judgment.up&spell_targets.divine_storm>=2&buff.divine_purpose.react
	if target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and BuffPresent(divine_purpose_buff) Spell(divine_storm)
	#divine_storm,if=debuff.judgment.up&spell_targets.divine_storm>=2&buff.the_fires_of_justice.react&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*3)
	if target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and BuffPresent(the_fires_of_justice_buff) and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 3 } Spell(divine_storm)
	#divine_storm,if=debuff.judgment.up&spell_targets.divine_storm>=2&holy_power>=4&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*4)
	if target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 4 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 4 } Spell(divine_storm)
	#justicars_vengeance,if=debuff.judgment.up&buff.divine_purpose.react&!equipped.whisper_of_the_nathrezim
	if target.DebuffPresent(judgment_debuff) and BuffPresent(divine_purpose_buff) and not HasEquippedItem(whisper_of_the_nathrezim) Spell(justicars_vengeance)
	#templars_verdict,if=debuff.judgment.up&buff.divine_purpose.react
	if target.DebuffPresent(judgment_debuff) and BuffPresent(divine_purpose_buff) Spell(templars_verdict)
	#templars_verdict,if=debuff.judgment.up&buff.the_fires_of_justice.react&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*3)
	if target.DebuffPresent(judgment_debuff) and BuffPresent(the_fires_of_justice_buff) and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 3 } Spell(templars_verdict)
	#templars_verdict,if=debuff.judgment.up&holy_power>=4&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*4)
	if target.DebuffPresent(judgment_debuff) and HolyPower() >= 4 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 4 } Spell(templars_verdict)
	#zeal,if=holy_power<=4
	if HolyPower() <= 4 Spell(zeal)
	#crusader_strike,if=holy_power<=4
	if HolyPower() <= 4 Spell(crusader_strike)
	#divine_storm,if=debuff.judgment.up&holy_power>=3&spell_targets.divine_storm>=2&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*5)
	if target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and Enemies(tagged=1) >= 2 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 5 } Spell(divine_storm)
	#templars_verdict,if=debuff.judgment.up&holy_power>=3&(!talent.crusade.enabled|cooldown.crusade.remains>gcd*5)
	if target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 5 } Spell(templars_verdict)
}

AddFunction RetributionDefaultMainPostConditions
{
}

AddFunction RetributionDefaultShortCdActions
{
	#auto_attack
	# RetributionGetInMeleeRange()
	#shield_of_vengeance
	Spell(shield_of_vengeance)
	#wake_of_ashes,if=holy_power>=0&time<2
	if HolyPower() >= 0 and TimeInCombat() < 2 Spell(wake_of_ashes)

	unless Enemies(tagged=1) <= 3 and { SpellCooldown(judgment) < GCD() * 4.5 or target.DebuffRemaining(judgment_debuff) > GCD() * 4.67 } and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 2 } and Spell(execution_sentence) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 5 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 3 } and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and not HasEquippedItem(whisper_of_the_nathrezim) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and not HasEquippedItem(whisper_of_the_nathrezim) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and Spell(templars_verdict) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and Spell(templars_verdict) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 5 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 3 } and Spell(templars_verdict) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and Enemies(tagged=1) >= 2 and { SpellCooldown(wake_of_ashes) < GCD() * 2 and HasArtifactTrait(wake_of_ashes) or BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() } and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 4 } and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and BuffPresent(divine_purpose_buff) and SpellCooldown(wake_of_ashes) < GCD() * 2 and HasArtifactTrait(wake_of_ashes) and not HasEquippedItem(whisper_of_the_nathrezim) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and { SpellCooldown(wake_of_ashes) < GCD() * 2 and HasArtifactTrait(wake_of_ashes) or BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() } and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 4 } and Spell(templars_verdict)
	{
		#wake_of_ashes,if=holy_power=0|holy_power=1&(cooldown.blade_of_justice.remains>gcd|cooldown.divine_hammer.remains>gcd)|holy_power=2&(cooldown.zeal.charges_fractional<=0.65|cooldown.crusader_strike.charges_fractional<=0.65)
		if HolyPower() == 0 or HolyPower() == 1 and { SpellCooldown(blade_of_justice) > GCD() or SpellCooldown(divine_hammer) > GCD() } or HolyPower() == 2 and { SpellCharges(zeal) <= 0.65 or SpellCharges(crusader_strike) <= 0.65 } Spell(wake_of_ashes)

		unless Charges(zeal) == 2 and HolyPower() <= 4 and Spell(zeal) or Charges(crusader_strike) == 2 and HolyPower() <= 4 and Spell(crusader_strike) or { HolyPower() <= 2 or HolyPower() <= 3 and { SpellCharges(zeal) <= 1.34 or SpellCharges(crusader_strike) <= 1.34 } } and Spell(blade_of_justice) or { HolyPower() <= 2 or HolyPower() <= 3 and { SpellCharges(zeal) <= 1.34 or SpellCharges(crusader_strike) <= 1.34 } } and Spell(divine_hammer) or { HolyPower() >= 3 or { SpellCharges(zeal) <= 1.67 or SpellCharges(crusader_strike) <= 1.67 } and { SpellCooldown(divine_hammer) > GCD() or SpellCooldown(blade_of_justice) > GCD() } or Talent(greater_judgment_talent) and target.HealthPercent() > 50 } and Spell(judgment)
		{
			#consecration
			Spell(consecration)
		}
	}
}

AddFunction RetributionDefaultShortCdPostConditions
{
	Enemies(tagged=1) <= 3 and { SpellCooldown(judgment) < GCD() * 4.5 or target.DebuffRemaining(judgment_debuff) > GCD() * 4.67 } and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 2 } and Spell(execution_sentence) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 5 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 3 } and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and not HasEquippedItem(whisper_of_the_nathrezim) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and not HasEquippedItem(whisper_of_the_nathrezim) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and Spell(templars_verdict) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and Spell(templars_verdict) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 5 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 3 } and Spell(templars_verdict) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and Enemies(tagged=1) >= 2 and { SpellCooldown(wake_of_ashes) < GCD() * 2 and HasArtifactTrait(wake_of_ashes) or BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() } and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 4 } and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and BuffPresent(divine_purpose_buff) and SpellCooldown(wake_of_ashes) < GCD() * 2 and HasArtifactTrait(wake_of_ashes) and not HasEquippedItem(whisper_of_the_nathrezim) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and { SpellCooldown(wake_of_ashes) < GCD() * 2 and HasArtifactTrait(wake_of_ashes) or BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() } and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 4 } and Spell(templars_verdict) or Charges(zeal) == 2 and HolyPower() <= 4 and Spell(zeal) or Charges(crusader_strike) == 2 and HolyPower() <= 4 and Spell(crusader_strike) or { HolyPower() <= 2 or HolyPower() <= 3 and { SpellCharges(zeal) <= 1.34 or SpellCharges(crusader_strike) <= 1.34 } } and Spell(blade_of_justice) or { HolyPower() <= 2 or HolyPower() <= 3 and { SpellCharges(zeal) <= 1.34 or SpellCharges(crusader_strike) <= 1.34 } } and Spell(divine_hammer) or { HolyPower() >= 3 or { SpellCharges(zeal) <= 1.67 or SpellCharges(crusader_strike) <= 1.67 } and { SpellCooldown(divine_hammer) > GCD() or SpellCooldown(blade_of_justice) > GCD() } or Talent(greater_judgment_talent) and target.HealthPercent() > 50 } and Spell(judgment) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and BuffPresent(divine_purpose_buff) and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and BuffPresent(the_fires_of_justice_buff) and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 3 } and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 4 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 4 } and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and BuffPresent(divine_purpose_buff) and not HasEquippedItem(whisper_of_the_nathrezim) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_debuff) and BuffPresent(divine_purpose_buff) and Spell(templars_verdict) or target.DebuffPresent(judgment_debuff) and BuffPresent(the_fires_of_justice_buff) and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 3 } and Spell(templars_verdict) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 4 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 4 } and Spell(templars_verdict) or HolyPower() <= 4 and Spell(zeal) or HolyPower() <= 4 and Spell(crusader_strike) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and Enemies(tagged=1) >= 2 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 5 } and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 5 } and Spell(templars_verdict)
}

AddFunction RetributionDefaultCdActions
{
	#rebuke
	# RetributionInterruptActions()
	#potion,name=old_war,if=(buff.bloodlust.react|buff.avenging_wrath.up|buff.crusade.up|target.time_to_die<=40)
	#use_item,name=faulty_countermeasure,if=(buff.avenging_wrath.up|buff.crusade.up)
	# if BuffPresent(avenging_wrath_melee_buff) or BuffPresent(crusade_buff) RetributionUseItemActions()
	#holy_wrath
	Spell(holy_wrath)
	#avenging_wrath
	Spell(avenging_wrath_melee)

	unless Spell(shield_of_vengeance)
	{
		#crusade,if=holy_power>=5
		if HolyPower() >= 5 Spell(crusade)

		unless HolyPower() >= 0 and TimeInCombat() < 2 and Spell(wake_of_ashes) or Enemies(tagged=1) <= 3 and { SpellCooldown(judgment) < GCD() * 4.5 or target.DebuffRemaining(judgment_debuff) > GCD() * 4.67 } and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 2 } and Spell(execution_sentence)
		{
			#blood_fury
			Spell(blood_fury_apsp)
			#berserking
			Spell(berserking)
			#arcane_torrent,if=holy_power<5
			if HolyPower() < 5 Spell(arcane_torrent_holy)
		}
	}
}

AddFunction RetributionDefaultCdPostConditions
{
	Spell(shield_of_vengeance) or HolyPower() >= 0 and TimeInCombat() < 2 and Spell(wake_of_ashes) or Enemies(tagged=1) <= 3 and { SpellCooldown(judgment) < GCD() * 4.5 or target.DebuffRemaining(judgment_debuff) > GCD() * 4.67 } and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 2 } and Spell(execution_sentence) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 5 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 3 } and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and not HasEquippedItem(whisper_of_the_nathrezim) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and not HasEquippedItem(whisper_of_the_nathrezim) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_debuff) and BuffPresent(divine_purpose_buff) and BuffRemaining(divine_purpose_buff) < GCD() * 2 and Spell(templars_verdict) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 5 and BuffPresent(divine_purpose_buff) and Spell(templars_verdict) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 5 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 3 } and Spell(templars_verdict) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and Enemies(tagged=1) >= 2 and { SpellCooldown(wake_of_ashes) < GCD() * 2 and HasArtifactTrait(wake_of_ashes) or BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() } and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 4 } and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and BuffPresent(divine_purpose_buff) and SpellCooldown(wake_of_ashes) < GCD() * 2 and HasArtifactTrait(wake_of_ashes) and not HasEquippedItem(whisper_of_the_nathrezim) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and { SpellCooldown(wake_of_ashes) < GCD() * 2 and HasArtifactTrait(wake_of_ashes) or BuffPresent(whisper_of_the_nathrezim_buff) and BuffRemaining(whisper_of_the_nathrezim_buff) < GCD() } and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 4 } and Spell(templars_verdict) or { HolyPower() == 0 or HolyPower() == 1 and { SpellCooldown(blade_of_justice) > GCD() or SpellCooldown(divine_hammer) > GCD() } or HolyPower() == 2 and { SpellCharges(zeal) <= 0.65 or SpellCharges(crusader_strike) <= 0.65 } } and Spell(wake_of_ashes) or Charges(zeal) == 2 and HolyPower() <= 4 and Spell(zeal) or Charges(crusader_strike) == 2 and HolyPower() <= 4 and Spell(crusader_strike) or { HolyPower() <= 2 or HolyPower() <= 3 and { SpellCharges(zeal) <= 1.34 or SpellCharges(crusader_strike) <= 1.34 } } and Spell(blade_of_justice) or { HolyPower() <= 2 or HolyPower() <= 3 and { SpellCharges(zeal) <= 1.34 or SpellCharges(crusader_strike) <= 1.34 } } and Spell(divine_hammer) or { HolyPower() >= 3 or { SpellCharges(zeal) <= 1.67 or SpellCharges(crusader_strike) <= 1.67 } and { SpellCooldown(divine_hammer) > GCD() or SpellCooldown(blade_of_justice) > GCD() } or Talent(greater_judgment_talent) and target.HealthPercent() > 50 } and Spell(judgment) or Spell(consecration) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and BuffPresent(divine_purpose_buff) and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and BuffPresent(the_fires_of_justice_buff) and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 3 } and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and Enemies(tagged=1) >= 2 and HolyPower() >= 4 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 4 } and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and BuffPresent(divine_purpose_buff) and not HasEquippedItem(whisper_of_the_nathrezim) and Spell(justicars_vengeance) or target.DebuffPresent(judgment_debuff) and BuffPresent(divine_purpose_buff) and Spell(templars_verdict) or target.DebuffPresent(judgment_debuff) and BuffPresent(the_fires_of_justice_buff) and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 3 } and Spell(templars_verdict) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 4 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 4 } and Spell(templars_verdict) or HolyPower() <= 4 and Spell(zeal) or HolyPower() <= 4 and Spell(crusader_strike) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and Enemies(tagged=1) >= 2 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 5 } and Spell(divine_storm) or target.DebuffPresent(judgment_debuff) and HolyPower() >= 3 and { not Talent(crusade_talent) or SpellCooldown(crusade) > GCD() * 5 } and Spell(templars_verdict)
}

### actions.precombat

AddFunction RetributionPrecombatMainActions
{
	#flask,type=flask_of_the_countless_armies
	#food,type=azshari_salad
	#augmentation,type=defiled
	# Spell(augmentation)
	#greater_blessing_of_might
	# Spell(greater_blessing_of_might)
}

AddFunction RetributionPrecombatMainPostConditions
{
}

AddFunction RetributionPrecombatShortCdActions
{
}

AddFunction RetributionPrecombatShortCdPostConditions
{
	Spell(augmentation) or Spell(greater_blessing_of_might)
}

AddFunction RetributionPrecombatCdActions
{
}

AddFunction RetributionPrecombatCdPostConditions
{
	Spell(augmentation) or Spell(greater_blessing_of_might)
}
]]

	OvaleScripts:RegisterScript("PALADIN", "retribution", name, desc, code, "script")
end
