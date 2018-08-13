local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_brewmaster"
	local desc = "[Xel][8.0] Monk: Brewmaster"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_monk_spells)

Define(ring_of_peace 116844)
Define(leg_sweep 119381)

# Brewmaster
AddIcon specialization=1 help=main
{
	if InCombat() InterruptActions()
	
	if target.InRange(tiger_palm) and HasFullControl()
	{
		if Boss() BrewmasterDefaultCdActions()
		
		BrewmasterDefaultShortCdActions()
		
		BrewmasterDefaultMainActions()
	}
}

AddFunction Boss
{
	IsBossFight() or target.Classification(worldboss) or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() }
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		if target.InRange(spear_hand_strike) Spell(spear_hand_strike)
		if not target.Classification(worldboss)
		{
			if target.InRange(paralysis) Spell(paralysis)
			if target.InRange(spear_hand_strike) Spell(arcane_torrent_chi)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.InRange(spear_hand_strike) Spell(leg_sweep)
			if target.InRange(spear_hand_strike) Spell(ring_of_peace)
			if target.InRange(spear_hand_strike) Spell(war_stomp)
		}
	}
}

### actions.default

AddFunction BrewmasterDefaultMainActions
{
 #invoke_niuzao_the_black_ox,if=target.time_to_die>45
 if target.TimeToDie() > 45 Spell(invoke_niuzao_the_black_ox)
 #black_ox_brew,if=incoming_damage_1500ms&stagger.heavy&cooldown.brews.charges_fractional<=0.75
 if IncomingDamage(1.5) > 0 and DebuffPresent(heavy_stagger_debuff) and SpellCharges(ironskin_brew count=0) <= 0.75 Spell(black_ox_brew)
 #black_ox_brew,if=(energy+(energy.regen*cooldown.keg_smash.remains))<40&buff.blackout_combo.down&cooldown.keg_smash.up
 if Energy() + EnergyRegenRate() * SpellCooldown(keg_smash) < 40 and BuffExpires(blackout_combo_buff) and not SpellCooldown(keg_smash) > 0 Spell(black_ox_brew)
 #keg_smash,if=spell_targets>=3
 if Enemies(tagged=1) >= 3 Spell(keg_smash)
 #tiger_palm,if=buff.blackout_combo.up
 if BuffPresent(blackout_combo_buff) Spell(tiger_palm)
 #keg_smash
 Spell(keg_smash)
 #rushing_jade_wind,if=buff.rushing_jade_wind.down
 if BuffExpires(rushing_jade_wind_buff) Spell(rushing_jade_wind)
 #blackout_strike
 Spell(blackout_strike)
 #breath_of_fire,if=buff.blackout_combo.down&(buff.bloodlust.down|(buff.bloodlust.up&&dot.breath_of_fire_dot.refreshable))
 if BuffExpires(blackout_combo_buff) and { BuffExpires(burst_haste_buff any=1) or BuffPresent(burst_haste_buff any=1) and target.DebuffRefreshable(breath_of_fire_debuff) } Spell(breath_of_fire)
 #chi_burst
 Spell(chi_burst)
 #chi_wave
 Spell(chi_wave)
 #tiger_palm,if=!talent.blackout_combo.enabled&cooldown.keg_smash.remains>gcd&(energy+(energy.regen*(cooldown.keg_smash.remains+gcd)))>=55
 if not Talent(blackout_combo_talent) and SpellCooldown(keg_smash) > GCD() and Energy() + EnergyRegenRate() * { SpellCooldown(keg_smash) + GCD() } >= 55 Spell(tiger_palm)
}

AddFunction BrewmasterDefaultMainPostConditions
{
}

AddFunction BrewmasterDefaultShortCdActions
{
 #auto_attack
 # BrewmasterGetInMeleeRange()

 unless target.TimeToDie() > 45 and Spell(invoke_niuzao_the_black_ox)
 {
  #purifying_brew,if=stagger.heavy|(stagger.moderate&cooldown.brews.charges_fractional>=cooldown.brews.max_charges-0.5&buff.ironskin_brew.remains>=buff.ironskin_brew.duration*2.5)
  if DebuffPresent(heavy_stagger_debuff) or DebuffPresent(moderate_stagger_debuff) and SpellCharges(ironskin_brew count=0) >= SpellMaxCharges(ironskin_brew) - 0.5 and BuffRemaining(ironskin_brew_buff) >= BaseDuration(ironskin_brew_buff) * 2.5 Spell(purifying_brew)
  #ironskin_brew,if=buff.blackout_combo.down&cooldown.brews.charges_fractional>=cooldown.brews.max_charges-1.0-(1+buff.ironskin_brew.remains<=buff.ironskin_brew.duration*0.5)&buff.ironskin_brew.remains<=buff.ironskin_brew.duration*2
  if BuffExpires(blackout_combo_buff) and SpellCharges(ironskin_brew count=0) >= SpellMaxCharges(ironskin_brew) - 1 - { 1 + BuffRemaining(ironskin_brew_buff) <= BaseDuration(ironskin_brew_buff) * 0.5 } and BuffRemaining(ironskin_brew_buff) <= BaseDuration(ironskin_brew_buff) * 2 Spell(ironskin_brew)
 }
}

AddFunction BrewmasterDefaultShortCdPostConditions
{
 target.TimeToDie() > 45 and Spell(invoke_niuzao_the_black_ox) or IncomingDamage(1.5) > 0 and DebuffPresent(heavy_stagger_debuff) and SpellCharges(ironskin_brew count=0) <= 0.75 and Spell(black_ox_brew) or Energy() + EnergyRegenRate() * SpellCooldown(keg_smash) < 40 and BuffExpires(blackout_combo_buff) and not SpellCooldown(keg_smash) > 0 and Spell(black_ox_brew) or Enemies(tagged=1) >= 3 and Spell(keg_smash) or BuffPresent(blackout_combo_buff) and Spell(tiger_palm) or Spell(keg_smash) or BuffExpires(rushing_jade_wind_buff) and Spell(rushing_jade_wind) or Spell(blackout_strike) or BuffExpires(blackout_combo_buff) and { BuffExpires(burst_haste_buff any=1) or BuffPresent(burst_haste_buff any=1) and target.DebuffRefreshable(breath_of_fire_debuff) } and Spell(breath_of_fire) or Spell(chi_burst) or Spell(chi_wave) or not Talent(blackout_combo_talent) and SpellCooldown(keg_smash) > GCD() and Energy() + EnergyRegenRate() * { SpellCooldown(keg_smash) + GCD() } >= 55 and Spell(tiger_palm)
}

AddFunction BrewmasterDefaultCdActions
{
 #gift_of_the_ox
 #dampen_harm,if=incoming_damage_1500ms&buff.fortifying_brew.down
 if IncomingDamage(1.5) > 0 and BuffExpires(fortifying_brew_buff) Spell(dampen_harm)
 #fortifying_brew,if=incoming_damage_1500ms&(buff.dampen_harm.down|buff.diffuse_magic.down)
 if IncomingDamage(1.5) > 0 and { BuffExpires(dampen_harm_buff) or BuffExpires(diffuse_magic_buff) } Spell(fortifying_brew)
 #use_item,name=archimondes_hatred_reborn
 # BrewmasterUseItemActions()
 #potion
 # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
 #blood_fury
 Spell(blood_fury_apsp)
 #berserking
 Spell(berserking)
 #lights_judgment
 # Spell(lights_judgment)
 #fireblood
 Spell(fireblood)
 #ancestral_call
 Spell(ancestral_call)

 unless target.TimeToDie() > 45 and Spell(invoke_niuzao_the_black_ox) or IncomingDamage(1.5) > 0 and DebuffPresent(heavy_stagger_debuff) and SpellCharges(ironskin_brew count=0) <= 0.75 and Spell(black_ox_brew) or Energy() + EnergyRegenRate() * SpellCooldown(keg_smash) < 40 and BuffExpires(blackout_combo_buff) and not SpellCooldown(keg_smash) > 0 and Spell(black_ox_brew)
 {
  #arcane_torrent,if=energy<31
  if Energy() < 31 Spell(arcane_torrent_chi)
 }
}

AddFunction BrewmasterDefaultCdPostConditions
{
 target.TimeToDie() > 45 and Spell(invoke_niuzao_the_black_ox) or IncomingDamage(1.5) > 0 and DebuffPresent(heavy_stagger_debuff) and SpellCharges(ironskin_brew count=0) <= 0.75 and Spell(black_ox_brew) or Energy() + EnergyRegenRate() * SpellCooldown(keg_smash) < 40 and BuffExpires(blackout_combo_buff) and not SpellCooldown(keg_smash) > 0 and Spell(black_ox_brew) or Enemies(tagged=1) >= 3 and Spell(keg_smash) or BuffPresent(blackout_combo_buff) and Spell(tiger_palm) or Spell(keg_smash) or BuffExpires(rushing_jade_wind_buff) and Spell(rushing_jade_wind) or Spell(blackout_strike) or BuffExpires(blackout_combo_buff) and { BuffExpires(burst_haste_buff any=1) or BuffPresent(burst_haste_buff any=1) and target.DebuffRefreshable(breath_of_fire_debuff) } and Spell(breath_of_fire) or Spell(chi_burst) or Spell(chi_wave) or not Talent(blackout_combo_talent) and SpellCooldown(keg_smash) > GCD() and Energy() + EnergyRegenRate() * { SpellCooldown(keg_smash) + GCD() } >= 55 and Spell(tiger_palm)
}

### actions.precombat

AddFunction BrewmasterPrecombatMainActions
{
 #chi_burst
 if CheckBoxOn(opt_chi_burst) Spell(chi_burst)
 #chi_wave
 Spell(chi_wave)
}

AddFunction BrewmasterPrecombatMainPostConditions
{
}

AddFunction BrewmasterPrecombatShortCdActions
{
}

AddFunction BrewmasterPrecombatShortCdPostConditions
{
 Spell(chi_burst) or Spell(chi_wave)
}

AddFunction BrewmasterPrecombatCdActions
{
 #flask
 #food
 #augmentation
 #snapshot_stats
 #potion
 # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
}

AddFunction BrewmasterPrecombatCdPostConditions
{
 Spell(chi_burst) or Spell(chi_wave)
}
]]

	OvaleScripts:RegisterScript("MONK", "brewmaster", name, desc, code, "script")
end
