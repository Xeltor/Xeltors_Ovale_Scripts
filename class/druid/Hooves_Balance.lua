local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "hooves_balance"
	local desc = "[Hooves][7.1] Druid: Balance"
	local code = [[
# Based on SimulationCraft profile "Druid_Balance_T18M".
#	class=druid
#	spec=balance
#	talents=0002001

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_druid_spells)

AddIcon specialization=1 help=main
{
	# Pre-combat stuff
	if not mounted() and target.Present() and target.Exists() and not target.IsFriend()
	{
		#mark_of_the_wild,if=!aura.str_agi_int.up
		# if not BuffPresent(str_agi_int_buff any=1) Spell(mark_of_the_wild)
		#moonkin_form
		if InCombat() Spell(moonkin_form)
	}
	
	# Rotation
	if target.InRange(solar_wrath) and HasFullControl() and target.Present() and InCombat()
	{
		# Cooldowns
		if Boss()
		{
			BalanceDefaultCdActions()
		}
		
		# Short Cooldowns
		BalanceDefaultShortCdActions()
		
		# Default Actions
		BalanceDefaultMainActions()
	}
}

AddFunction Boss
{
	IsBossFight() or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}
### actions.default
AddFunction BalanceDefaultMainActions
{
	#potion,name=deadly_grace,if=buff.celestial_alignment.up|buff.incarnation.up
	#blessing_of_elune,if=active_enemies<=2&talent.blessing_of_the_ancients.enabled&buff.blessing_of_elune.down
	if Enemies(tagged=1) <= 2 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_elune_buff) Spell(blessing_of_elune)
	#blessing_of_elune,if=active_enemies>=3&talent.blessing_of_the_ancients.enabled&buff.blessing_of_anshe.down
	if Enemies(tagged=1) >= 3 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_anshe_buff) Spell(blessing_of_elune)
	#call_action_list,name=fury_of_elune,if=talent.fury_of_elune.enabled&cooldown.fury_of_elue.remains<target.time_to_die
	if Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() BalanceFuryOfEluneMainActions()
	unless Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() and BalanceFuryOfEluneMainPostConditions()
	{
		#call_action_list,name=ed,if=equipped.the_emerald_dreamcatcher
		if HasEquippedItem(the_emerald_dreamcatcher) BalanceEdMainActions()
		unless HasEquippedItem(the_emerald_dreamcatcher) and BalanceEdMainPostConditions()
		{
			if AstralPower() >=40 and Enemies(tagged=1) >= 2 Spell(starfall)
			#new_moon,if=(charges=2&recharge_time<5)|charges=3
			if Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 Spell(new_moon)
			#half_moon,if=(charges=2&recharge_time<5)|charges=3|(target.time_to_die<15&charges=2)
			if Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 or target.TimeToDie() < 15 and Charges(half_moon) == 2 Spell(half_moon)
			#full_moon,if=(charges=2&recharge_time<5)|charges=3|target.time_to_die<15
			if Charges(full_moon) == 2 and SpellChargeCooldown(full_moon) < 5 or Charges(full_moon) == 3 or target.TimeToDie() < 15 Spell(full_moon)
			#stellar_flare,cycle_targets=1,max_cycle_targets=4,if=active_enemies<4&remains<7.2&astral_power>=15
			if DebuffCountOnAny(stellar_flare_debuff) < Enemies(tagged=1) and DebuffCountOnAny(stellar_flare_debuff) <= 4 and Enemies(tagged=1) < 4 and target.DebuffRemaining(stellar_flare_debuff) < 7.2 and AstralPower() >= 15 Spell(stellar_flare)
			#moonfire,if=(talent.natures_balance.enabled&remains<3)|(remains<6.6&!talent.natures_balance.enabled)
			if Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 and not Talent(natures_balance_talent) Spell(moonfire)
			#,if=(talent.natures_balance.enabled&remains<3)|(remains<5.4&!talent.natures_balance.enabled)
			if Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 and not Talent(natures_balance_talent) Spell(sunfire)
			#starfall,if=buff.oneths_overconfidence.up
			if BuffPresent(oneths_overconfidence_buff) Spell(starfall)
			#solar_wrath,if=buff.solar_empowerment.stack=3
			if BuffStacks(solar_empowerment_buff) == 3 Spell(solar_wrath)
			#lunar_strike,if=buff.lunar_empowerment.stack=3
			if BuffStacks(lunar_empowerment_buff) == 3 Spell(lunar_strike_balance)
			#call_action_list,name=celestial_alignment_phase,if=buff.celestial_alignment.up|buff.incarnation.up
			if BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) BalanceCelestialAlignmentPhaseMainActions()
			unless { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and BalanceCelestialAlignmentPhaseMainPostConditions()
			{
				#call_action_list,name=single_target
				BalanceSingleTargetMainActions()
			}
		}
	}
}
AddFunction BalanceDefaultMainPostConditions
{
	Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() and BalanceFuryOfEluneMainPostConditions() or HasEquippedItem(the_emerald_dreamcatcher) and BalanceEdMainPostConditions() or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and BalanceCelestialAlignmentPhaseMainPostConditions() or BalanceSingleTargetMainPostConditions()
}
AddFunction BalanceDefaultShortCdActions
{
	unless Enemies(tagged=1) <= 2 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_elune_buff) and Spell(blessing_of_elune) or Enemies(tagged=1) >= 3 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_anshe_buff) and Spell(blessing_of_elune)
	{
		#call_action_list,name=fury_of_elune,if=talent.fury_of_elune.enabled&cooldown.fury_of_elue.remains<target.time_to_die
		if Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() BalanceFuryOfEluneShortCdActions()
		unless Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() and BalanceFuryOfEluneShortCdPostConditions()
		{
			#call_action_list,name=ed,if=equipped.the_emerald_dreamcatcher
			if HasEquippedItem(the_emerald_dreamcatcher) BalanceEdShortCdActions()
			unless HasEquippedItem(the_emerald_dreamcatcher) and BalanceEdShortCdPostConditions() or { Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and Spell(new_moon) or { Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 or target.TimeToDie() < 15 and Charges(half_moon) == 2 } and Spell(half_moon) or { Charges(full_moon) == 2 and SpellChargeCooldown(full_moon) < 5 or Charges(full_moon) == 3 or target.TimeToDie() < 15 } and Spell(full_moon) or DebuffCountOnAny(stellar_flare_debuff) < Enemies(tagged=1) and DebuffCountOnAny(stellar_flare_debuff) <= 4 and Enemies(tagged=1) < 4 and target.DebuffRemaining(stellar_flare_debuff) < 7.2 and AstralPower() >= 15 and Spell(stellar_flare) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 and not Talent(natures_balance_talent) } and Spell(moonfire) or { Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 and not Talent(natures_balance_talent) } and Spell(sunfire)
			{
				#astral_communion,if=astral_power.deficit>=75
				if AstralPowerDeficit() >= 75 Spell(astral_communion)
				unless BuffPresent(oneths_overconfidence_buff) and Spell(starfall) or BuffStacks(solar_empowerment_buff) == 3 and Spell(solar_wrath) or BuffStacks(lunar_empowerment_buff) == 3 and Spell(lunar_strike_balance)
				{
					#call_action_list,name=celestial_alignment_phase,if=buff.celestial_alignment.up|buff.incarnation.up
					if BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) BalanceCelestialAlignmentPhaseShortCdActions()
					unless { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and BalanceCelestialAlignmentPhaseShortCdPostConditions()
					{
						#call_action_list,name=single_target
						BalanceSingleTargetShortCdActions()
					}
				}
			}
		}
	}
}
AddFunction BalanceDefaultShortCdPostConditions
{
	Enemies(tagged=1) <= 2 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_elune_buff) and Spell(blessing_of_elune) or Enemies(tagged=1) >= 3 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_anshe_buff) and Spell(blessing_of_elune) or Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() and BalanceFuryOfEluneShortCdPostConditions() or HasEquippedItem(the_emerald_dreamcatcher) and BalanceEdShortCdPostConditions() or { Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and Spell(new_moon) or { Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 or target.TimeToDie() < 15 and Charges(half_moon) == 2 } and Spell(half_moon) or { Charges(full_moon) == 2 and SpellChargeCooldown(full_moon) < 5 or Charges(full_moon) == 3 or target.TimeToDie() < 15 } and Spell(full_moon) or DebuffCountOnAny(stellar_flare_debuff) < Enemies(tagged=1) and DebuffCountOnAny(stellar_flare_debuff) <= 4 and Enemies(tagged=1) < 4 and target.DebuffRemaining(stellar_flare_debuff) < 7.2 and AstralPower() >= 15 and Spell(stellar_flare) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 and not Talent(natures_balance_talent) } and Spell(moonfire) or { Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 and not Talent(natures_balance_talent) } and Spell(sunfire) or BuffPresent(oneths_overconfidence_buff) and Spell(starfall) or BuffStacks(solar_empowerment_buff) == 3 and Spell(solar_wrath) or BuffStacks(lunar_empowerment_buff) == 3 and Spell(lunar_strike_balance) or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and BalanceCelestialAlignmentPhaseShortCdPostConditions() or BalanceSingleTargetShortCdPostConditions()
}
AddFunction BalanceDefaultCdActions
{
	unless Enemies(tagged=1) <= 2 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_elune_buff) and Spell(blessing_of_elune) or Enemies(tagged=1) >= 3 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_anshe_buff) and Spell(blessing_of_elune)
	{
		#blood_fury,if=buff.celestial_alignment.up|buff.incarnation.up
		if BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) Spell(blood_fury_apsp)
		#berserking,if=buff.celestial_alignment.up|buff.incarnation.up
		if BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) Spell(berserking)
		#arcane_torrent,if=buff.celestial_alignment.up|buff.incarnation.up
		if BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) Spell(arcane_torrent_energy)
		#call_action_list,name=fury_of_elune,if=talent.fury_of_elune.enabled&cooldown.fury_of_elue.remains<target.time_to_die
		if Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() BalanceFuryOfEluneCdActions()
		unless Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() and BalanceFuryOfEluneCdPostConditions()
		{
			#call_action_list,name=ed,if=equipped.the_emerald_dreamcatcher
			if HasEquippedItem(the_emerald_dreamcatcher) BalanceEdCdActions()
			unless HasEquippedItem(the_emerald_dreamcatcher) and BalanceEdCdPostConditions() or { Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and Spell(new_moon) or { Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 or target.TimeToDie() < 15 and Charges(half_moon) == 2 } and Spell(half_moon) or { Charges(full_moon) == 2 and SpellChargeCooldown(full_moon) < 5 or Charges(full_moon) == 3 or target.TimeToDie() < 15 } and Spell(full_moon) or DebuffCountOnAny(stellar_flare_debuff) < Enemies(tagged=1) and DebuffCountOnAny(stellar_flare_debuff) <= 4 and Enemies(tagged=1) < 4 and target.DebuffRemaining(stellar_flare_debuff) < 7.2 and AstralPower() >= 15 and Spell(stellar_flare) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 and not Talent(natures_balance_talent) } and Spell(moonfire) or { Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 and not Talent(natures_balance_talent) } and Spell(sunfire) or AstralPowerDeficit() >= 75 and Spell(astral_communion)
			{
				#celestial_alignment,if=astral_power>=40
				if AstralPower() >= 40 Spell(celestial_alignment)
				unless BuffPresent(oneths_overconfidence_buff) and Spell(starfall) or BuffStacks(solar_empowerment_buff) == 3 and Spell(solar_wrath) or BuffStacks(lunar_empowerment_buff) == 3 and Spell(lunar_strike_balance)
				{
					#call_action_list,name=celestial_alignment_phase,if=buff.celestial_alignment.up|buff.incarnation.up
					if BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) BalanceCelestialAlignmentPhaseCdActions()
					unless { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and BalanceCelestialAlignmentPhaseCdPostConditions()
					{
						#call_action_list,name=single_target
						BalanceSingleTargetCdActions()
					}
				}
			}
		}
	}
}
AddFunction BalanceDefaultCdPostConditions
{
	Enemies(tagged=1) <= 2 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_elune_buff) and Spell(blessing_of_elune) or Enemies(tagged=1) >= 3 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_anshe_buff) and Spell(blessing_of_elune) or Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() and BalanceFuryOfEluneCdPostConditions() or HasEquippedItem(the_emerald_dreamcatcher) and BalanceEdCdPostConditions() or { Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and Spell(new_moon) or { Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 or target.TimeToDie() < 15 and Charges(half_moon) == 2 } and Spell(half_moon) or { Charges(full_moon) == 2 and SpellChargeCooldown(full_moon) < 5 or Charges(full_moon) == 3 or target.TimeToDie() < 15 } and Spell(full_moon) or DebuffCountOnAny(stellar_flare_debuff) < Enemies(tagged=1) and DebuffCountOnAny(stellar_flare_debuff) <= 4 and Enemies(tagged=1) < 4 and target.DebuffRemaining(stellar_flare_debuff) < 7.2 and AstralPower() >= 15 and Spell(stellar_flare) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 and not Talent(natures_balance_talent) } and Spell(moonfire) or { Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 and not Talent(natures_balance_talent) } and Spell(sunfire) or AstralPowerDeficit() >= 75 and Spell(astral_communion) or BuffPresent(oneths_overconfidence_buff) and Spell(starfall) or BuffStacks(solar_empowerment_buff) == 3 and Spell(solar_wrath) or BuffStacks(lunar_empowerment_buff) == 3 and Spell(lunar_strike_balance) or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and BalanceCelestialAlignmentPhaseCdPostConditions() or BalanceSingleTargetCdPostConditions()
}
### actions.celestial_alignment_phase
AddFunction BalanceCelestialAlignmentPhaseMainActions
{
	#starfall,if=(active_enemies>=2&talent.stellar_flare.enabled|active_enemies>=3)&((talent.fury_of_elune.enabled&cooldown.fury_of_elune.remains>12&buff.fury_of_elune_up.down)|!talent.fury_of_elune.enabled)
	if { Enemies(tagged=1) >= 2 and Talent(stellar_flare_talent) or Enemies(tagged=1) >= 2 } and { Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) > 12 and BuffExpires(fury_of_elune_up_buff) or not Talent(fury_of_elune_talent) } Spell(starfall)
	#starsurge,if=active_enemies<=2
	if Enemies(tagged=1) <= 2 Spell(starsurge_moonkin)
	#warrior_of_elune
	Spell(warrior_of_elune)
	#lunar_strike,if=buff.warrior_of_elune.up
	if BuffPresent(warrior_of_elune_buff) Spell(lunar_strike_balance)
	#solar_wrath,if=buff.solar_empowerment.up
	if BuffPresent(solar_empowerment_buff) Spell(solar_wrath)
	#lunar_strike,if=buff.lunar_empowerment.up
	if BuffPresent(lunar_empowerment_buff) Spell(lunar_strike_balance)
	#solar_wrath,if=talent.natures_balance.enabled&dot.sunfire_dmg.remains<5&cast_time<dot.sunfire_dmg.remains
	if Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_dmg_debuff) < 5 and CastTime(solar_wrath) < target.DebuffRemaining(sunfire_dmg_debuff) Spell(solar_wrath)
	#lunar_strike,if=(talent.natures_balance.enabled&dot.moonfire_dmg.remains<5&cast_time<dot.moonfire_dmg.remains)|active_enemies>=2
	if Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_dmg_debuff) < 5 and CastTime(lunar_strike_balance) < target.DebuffRemaining(moonfire_dmg_debuff) or Enemies(tagged=1) >= 2 Spell(lunar_strike_balance)
	#solar_wrath
	Spell(solar_wrath)
}
AddFunction BalanceCelestialAlignmentPhaseMainPostConditions
{
}
AddFunction BalanceCelestialAlignmentPhaseShortCdActions
{
}
AddFunction BalanceCelestialAlignmentPhaseShortCdPostConditions
{
	{ Enemies(tagged=1) >= 2 and Talent(stellar_flare_talent) or Enemies(tagged=1) >= 3 } and { Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) > 12 and BuffExpires(fury_of_elune_up_buff) or not Talent(fury_of_elune_talent) } and Spell(starfall) or Enemies(tagged=1) <= 2 and Spell(starsurge_moonkin) or Spell(warrior_of_elune) or BuffPresent(warrior_of_elune_buff) and Spell(lunar_strike_balance) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and Spell(lunar_strike_balance) or Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_dmg_debuff) < 5 and CastTime(solar_wrath) < target.DebuffRemaining(sunfire_dmg_debuff) and Spell(solar_wrath) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_dmg_debuff) < 5 and CastTime(lunar_strike_balance) < target.DebuffRemaining(moonfire_dmg_debuff) or Enemies(tagged=1) >= 2 } and Spell(lunar_strike_balance) or Spell(solar_wrath)
}
AddFunction BalanceCelestialAlignmentPhaseCdActions
{
}
AddFunction BalanceCelestialAlignmentPhaseCdPostConditions
{
	{ Enemies(tagged=1) >= 2 and Talent(stellar_flare_talent) or Enemies(tagged=1) >= 3 } and { Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) > 12 and BuffExpires(fury_of_elune_up_buff) or not Talent(fury_of_elune_talent) } and Spell(starfall) or Enemies(tagged=1) <= 2 and Spell(starsurge_moonkin) or Spell(warrior_of_elune) or BuffPresent(warrior_of_elune_buff) and Spell(lunar_strike_balance) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and Spell(lunar_strike_balance) or Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_dmg_debuff) < 5 and CastTime(solar_wrath) < target.DebuffRemaining(sunfire_dmg_debuff) and Spell(solar_wrath) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_dmg_debuff) < 5 and CastTime(lunar_strike_balance) < target.DebuffRemaining(moonfire_dmg_debuff) or Enemies(tagged=1) >= 2 } and Spell(lunar_strike_balance) or Spell(solar_wrath)
}
### actions.ed
AddFunction BalanceEdMainActions
{
	#starsurge,if=(buff.the_emerald_dreamcatcher.up&buff.the_emerald_dreamcatcher.remains<gcd.max)|astral_power>=90|((buff.celestial_alignment.up|buff.incarnation.up)&astral_power>=85)
	if BuffPresent(the_emerald_dreamcatcher_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) < GCD() or AstralPower() >= 90 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPower() >= 85 Spell(starsurge_moonkin)
	#stellar_flare,cycle_targets=1,max_cycle_targets=4,if=active_enemies<4&remains<7.2&astral_power>=15
	if DebuffCountOnAny(stellar_flare_debuff) < Enemies(tagged=1) and DebuffCountOnAny(stellar_flare_debuff) <= 4 and Enemies(tagged=1) < 4 and target.DebuffRemaining(stellar_flare_debuff) < 7.2 and AstralPower() >= 15 Spell(stellar_flare)
	#moonfire,if=(talent.natures_balance.enabled&remains<3)|(remains<6.6&!talent.natures_balance.enabled)
	if Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 and not Talent(natures_balance_talent) Spell(moonfire)
	#sunfire,if=(talent.natures_balance.enabled&remains<3)|(remains<5.4&!talent.natures_balance.enabled)
	if Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 and not Talent(natures_balance_talent) Spell(sunfire)
	#solar_wrath,if=buff.solar_empowerment.up&buff.the_emerald_dreamcatcher.remains>execute_time&astral_power>=12&dot.sunfire.remains<5.4&dot.moonfire.remains>6.6
	if BuffPresent(solar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(solar_wrath) and AstralPower() >= 12 and target.DebuffRemaining(sunfire_debuff) < 5.4 and target.DebuffRemaining(moonfire_debuff) > 6.6 Spell(solar_wrath)
	#lunar_strike,if=buff.lunar_empowerment.up&buff.the_emerald_dreamcatcher.remains>execute_time&astral_power>=8&(!(buff.celestial_alignment.up|buff.incarnation.up)|(buff.celestial_alignment.up|buff.incarnation.up)&astral_power<=77)
	if BuffPresent(lunar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(lunar_strike_balance) and AstralPower() >= 8 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPower() <= 77 } Spell(lunar_strike_balance)
	#new_moon,if=astral_power<=90
	if AstralPower() <= 90 Spell(new_moon)
	#half_moon,if=astral_power<=80
	if AstralPower() <= 80 Spell(half_moon)
	#full_moon,if=astral_power<=60
	if AstralPower() <= 60 Spell(full_moon)
	#solar_wrath,if=buff.solar_empowerment.up
	if BuffPresent(solar_empowerment_buff) Spell(solar_wrath)
	#lunar_strike,if=buff.lunar_empowerment.up
	if BuffPresent(lunar_empowerment_buff) Spell(lunar_strike_balance)
	#solar_wrath
	Spell(solar_wrath)
}
AddFunction BalanceEdMainPostConditions
{
}
AddFunction BalanceEdShortCdActions
{
	#astral_communion,if=astral_power.deficit>=75&buff.the_emerald_dreamcatcher.up
	if AstralPowerDeficit() >= 75 and BuffPresent(the_emerald_dreamcatcher_buff) Spell(astral_communion)
}
AddFunction BalanceEdShortCdPostConditions
{
	{ BuffPresent(the_emerald_dreamcatcher_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) < GCD() or AstralPower() >= 90 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPower() >= 85 } and Spell(starsurge_moonkin) or DebuffCountOnAny(stellar_flare_debuff) < Enemies(tagged=1) and DebuffCountOnAny(stellar_flare_debuff) <= 4 and Enemies(tagged=1) < 4 and target.DebuffRemaining(stellar_flare_debuff) < 7.2 and AstralPower() >= 15 and Spell(stellar_flare) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 and not Talent(natures_balance_talent) } and Spell(moonfire) or { Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 and not Talent(natures_balance_talent) } and Spell(sunfire) or BuffPresent(solar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(solar_wrath) and AstralPower() >= 12 and target.DebuffRemaining(sunfire_debuff) < 5.4 and target.DebuffRemaining(moonfire_debuff) > 6.6 and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(lunar_strike_balance) and AstralPower() >= 8 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPower() <= 77 } and Spell(lunar_strike_balance) or AstralPower() <= 90 and Spell(new_moon) or AstralPower() <= 80 and Spell(half_moon) or AstralPower() <= 60 and Spell(full_moon) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and Spell(lunar_strike_balance) or Spell(solar_wrath)
}
AddFunction BalanceEdCdActions
{
	unless AstralPowerDeficit() >= 75 and BuffPresent(the_emerald_dreamcatcher_buff) and Spell(astral_communion)
	{
		#incarnation,if=astral_power>=85&!buff.the_emerald_dreamcatcher.up
		if AstralPower() >= 85 and not BuffPresent(the_emerald_dreamcatcher_buff) Spell(incarnation_chosen_of_elune)
		#celestial_alignment,if=astral_power>=85&!buff.the_emerald_dreamcatcher.up
		if AstralPower() >= 85 and not BuffPresent(the_emerald_dreamcatcher_buff) Spell(celestial_alignment)
	}
}
AddFunction BalanceEdCdPostConditions
{
	AstralPowerDeficit() >= 75 and BuffPresent(the_emerald_dreamcatcher_buff) and Spell(astral_communion) or { BuffPresent(the_emerald_dreamcatcher_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) < GCD() or AstralPower() >= 90 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPower() >= 85 } and Spell(starsurge_moonkin) or DebuffCountOnAny(stellar_flare_debuff) < Enemies(tagged=1) and DebuffCountOnAny(stellar_flare_debuff) <= 4 and Enemies(tagged=1) < 4 and target.DebuffRemaining(stellar_flare_debuff) < 7.2 and AstralPower() >= 15 and Spell(stellar_flare) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 and not Talent(natures_balance_talent) } and Spell(moonfire) or { Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 and not Talent(natures_balance_talent) } and Spell(sunfire) or BuffPresent(solar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(solar_wrath) and AstralPower() >= 12 and target.DebuffRemaining(sunfire_debuff) < 5.4 and target.DebuffRemaining(moonfire_debuff) > 6.6 and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(lunar_strike_balance) and AstralPower() >= 8 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPower() <= 77 } and Spell(lunar_strike_balance) or AstralPower() <= 90 and Spell(new_moon) or AstralPower() <= 80 and Spell(half_moon) or AstralPower() <= 60 and Spell(full_moon) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and Spell(lunar_strike_balance) or Spell(solar_wrath)
}
### actions.fury_of_elune
AddFunction BalanceFuryOfEluneMainActions
{
	#new_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune_up.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=90))
	if { Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and { BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 90 } Spell(new_moon)
	#half_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune_up.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=80))
	if { Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 } and { BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 80 } Spell(half_moon)
	#full_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune_up.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=60))
	if { Charges(full_moon) == 2 and SpellChargeCooldown(full_moon) < 5 or Charges(full_moon) == 3 } and { BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 60 } Spell(full_moon)
	#warrior_of_elune,if=buff.fury_of_elune_up.up|(cooldown.fury_of_elune.remains>=35&buff.lunar_empowerment.up)
	if BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) >= 35 and BuffPresent(lunar_empowerment_buff) Spell(warrior_of_elune)
	#lunar_strike,if=buff.warrior_of_elune.up&(astral_power<=90|(astral_power<=85&buff.incarnation.up))
	if BuffPresent(warrior_of_elune_buff) and { AstralPower() <= 90 or AstralPower() <= 85 and BuffPresent(incarnation_chosen_of_elune_buff) } Spell(lunar_strike_balance)
	#new_moon,if=astral_power<=90&buff.fury_of_elune_up.up
	if AstralPower() <= 90 and BuffPresent(fury_of_elune_up_buff) Spell(new_moon)
	#half_moon,if=astral_power<=80&buff.fury_of_elune_up.up&astral_power>cast_time*12
	if AstralPower() <= 80 and BuffPresent(fury_of_elune_up_buff) and AstralPower() > CastTime(half_moon) * 12 Spell(half_moon)
	#full_moon,if=astral_power<=60&buff.fury_of_elune_up.up&astral_power>cast_time*12
	if AstralPower() <= 60 and BuffPresent(fury_of_elune_up_buff) and AstralPower() > CastTime(full_moon) * 12 Spell(full_moon)
	#moonfire,if=buff.fury_of_elune_up.down&remains<=6.6
	if BuffExpires(fury_of_elune_up_buff) and target.DebuffRemaining(moonfire_debuff) <= 6.6 Spell(moonfire)
	#sunfire,if=buff.fury_of_elune_up.down&remains<5.4
	if BuffExpires(fury_of_elune_up_buff) and target.DebuffRemaining(sunfire_debuff) < 5.4 Spell(sunfire)
	#stellar_flare,if=remains<7.2&active_enemies=1
	if target.DebuffRemaining(stellar_flare_debuff) < 7.2 and Enemies(tagged=1) == 1 Spell(stellar_flare)
	#starfall,if=(active_enemies>=2&talent.stellar_flare.enabled|active_enemies>=3)&buff.fury_of_elune_up.down&cooldown.fury_of_elune.remains>10
	if { Enemies(tagged=1) >= 2 and Talent(stellar_flare_talent) or Enemies(tagged=1) >= 3 } and BuffExpires(fury_of_elune_up_buff) and SpellCooldown(fury_of_elune) > 10 Spell(starfall)
	#starsurge,if=active_enemies<=2&buff.fury_of_elune_up.down&cooldown.fury_of_elune.remains>7
	if Enemies(tagged=1) <= 2 and BuffExpires(fury_of_elune_up_buff) and SpellCooldown(fury_of_elune) > 7 Spell(starsurge_moonkin)
	#starsurge,if=buff.fury_of_elune_up.down&((astral_power>=92&cooldown.fury_of_elune.remains>gcd*3)|(cooldown.warrior_of_elune.remains<=5&cooldown.fury_of_elune.remains>=35&buff.lunar_empowerment.stack<2))
	if BuffExpires(fury_of_elune_up_buff) and { AstralPower() >= 92 and SpellCooldown(fury_of_elune) > GCD() * 3 or SpellCooldown(warrior_of_elune) <= 5 and SpellCooldown(fury_of_elune) >= 35 and BuffStacks(lunar_empowerment_buff) < 2 } Spell(starsurge_moonkin)
	#solar_wrath,if=buff.solar_empowerment.up
	if BuffPresent(solar_empowerment_buff) Spell(solar_wrath)
	#lunar_strike,if=buff.lunar_empowerment.stack=3|(buff.lunar_empowerment.remains<5&buff.lunar_empowerment.up)|active_enemies>=2
	if BuffStacks(lunar_empowerment_buff) == 3 or BuffRemaining(lunar_empowerment_buff) < 5 and BuffPresent(lunar_empowerment_buff) or Enemies(tagged=1) >= 2 Spell(lunar_strike_balance)
	#solar_wrath
	Spell(solar_wrath)
}
AddFunction BalanceFuryOfEluneMainPostConditions
{
}
AddFunction BalanceFuryOfEluneShortCdActions
{
	#fury_of_elune,if=astral_power>=95
	if AstralPower() >= 95 Spell(fury_of_elune)
	unless { Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and { BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 90 } and Spell(new_moon) or { Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 } and { BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 80 } and Spell(half_moon) or { Charges(full_moon) == 2 and SpellChargeCooldown(full_moon) < 5 or Charges(full_moon) == 3 } and { BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 60 } and Spell(full_moon)
	{
		#astral_communion,if=buff.fury_of_elune_up.up&astral_power<=25
		if BuffPresent(fury_of_elune_up_buff) and AstralPower() <= 25 Spell(astral_communion)
	}
}
AddFunction BalanceFuryOfEluneShortCdPostConditions
{
	{ Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and { BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 90 } and Spell(new_moon) or { Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 } and { BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 80 } and Spell(half_moon) or { Charges(full_moon) == 2 and SpellChargeCooldown(full_moon) < 5 or Charges(full_moon) == 3 } and { BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 60 } and Spell(full_moon) or { BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) >= 35 and BuffPresent(lunar_empowerment_buff) } and Spell(warrior_of_elune) or BuffPresent(warrior_of_elune_buff) and { AstralPower() <= 90 or AstralPower() <= 85 and BuffPresent(incarnation_chosen_of_elune_buff) } and Spell(lunar_strike_balance) or AstralPower() <= 90 and BuffPresent(fury_of_elune_up_buff) and Spell(new_moon) or AstralPower() <= 80 and BuffPresent(fury_of_elune_up_buff) and AstralPower() > CastTime(half_moon) * 12 and Spell(half_moon) or AstralPower() <= 60 and BuffPresent(fury_of_elune_up_buff) and AstralPower() > CastTime(full_moon) * 12 and Spell(full_moon) or BuffExpires(fury_of_elune_up_buff) and target.DebuffRemaining(moonfire_debuff) <= 6.6 and Spell(moonfire) or BuffExpires(fury_of_elune_up_buff) and target.DebuffRemaining(sunfire_debuff) < 5.4 and Spell(sunfire) or target.DebuffRemaining(stellar_flare_debuff) < 7.2 and Enemies(tagged=1) == 1 and Spell(stellar_flare) or { Enemies(tagged=1) >= 2 and Talent(stellar_flare_talent) or Enemies(tagged=1) >= 3 } and BuffExpires(fury_of_elune_up_buff) and SpellCooldown(fury_of_elune) > 10 and Spell(starfall) or Enemies(tagged=1) <= 2 and BuffExpires(fury_of_elune_up_buff) and SpellCooldown(fury_of_elune) > 7 and Spell(starsurge_moonkin) or BuffExpires(fury_of_elune_up_buff) and { AstralPower() >= 92 and SpellCooldown(fury_of_elune) > GCD() * 3 or SpellCooldown(warrior_of_elune) <= 5 and SpellCooldown(fury_of_elune) >= 35 and BuffStacks(lunar_empowerment_buff) < 2 } and Spell(starsurge_moonkin) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or { BuffStacks(lunar_empowerment_buff) == 3 or BuffRemaining(lunar_empowerment_buff) < 5 and BuffPresent(lunar_empowerment_buff) or Enemies(tagged=1) >= 2 } and Spell(lunar_strike_balance) or Spell(solar_wrath)
}
AddFunction BalanceFuryOfEluneCdActions
{
	#incarnation,if=astral_power>=95&cooldown.fury_of_elune.remains<=gcd
	if AstralPower() >= 95 and SpellCooldown(fury_of_elune) <= GCD() Spell(incarnation_chosen_of_elune)
}
AddFunction BalanceFuryOfEluneCdPostConditions
{
	AstralPower() >= 95 and Spell(fury_of_elune) or { Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and { BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 90 } and Spell(new_moon) or { Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 } and { BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 80 } and Spell(half_moon) or { Charges(full_moon) == 2 and SpellChargeCooldown(full_moon) < 5 or Charges(full_moon) == 3 } and { BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 60 } and Spell(full_moon) or BuffPresent(fury_of_elune_up_buff) and AstralPower() <= 25 and Spell(astral_communion) or { BuffPresent(fury_of_elune_up_buff) or SpellCooldown(fury_of_elune) >= 35 and BuffPresent(lunar_empowerment_buff) } and Spell(warrior_of_elune) or BuffPresent(warrior_of_elune_buff) and { AstralPower() <= 90 or AstralPower() <= 85 and BuffPresent(incarnation_chosen_of_elune_buff) } and Spell(lunar_strike_balance) or AstralPower() <= 90 and BuffPresent(fury_of_elune_up_buff) and Spell(new_moon) or AstralPower() <= 80 and BuffPresent(fury_of_elune_up_buff) and AstralPower() > CastTime(half_moon) * 12 and Spell(half_moon) or AstralPower() <= 60 and BuffPresent(fury_of_elune_up_buff) and AstralPower() > CastTime(full_moon) * 12 and Spell(full_moon) or BuffExpires(fury_of_elune_up_buff) and target.DebuffRemaining(moonfire_debuff) <= 6.6 and Spell(moonfire) or BuffExpires(fury_of_elune_up_buff) and target.DebuffRemaining(sunfire_debuff) < 5.4 and Spell(sunfire) or target.DebuffRemaining(stellar_flare_debuff) < 7.2 and Enemies(tagged=1) == 1 and Spell(stellar_flare) or { Enemies(tagged=1) >= 2 and Talent(stellar_flare_talent) or Enemies(tagged=1) >= 3 } and BuffExpires(fury_of_elune_up_buff) and SpellCooldown(fury_of_elune) > 10 and Spell(starfall) or Enemies(tagged=1) <= 2 and BuffExpires(fury_of_elune_up_buff) and SpellCooldown(fury_of_elune) > 7 and Spell(starsurge_moonkin) or BuffExpires(fury_of_elune_up_buff) and { AstralPower() >= 92 and SpellCooldown(fury_of_elune) > GCD() * 3 or SpellCooldown(warrior_of_elune) <= 5 and SpellCooldown(fury_of_elune) >= 35 and BuffStacks(lunar_empowerment_buff) < 2 } and Spell(starsurge_moonkin) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or { BuffStacks(lunar_empowerment_buff) == 3 or BuffRemaining(lunar_empowerment_buff) < 5 and BuffPresent(lunar_empowerment_buff) or Enemies(tagged=1) >= 2 } and Spell(lunar_strike_balance) or Spell(solar_wrath)
}
### actions.precombat
AddFunction BalancePrecombatMainActions
{
	#flask,type=flask_of_the_whispered_pact
	#food,type=azshari_salad
	#augmentation,type=defiled
	Spell(augmentation)
	#moonkin_form
	Spell(moonkin_form)
	#blessing_of_elune
	Spell(blessing_of_elune)
	#snapshot_stats
	#potion,name=deadly_grace
	#new_moon
	Spell(new_moon)
}
AddFunction BalancePrecombatMainPostConditions
{
}
AddFunction BalancePrecombatShortCdActions
{
}
AddFunction BalancePrecombatShortCdPostConditions
{
	Spell(augmentation) or Spell(moonkin_form) or Spell(blessing_of_elune) or Spell(new_moon)
}
AddFunction BalancePrecombatCdActions
{
}
AddFunction BalancePrecombatCdPostConditions
{
	Spell(augmentation) or Spell(moonkin_form) or Spell(blessing_of_elune) or Spell(new_moon)
}
### actions.single_target
AddFunction BalanceSingleTargetMainActions
{
	if AstralPower() >=40 and Enemies(tagged=1) >= 2 Spell(starfall)
	#new_moon,if=astral_power<=90
	if AstralPower() <= 90 Spell(new_moon)
	#half_moon,if=astral_power<=80
	if AstralPower() <= 80 Spell(half_moon)
	#full_moon,if=astral_power<=60
	if AstralPower() <= 60 Spell(full_moon)
	#starfall,if=(active_enemies>=2&talent.stellar_flare.enabled|active_enemies>=3)&((talent.fury_of_elune.enabled&cooldown.fury_of_elune.remains>12&buff.fury_of_elune_up.down)|!talent.fury_of_elune.enabled)
	
	#starsurge,if=active_enemies<=2
	if Enemies(tagged=1) <= 2 Spell(starsurge_moonkin)
	#warrior_of_elune
	Spell(warrior_of_elune)
	#lunar_strike,if=buff.warrior_of_elune.up
	if BuffPresent(warrior_of_elune_buff) Spell(lunar_strike_balance)
	#solar_wrath,if=buff.solar_empowerment.up
	if BuffPresent(solar_empowerment_buff) Spell(solar_wrath)
	#lunar_strike,if=buff.lunar_empowerment.up
	if BuffPresent(lunar_empowerment_buff) Spell(lunar_strike_balance)
	#solar_wrath,if=talent.natures_balance.enabled&dot.sunfire_dmg.remains<5&cast_time<dot.sunfire_dmg.remains
	if Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_dmg_debuff) < 5 and CastTime(solar_wrath) < target.DebuffRemaining(sunfire_dmg_debuff) Spell(solar_wrath)
	#lunar_strike,if=(talent.natures_balance.enabled&dot.moonfire_dmg.remains<5&cast_time<dot.moonfire_dmg.remains)|active_enemies>=2
	if Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_dmg_debuff) < 5 and CastTime(lunar_strike_balance) < target.DebuffRemaining(moonfire_dmg_debuff) or Enemies(tagged=1) >= 2 Spell(lunar_strike_balance)
	#solar_wrath
	Spell(solar_wrath)
}
AddFunction BalanceSingleTargetMainPostConditions
{
}
AddFunction BalanceSingleTargetShortCdActions
{
}
AddFunction BalanceSingleTargetShortCdPostConditions
{
	AstralPower() <= 90 and Spell(new_moon) or AstralPower() <= 80 and Spell(half_moon) or AstralPower() <= 60 and Spell(full_moon) or { Enemies(tagged=1) >= 2 and Talent(stellar_flare_talent) or Enemies(tagged=1) >= 3 } and { Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) > 12 and BuffExpires(fury_of_elune_up_buff) or not Talent(fury_of_elune_talent) } and Spell(starfall) or Enemies(tagged=1) <= 2 and Spell(starsurge_moonkin) or Spell(warrior_of_elune) or BuffPresent(warrior_of_elune_buff) and Spell(lunar_strike_balance) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and Spell(lunar_strike_balance) or Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_dmg_debuff) < 5 and CastTime(solar_wrath) < target.DebuffRemaining(sunfire_dmg_debuff) and Spell(solar_wrath) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_dmg_debuff) < 5 and CastTime(lunar_strike_balance) < target.DebuffRemaining(moonfire_dmg_debuff) or Enemies(tagged=1) >= 2 } and Spell(lunar_strike_balance) or Spell(solar_wrath)
}
AddFunction BalanceSingleTargetCdActions
{
}
AddFunction BalanceSingleTargetCdPostConditions
{
	AstralPower() <= 90 and Spell(new_moon) or AstralPower() <= 80 and Spell(half_moon) or AstralPower() <= 60 and Spell(full_moon) or { Enemies(tagged=1) >= 2 and Talent(stellar_flare_talent) or Enemies(tagged=1) >= 3 } and { Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) > 12 and BuffExpires(fury_of_elune_up_buff) or not Talent(fury_of_elune_talent) } and Spell(starfall) or Enemies(tagged=1) <= 2 and Spell(starsurge_moonkin) or Spell(warrior_of_elune) or BuffPresent(warrior_of_elune_buff) and Spell(lunar_strike_balance) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and Spell(lunar_strike_balance) or Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_dmg_debuff) < 5 and CastTime(solar_wrath) < target.DebuffRemaining(sunfire_dmg_debuff) and Spell(solar_wrath) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_dmg_debuff) < 5 and CastTime(lunar_strike_balance) < target.DebuffRemaining(moonfire_dmg_debuff) or Enemies(tagged=1) >= 2 } and Spell(lunar_strike_balance) or Spell(solar_wrath)
}
]]
	OvaleScripts:RegisterScript("DRUID", "balance", name, desc, code, "script")
end
