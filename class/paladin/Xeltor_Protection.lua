local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_prot"
	local desc = "[Xel][7.1] Paladin: Protection"
	local code = [[
# Based on SimulationCraft profile "Paladin_Protection_T17M".
#	class=paladin
#	spec=protection
#	talents=3032322
#	glyphs=focused_shield/divine_protection/final_wrath

Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_paladin_spells)

Define(greater_blessing_of_kings 203538)
	SpellInfo(greater_blessing_of_kings duration=3600)
Define(greater_blessing_of_might 203528)
	SpellInfo(greater_blessing_of_might duration=3600)
Define(greater_blessing_of_wisdom 203539)
	SpellInfo(greater_blessing_of_wisdom duration=3600)

# Protection
AddIcon specialization=2 help=main
{
	
	if not mounted() and HasFullControl()
	{
		if not BuffPresent(greater_blessing_of_kings) Spell(greater_blessing_of_kings)
		# if not BuffPresent(greater_blessing_of_might) Spell(greater_blessing_of_might)
		# if not BuffPresent(greater_blessing_of_wisdom) Spell(greater_blessing_of_wisdom)
	}
	
	# Interrupt
	if InCombat() and target.Casting(interrupt) InterruptActions()
	
	if target.InRange(hammer_of_the_righteous) and HasFullControl()
	{
		if target.Classification(worldboss) or HealthPercent() < 50 ProtectionDefaultCdActions()
		ProtectionDefaultShortCdActions()
		ProtectionDefaultMainActions()
	}
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(rebuke) Spell(rebuke)
		if not target.Classification(worldboss)
		{
			if target.InRange(avengers_shield) Spell(avengers_shield)
			if not InFlightToTarget(avengers_shield) and not target.Classification(worldboss)
			{
				if target.InRange(fist_of_justice) Spell(fist_of_justice)
				if target.InRange(hammer_of_justice) Spell(hammer_of_justice)
				if target.Distance(less 10) Spell(blinding_light)
				if target.Distance(less 8) Spell(arcane_torrent_holy)
				if target.InRange(quaking_palm) Spell(quaking_palm)
				if target.Distance(less 8) Spell(war_stomp)
			}
		}
	}
}

### actions.default

AddFunction ProtectionDefaultMainActions
{
	#call_action_list,name=prot
	ProtectionProtMainActions()
}

AddFunction ProtectionDefaultMainPostConditions
{
	ProtectionProtMainPostConditions()
}

AddFunction ProtectionDefaultShortCdActions
{
	#auto_attack
	# ProtectionGetInMeleeRange()
	#call_action_list,name=prot
	ProtectionProtShortCdActions()
}

AddFunction ProtectionDefaultShortCdPostConditions
{
	ProtectionProtShortCdPostConditions()
}

AddFunction ProtectionDefaultCdActions
{
	#use_item,name=shivermaws_jawbone
	# ProtectionUseItemActions()
	#blood_fury
	Spell(blood_fury_apsp)
	#berserking
	Spell(berserking)
	#arcane_torrent
	Spell(arcane_torrent_holy)
	#blood_fury
	Spell(blood_fury_apsp)
	#berserking
	Spell(berserking)
	#arcane_torrent
	Spell(arcane_torrent_holy)
	#call_action_list,name=prot
	ProtectionProtCdActions()
}

AddFunction ProtectionDefaultCdPostConditions
{
	ProtectionProtCdPostConditions()
}

### actions.max_dps

AddFunction ProtectionMaxDpsMainActions
{
}

AddFunction ProtectionMaxDpsMainPostConditions
{
}

AddFunction ProtectionMaxDpsShortCdActions
{
	#auto_attack
	# ProtectionGetInMeleeRange()
}

AddFunction ProtectionMaxDpsShortCdPostConditions
{
}

AddFunction ProtectionMaxDpsCdActions
{
	#use_item,name=shivermaws_jawbone
	# ProtectionUseItemActions()
	#blood_fury
	Spell(blood_fury_apsp)
	#berserking
	Spell(berserking)
	#arcane_torrent
	Spell(arcane_torrent_holy)
}

AddFunction ProtectionMaxDpsCdPostConditions
{
}

### actions.max_survival

AddFunction ProtectionMaxSurvivalMainActions
{
}

AddFunction ProtectionMaxSurvivalMainPostConditions
{
}

AddFunction ProtectionMaxSurvivalShortCdActions
{
	#auto_attack
	# ProtectionGetInMeleeRange()
}

AddFunction ProtectionMaxSurvivalShortCdPostConditions
{
}

AddFunction ProtectionMaxSurvivalCdActions
{
	#use_item,name=shivermaws_jawbone
	# ProtectionUseItemActions()
	#blood_fury
	Spell(blood_fury_apsp)
	#berserking
	Spell(berserking)
	#arcane_torrent
	Spell(arcane_torrent_holy)
}

AddFunction ProtectionMaxSurvivalCdPostConditions
{
}

### actions.precombat

AddFunction ProtectionPrecombatMainActions
{
}

AddFunction ProtectionPrecombatMainPostConditions
{
}

AddFunction ProtectionPrecombatShortCdActions
{
}

AddFunction ProtectionPrecombatShortCdPostConditions
{
}

AddFunction ProtectionPrecombatCdActions
{
}

AddFunction ProtectionPrecombatCdPostConditions
{
}

### actions.prot

AddFunction ProtectionProtMainActions
{
	#light_of_the_protector,if=(health.pct<40)
	if HealthPercent() < 40 Spell(light_of_the_protector)
	#hand_of_the_protector,if=(health.pct<40)
	if HealthPercent() < 40 Spell(hand_of_the_protector)
	#light_of_the_protector,if=(incoming_damage_10000ms<health.max*1.25)&health.pct<55&talent.righteous_protector.enabled
	if IncomingDamage(10) < MaxHealth() * 1.25 and HealthPercent() < 55 and Talent(righteous_protector_talent) Spell(light_of_the_protector)
	#light_of_the_protector,if=(incoming_damage_13000ms<health.max*1.6)&health.pct<55
	if IncomingDamage(13) < MaxHealth() * 1.6 and HealthPercent() < 55 Spell(light_of_the_protector)
	#hand_of_the_protector,if=(incoming_damage_6000ms<health.max*0.7)&health.pct<65&talent.righteous_protector.enabled
	if IncomingDamage(6) < MaxHealth() * 0.7 and HealthPercent() < 65 and Talent(righteous_protector_talent) Spell(hand_of_the_protector)
	#hand_of_the_protector,if=(incoming_damage_9000ms<health.max*1.2)&health.pct<55
	if IncomingDamage(9) < MaxHealth() * 1.2 and HealthPercent() < 55 Spell(hand_of_the_protector)
	#judgment
	Spell(judgment)
    #avengers_shield,if=talent.crusaders_judgment.enabled&buff.grand_crusader.up
    if Talent(crusaders_judgment_talent) and BuffPresent(grand_crusader_buff) Spell(avengers_shield)
	#blessed_hammer
	Spell(blessed_hammer)
	#avengers_shield
	Spell(avengers_shield)
	#hammer_of_the_righteous
	Spell(hammer_of_the_righteous)
}

AddFunction ProtectionProtMainPostConditions
{
}

AddFunction ProtectionProtShortCdActions
{
	#seraphim,if=talent.seraphim.enabled&action.shield_of_the_righteous.charges>=2
	if Talent(seraphim_talent) and Charges(shield_of_the_righteous) >= 2 Spell(seraphim)
	#shield_of_the_righteous,if=(!talent.seraphim.enabled|action.shield_of_the_righteous.charges>2)&!(debuff.eye_of_tyr.up&buff.aegis_of_light.up&buff.ardent_defender.up&buff.guardian_of_ancient_kings.up&buff.divine_shield.up&buff.potion.up)
	if { not Talent(seraphim_talent) or Charges(shield_of_the_righteous) > 2 } and not { target.DebuffPresent(eye_of_tyr_debuff) and BuffPresent(aegis_of_light_buff) and BuffPresent(ardent_defender_buff) and BuffPresent(guardian_of_ancient_kings_buff) and BuffPresent(divine_shield_buff) } Spell(shield_of_the_righteous)
    #shield_of_the_righteous,if=(talent.bastion_of_light.enabled&talent.seraphim.enabled&buff.seraphim.up&cooldown.bastion_of_light.up)&!(debuff.eye_of_tyr.up&buff.aegis_of_light.up&buff.ardent_defender.up&buff.guardian_of_ancient_kings.up&buff.divine_shield.up&buff.potion.up)
    if Talent(bastion_of_light_talent) and Talent(seraphim_talent) and BuffPresent(seraphim_buff) and not SpellCooldown(bastion_of_light) > 0 and not { target.DebuffPresent(eye_of_tyr_debuff) and BuffPresent(aegis_of_light_buff) and BuffPresent(ardent_defender_buff) and BuffPresent(guardian_of_ancient_kings_buff) and BuffPresent(divine_shield_buff) } Spell(shield_of_the_righteous)
    #shield_of_the_righteous,if=(talent.bastion_of_light.enabled&!talent.seraphim.enabled&cooldown.bastion_of_light.up)&!(debuff.eye_of_tyr.up&buff.aegis_of_light.up&buff.ardent_defender.up&buff.guardian_of_ancient_kings.up&buff.divine_shield.up&buff.potion.up)
    if Talent(bastion_of_light_talent) and not Talent(seraphim_talent) and not SpellCooldown(bastion_of_light) > 0 and not { target.DebuffPresent(eye_of_tyr_debuff) and BuffPresent(aegis_of_light_buff) and BuffPresent(ardent_defender_buff) and BuffPresent(guardian_of_ancient_kings_buff) and BuffPresent(divine_shield_buff) } Spell(shield_of_the_righteous)

	unless HealthPercent() < 40 and Spell(light_of_the_protector) or HealthPercent() < 40 and Spell(hand_of_the_protector) or IncomingDamage(10) < MaxHealth() * 1.25 and HealthPercent() < 55 and Talent(righteous_protector_talent) and Spell(light_of_the_protector) or IncomingDamage(13) < MaxHealth() * 1.6 and HealthPercent() < 55 and Spell(light_of_the_protector) or IncomingDamage(6) < MaxHealth() * 0.7 and HealthPercent() < 65 and Talent(righteous_protector_talent) and Spell(hand_of_the_protector) or IncomingDamage(9) < MaxHealth() * 1.2 and HealthPercent() < 55 and Spell(hand_of_the_protector)
	{
		#divine_steed,if=talent.knight_templar.enabled&incoming_damage_2500ms>health.max*0.4&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)
		if Talent(knight_templar_talent) and IncomingDamage(2.5) > MaxHealth() * 0.4 and not { target.DebuffPresent(eye_of_tyr_debuff) or BuffPresent(aegis_of_light_buff) or BuffPresent(ardent_defender_buff) or BuffPresent(guardian_of_ancient_kings_buff) or BuffPresent(divine_shield_buff) } Spell(divine_steed)
		#eye_of_tyr,if=incoming_damage_2500ms>health.max*0.4&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)
		if IncomingDamage(2.5) > MaxHealth() * 0.4 and not { target.DebuffPresent(eye_of_tyr_debuff) or BuffPresent(aegis_of_light_buff) or BuffPresent(ardent_defender_buff) or BuffPresent(guardian_of_ancient_kings_buff) or BuffPresent(divine_shield_buff) } Spell(eye_of_tyr)

        unless Spell(judgment) or Talent(crusaders_judgment_talent) and BuffPresent(grand_crusader_buff) and Spell(avengers_shield) or Spell(blessed_hammer) or Spell(avengers_shield)
		{
			#consecration
			Spell(consecration)
		}
	}
}

AddFunction ProtectionProtShortCdPostConditions
{
    HealthPercent() < 40 and Spell(light_of_the_protector) or HealthPercent() < 40 and Spell(hand_of_the_protector) or IncomingDamage(10) < MaxHealth() * 1.25 and HealthPercent() < 55 and Talent(righteous_protector_talent) and Spell(light_of_the_protector) or IncomingDamage(13) < MaxHealth() * 1.6 and HealthPercent() < 55 and Spell(light_of_the_protector) or IncomingDamage(6) < MaxHealth() * 0.7 and HealthPercent() < 65 and Talent(righteous_protector_talent) and Spell(hand_of_the_protector) or IncomingDamage(9) < MaxHealth() * 1.2 and HealthPercent() < 55 and Spell(hand_of_the_protector) or Spell(judgment) or Talent(crusaders_judgment_talent) and BuffPresent(grand_crusader_buff) and Spell(avengers_shield) or Spell(blessed_hammer) or Spell(avengers_shield) or Spell(hammer_of_the_righteous)
}

AddFunction ProtectionProtCdActions
{
	#bastion_of_light,if=talent.bastion_of_light.enabled&action.shield_of_the_righteous.charges<1
	if Talent(bastion_of_light_talent) and Charges(shield_of_the_righteous) < 1 Spell(bastion_of_light)

	unless HealthPercent() < 40 and Spell(light_of_the_protector) or HealthPercent() < 40 and Spell(hand_of_the_protector) or IncomingDamage(10) < MaxHealth() * 1.25 and HealthPercent() < 55 and Talent(righteous_protector_talent) and Spell(light_of_the_protector) or IncomingDamage(13) < MaxHealth() * 1.6 and HealthPercent() < 55 and Spell(light_of_the_protector) or IncomingDamage(6) < MaxHealth() * 0.7 and HealthPercent() < 65 and Talent(righteous_protector_talent) and Spell(hand_of_the_protector) or IncomingDamage(9) < MaxHealth() * 1.2 and HealthPercent() < 55 and Spell(hand_of_the_protector) or Talent(knight_templar_talent) and IncomingDamage(2.5) > MaxHealth() * 0.4 and not { target.DebuffPresent(eye_of_tyr_debuff) or BuffPresent(aegis_of_light_buff) or BuffPresent(ardent_defender_buff) or BuffPresent(guardian_of_ancient_kings_buff) or BuffPresent(divine_shield_buff) } and Spell(divine_steed) or IncomingDamage(2.5) > MaxHealth() * 0.4 and not { target.DebuffPresent(eye_of_tyr_debuff) or BuffPresent(aegis_of_light_buff) or BuffPresent(ardent_defender_buff) or BuffPresent(guardian_of_ancient_kings_buff) or BuffPresent(divine_shield_buff) } and Spell(eye_of_tyr)
	{
		#aegis_of_light,if=incoming_damage_2500ms>health.max*0.4&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)
		if IncomingDamage(2.5) > MaxHealth() * 0.4 and not { target.DebuffPresent(eye_of_tyr_debuff) or BuffPresent(aegis_of_light_buff) or BuffPresent(ardent_defender_buff) or BuffPresent(guardian_of_ancient_kings_buff) or BuffPresent(divine_shield_buff) } Spell(aegis_of_light)
		#guardian_of_ancient_kings,if=incoming_damage_2500ms>health.max*0.4&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)
		if IncomingDamage(2.5) > MaxHealth() * 0.4 and not { target.DebuffPresent(eye_of_tyr_debuff) or BuffPresent(aegis_of_light_buff) or BuffPresent(ardent_defender_buff) or BuffPresent(guardian_of_ancient_kings_buff) or BuffPresent(divine_shield_buff) } Spell(guardian_of_ancient_kings)
		#divine_shield,if=talent.final_stand.enabled&incoming_damage_2500ms>health.max*0.4&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)
		if Talent(final_stand_talent) and IncomingDamage(2.5) > MaxHealth() * 0.4 and not { target.DebuffPresent(eye_of_tyr_debuff) or BuffPresent(aegis_of_light_buff) or BuffPresent(ardent_defender_buff) or BuffPresent(guardian_of_ancient_kings_buff) or BuffPresent(divine_shield_buff) } Spell(divine_shield)
		#ardent_defender,if=incoming_damage_2500ms>health.max*0.4&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)
		if IncomingDamage(2.5) > MaxHealth() * 0.4 and not { target.DebuffPresent(eye_of_tyr_debuff) or BuffPresent(aegis_of_light_buff) or BuffPresent(ardent_defender_buff) or BuffPresent(guardian_of_ancient_kings_buff) or BuffPresent(divine_shield_buff) } Spell(ardent_defender)
		#lay_on_hands,if=health.pct<15
		if HealthPercent() < 15 Spell(lay_on_hands)
		#potion,name=unbending_potion
		#potion,name=draenic_strength,if=incoming_damage_2500ms>health.max*0.4&&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)|target.time_to_die<=25
		# if IncomingDamage(2.5) > MaxHealth() * 0.4 and not { target.DebuffPresent(eye_of_tyr_debuff) or BuffPresent(aegis_of_light_buff) or BuffPresent(ardent_defender_buff) or BuffPresent(guardian_of_ancient_kings_buff) or BuffPresent(divine_shield_buff) or BuffPresent(potion_strength_buff) } or target.TimeToDie() <= 25 ProtectionUsePotionStrength()
		#stoneform,if=incoming_damage_2500ms>health.max*0.4&!(debuff.eye_of_tyr.up|buff.aegis_of_light.up|buff.ardent_defender.up|buff.guardian_of_ancient_kings.up|buff.divine_shield.up|buff.potion.up)
		if IncomingDamage(2.5) > MaxHealth() * 0.4 and not { target.DebuffPresent(eye_of_tyr_debuff) or BuffPresent(aegis_of_light_buff) or BuffPresent(ardent_defender_buff) or BuffPresent(guardian_of_ancient_kings_buff) or BuffPresent(divine_shield_buff) or BuffPresent(potion_strength_buff) } Spell(stoneform)
		#avenging_wrath,if=!talent.seraphim.enabled
		if not Talent(seraphim_talent) Spell(avenging_wrath_melee)
		#avenging_wrath,if=talent.seraphim.enabled&buff.seraphim.up
		if Talent(seraphim_talent) and BuffPresent(seraphim_buff) Spell(avenging_wrath_melee)

        unless Spell(judgment) or Talent(crusaders_judgment_talent) and BuffPresent(grand_crusader_buff) and Spell(avengers_shield) or Spell(blessed_hammer) or Spell(avengers_shield) or Spell(consecration)
		{
			#blinding_light
			Spell(blinding_light)
		}
	}
}

AddFunction ProtectionProtCdPostConditions
{
    HealthPercent() < 40 and Spell(light_of_the_protector) or HealthPercent() < 40 and Spell(hand_of_the_protector) or IncomingDamage(10) < MaxHealth() * 1.25 and HealthPercent() < 55 and Talent(righteous_protector_talent) and Spell(light_of_the_protector) or IncomingDamage(13) < MaxHealth() * 1.6 and HealthPercent() < 55 and Spell(light_of_the_protector) or IncomingDamage(6) < MaxHealth() * 0.7 and HealthPercent() < 65 and Talent(righteous_protector_talent) and Spell(hand_of_the_protector) or IncomingDamage(9) < MaxHealth() * 1.2 and HealthPercent() < 55 and Spell(hand_of_the_protector) or Talent(knight_templar_talent) and IncomingDamage(2.5) > MaxHealth() * 0.4 and not { target.DebuffPresent(eye_of_tyr_debuff) or BuffPresent(aegis_of_light_buff) or BuffPresent(ardent_defender_buff) or BuffPresent(guardian_of_ancient_kings_buff) or BuffPresent(divine_shield_buff) } and Spell(divine_steed) or IncomingDamage(2.5) > MaxHealth() * 0.4 and not { target.DebuffPresent(eye_of_tyr_debuff) or BuffPresent(aegis_of_light_buff) or BuffPresent(ardent_defender_buff) or BuffPresent(guardian_of_ancient_kings_buff) or BuffPresent(divine_shield_buff) } and Spell(eye_of_tyr) or Spell(judgment) or Talent(crusaders_judgment_talent) and BuffPresent(grand_crusader_buff) and Spell(avengers_shield) or Spell(blessed_hammer) or Spell(avengers_shield) or Spell(consecration) or Spell(hammer_of_the_righteous)
}

### actions.prot_aoe

AddFunction ProtectionProtAoeMainActions
{
	#avengers_shield
	Spell(avengers_shield)
	#blessed_hammer
	Spell(blessed_hammer)
	#judgment
	Spell(judgment)
	#hammer_of_the_righteous
	Spell(hammer_of_the_righteous)
}

AddFunction ProtectionProtAoeMainPostConditions
{
}

AddFunction ProtectionProtAoeShortCdActions
{
	unless Spell(avengers_shield) or Spell(blessed_hammer) or Spell(judgment)
	{
		#consecration
		Spell(consecration)
	}
}

AddFunction ProtectionProtAoeShortCdPostConditions
{
	Spell(avengers_shield) or Spell(blessed_hammer) or Spell(judgment) or Spell(hammer_of_the_righteous)
}

AddFunction ProtectionProtAoeCdActions
{
}

AddFunction ProtectionProtAoeCdPostConditions
{
	Spell(avengers_shield) or Spell(blessed_hammer) or Spell(judgment) or Spell(consecration) or Spell(hammer_of_the_righteous)
}
]]

	OvaleScripts:RegisterScript("PALADIN", "protection", name, desc, code, "script")
end
