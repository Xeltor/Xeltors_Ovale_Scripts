local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_balance"
	local desc = "[Xel][8.1] Druid: Balance"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_druid_spells)

AddIcon specialization=1 help=main
{
	if not mounted() and target.Present() and target.Exists() and not target.IsFriend()
	{
		if InCombat() Spell(moonkin_form)
	}
	
	# Interrupt
	if InCombat() InterruptActions()
	
	if target.InRange(solar_wrath) and HasFullControl() and target.Present() and InCombat()
	{
		# Cooldowns
		if Boss() and { CanMove() > 0 or Speed() == 0 } BalanceDefaultCdActions()
		
		# Short Cooldowns
		if CanMove() > 0 or Speed() == 0 BalanceDefaultShortCdActions()
		
		# Default Actions
		if CanMove() > 0 or Speed() == 0 BalanceDefaultMainActions()
	}
}

AddFunction InterruptActions
{
 if { target.HasManagedInterrupts() and target.MustBeInterrupted() } or { not target.HasManagedInterrupts() and target.IsInterruptible() }
 {
  if target.InRange(solar_beam) and target.IsInterruptible() Spell(solar_beam)
  if target.InRange(mighty_bash) and not target.Classification(worldboss) Spell(mighty_bash)
  if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
  if target.Distance(less 15) and not target.Classification(worldboss) Spell(typhoon)
 }
}

AddFunction sf_safety
{
	MouseOver.DebuffPresent(sunfire_debuff)
}

AddFunction sf_targets
{
 4
}

AddFunction az_ap
{
 AzeriteTraitRank(arcanic_pulsar_trait)
}

AddFunction az_ss
{
 AzeriteTraitRank(streaking_stars_trait)
}

AddFunction BalanceUseItemActions
{
	if Item(Trinket0Slot usable=1) Texture(inv_jewelry_talisman_12)
	if Item(Trinket1Slot usable=1) Texture(inv_jewelry_talisman_12)
}

### actions.precombat

AddFunction BalancePrecombatMainActions
{
 #flask
 #food
 #augmentation
 #variable,name=az_ss,value=azerite.streaking_stars.rank
 #variable,name=az_ap,value=azerite.arcanic_pulsar.rank
 #variable,name=sf_targets,value=4
 #variable,name=sf_targets,op=add,value=1,if=talent.twin_moons.enabled&(azerite.arcanic_pulsar.enabled|talent.starlord.enabled)
 #variable,name=sf_targets,op=sub,value=1,if=!azerite.arcanic_pulsar.enabled&!talent.starlord.enabled&talent.stellar_drift.enabled
 #moonkin_form
 Spell(moonkin_form_balance)
 #solar_wrath
 Spell(solar_wrath_balance)
}

AddFunction BalancePrecombatMainPostConditions
{
}

AddFunction BalancePrecombatShortCdActions
{
}

AddFunction BalancePrecombatShortCdPostConditions
{
 Spell(moonkin_form_balance) or Spell(solar_wrath_balance)
}

AddFunction BalancePrecombatCdActions
{
 unless Spell(moonkin_form_balance)
 {
  #snapshot_stats
  #potion
  # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(rising_death usable=1)
 }
}

AddFunction BalancePrecombatCdPostConditions
{
 Spell(moonkin_form_balance) or Spell(solar_wrath_balance)
}

### actions.default

AddFunction BalanceDefaultMainActions
{
 #cancel_buff,name=starlord,if=buff.starlord.remains<8&!solar_wrath.ap_check
 # if BuffRemaining(starlord_buff) < 8 and not AstralPower() >= AstralPowerCost(solar_wrath) and BuffPresent(starlord_buff) Texture(starlord text=cancel)
 #starfall,if=(buff.starlord.stack<3|buff.starlord.remains>=8)&spell_targets>=variable.sf_targets&(target.time_to_die+1)*spell_targets>cost%2.5
 if { BuffStacks(starlord_buff) < 3 or BuffRemaining(starlord_buff) >= 8 } and Enemies(tagged=1) >= sf_targets() and { target.TimeToDie() + 1 } * Enemies(tagged=1) > PowerCost(starfall) / 2.5 and sf_safety() Spell(starfall)
 #starsurge,if=(talent.starlord.enabled&(buff.starlord.stack<3|buff.starlord.remains>=8&buff.arcanic_pulsar.stack<8)|!talent.starlord.enabled&(buff.arcanic_pulsar.stack<8|buff.ca_inc.up))&spell_targets.starfall<variable.sf_targets&buff.lunar_empowerment.stack+buff.solar_empowerment.stack<4&buff.solar_empowerment.stack<3&buff.lunar_empowerment.stack<3&(!variable.az_ss|!buff.ca_inc.up|!prev.starsurge)|target.time_to_die<=execute_time*astral_power%40|!solar_wrath.ap_check
 if { Talent(starlord_talent) and { BuffStacks(starlord_buff) < 3 or BuffRemaining(starlord_buff) >= 8 and BuffStacks(arcanic_pulsar_buff) < 8 } or not Talent(starlord_talent) and { BuffStacks(arcanic_pulsar_buff) < 8 or DebuffPresent(ca_inc) } } and Enemies(tagged=1) < sf_targets() and BuffStacks(lunar_empowerment_buff) + BuffStacks(solar_empowerment_buff) < 4 and BuffStacks(solar_empowerment_buff) < 3 and BuffStacks(lunar_empowerment_buff) < 3 and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(starsurge_balance) } or target.TimeToDie() <= ExecuteTime(starsurge_balance) * AstralPower() / 40 or not AstralPower() >= AstralPowerCost(solar_wrath) Spell(starsurge_balance)
 #sunfire,target_if=refreshable,if=ap_check&floor(target.time_to_die%(2*spell_haste))*spell_targets>=ceil(floor(2%spell_targets)*1.5)+2*spell_targets&(spell_targets>1+talent.twin_moons.enabled|dot.moonfire.ticking)&(!variable.az_ss|!buff.ca_inc.up|!prev.sunfire)
 if target.Refreshable(sunfire_debuff) and AstralPower() >= AstralPowerCost(sunfire) and target.TimeToDie() / { 2 * { 100 / { 100 + SpellCastSpeedPercent() } } } * Enemies(tagged=1) >= 2 / Enemies(tagged=1) * 1.5 + 2 * Enemies(tagged=1) and { Enemies(tagged=1) > 1 + TalentPoints(twin_moons_talent) or target.DebuffPresent(moonfire_debuff) } and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(sunfire) } Spell(sunfire)
 #moonfire,target_if=refreshable,if=ap_check&floor(target.time_to_die%(2*spell_haste))*spell_targets>=6&(!variable.az_ss|!buff.ca_inc.up|!prev.moonfire)
 if target.Refreshable(moonfire_debuff) and AstralPower() >= AstralPowerCost(moonfire) and target.TimeToDie() / { 2 * { 100 / { 100 + SpellCastSpeedPercent() } } } * Enemies(tagged=1) >= 6 and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(moonfire) } Spell(moonfire)
 #stellar_flare,target_if=refreshable,if=ap_check&floor(target.time_to_die%(2*spell_haste))>=5&(!variable.az_ss|!buff.ca_inc.up|!prev.stellar_flare)
 if target.Refreshable(stellar_flare_debuff) and AstralPower() >= AstralPowerCost(stellar_flare) and target.TimeToDie() / { 2 * { 100 / { 100 + SpellCastSpeedPercent() } } } >= 5 and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(stellar_flare) } Spell(stellar_flare)
 #new_moon,if=ap_check
 if AstralPower() >= AstralPowerCost(new_moon) and not SpellKnown(half_moon) and not SpellKnown(full_moon) Spell(new_moon)
 #half_moon,if=ap_check
 if AstralPower() >= AstralPowerCost(half_moon) and SpellKnown(half_moon) Spell(half_moon)
 #full_moon,if=ap_check
 if AstralPower() >= AstralPowerCost(full_moon) and SpellKnown(full_moon) Spell(full_moon)
 #lunar_strike,if=buff.solar_empowerment.stack<3&(ap_check|buff.lunar_empowerment.stack=3)&((buff.warrior_of_elune.up|buff.lunar_empowerment.up|spell_targets>=2&!buff.solar_empowerment.up)&(!variable.az_ss|!buff.ca_inc.up|(!prev.lunar_strike&!talent.incarnation.enabled|prev.solar_wrath))|variable.az_ss&buff.ca_inc.up&prev.solar_wrath)
 if BuffStacks(solar_empowerment_buff) < 3 and { AstralPower() >= AstralPowerCost(lunar_strike) or BuffStacks(lunar_empowerment_buff) == 3 } and { { BuffPresent(warrior_of_elune_buff) or BuffPresent(lunar_empowerment_buff) or Enemies(tagged=1) >= 2 and not BuffPresent(solar_empowerment_buff) } and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(lunar_strike) and not Talent(incarnation_talent) or PreviousSpell(solar_wrath_balance) } or az_ss() and DebuffPresent(ca_inc) and PreviousSpell(solar_wrath_balance) } Spell(lunar_strike)
 #solar_wrath,if=variable.az_ss<3|!buff.ca_inc.up|!prev.solar_wrath
 if az_ss() < 3 or not DebuffPresent(ca_inc) or not PreviousSpell(solar_wrath_balance) Spell(solar_wrath_balance)
 #sunfire
 Spell(sunfire)
}

AddFunction BalanceDefaultMainPostConditions
{
}

AddFunction BalanceDefaultShortCdActions
{
 #warrior_of_elune
 Spell(warrior_of_elune)
 #fury_of_elune,if=(buff.ca_inc.up|cooldown.ca_inc.remains>30)&solar_wrath.ap_check
 if { DebuffPresent(ca_inc) or SpellCooldown(ca_inc) > 30 } and AstralPower() >= AstralPowerCost(solar_wrath) Spell(fury_of_elune)
 #force_of_nature,if=(buff.ca_inc.up|cooldown.ca_inc.remains>30)&ap_check
 if { DebuffPresent(ca_inc) or SpellCooldown(ca_inc) > 30 } and AstralPower() >= AstralPowerCost(force_of_nature) Spell(force_of_nature)
}

AddFunction BalanceDefaultShortCdPostConditions
{
 BuffRemaining(starlord_buff) < 8 and not AstralPower() >= AstralPowerCost(solar_wrath) and BuffPresent(starlord_buff) and Texture(starlord text=cancel) or { BuffStacks(starlord_buff) < 3 or BuffRemaining(starlord_buff) >= 8 } and Enemies(tagged=1) >= sf_targets() and { target.TimeToDie() + 1 } * Enemies(tagged=1) > PowerCost(starfall) / 2.5 and Spell(starfall) or { { Talent(starlord_talent) and { BuffStacks(starlord_buff) < 3 or BuffRemaining(starlord_buff) >= 8 and BuffStacks(arcanic_pulsar_buff) < 8 } or not Talent(starlord_talent) and { BuffStacks(arcanic_pulsar_buff) < 8 or DebuffPresent(ca_inc) } } and Enemies(tagged=1) < sf_targets() and BuffStacks(lunar_empowerment_buff) + BuffStacks(solar_empowerment_buff) < 4 and BuffStacks(solar_empowerment_buff) < 3 and BuffStacks(lunar_empowerment_buff) < 3 and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(starsurge_balance) } or target.TimeToDie() <= ExecuteTime(starsurge_balance) * AstralPower() / 40 or not AstralPower() >= AstralPowerCost(solar_wrath) } and Spell(starsurge_balance) or target.Refreshable(sunfire_debuff) and AstralPower() >= AstralPowerCost(sunfire) and target.TimeToDie() / { 2 * { 100 / { 100 + SpellCastSpeedPercent() } } } * Enemies(tagged=1) >= 2 / Enemies(tagged=1) * 1.5 + 2 * Enemies(tagged=1) and { Enemies(tagged=1) > 1 + TalentPoints(twin_moons_talent) or target.DebuffPresent(moonfire_debuff) } and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(sunfire) } and Spell(sunfire) or target.Refreshable(moonfire_debuff) and AstralPower() >= AstralPowerCost(moonfire) and target.TimeToDie() / { 2 * { 100 / { 100 + SpellCastSpeedPercent() } } } * Enemies(tagged=1) >= 6 and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(moonfire) } and Spell(moonfire) or target.Refreshable(stellar_flare_debuff) and AstralPower() >= AstralPowerCost(stellar_flare) and target.TimeToDie() / { 2 * { 100 / { 100 + SpellCastSpeedPercent() } } } >= 5 and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(stellar_flare) } and Spell(stellar_flare) or AstralPower() >= AstralPowerCost(new_moon) and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or AstralPower() >= AstralPowerCost(half_moon) and SpellKnown(half_moon) and Spell(half_moon) or AstralPower() >= AstralPowerCost(full_moon) and SpellKnown(full_moon) and Spell(full_moon) or BuffStacks(solar_empowerment_buff) < 3 and { AstralPower() >= AstralPowerCost(lunar_strike) or BuffStacks(lunar_empowerment_buff) == 3 } and { { BuffPresent(warrior_of_elune_buff) or BuffPresent(lunar_empowerment_buff) or Enemies(tagged=1) >= 2 and not BuffPresent(solar_empowerment_buff) } and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(lunar_strike) and not Talent(incarnation_talent) or PreviousSpell(solar_wrath_balance) } or az_ss() and DebuffPresent(ca_inc) and PreviousSpell(solar_wrath_balance) } and Spell(lunar_strike) or { az_ss() < 3 or not DebuffPresent(ca_inc) or not PreviousSpell(solar_wrath_balance) } and Spell(solar_wrath_balance) or Spell(sunfire)
}

AddFunction BalanceDefaultCdActions
{
 # BalanceInterruptActions()
 #potion,if=buff.ca_inc.remains>6&active_enemies=1
 # if DebuffRemaining(ca_inc) > 6 and Enemies(tagged=1) == 1 and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(rising_death usable=1)
 #potion,name=battle_potion_of_intellect,if=buff.ca_inc.remains>6
 # if DebuffRemaining(ca_inc) > 6 and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_intellect usable=1)
 #blood_fury,if=buff.ca_inc.up
 if DebuffPresent(ca_inc) Spell(blood_fury)
 #berserking,if=buff.ca_inc.up
 if DebuffPresent(ca_inc) Spell(berserking)
 #arcane_torrent,if=buff.ca_inc.up
 if DebuffPresent(ca_inc) Spell(arcane_torrent_energy)
 #lights_judgment,if=buff.ca_inc.up
 if DebuffPresent(ca_inc) Spell(lights_judgment)
 #fireblood,if=buff.ca_inc.up
 if DebuffPresent(ca_inc) Spell(fireblood)
 #ancestral_call,if=buff.ca_inc.up
 if DebuffPresent(ca_inc) Spell(ancestral_call)
 #use_item,name=balefire_branch,if=equipped.159630&cooldown.ca_inc.remains>30
 if HasEquippedItem(159630) and SpellCooldown(ca_inc) > 30 BalanceUseItemActions()
 #use_item,name=dread_gladiators_badge,if=equipped.161902&cooldown.ca_inc.remains>30
 if HasEquippedItem(161902) and SpellCooldown(ca_inc) > 30 BalanceUseItemActions()
 #use_item,name=azurethos_singed_plumage,if=equipped.161377&cooldown.ca_inc.remains>30
 if HasEquippedItem(161377) and SpellCooldown(ca_inc) > 30 BalanceUseItemActions()
 #use_items,if=cooldown.ca_inc.remains>30
 if SpellCooldown(ca_inc) > 30 BalanceUseItemActions()

 unless Spell(warrior_of_elune)
 {
  #innervate,if=azerite.lively_spirit.enabled&(cooldown.incarnation.remains<2|cooldown.celestial_alignment.remains<12)
  if HasAzeriteTrait(lively_spirit_trait) and { SpellCooldown(incarnation_chosen_of_elune) < 2 or SpellCooldown(celestial_alignment) < 12 } Spell(innervate)
  #incarnation,if=astral_power>=40
  if AstralPower() >= 40 Spell(incarnation_chosen_of_elune)
  #celestial_alignment,if=astral_power>=40&(!azerite.lively_spirit.enabled|buff.lively_spirit.up)&(buff.starlord.stack>=2|!talent.starlord.enabled|!variable.az_ss)
  if AstralPower() >= 40 and { not HasAzeriteTrait(lively_spirit_trait) or BuffPresent(lively_spirit_buff) } and { BuffStacks(starlord_buff) >= 2 or not Talent(starlord_talent) or not az_ss() } Spell(celestial_alignment)
 }
}

AddFunction BalanceDefaultCdPostConditions
{
 Spell(warrior_of_elune) or { DebuffPresent(ca_inc) or SpellCooldown(ca_inc) > 30 } and AstralPower() >= AstralPowerCost(solar_wrath) and Spell(fury_of_elune) or { DebuffPresent(ca_inc) or SpellCooldown(ca_inc) > 30 } and AstralPower() >= AstralPowerCost(force_of_nature) and Spell(force_of_nature) or BuffRemaining(starlord_buff) < 8 and not AstralPower() >= AstralPowerCost(solar_wrath) and BuffPresent(starlord_buff) and Texture(starlord text=cancel) or { BuffStacks(starlord_buff) < 3 or BuffRemaining(starlord_buff) >= 8 } and Enemies(tagged=1) >= sf_targets() and { target.TimeToDie() + 1 } * Enemies(tagged=1) > PowerCost(starfall) / 2.5 and Spell(starfall) or { { Talent(starlord_talent) and { BuffStacks(starlord_buff) < 3 or BuffRemaining(starlord_buff) >= 8 and BuffStacks(arcanic_pulsar_buff) < 8 } or not Talent(starlord_talent) and { BuffStacks(arcanic_pulsar_buff) < 8 or DebuffPresent(ca_inc) } } and Enemies(tagged=1) < sf_targets() and BuffStacks(lunar_empowerment_buff) + BuffStacks(solar_empowerment_buff) < 4 and BuffStacks(solar_empowerment_buff) < 3 and BuffStacks(lunar_empowerment_buff) < 3 and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(starsurge_balance) } or target.TimeToDie() <= ExecuteTime(starsurge_balance) * AstralPower() / 40 or not AstralPower() >= AstralPowerCost(solar_wrath) } and Spell(starsurge_balance) or target.Refreshable(sunfire_debuff) and AstralPower() >= AstralPowerCost(sunfire) and target.TimeToDie() / { 2 * { 100 / { 100 + SpellCastSpeedPercent() } } } * Enemies(tagged=1) >= 2 / Enemies(tagged=1) * 1.5 + 2 * Enemies(tagged=1) and { Enemies(tagged=1) > 1 + TalentPoints(twin_moons_talent) or target.DebuffPresent(moonfire_debuff) } and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(sunfire) } and Spell(sunfire) or target.Refreshable(moonfire_debuff) and AstralPower() >= AstralPowerCost(moonfire) and target.TimeToDie() / { 2 * { 100 / { 100 + SpellCastSpeedPercent() } } } * Enemies(tagged=1) >= 6 and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(moonfire) } and Spell(moonfire) or target.Refreshable(stellar_flare_debuff) and AstralPower() >= AstralPowerCost(stellar_flare) and target.TimeToDie() / { 2 * { 100 / { 100 + SpellCastSpeedPercent() } } } >= 5 and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(stellar_flare) } and Spell(stellar_flare) or AstralPower() >= AstralPowerCost(new_moon) and not SpellKnown(half_moon) and not SpellKnown(full_moon) and Spell(new_moon) or AstralPower() >= AstralPowerCost(half_moon) and SpellKnown(half_moon) and Spell(half_moon) or AstralPower() >= AstralPowerCost(full_moon) and SpellKnown(full_moon) and Spell(full_moon) or BuffStacks(solar_empowerment_buff) < 3 and { AstralPower() >= AstralPowerCost(lunar_strike) or BuffStacks(lunar_empowerment_buff) == 3 } and { { BuffPresent(warrior_of_elune_buff) or BuffPresent(lunar_empowerment_buff) or Enemies(tagged=1) >= 2 and not BuffPresent(solar_empowerment_buff) } and { not az_ss() or not DebuffPresent(ca_inc) or not PreviousSpell(lunar_strike) and not Talent(incarnation_talent) or PreviousSpell(solar_wrath_balance) } or az_ss() and DebuffPresent(ca_inc) and PreviousSpell(solar_wrath_balance) } and Spell(lunar_strike) or { az_ss() < 3 or not DebuffPresent(ca_inc) or not PreviousSpell(solar_wrath_balance) } and Spell(solar_wrath_balance) or Spell(sunfire)
}
]]
	OvaleScripts:RegisterScript("DRUID", "balance", name, desc, code, "script")
end
