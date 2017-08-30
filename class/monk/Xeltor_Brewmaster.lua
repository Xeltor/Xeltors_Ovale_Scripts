local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_brewmaster"
	local desc = "[Xel][7.1.5] Monk: Brewmaster"
	local code = [[
Include(ovale_common)
Include(ovale_interrupt)
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
		if Talent(blackout_combo_talent) BrewmasterBlackoutComboMainActions()
		unless Talent(blackout_combo_talent) 
		{
			BrewmasterDefaultMainActions()
		}
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

AddFunction BrewmasterExpelHarmOffensivelyPreConditions
{
	(SpellCount(expel_harm) >= 3 and (SpellCount(expel_harm) * 7.5 * AttackPower() * 2.65) <= HealthMissing()) and Spell(expel_harm)
}

AddFunction BrewmasterHealMe
{
	if (HealthPercent() < 35) Spell(healing_elixir)
	if (SpellCount(expel_harm) >= 1 and HealthPercent() < 35) Spell(expel_harm)
	if (HealthPercent() <= 100 - (15 * 2.6)) Spell(healing_elixir)
}

AddFunction StaggerPercentage
{
	StaggerRemaining() / MaxHealth() * 100
}

AddFunction BrewmasterRangeCheck
{
	if not target.InRange(tiger_palm) Texture(misc_arrowlup help=L(not_in_melee_range))
}

AddFunction BrewmasterDefaultShortCDActions
{
	# keep stagger below 100%
	if (StaggerPercentage() > 100 and SpellCharges(purifying_brew) > 0) Spell(purifying_brew)
	# use black_ox_brew when at 0 charges but delay it when a charge is about to come off cd
	if ((SpellCharges(purifying_brew) == 0) and (SpellChargeCooldown(purifying_brew) > 2 or StaggerPercentage() > 100)) Spell(black_ox_brew)
	# heal me
	BrewmasterHealMe()
	
	# range check
	# BrewmasterRangeCheck()

	unless StaggerPercentage() > 100 or BrewmasterHealMe() or (StaggerRemaining() == 0 and not Talent(special_delivery_talent))
	{
		# purify heavy stagger when we have enough ISB
		if (DebuffPresent(heavy_stagger_debuff) and (not Talent(elusive_dance_talent) or BuffExpires(elusive_dance_buff)) and (BuffRemaining(ironskin_brew_buff) > 1.5*SpellRechargeDuration(ironskin_brew))) Spell(purifying_brew)
		# always keep 1 charge unless black_ox_brew is coming off cd
		if (SpellCharges(ironskin_brew) > 1 or (Talent(black_ox_brew_talent) and SpellCooldown(black_ox_brew) <= 3))
		{
			# never be at (almost) max charges 
			if (SpellCharges(ironskin_brew count=0) >= SpellMaxCharges(ironskin_brew)-0.3) Spell(ironskin_brew)
			# use up those charges when black_ox_brew_talent comes off cd
			if (Talent(black_ox_brew_talent) and SpellCooldown(black_ox_brew) <= 3) Spell(ironskin_brew)
			
			if(StaggerRemaining() > 0)
			{
				# keep brew-stache rolling (when not elusive_dance)
				if (HasArtifactTrait(brew_stache_trait) and BuffExpires(brew_stache_buff) and not Talent(elusive_dance_talent)) Spell(ironskin_brew text=stache)
				# keep up ironskin_brew_buff
				if (BuffExpires(ironskin_brew_buff 2)) Spell(ironskin_brew)
				# purify stagger when doing trash when talent elusive dance 
				if (Talent(elusive_dance_talent) and not IsBossFight() and BuffExpires(elusive_dance_buff)) Spell(purifying_brew)
			}
		}
	}
}

#
# Single-Target
#

AddFunction BrewmasterDefaultMainActions
{
	Spell(keg_smash)
	if EnergyDeficit() <= 35 Spell(tiger_palm)
	unless EnergyDeficit() <= 35
	{
		Spell(blackout_strike)
		Spell(rushing_jade_wind)
		if target.DebuffPresent(keg_smash_debuff) Spell(breath_of_fire)
		Spell(chi_burst)
		Spell(chi_wave)
		Spell(exploding_keg)
	}
}

AddFunction BrewmasterBlackoutComboMainActions
{
	if(not BuffPresent(blackout_combo_buff)) Spell(blackout_strike)
	if(BuffPresent(blackout_combo_buff)) 
	{
		Spell(keg_smash)
		unless (SpellCooldown(keg_smash) < GCD())
		{
			Spell(breath_of_fire)
			Spell(tiger_palm)
		}
	}
	
	unless (BuffPresent(blackout_combo_buff)) 
	{
		Spell(rushing_jade_wind)
		Spell(chi_burst)
		Spell(chi_wave)
		if EnergyDeficit() <= 35 Spell(tiger_palm)
		Spell(exploding_keg)
	}
}

#
# AOE
#

AddFunction BrewmasterDefaultAoEActions
{
	Spell(exploding_keg)
	Spell(keg_smash)
	Spell(chi_burst)
	Spell(chi_wave)
	if target.DebuffPresent(keg_smash_debuff) Spell(breath_of_fire)
	Spell(rushing_jade_wind)
	if EnergyDeficit() <= 35 Spell(tiger_palm)
	unless EnergyDeficit() <= 35
	{
		Spell(blackout_strike)
	}
}

AddFunction BrewmasterBlackoutComboAoEActions
{
	if(not BuffPresent(blackout_combo_buff)) Spell(blackout_strike)
	if(BuffPresent(blackout_combo_buff)) 
	{
		Spell(keg_smash)
		Spell(breath_of_fire)
		Spell(tiger_palm)
	}
	
	unless (BuffPresent(blackout_combo_buff)) 
	{
		Spell(exploding_keg)
		Spell(rushing_jade_wind)
		Spell(chi_burst)
		Spell(chi_wave)
		if EnergyDeficit() <= 35 Spell(tiger_palm)
	}
}

AddFunction BrewmasterDefaultCdActions 
{
	# BrewmasterInterruptActions()
	# if CheckBoxOn(opt_legendary_ring_tank) Item(legendary_ring_bonus_armor usable=1)
	if not PetPresent(name=Niuzao) Spell(invoke_niuzao)
	# Item(Trinket0Slot usable=1 text=13)
	# Item(Trinket1Slot usable=1 text=14)
	if (HasEquippedItem(fundamental_observation)) Spell(zen_meditation)
	Spell(fortifying_brew)
	Spell(zen_meditation)
	Spell(dampen_harm)
	# Item(unbending_potion usable=1)
}
]]

	OvaleScripts:RegisterScript("MONK", "brewmaster", name, desc, code, "script")
end
