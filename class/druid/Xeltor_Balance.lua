local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_balance"
	local desc = "[Xel][7.3] Druid: Balance"
	local code = [[
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
			if CanMove() > 0 or Speed() == 0 BalanceDefaultCdActions()
		}
		
		# Short Cooldowns
		if CanMove() > 0 or Speed() == 0 BalanceDefaultShortCdActions()
		
		# Default Actions
		if CanMove() > 0 or Speed() == 0 BalanceDefaultMainActions()
	}
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

### actions.AoE

AddFunction BalanceAoeMainActions
{
 #starfall,if=debuff.stellar_empowerment.remains<gcd.max*2|astral_power.deficit<22.5|(buff.celestial_alignment.remains>8|buff.incarnation.remains>8)|target.time_to_die<8
 if target.DebuffRemaining(stellar_empowerment_debuff) < GCD() * 2 or AstralPowerDeficit() < 22.5 or BuffRemaining(celestial_alignment_buff) > 8 or BuffRemaining(incarnation_chosen_of_elune_buff) > 8 or target.TimeToDie() < 8 Spell(starfall)
 #stellar_flare,target_if=refreshable,if=target.time_to_die>10
 if target.TimeToDie() > 10 and target.Refreshable(stellar_flare_debuff) Spell(stellar_flare)
 #sunfire,target_if=refreshable,if=astral_power.deficit>7&target.time_to_die>4
 if AstralPowerDeficit() > 7 and target.TimeToDie() > 4 and target.Refreshable(sunfire_debuff) Spell(sunfire)
 #moonfire,target_if=refreshable,if=astral_power.deficit>7&target.time_to_die>4
 if AstralPowerDeficit() > 7 and target.TimeToDie() > 4 and target.Refreshable(moonfire_debuff) Spell(moonfire)
 #starsurge,if=buff.oneths_intuition.react&(!buff.astral_acceleration.up|buff.astral_acceleration.remains>5|astral_power.deficit<44)
 if BuffPresent(oneths_intuition_buff) and { not BuffPresent(astral_acceleration_buff) or BuffRemaining(astral_acceleration_buff) > 5 or AstralPowerDeficit() < 44 } Spell(starsurge_moonkin)
 #new_moon,if=astral_power.deficit>14&(!(buff.celestial_alignment.up|buff.incarnation.up)|(charges=2&recharge_time<5)|charges=3)
 if AstralPowerDeficit() > 14 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } or Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and not SpellKnown(half_moon) and not SpellKnown(full_moon) Spell(new_moon)
 #half_moon,if=astral_power.deficit>24
 if AstralPowerDeficit() > 24 and SpellKnown(half_moon) Spell(half_moon)
 #full_moon,if=astral_power.deficit>44
 if AstralPowerDeficit() > 44 and SpellKnown(full_moon) Spell(full_moon)
 #lunar_strike,if=buff.warrior_of_elune.up
 if BuffPresent(warrior_of_elune_buff) Spell(lunar_strike_balance)
 #solar_wrath,if=buff.solar_empowerment.up
 if BuffPresent(solar_empowerment_buff) Spell(solar_wrath)
 #lunar_strike,if=buff.lunar_empowerment.up
 if BuffPresent(lunar_empowerment_buff) Spell(lunar_strike_balance)
 #moonfire,if=equipped.lady_and_the_child&talent.soul_of_the_forest.enabled&(active_enemies<3|(active_enemies<4&!set_bonus.tier20_4pc)|(equipped.radiant_moonlight&active_enemies<7&!set_bonus.tier20_4pc))&spell_haste>0.4&!buff.celestial_alignment.up&!buff.incarnation.up
 if HasEquippedItem(lady_and_the_child) and Talent(soul_of_the_forest_talent) and { Enemies(tagged=1) < 3 or Enemies(tagged=1) < 4 and not ArmorSetBonus(T20 4) or HasEquippedItem(radiant_moonlight) and Enemies(tagged=1) < 7 and not ArmorSetBonus(T20 4) } and 100 / { 100 + SpellHaste() } > 0.4 and not BuffPresent(celestial_alignment_buff) and not BuffPresent(incarnation_chosen_of_elune_buff) Spell(moonfire)
 #lunar_strike,if=spell_targets.lunar_strike>=4|spell_haste<0.45
 if Enemies(tagged=1) >= 4 or 100 / { 100 + SpellHaste() } < 0.45 Spell(lunar_strike_balance)
 #solar_wrath
 Spell(solar_wrath)
}

AddFunction BalanceAoeMainPostConditions
{
}

AddFunction BalanceAoeShortCdActions
{
 unless { target.DebuffRemaining(stellar_empowerment_debuff) < GCD() * 2 or AstralPowerDeficit() < 22.5 or BuffRemaining(celestial_alignment_buff) > 8 or BuffRemaining(incarnation_chosen_of_elune_buff) > 8 or target.TimeToDie() < 8 } and Spell(starfall) or target.TimeToDie() > 10 and target.Refreshable(stellar_flare_debuff) and Spell(stellar_flare) or AstralPowerDeficit() > 7 and target.TimeToDie() > 4 and target.Refreshable(sunfire_debuff) and Spell(sunfire) or AstralPowerDeficit() > 7 and target.TimeToDie() > 4 and target.Refreshable(moonfire_debuff) and Spell(moonfire)
 {
  #force_of_nature
  Spell(force_of_nature_caster)
 }
}

AddFunction BalanceAoeShortCdPostConditions
{
 { target.DebuffRemaining(stellar_empowerment_debuff) < GCD() * 2 or AstralPowerDeficit() < 22.5 or BuffRemaining(celestial_alignment_buff) > 8 or BuffRemaining(incarnation_chosen_of_elune_buff) > 8 or target.TimeToDie() < 8 } and Spell(starfall) or target.TimeToDie() > 10 and target.Refreshable(stellar_flare_debuff) and Spell(stellar_flare) or AstralPowerDeficit() > 7 and target.TimeToDie() > 4 and target.Refreshable(sunfire_debuff) and Spell(sunfire) or AstralPowerDeficit() > 7 and target.TimeToDie() > 4 and target.Refreshable(moonfire_debuff) and Spell(moonfire) or BuffPresent(oneths_intuition_buff) and { not BuffPresent(astral_acceleration_buff) or BuffRemaining(astral_acceleration_buff) > 5 or AstralPowerDeficit() < 44 } and Spell(starsurge_moonkin) or AstralPowerDeficit() > 14 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } or Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or AstralPowerDeficit() > 24 and SpellKnown(half_moon) and Spell(half_moon) or AstralPowerDeficit() > 44 and SpellKnown(full_moon) and Spell(full_moon) or BuffPresent(warrior_of_elune_buff) and Spell(lunar_strike_balance) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and Spell(lunar_strike_balance) or HasEquippedItem(lady_and_the_child) and Talent(soul_of_the_forest_talent) and { Enemies(tagged=1) < 3 or Enemies(tagged=1) < 4 and not ArmorSetBonus(T20 4) or HasEquippedItem(radiant_moonlight) and Enemies(tagged=1) < 7 and not ArmorSetBonus(T20 4) } and 100 / { 100 + SpellHaste() } > 0.4 and not BuffPresent(celestial_alignment_buff) and not BuffPresent(incarnation_chosen_of_elune_buff) and Spell(moonfire) or { Enemies(tagged=1) >= 4 or 100 / { 100 + SpellHaste() } < 0.45 } and Spell(lunar_strike_balance) or Spell(solar_wrath)
}

AddFunction BalanceAoeCdActions
{
}

AddFunction BalanceAoeCdPostConditions
{
 { target.DebuffRemaining(stellar_empowerment_debuff) < GCD() * 2 or AstralPowerDeficit() < 22.5 or BuffRemaining(celestial_alignment_buff) > 8 or BuffRemaining(incarnation_chosen_of_elune_buff) > 8 or target.TimeToDie() < 8 } and Spell(starfall) or target.TimeToDie() > 10 and target.Refreshable(stellar_flare_debuff) and Spell(stellar_flare) or AstralPowerDeficit() > 7 and target.TimeToDie() > 4 and target.Refreshable(sunfire_debuff) and Spell(sunfire) or AstralPowerDeficit() > 7 and target.TimeToDie() > 4 and target.Refreshable(moonfire_debuff) and Spell(moonfire) or Spell(force_of_nature_caster) or BuffPresent(oneths_intuition_buff) and { not BuffPresent(astral_acceleration_buff) or BuffRemaining(astral_acceleration_buff) > 5 or AstralPowerDeficit() < 44 } and Spell(starsurge_moonkin) or AstralPowerDeficit() > 14 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } or Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or AstralPowerDeficit() > 24 and SpellKnown(half_moon) and Spell(half_moon) or AstralPowerDeficit() > 44 and SpellKnown(full_moon) and Spell(full_moon) or BuffPresent(warrior_of_elune_buff) and Spell(lunar_strike_balance) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and Spell(lunar_strike_balance) or HasEquippedItem(lady_and_the_child) and Talent(soul_of_the_forest_talent) and { Enemies(tagged=1) < 3 or Enemies(tagged=1) < 4 and not ArmorSetBonus(T20 4) or HasEquippedItem(radiant_moonlight) and Enemies(tagged=1) < 7 and not ArmorSetBonus(T20 4) } and 100 / { 100 + SpellHaste() } > 0.4 and not BuffPresent(celestial_alignment_buff) and not BuffPresent(incarnation_chosen_of_elune_buff) and Spell(moonfire) or { Enemies(tagged=1) >= 4 or 100 / { 100 + SpellHaste() } < 0.45 } and Spell(lunar_strike_balance) or Spell(solar_wrath)
}

### actions.default

AddFunction BalanceDefaultMainActions
{
 #blessing_of_elune,if=active_enemies<=2&talent.blessing_of_the_ancients.enabled&buff.blessing_of_elune.down
 if Enemies(tagged=1) <= 2 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_elune_buff) Spell(blessing_of_elune)
 #blessing_of_elune,if=active_enemies>=3&talent.blessing_of_the_ancients.enabled&buff.blessing_of_anshe.down
 if Enemies(tagged=1) >= 3 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_anshe_buff) Spell(blessing_of_elune)
 #call_action_list,name=fury_of_elune,if=talent.fury_of_elune.enabled&cooldown.fury_of_elune.remains<target.time_to_die
 if Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() BalanceFuryOfEluneMainActions()

 unless Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() and BalanceFuryOfEluneMainPostConditions()
 {
  #call_action_list,name=ed,if=equipped.the_emerald_dreamcatcher&active_enemies<=1
  if HasEquippedItem(the_emerald_dreamcatcher) and Enemies(tagged=1) <= 1 BalanceEdMainActions()

  unless HasEquippedItem(the_emerald_dreamcatcher) and Enemies(tagged=1) <= 1 and BalanceEdMainPostConditions()
  {
   #call_action_list,name=AoE,if=(spell_targets.starfall>=2&talent.stellar_drift.enabled)|spell_targets.starfall>=3
   if Enemies(tagged=1) >= 2 and Talent(stellar_drift_talent) or Enemies(tagged=1) >= 3 BalanceAoeMainActions()

   unless { Enemies(tagged=1) >= 2 and Talent(stellar_drift_talent) or Enemies(tagged=1) >= 3 } and BalanceAoeMainPostConditions()
   {
    #call_action_list,name=single_target
    BalanceSingleTargetMainActions()
   }
  }
 }
}

AddFunction BalanceDefaultMainPostConditions
{
 Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() and BalanceFuryOfEluneMainPostConditions() or HasEquippedItem(the_emerald_dreamcatcher) and Enemies(tagged=1) <= 1 and BalanceEdMainPostConditions() or { Enemies(tagged=1) >= 2 and Talent(stellar_drift_talent) or Enemies(tagged=1) >= 3 } and BalanceAoeMainPostConditions() or BalanceSingleTargetMainPostConditions()
}

AddFunction BalanceDefaultShortCdActions
{
 unless Enemies(tagged=1) <= 2 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_elune_buff) and Spell(blessing_of_elune) or Enemies(tagged=1) >= 3 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_anshe_buff) and Spell(blessing_of_elune)
 {
  #call_action_list,name=fury_of_elune,if=talent.fury_of_elune.enabled&cooldown.fury_of_elune.remains<target.time_to_die
  if Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() BalanceFuryOfEluneShortCdActions()

  unless Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() and BalanceFuryOfEluneShortCdPostConditions()
  {
   #call_action_list,name=ed,if=equipped.the_emerald_dreamcatcher&active_enemies<=1
   if HasEquippedItem(the_emerald_dreamcatcher) and Enemies(tagged=1) <= 1 BalanceEdShortCdActions()

   unless HasEquippedItem(the_emerald_dreamcatcher) and Enemies(tagged=1) <= 1 and BalanceEdShortCdPostConditions()
   {
    #astral_communion,if=astral_power.deficit>=79
    if AstralPowerDeficit() >= 79 Spell(astral_communion)
    #warrior_of_elune
    Spell(warrior_of_elune)
    #call_action_list,name=AoE,if=(spell_targets.starfall>=2&talent.stellar_drift.enabled)|spell_targets.starfall>=3
    if Enemies(tagged=1) >= 2 and Talent(stellar_drift_talent) or Enemies(tagged=1) >= 3 BalanceAoeShortCdActions()

    unless { Enemies(tagged=1) >= 2 and Talent(stellar_drift_talent) or Enemies(tagged=1) >= 3 } and BalanceAoeShortCdPostConditions()
    {
     #call_action_list,name=single_target
     BalanceSingleTargetShortCdActions()
    }
   }
  }
 }
}

AddFunction BalanceDefaultShortCdPostConditions
{
 Enemies(tagged=1) <= 2 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_elune_buff) and Spell(blessing_of_elune) or Enemies(tagged=1) >= 3 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_anshe_buff) and Spell(blessing_of_elune) or Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() and BalanceFuryOfEluneShortCdPostConditions() or HasEquippedItem(the_emerald_dreamcatcher) and Enemies(tagged=1) <= 1 and BalanceEdShortCdPostConditions() or { Enemies(tagged=1) >= 2 and Talent(stellar_drift_talent) or Enemies(tagged=1) >= 3 } and BalanceAoeShortCdPostConditions() or BalanceSingleTargetShortCdPostConditions()
}

AddFunction BalanceDefaultCdActions
{
 #potion,name=potion_of_prolonged_power,if=buff.celestial_alignment.up|buff.incarnation.up
 # if { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(potion_of_prolonged_power_potion usable=1)

 unless Enemies(tagged=1) <= 2 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_elune_buff) and Spell(blessing_of_elune) or Enemies(tagged=1) >= 3 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_anshe_buff) and Spell(blessing_of_elune)
 {
  #blood_fury,if=buff.celestial_alignment.up|buff.incarnation.up
  if BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) Spell(blood_fury_apsp)
  #berserking,if=buff.celestial_alignment.up|buff.incarnation.up
  if BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) Spell(berserking)
  #arcane_torrent,if=buff.celestial_alignment.up|buff.incarnation.up
  if BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) Spell(arcane_torrent_energy)
  #use_items
  # BalanceUseItemActions()
  #call_action_list,name=fury_of_elune,if=talent.fury_of_elune.enabled&cooldown.fury_of_elune.remains<target.time_to_die
  if Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() BalanceFuryOfEluneCdActions()

  unless Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() and BalanceFuryOfEluneCdPostConditions()
  {
   #call_action_list,name=ed,if=equipped.the_emerald_dreamcatcher&active_enemies<=1
   if HasEquippedItem(the_emerald_dreamcatcher) and Enemies(tagged=1) <= 1 BalanceEdCdActions()

   unless HasEquippedItem(the_emerald_dreamcatcher) and Enemies(tagged=1) <= 1 and BalanceEdCdPostConditions() or AstralPowerDeficit() >= 79 and Spell(astral_communion)
   {
    #incarnation,if=astral_power>=40
    if AstralPower() >= 40 Spell(incarnation_chosen_of_elune)
    #celestial_alignment,if=astral_power>=40
    if AstralPower() >= 40 Spell(celestial_alignment)
    #call_action_list,name=AoE,if=(spell_targets.starfall>=2&talent.stellar_drift.enabled)|spell_targets.starfall>=3
    if Enemies(tagged=1) >= 2 and Talent(stellar_drift_talent) or Enemies(tagged=1) >= 3 BalanceAoeCdActions()

    unless { Enemies(tagged=1) >= 2 and Talent(stellar_drift_talent) or Enemies(tagged=1) >= 3 } and BalanceAoeCdPostConditions()
    {
     #call_action_list,name=single_target
     BalanceSingleTargetCdActions()
    }
   }
  }
 }
}

AddFunction BalanceDefaultCdPostConditions
{
 Enemies(tagged=1) <= 2 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_elune_buff) and Spell(blessing_of_elune) or Enemies(tagged=1) >= 3 and Talent(blessing_of_the_ancients_talent) and BuffExpires(blessing_of_anshe_buff) and Spell(blessing_of_elune) or Talent(fury_of_elune_talent) and SpellCooldown(fury_of_elune) < target.TimeToDie() and BalanceFuryOfEluneCdPostConditions() or HasEquippedItem(the_emerald_dreamcatcher) and Enemies(tagged=1) <= 1 and BalanceEdCdPostConditions() or AstralPowerDeficit() >= 79 and Spell(astral_communion) or { Enemies(tagged=1) >= 2 and Talent(stellar_drift_talent) or Enemies(tagged=1) >= 3 } and BalanceAoeCdPostConditions() or BalanceSingleTargetCdPostConditions()
}

### actions.ed

AddFunction BalanceEdMainActions
{
 #starsurge,if=(gcd.max*astral_power%26)>target.time_to_die
 if GCD() * AstralPower() / 26 > target.TimeToDie() Spell(starsurge_moonkin)
 #stellar_flare,cycle_targets=1,max_cycle_targets=4,if=active_enemies<4&remains<7.2
 if DebuffCountOnAny(stellar_flare_debuff) < Enemies(tagged=1) and DebuffCountOnAny(stellar_flare_debuff) <= 4 and Enemies(tagged=1) < 4 and target.DebuffRemaining(stellar_flare_debuff) < 7.2 Spell(stellar_flare)
 #moonfire,if=((talent.natures_balance.enabled&remains<3)|(remains<6.6&!talent.natures_balance.enabled))&(buff.the_emerald_dreamcatcher.remains>gcd.max|!buff.the_emerald_dreamcatcher.up)
 if { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 and not Talent(natures_balance_talent) } and { BuffRemaining(the_emerald_dreamcatcher_buff) > GCD() or not BuffPresent(the_emerald_dreamcatcher_buff) } Spell(moonfire)
 #sunfire,if=((talent.natures_balance.enabled&remains<3)|(remains<5.4&!talent.natures_balance.enabled))&(buff.the_emerald_dreamcatcher.remains>gcd.max|!buff.the_emerald_dreamcatcher.up)
 if { Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 and not Talent(natures_balance_talent) } and { BuffRemaining(the_emerald_dreamcatcher_buff) > GCD() or not BuffPresent(the_emerald_dreamcatcher_buff) } Spell(sunfire)
 #starfall,if=buff.oneths_overconfidence.react&buff.the_emerald_dreamcatcher.remains>execute_time
 if BuffPresent(oneths_overconfidence_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(starfall) Spell(starfall)
 #new_moon,if=astral_power.deficit>=10&buff.the_emerald_dreamcatcher.remains>execute_time&astral_power>=16
 if AstralPowerDeficit() >= 10 and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(new_moon) and AstralPower() >= 16 and not SpellKnown(half_moon) and not SpellKnown(full_moon) Spell(new_moon)
 #half_moon,if=astral_power.deficit>=20&buff.the_emerald_dreamcatcher.remains>execute_time&astral_power>=6
 if AstralPowerDeficit() >= 20 and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(half_moon) and AstralPower() >= 6 and SpellKnown(half_moon) Spell(half_moon)
 #full_moon,if=astral_power.deficit>=40&buff.the_emerald_dreamcatcher.remains>execute_time
 if AstralPowerDeficit() >= 40 and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(full_moon) and SpellKnown(full_moon) Spell(full_moon)
 #lunar_strike,if=(buff.lunar_empowerment.up&buff.the_emerald_dreamcatcher.remains>execute_time&(!(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=15|(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=22.5))&spell_haste<0.4
 if BuffPresent(lunar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(lunar_strike_balance) and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 15 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 22.5 } and 100 / { 100 + SpellHaste() } < 0.4 Spell(lunar_strike_balance)
 #solar_wrath,if=buff.solar_empowerment.stack>1&buff.the_emerald_dreamcatcher.remains>2*execute_time&astral_power>=6&(dot.moonfire.remains>5|(dot.sunfire.remains<5.4&dot.moonfire.remains>6.6))&(!(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=10|(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=15)
 if BuffStacks(solar_empowerment_buff) > 1 and BuffRemaining(the_emerald_dreamcatcher_buff) > 2 * ExecuteTime(solar_wrath) and AstralPower() >= 6 and { target.DebuffRemaining(moonfire_debuff) > 5 or target.DebuffRemaining(sunfire_debuff) < 5.4 and target.DebuffRemaining(moonfire_debuff) > 6.6 } and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 10 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 15 } Spell(solar_wrath)
 #lunar_strike,if=buff.lunar_empowerment.up&buff.the_emerald_dreamcatcher.remains>execute_time&astral_power>=11&(!(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=15|(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=22.5)
 if BuffPresent(lunar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(lunar_strike_balance) and AstralPower() >= 11 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 15 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 22.5 } Spell(lunar_strike_balance)
 #solar_wrath,if=buff.solar_empowerment.up&buff.the_emerald_dreamcatcher.remains>execute_time&astral_power>=16&(!(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=10|(buff.celestial_alignment.up|buff.incarnation.up)&astral_power.deficit>=15)
 if BuffPresent(solar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(solar_wrath) and AstralPower() >= 16 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 10 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 15 } Spell(solar_wrath)
 #starsurge,if=(buff.the_emerald_dreamcatcher.up&buff.the_emerald_dreamcatcher.remains<gcd.max)|astral_power>85|((buff.celestial_alignment.up|buff.incarnation.up)&astral_power>30)
 if BuffPresent(the_emerald_dreamcatcher_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) < GCD() or AstralPower() > 85 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPower() > 30 Spell(starsurge_moonkin)
 #starfall,if=buff.oneths_overconfidence.up
 if BuffPresent(oneths_overconfidence_buff) Spell(starfall)
 #new_moon,if=astral_power.deficit>=10
 if AstralPowerDeficit() >= 10 and not SpellKnown(half_moon) and not SpellKnown(full_moon) Spell(new_moon)
 #half_moon,if=astral_power.deficit>=20
 if AstralPowerDeficit() >= 20 and SpellKnown(half_moon) Spell(half_moon)
 #full_moon,if=astral_power.deficit>=40
 if AstralPowerDeficit() >= 40 and SpellKnown(full_moon) Spell(full_moon)
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

 unless GCD() * AstralPower() / 26 > target.TimeToDie() and Spell(starsurge_moonkin) or DebuffCountOnAny(stellar_flare_debuff) < Enemies(tagged=1) and DebuffCountOnAny(stellar_flare_debuff) <= 4 and Enemies(tagged=1) < 4 and target.DebuffRemaining(stellar_flare_debuff) < 7.2 and Spell(stellar_flare) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 and not Talent(natures_balance_talent) } and { BuffRemaining(the_emerald_dreamcatcher_buff) > GCD() or not BuffPresent(the_emerald_dreamcatcher_buff) } and Spell(moonfire) or { Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 and not Talent(natures_balance_talent) } and { BuffRemaining(the_emerald_dreamcatcher_buff) > GCD() or not BuffPresent(the_emerald_dreamcatcher_buff) } and Spell(sunfire)
 {
  #force_of_nature,if=buff.the_emerald_dreamcatcher.remains>execute_time
  if BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(force_of_nature_caster) Spell(force_of_nature_caster)
 }
}

AddFunction BalanceEdShortCdPostConditions
{
 GCD() * AstralPower() / 26 > target.TimeToDie() and Spell(starsurge_moonkin) or DebuffCountOnAny(stellar_flare_debuff) < Enemies(tagged=1) and DebuffCountOnAny(stellar_flare_debuff) <= 4 and Enemies(tagged=1) < 4 and target.DebuffRemaining(stellar_flare_debuff) < 7.2 and Spell(stellar_flare) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 and not Talent(natures_balance_talent) } and { BuffRemaining(the_emerald_dreamcatcher_buff) > GCD() or not BuffPresent(the_emerald_dreamcatcher_buff) } and Spell(moonfire) or { Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 and not Talent(natures_balance_talent) } and { BuffRemaining(the_emerald_dreamcatcher_buff) > GCD() or not BuffPresent(the_emerald_dreamcatcher_buff) } and Spell(sunfire) or BuffPresent(oneths_overconfidence_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(starfall) and Spell(starfall) or AstralPowerDeficit() >= 10 and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(new_moon) and AstralPower() >= 16 and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or AstralPowerDeficit() >= 20 and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(half_moon) and AstralPower() >= 6 and SpellKnown(half_moon) and Spell(half_moon) or AstralPowerDeficit() >= 40 and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(full_moon) and SpellKnown(full_moon) and Spell(full_moon) or BuffPresent(lunar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(lunar_strike_balance) and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 15 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 22.5 } and 100 / { 100 + SpellHaste() } < 0.4 and Spell(lunar_strike_balance) or BuffStacks(solar_empowerment_buff) > 1 and BuffRemaining(the_emerald_dreamcatcher_buff) > 2 * ExecuteTime(solar_wrath) and AstralPower() >= 6 and { target.DebuffRemaining(moonfire_debuff) > 5 or target.DebuffRemaining(sunfire_debuff) < 5.4 and target.DebuffRemaining(moonfire_debuff) > 6.6 } and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 10 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 15 } and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(lunar_strike_balance) and AstralPower() >= 11 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 15 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 22.5 } and Spell(lunar_strike_balance) or BuffPresent(solar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(solar_wrath) and AstralPower() >= 16 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 10 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 15 } and Spell(solar_wrath) or { BuffPresent(the_emerald_dreamcatcher_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) < GCD() or AstralPower() > 85 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPower() > 30 } and Spell(starsurge_moonkin) or BuffPresent(oneths_overconfidence_buff) and Spell(starfall) or AstralPowerDeficit() >= 10 and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or AstralPowerDeficit() >= 20 and SpellKnown(half_moon) and Spell(half_moon) or AstralPowerDeficit() >= 40 and SpellKnown(full_moon) and Spell(full_moon) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and Spell(lunar_strike_balance) or Spell(solar_wrath)
}

AddFunction BalanceEdCdActions
{
 unless AstralPowerDeficit() >= 75 and BuffPresent(the_emerald_dreamcatcher_buff) and Spell(astral_communion)
 {
  #incarnation,if=astral_power>=60|buff.bloodlust.up
  if AstralPower() >= 60 or BuffPresent(burst_haste_buff any=1) Spell(incarnation_chosen_of_elune)
  #celestial_alignment,if=astral_power>=60&!buff.the_emerald_dreamcatcher.up
  if AstralPower() >= 60 and not BuffPresent(the_emerald_dreamcatcher_buff) Spell(celestial_alignment)
 }
}

AddFunction BalanceEdCdPostConditions
{
 AstralPowerDeficit() >= 75 and BuffPresent(the_emerald_dreamcatcher_buff) and Spell(astral_communion) or GCD() * AstralPower() / 26 > target.TimeToDie() and Spell(starsurge_moonkin) or DebuffCountOnAny(stellar_flare_debuff) < Enemies(tagged=1) and DebuffCountOnAny(stellar_flare_debuff) <= 4 and Enemies(tagged=1) < 4 and target.DebuffRemaining(stellar_flare_debuff) < 7.2 and Spell(stellar_flare) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 and not Talent(natures_balance_talent) } and { BuffRemaining(the_emerald_dreamcatcher_buff) > GCD() or not BuffPresent(the_emerald_dreamcatcher_buff) } and Spell(moonfire) or { Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 and not Talent(natures_balance_talent) } and { BuffRemaining(the_emerald_dreamcatcher_buff) > GCD() or not BuffPresent(the_emerald_dreamcatcher_buff) } and Spell(sunfire) or BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(force_of_nature_caster) and Spell(force_of_nature_caster) or BuffPresent(oneths_overconfidence_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(starfall) and Spell(starfall) or AstralPowerDeficit() >= 10 and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(new_moon) and AstralPower() >= 16 and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or AstralPowerDeficit() >= 20 and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(half_moon) and AstralPower() >= 6 and SpellKnown(half_moon) and Spell(half_moon) or AstralPowerDeficit() >= 40 and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(full_moon) and SpellKnown(full_moon) and Spell(full_moon) or BuffPresent(lunar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(lunar_strike_balance) and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 15 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 22.5 } and 100 / { 100 + SpellHaste() } < 0.4 and Spell(lunar_strike_balance) or BuffStacks(solar_empowerment_buff) > 1 and BuffRemaining(the_emerald_dreamcatcher_buff) > 2 * ExecuteTime(solar_wrath) and AstralPower() >= 6 and { target.DebuffRemaining(moonfire_debuff) > 5 or target.DebuffRemaining(sunfire_debuff) < 5.4 and target.DebuffRemaining(moonfire_debuff) > 6.6 } and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 10 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 15 } and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(lunar_strike_balance) and AstralPower() >= 11 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 15 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 22.5 } and Spell(lunar_strike_balance) or BuffPresent(solar_empowerment_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) > ExecuteTime(solar_wrath) and AstralPower() >= 16 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 10 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPowerDeficit() >= 15 } and Spell(solar_wrath) or { BuffPresent(the_emerald_dreamcatcher_buff) and BuffRemaining(the_emerald_dreamcatcher_buff) < GCD() or AstralPower() > 85 or { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } and AstralPower() > 30 } and Spell(starsurge_moonkin) or BuffPresent(oneths_overconfidence_buff) and Spell(starfall) or AstralPowerDeficit() >= 10 and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or AstralPowerDeficit() >= 20 and SpellKnown(half_moon) and Spell(half_moon) or AstralPowerDeficit() >= 40 and SpellKnown(full_moon) and Spell(full_moon) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and Spell(lunar_strike_balance) or Spell(solar_wrath)
}

### actions.fury_of_elune

AddFunction BalanceFuryOfEluneMainActions
{
 #new_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=90))
 if { Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and { BuffPresent(fury_of_elune_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 90 } and not SpellKnown(half_moon) and not SpellKnown(full_moon) Spell(new_moon)
 #half_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=80))
 if { Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 } and { BuffPresent(fury_of_elune_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 80 } and SpellKnown(half_moon) Spell(half_moon)
 #full_moon,if=((charges=2&recharge_time<5)|charges=3)&&(buff.fury_of_elune.up|(cooldown.fury_of_elune.remains>gcd*3&astral_power<=60))
 if { Charges(full_moon) == 2 and SpellChargeCooldown(full_moon) < 5 or Charges(full_moon) == 3 } and { BuffPresent(fury_of_elune_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 60 } and SpellKnown(full_moon) Spell(full_moon)
 #lunar_strike,if=buff.warrior_of_elune.up&(astral_power<=90|(astral_power<=85&buff.incarnation.up))
 if BuffPresent(warrior_of_elune_buff) and { AstralPower() <= 90 or AstralPower() <= 85 and BuffPresent(incarnation_chosen_of_elune_buff) } Spell(lunar_strike_balance)
 #new_moon,if=astral_power<=90&buff.fury_of_elune.up
 if AstralPower() <= 90 and BuffPresent(fury_of_elune_buff) and not SpellKnown(half_moon) and not SpellKnown(full_moon) Spell(new_moon)
 #half_moon,if=astral_power<=80&buff.fury_of_elune.up&astral_power>cast_time*12
 if AstralPower() <= 80 and BuffPresent(fury_of_elune_buff) and AstralPower() > CastTime(half_moon) * 12 and SpellKnown(half_moon) Spell(half_moon)
 #full_moon,if=astral_power<=60&buff.fury_of_elune.up&astral_power>cast_time*12
 if AstralPower() <= 60 and BuffPresent(fury_of_elune_buff) and AstralPower() > CastTime(full_moon) * 12 and SpellKnown(full_moon) Spell(full_moon)
 #moonfire,if=buff.fury_of_elune.down&remains<=6.6
 if BuffExpires(fury_of_elune_buff) and target.DebuffRemaining(moonfire_debuff) <= 6.6 Spell(moonfire)
 #sunfire,if=buff.fury_of_elune.down&remains<5.4
 if BuffExpires(fury_of_elune_buff) and target.DebuffRemaining(sunfire_debuff) < 5.4 Spell(sunfire)
 #stellar_flare,if=remains<7.2&active_enemies=1
 if target.DebuffRemaining(stellar_flare_debuff) < 7.2 and Enemies(tagged=1) == 1 Spell(stellar_flare)
 #starfall,if=(active_enemies>=2&talent.stellar_flare.enabled|active_enemies>=3)&buff.fury_of_elune.down&cooldown.fury_of_elune.remains>10
 if { Enemies(tagged=1) >= 2 and Talent(stellar_flare_talent) or Enemies(tagged=1) >= 3 } and BuffExpires(fury_of_elune_buff) and SpellCooldown(fury_of_elune) > 10 Spell(starfall)
 #starsurge,if=active_enemies<=2&buff.fury_of_elune.down&cooldown.fury_of_elune.remains>7
 if Enemies(tagged=1) <= 2 and BuffExpires(fury_of_elune_buff) and SpellCooldown(fury_of_elune) > 7 Spell(starsurge_moonkin)
 #starsurge,if=buff.fury_of_elune.down&((astral_power>=92&cooldown.fury_of_elune.remains>gcd*3)|(cooldown.warrior_of_elune.remains<=5&cooldown.fury_of_elune.remains>=35&buff.lunar_empowerment.stack<2))
 if BuffExpires(fury_of_elune_buff) and { AstralPower() >= 92 and SpellCooldown(fury_of_elune) > GCD() * 3 or SpellCooldown(warrior_of_elune) <= 5 and SpellCooldown(fury_of_elune) >= 35 and BuffStacks(lunar_empowerment_buff) < 2 } Spell(starsurge_moonkin)
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
 #force_of_nature,if=!buff.fury_of_elune.up
 if not BuffPresent(fury_of_elune_buff) Spell(force_of_nature_caster)
 #fury_of_elune,if=astral_power>=95
 if AstralPower() >= 95 Spell(fury_of_elune)

 unless { Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and { BuffPresent(fury_of_elune_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 90 } and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or { Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 } and { BuffPresent(fury_of_elune_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 80 } and SpellKnown(half_moon) and Spell(half_moon) or { Charges(full_moon) == 2 and SpellChargeCooldown(full_moon) < 5 or Charges(full_moon) == 3 } and { BuffPresent(fury_of_elune_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 60 } and SpellKnown(full_moon) and Spell(full_moon)
 {
  #astral_communion,if=buff.fury_of_elune.up&astral_power<=25
  if BuffPresent(fury_of_elune_buff) and AstralPower() <= 25 Spell(astral_communion)
  #warrior_of_elune,if=buff.fury_of_elune.up|(cooldown.fury_of_elune.remains>=35&buff.lunar_empowerment.up)
  if BuffPresent(fury_of_elune_buff) or SpellCooldown(fury_of_elune) >= 35 and BuffPresent(lunar_empowerment_buff) Spell(warrior_of_elune)
 }
}

AddFunction BalanceFuryOfEluneShortCdPostConditions
{
 { Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and { BuffPresent(fury_of_elune_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 90 } and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or { Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 } and { BuffPresent(fury_of_elune_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 80 } and SpellKnown(half_moon) and Spell(half_moon) or { Charges(full_moon) == 2 and SpellChargeCooldown(full_moon) < 5 or Charges(full_moon) == 3 } and { BuffPresent(fury_of_elune_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 60 } and SpellKnown(full_moon) and Spell(full_moon) or BuffPresent(warrior_of_elune_buff) and { AstralPower() <= 90 or AstralPower() <= 85 and BuffPresent(incarnation_chosen_of_elune_buff) } and Spell(lunar_strike_balance) or AstralPower() <= 90 and BuffPresent(fury_of_elune_buff) and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or AstralPower() <= 80 and BuffPresent(fury_of_elune_buff) and AstralPower() > CastTime(half_moon) * 12 and SpellKnown(half_moon) and Spell(half_moon) or AstralPower() <= 60 and BuffPresent(fury_of_elune_buff) and AstralPower() > CastTime(full_moon) * 12 and SpellKnown(full_moon) and Spell(full_moon) or BuffExpires(fury_of_elune_buff) and target.DebuffRemaining(moonfire_debuff) <= 6.6 and Spell(moonfire) or BuffExpires(fury_of_elune_buff) and target.DebuffRemaining(sunfire_debuff) < 5.4 and Spell(sunfire) or target.DebuffRemaining(stellar_flare_debuff) < 7.2 and Enemies(tagged=1) == 1 and Spell(stellar_flare) or { Enemies(tagged=1) >= 2 and Talent(stellar_flare_talent) or Enemies(tagged=1) >= 3 } and BuffExpires(fury_of_elune_buff) and SpellCooldown(fury_of_elune) > 10 and Spell(starfall) or Enemies(tagged=1) <= 2 and BuffExpires(fury_of_elune_buff) and SpellCooldown(fury_of_elune) > 7 and Spell(starsurge_moonkin) or BuffExpires(fury_of_elune_buff) and { AstralPower() >= 92 and SpellCooldown(fury_of_elune) > GCD() * 3 or SpellCooldown(warrior_of_elune) <= 5 and SpellCooldown(fury_of_elune) >= 35 and BuffStacks(lunar_empowerment_buff) < 2 } and Spell(starsurge_moonkin) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or { BuffStacks(lunar_empowerment_buff) == 3 or BuffRemaining(lunar_empowerment_buff) < 5 and BuffPresent(lunar_empowerment_buff) or Enemies(tagged=1) >= 2 } and Spell(lunar_strike_balance) or Spell(solar_wrath)
}

AddFunction BalanceFuryOfEluneCdActions
{
 #incarnation,if=astral_power>=95&cooldown.fury_of_elune.remains<=gcd
 if AstralPower() >= 95 and SpellCooldown(fury_of_elune) <= GCD() Spell(incarnation_chosen_of_elune)
}

AddFunction BalanceFuryOfEluneCdPostConditions
{
 not BuffPresent(fury_of_elune_buff) and Spell(force_of_nature_caster) or AstralPower() >= 95 and Spell(fury_of_elune) or { Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and { BuffPresent(fury_of_elune_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 90 } and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or { Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 } and { BuffPresent(fury_of_elune_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 80 } and SpellKnown(half_moon) and Spell(half_moon) or { Charges(full_moon) == 2 and SpellChargeCooldown(full_moon) < 5 or Charges(full_moon) == 3 } and { BuffPresent(fury_of_elune_buff) or SpellCooldown(fury_of_elune) > GCD() * 3 and AstralPower() <= 60 } and SpellKnown(full_moon) and Spell(full_moon) or BuffPresent(fury_of_elune_buff) and AstralPower() <= 25 and Spell(astral_communion) or BuffPresent(warrior_of_elune_buff) and { AstralPower() <= 90 or AstralPower() <= 85 and BuffPresent(incarnation_chosen_of_elune_buff) } and Spell(lunar_strike_balance) or AstralPower() <= 90 and BuffPresent(fury_of_elune_buff) and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or AstralPower() <= 80 and BuffPresent(fury_of_elune_buff) and AstralPower() > CastTime(half_moon) * 12 and SpellKnown(half_moon) and Spell(half_moon) or AstralPower() <= 60 and BuffPresent(fury_of_elune_buff) and AstralPower() > CastTime(full_moon) * 12 and SpellKnown(full_moon) and Spell(full_moon) or BuffExpires(fury_of_elune_buff) and target.DebuffRemaining(moonfire_debuff) <= 6.6 and Spell(moonfire) or BuffExpires(fury_of_elune_buff) and target.DebuffRemaining(sunfire_debuff) < 5.4 and Spell(sunfire) or target.DebuffRemaining(stellar_flare_debuff) < 7.2 and Enemies(tagged=1) == 1 and Spell(stellar_flare) or { Enemies(tagged=1) >= 2 and Talent(stellar_flare_talent) or Enemies(tagged=1) >= 3 } and BuffExpires(fury_of_elune_buff) and SpellCooldown(fury_of_elune) > 10 and Spell(starfall) or Enemies(tagged=1) <= 2 and BuffExpires(fury_of_elune_buff) and SpellCooldown(fury_of_elune) > 7 and Spell(starsurge_moonkin) or BuffExpires(fury_of_elune_buff) and { AstralPower() >= 92 and SpellCooldown(fury_of_elune) > GCD() * 3 or SpellCooldown(warrior_of_elune) <= 5 and SpellCooldown(fury_of_elune) >= 35 and BuffStacks(lunar_empowerment_buff) < 2 } and Spell(starsurge_moonkin) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or { BuffStacks(lunar_empowerment_buff) == 3 or BuffRemaining(lunar_empowerment_buff) < 5 and BuffPresent(lunar_empowerment_buff) or Enemies(tagged=1) >= 2 } and Spell(lunar_strike_balance) or Spell(solar_wrath)
}

### actions.precombat

AddFunction BalancePrecombatMainActions
{
 #flask
 #food
 #augmentation
 #moonkin_form
 Spell(moonkin_form)
 #blessing_of_elune
 Spell(blessing_of_elune)
 #new_moon
 if not SpellKnown(half_moon) and not SpellKnown(full_moon) Spell(new_moon)
}

AddFunction BalancePrecombatMainPostConditions
{
}

AddFunction BalancePrecombatShortCdActions
{
}

AddFunction BalancePrecombatShortCdPostConditions
{
 Spell(moonkin_form) or Spell(blessing_of_elune) or not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon)
}

AddFunction BalancePrecombatCdActions
{
 unless Spell(moonkin_form) or Spell(blessing_of_elune)
 {
  #snapshot_stats
  #potion
  # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(potion_of_prolonged_power_potion usable=1)
 }
}

AddFunction BalancePrecombatCdPostConditions
{
 Spell(moonkin_form) or Spell(blessing_of_elune) or not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon)
}

### actions.single_target

AddFunction BalanceSingleTargetMainActions
{
 #stellar_flare,target_if=refreshable,if=target.time_to_die>10
 if target.TimeToDie() > 10 and target.Refreshable(stellar_flare_debuff) Spell(stellar_flare)
 #moonfire,target_if=refreshable,if=((talent.natures_balance.enabled&remains<3)|remains<6.6)&astral_power.deficit>7&target.time_to_die>8
 if { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 } and AstralPowerDeficit() > 7 and target.TimeToDie() > 8 and target.Refreshable(moonfire_debuff) Spell(moonfire)
 #sunfire,target_if=refreshable,if=((talent.natures_balance.enabled&remains<3)|remains<5.4)&astral_power.deficit>7&target.time_to_die>8
 if { Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 } and AstralPowerDeficit() > 7 and target.TimeToDie() > 8 and target.Refreshable(sunfire_debuff) Spell(sunfire)
 #starfall,if=buff.oneths_overconfidence.react&(!buff.astral_acceleration.up|buff.astral_acceleration.remains>5|astral_power.deficit<44)
 if BuffPresent(oneths_overconfidence_buff) and { not BuffPresent(astral_acceleration_buff) or BuffRemaining(astral_acceleration_buff) > 5 or AstralPowerDeficit() < 44 } Spell(starfall)
 #solar_wrath,if=buff.solar_empowerment.stack=3
 if BuffStacks(solar_empowerment_buff) == 3 Spell(solar_wrath)
 #lunar_strike,if=buff.lunar_empowerment.stack=3
 if BuffStacks(lunar_empowerment_buff) == 3 Spell(lunar_strike_balance)
 #starsurge,if=astral_power.deficit<44|(buff.celestial_alignment.up|buff.incarnation.up|buff.astral_acceleration.remains>5|(set_bonus.tier21_4pc&!buff.solar_solstice.up))|(gcd.max*(astral_power%40))>target.time_to_die
 if AstralPowerDeficit() < 44 or BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) or BuffRemaining(astral_acceleration_buff) > 5 or ArmorSetBonus(T21 4) and not BuffPresent(solar_solstice_buff) or GCD() * { AstralPower() / 40 } > target.TimeToDie() Spell(starsurge_moonkin)
 #new_moon,if=astral_power.deficit>14&(!(buff.celestial_alignment.up|buff.incarnation.up)|(charges=2&recharge_time<5)|charges=3)
 if AstralPowerDeficit() > 14 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } or Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and not SpellKnown(half_moon) and not SpellKnown(full_moon) Spell(new_moon)
 #half_moon,if=astral_power.deficit>24&(!(buff.celestial_alignment.up|buff.incarnation.up)|(charges=2&recharge_time<5)|charges=3)
 if AstralPowerDeficit() > 24 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } or Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 } and SpellKnown(half_moon) Spell(half_moon)
 #full_moon,if=astral_power.deficit>44
 if AstralPowerDeficit() > 44 and SpellKnown(full_moon) Spell(full_moon)
 #lunar_strike,if=buff.warrior_of_elune.up&buff.lunar_empowerment.up
 if BuffPresent(warrior_of_elune_buff) and BuffPresent(lunar_empowerment_buff) Spell(lunar_strike_balance)
 #solar_wrath,if=buff.solar_empowerment.up
 if BuffPresent(solar_empowerment_buff) Spell(solar_wrath)
 #lunar_strike,if=buff.lunar_empowerment.up
 if BuffPresent(lunar_empowerment_buff) Spell(lunar_strike_balance)
 #solar_wrath
 Spell(solar_wrath)
}

AddFunction BalanceSingleTargetMainPostConditions
{
}

AddFunction BalanceSingleTargetShortCdActions
{
 #force_of_nature
 Spell(force_of_nature_caster)
}

AddFunction BalanceSingleTargetShortCdPostConditions
{
 target.TimeToDie() > 10 and target.Refreshable(stellar_flare_debuff) and Spell(stellar_flare) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 } and AstralPowerDeficit() > 7 and target.TimeToDie() > 8 and target.Refreshable(moonfire_debuff) and Spell(moonfire) or { Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 } and AstralPowerDeficit() > 7 and target.TimeToDie() > 8 and target.Refreshable(sunfire_debuff) and Spell(sunfire) or BuffPresent(oneths_overconfidence_buff) and { not BuffPresent(astral_acceleration_buff) or BuffRemaining(astral_acceleration_buff) > 5 or AstralPowerDeficit() < 44 } and Spell(starfall) or BuffStacks(solar_empowerment_buff) == 3 and Spell(solar_wrath) or BuffStacks(lunar_empowerment_buff) == 3 and Spell(lunar_strike_balance) or { AstralPowerDeficit() < 44 or BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) or BuffRemaining(astral_acceleration_buff) > 5 or ArmorSetBonus(T21 4) and not BuffPresent(solar_solstice_buff) or GCD() * { AstralPower() / 40 } > target.TimeToDie() } and Spell(starsurge_moonkin) or AstralPowerDeficit() > 14 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } or Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or AstralPowerDeficit() > 24 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } or Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 } and SpellKnown(half_moon) and Spell(half_moon) or AstralPowerDeficit() > 44 and SpellKnown(full_moon) and Spell(full_moon) or BuffPresent(warrior_of_elune_buff) and BuffPresent(lunar_empowerment_buff) and Spell(lunar_strike_balance) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and Spell(lunar_strike_balance) or Spell(solar_wrath)
}

AddFunction BalanceSingleTargetCdActions
{
}

AddFunction BalanceSingleTargetCdPostConditions
{
 Spell(force_of_nature_caster) or target.TimeToDie() > 10 and target.Refreshable(stellar_flare_debuff) and Spell(stellar_flare) or { Talent(natures_balance_talent) and target.DebuffRemaining(moonfire_debuff) < 3 or target.DebuffRemaining(moonfire_debuff) < 6.6 } and AstralPowerDeficit() > 7 and target.TimeToDie() > 8 and target.Refreshable(moonfire_debuff) and Spell(moonfire) or { Talent(natures_balance_talent) and target.DebuffRemaining(sunfire_debuff) < 3 or target.DebuffRemaining(sunfire_debuff) < 5.4 } and AstralPowerDeficit() > 7 and target.TimeToDie() > 8 and target.Refreshable(sunfire_debuff) and Spell(sunfire) or BuffPresent(oneths_overconfidence_buff) and { not BuffPresent(astral_acceleration_buff) or BuffRemaining(astral_acceleration_buff) > 5 or AstralPowerDeficit() < 44 } and Spell(starfall) or BuffStacks(solar_empowerment_buff) == 3 and Spell(solar_wrath) or BuffStacks(lunar_empowerment_buff) == 3 and Spell(lunar_strike_balance) or { AstralPowerDeficit() < 44 or BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) or BuffRemaining(astral_acceleration_buff) > 5 or ArmorSetBonus(T21 4) and not BuffPresent(solar_solstice_buff) or GCD() * { AstralPower() / 40 } > target.TimeToDie() } and Spell(starsurge_moonkin) or AstralPowerDeficit() > 14 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } or Charges(new_moon) == 2 and SpellChargeCooldown(new_moon) < 5 or Charges(new_moon) == 3 } and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or AstralPowerDeficit() > 24 and { not { BuffPresent(celestial_alignment_buff) or BuffPresent(incarnation_chosen_of_elune_buff) } or Charges(half_moon) == 2 and SpellChargeCooldown(half_moon) < 5 or Charges(half_moon) == 3 } and SpellKnown(half_moon) and Spell(half_moon) or AstralPowerDeficit() > 44 and SpellKnown(full_moon) and Spell(full_moon) or BuffPresent(warrior_of_elune_buff) and BuffPresent(lunar_empowerment_buff) and Spell(lunar_strike_balance) or BuffPresent(solar_empowerment_buff) and Spell(solar_wrath) or BuffPresent(lunar_empowerment_buff) and Spell(lunar_strike_balance) or Spell(solar_wrath)
}
]]
	OvaleScripts:RegisterScript("DRUID", "balance", name, desc, code, "script")
end
