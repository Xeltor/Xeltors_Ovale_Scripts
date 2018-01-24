local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_brewmaster"
	local desc = "[Xel][7.3] Monk: Brewmaster"
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
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
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
 #call_action_list,name=st
 BrewmasterStMainActions()
}

AddFunction BrewmasterDefaultMainPostConditions
{
 BrewmasterStMainPostConditions()
}

AddFunction BrewmasterDefaultShortCdActions
{
 #auto_attack
 # BrewmasterGetInMeleeRange()
 #call_action_list,name=st
 BrewmasterStShortCdActions()
}

AddFunction BrewmasterDefaultShortCdPostConditions
{
 BrewmasterStShortCdPostConditions()
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
 #call_action_list,name=st
 BrewmasterStCdActions()
}

AddFunction BrewmasterDefaultCdPostConditions
{
 BrewmasterStCdPostConditions()
}

### actions.precombat

AddFunction BrewmasterPrecombatMainActions
{
 #chi_burst
 Spell(chi_burst)
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
 # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(old_war_potion usable=1)
 #dampen_harm
 Spell(dampen_harm)
}

AddFunction BrewmasterPrecombatCdPostConditions
{
 Spell(chi_burst) or Spell(chi_wave)
}

### actions.st

AddFunction BrewmasterStMainActions
{
 #exploding_keg
 Spell(exploding_keg)
 #tiger_palm,if=buff.blackout_combo.up
 if BuffPresent(blackout_combo_buff) Spell(tiger_palm)
 #blackout_strike,if=cooldown.keg_smash.remains>0
 if SpellCooldown(keg_smash) > 0 Spell(blackout_strike)
 #keg_smash
 Spell(keg_smash)
 #breath_of_fire,if=buff.bloodlust.down&buff.blackout_combo.down|(buff.bloodlust.up&buff.blackout_combo.down&dot.breath_of_fire.remains<=0)
 if BuffExpires(burst_haste_buff any=1) and BuffExpires(blackout_combo_buff) or BuffPresent(burst_haste_buff any=1) and BuffExpires(blackout_combo_buff) and target.DebuffRemaining(breath_of_fire_debuff) <= 0 Spell(breath_of_fire)
 #rushing_jade_wind
 Spell(rushing_jade_wind)
 #tiger_palm,if=!talent.blackout_combo.enabled&cooldown.keg_smash.remains>=gcd&(energy+(energy.regen*(cooldown.keg_smash.remains)))>=55
 if not Talent(blackout_combo_talent) and SpellCooldown(keg_smash) >= GCD() and Energy() + EnergyRegenRate() * SpellCooldown(keg_smash) >= 55 Spell(tiger_palm)
}

AddFunction BrewmasterStMainPostConditions
{
}

AddFunction BrewmasterStShortCdActions
{
 unless Spell(exploding_keg)
 {
  #ironskin_brew,if=buff.blackout_combo.down&cooldown.ironskin_brew.charges>=1
  if BuffExpires(blackout_combo_buff) and SpellCharges(ironskin_brew) >= 1 Spell(ironskin_brew)
  #black_ox_brew,if=(energy+(energy.regen*(cooldown.keg_smash.remains)))<40&buff.blackout_combo.down&cooldown.keg_smash.up
  if Energy() + EnergyRegenRate() * SpellCooldown(keg_smash) < 40 and BuffExpires(blackout_combo_buff) and not SpellCooldown(keg_smash) > 0 Spell(black_ox_brew)
 }
}

AddFunction BrewmasterStShortCdPostConditions
{
 Spell(exploding_keg) or BuffPresent(blackout_combo_buff) and Spell(tiger_palm) or SpellCooldown(keg_smash) > 0 and Spell(blackout_strike) or Spell(keg_smash) or { BuffExpires(burst_haste_buff any=1) and BuffExpires(blackout_combo_buff) or BuffPresent(burst_haste_buff any=1) and BuffExpires(blackout_combo_buff) and target.DebuffRemaining(breath_of_fire_debuff) <= 0 } and Spell(breath_of_fire) or Spell(rushing_jade_wind) or not Talent(blackout_combo_talent) and SpellCooldown(keg_smash) >= GCD() and Energy() + EnergyRegenRate() * SpellCooldown(keg_smash) >= 55 and Spell(tiger_palm)
}

AddFunction BrewmasterStCdActions
{
 #potion
 # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(old_war_potion usable=1)
 #blood_fury
 Spell(blood_fury_apsp)
 #berserking
 Spell(berserking)

 unless Spell(exploding_keg)
 {
  #invoke_niuzao,if=target.time_to_die>45
  if target.TimeToDie() > 45 Spell(invoke_niuzao)
  #arcane_torrent,if=energy<31
  if Energy() < 31 Spell(arcane_torrent_chi)
 }
}

AddFunction BrewmasterStCdPostConditions
{
 Spell(exploding_keg) or BuffPresent(blackout_combo_buff) and Spell(tiger_palm) or SpellCooldown(keg_smash) > 0 and Spell(blackout_strike) or Spell(keg_smash) or { BuffExpires(burst_haste_buff any=1) and BuffExpires(blackout_combo_buff) or BuffPresent(burst_haste_buff any=1) and BuffExpires(blackout_combo_buff) and target.DebuffRemaining(breath_of_fire_debuff) <= 0 } and Spell(breath_of_fire) or Spell(rushing_jade_wind) or not Talent(blackout_combo_talent) and SpellCooldown(keg_smash) >= GCD() and Energy() + EnergyRegenRate() * SpellCooldown(keg_smash) >= 55 and Spell(tiger_palm)
}
]]

	OvaleScripts:RegisterScript("MONK", "brewmaster", name, desc, code, "script")
end
