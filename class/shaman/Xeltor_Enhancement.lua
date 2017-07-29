local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_enhancement"
	local desc = "[Xel][7.2.0] Shaman: Enhancement"
	local code = [[
Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_shaman_spells)

Define(ghost_wolf 2645)
Define(ghost_wolf_buff 2645)

# Enhancement
AddIcon specialization=2 help=main
{
	# Disable when out of combat, dangerous and all :P
	if {not InCombat() or { Speed() > 0 and not target.Present() }} and BuffPresent(fury_of_air_buff) and Spell(fury_of_air) Spell(fury_of_air)

	# Interrupt
	if InCombat() and target.Casting(interrupt) InterruptActions()
	
	if target.InRange(rockbiter) and HasFullControl() and InCombat()
    {
		# Cooldowns
		if Boss()
		{
			EnhancementDefaultCdActions()
		}
		
		# Short Cooldowns
		EnhancementDefaultShortCdActions()
		
		# Default rotation
		EnhancementDefaultMainActions()
	}
	
	# Go forth and murder
	if InCombat() and HasFullControl() and target.Present() and not target.InRange(rockbiter) and { TimeInCombat() < 6 or Falling() }
	{
		if target.InRange(feral_lunge) Spell(feral_lunge)
	}
	if InCombat() and not target.InRange(rockbiter) and target.Present() and not target.IsFriend() and not BuffPresent(ghost_wolf_buff) Spell(ghost_wolf)
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction StandingStill
{
	{Speed() == 0 or BuffPresent(spiritwalkers_grace)}
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(wind_shear) and target.IsInterruptible() Spell(wind_shear)
		if target.Distance(less 5) and not target.Classification(worldboss) Spell(sundering)
		if not target.Classification(worldboss) and target.RemainingCastTime() > 2 Spell(lightning_surge_totem)
		if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
		if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
	}
}

### actions.default

AddFunction EnhancementDefaultMainActions
{
	#crash_lightning,if=artifact.alpha_wolf.rank&prev_gcd.1.feral_spirit
	if ArtifactTraitRank(alpha_wolf) and PreviousGCDSpell(feral_spirit) Spell(crash_lightning)
	#potion,name=prolonged_power,if=feral_spirit.remains>5|target.time_to_die<=60
	#boulderfist,if=buff.boulderfist.remains<gcd|(maelstrom<=50&active_enemies>=3)
	if Talent(boulderfist_talent) and { BuffRemaining(boulderfist_buff) < GCD() or Maelstrom() <= 50 and Enemies(tagged=1) >= 3 } Spell(boulderfist)
	#boulderfist,if=buff.boulderfist.remains<gcd|(charges_fractional>1.75&maelstrom<=100&active_enemies<=2)
	if Talent(boulderfist_talent) and { BuffRemaining(boulderfist_buff) < GCD() or Charges(boulderfist count=0) > 1.75 and Maelstrom() <= 100 and Enemies(tagged=1) <= 2 } Spell(boulderfist)
	#rockbiter,if=talent.landslide.enabled&buff.landslide.remains<gcd
	if Talent(landslide_talent) and BuffRemaining(landslide_buff) < GCD() Spell(rockbiter)
	#fury_of_air,if=!ticking&maelstrom>22
	if not target.DebuffPresent(fury_of_air_debuff) and Maelstrom() > 22 Spell(fury_of_air)
	#frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<gcd
	if Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < GCD() Spell(frostbrand)
	#flametongue,if=buff.flametongue.remains<gcd|(cooldown.doom_winds.remains<6&buff.flametongue.remains<4)
	if BuffRemaining(flametongue_buff) < GCD() or SpellCooldown(doom_winds) < 6 and BuffRemaining(flametongue_buff) < 4 Spell(flametongue)
	#crash_lightning,if=talent.crashing_storm.enabled&active_enemies>=3&(!talent.hailstorm.enabled|buff.frostbrand.remains>gcd)
	if Talent(crashing_storm_talent) and Enemies(tagged=1) >= 3 and { not Talent(hailstorm_talent) or BuffRemaining(frostbrand_buff) > GCD() } Spell(crash_lightning)
	#earthen_spike
	Spell(earthen_spike)
	#lightning_bolt,if=(talent.overcharge.enabled&maelstrom>=40&!talent.fury_of_air.enabled)|(talent.overcharge.enabled&talent.fury_of_air.enabled&maelstrom>46)
	if Talent(overcharge_talent) and Maelstrom() >= 40 and not Talent(fury_of_air_talent) or Talent(overcharge_talent) and Talent(fury_of_air_talent) and Maelstrom() > 46 Spell(lightning_bolt)
	#crash_lightning,if=buff.crash_lightning.remains<gcd&active_enemies>=2
	if BuffRemaining(crash_lightning_buff) < GCD() and Enemies(tagged=1) >= 2 Spell(crash_lightning)
	#windstrike,if=buff.stormbringer.react&((talent.fury_of_air.enabled&maelstrom>=26)|(!talent.fury_of_air.enabled))
	if BuffPresent(stormbringer_buff) and { Talent(fury_of_air_talent) and Maelstrom() >= 26 or not Talent(fury_of_air_talent) } Spell(windstrike)
	#stormstrike,if=buff.stormbringer.react&((talent.fury_of_air.enabled&maelstrom>=26)|(!talent.fury_of_air.enabled))
	if BuffPresent(stormbringer_buff) and { Talent(fury_of_air_talent) and Maelstrom() >= 26 or not Talent(fury_of_air_talent) } Spell(stormstrike)
	#lava_lash,if=talent.hot_hand.enabled&buff.hot_hand.react
	if Talent(hot_hand_talent) and BuffPresent(hot_hand_buff) Spell(lava_lash)
	#crash_lightning,if=active_enemies>=4
	if Enemies(tagged=1) >= 4 Spell(crash_lightning)
	#windstrike
	Spell(windstrike)
	#stormstrike,if=talent.overcharge.enabled&cooldown.lightning_bolt.remains<gcd&maelstrom>80
	if Talent(overcharge_talent) and SpellCooldown(lightning_bolt) < GCD() and Maelstrom() > 80 Spell(stormstrike)
	#stormstrike,if=talent.fury_of_air.enabled&maelstrom>46&(cooldown.lightning_bolt.remains>gcd|!talent.overcharge.enabled)
	if Talent(fury_of_air_talent) and Maelstrom() > 46 and { SpellCooldown(lightning_bolt) > GCD() or not Talent(overcharge_talent) } Spell(stormstrike)
	#stormstrike,if=!talent.overcharge.enabled&!talent.fury_of_air.enabled
	if not Talent(overcharge_talent) and not Talent(fury_of_air_talent) Spell(stormstrike)
	#crash_lightning,if=((active_enemies>1|talent.crashing_storm.enabled|talent.boulderfist.enabled)&!set_bonus.tier19_4pc)|feral_spirit.remains>5
	if { Enemies(tagged=1) > 1 or Talent(crashing_storm_talent) or Talent(boulderfist_talent) } and not ArmorSetBonus(T19 4) or TotemRemaining(sprit_wolf) > 5 Spell(crash_lightning)
	#frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<4.8
	if Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < 4.8 Spell(frostbrand)
	#lava_lash,if=talent.fury_of_air.enabled&talent.overcharge.enabled&(set_bonus.tier19_4pc&maelstrom>=80)
	if Talent(fury_of_air_talent) and Talent(overcharge_talent) and ArmorSetBonus(T19 4) and Maelstrom() >= 80 Spell(lava_lash)
	#lava_lash,if=talent.fury_of_air.enabled&!talent.overcharge.enabled&(set_bonus.tier19_4pc&maelstrom>=53)
	if Talent(fury_of_air_talent) and not Talent(overcharge_talent) and ArmorSetBonus(T19 4) and Maelstrom() >= 53 Spell(lava_lash)
	#lava_lash,if=(!set_bonus.tier19_4pc&maelstrom>=120)|(!talent.fury_of_air.enabled&set_bonus.tier19_4pc&maelstrom>=40)
	if not ArmorSetBonus(T19 4) and Maelstrom() >= 120 or not Talent(fury_of_air_talent) and ArmorSetBonus(T19 4) and Maelstrom() >= 40 Spell(lava_lash)
	#flametongue,if=buff.flametongue.remains<4.8
	if BuffRemaining(flametongue_buff) < 4.8 Spell(flametongue)
	#sundering
	Spell(sundering)
	#rockbiter
	Spell(rockbiter)
	#flametongue
	Spell(flametongue)
	#boulderfist
	if Talent(boulderfist_talent) Spell(boulderfist)
}

AddFunction EnhancementDefaultMainPostConditions
{
}

AddFunction EnhancementDefaultShortCdActions
{
	#auto_attack
	# EnhancementGetInMeleeRange()

	unless ArtifactTraitRank(alpha_wolf) and PreviousGCDSpell(feral_spirit) and Spell(crash_lightning) or { BuffRemaining(boulderfist_buff) < GCD() or Maelstrom() <= 50 and Enemies(tagged=1) >= 3 } and Spell(boulderfist) or { BuffRemaining(boulderfist_buff) < GCD() or Charges(boulderfist count=0) > 1.75 and Maelstrom() <= 100 and Enemies(tagged=1) <= 2 } and Spell(boulderfist) or Talent(landslide_talent) and BuffRemaining(landslide_buff) < GCD() and Spell(rockbiter) or not target.DebuffPresent(fury_of_air_debuff) and Maelstrom() > 22 and Spell(fury_of_air) or Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < GCD() and Spell(frostbrand) or { BuffRemaining(flametongue_buff) < GCD() or SpellCooldown(doom_winds) < 6 and BuffRemaining(flametongue_buff) < 4 } and Spell(flametongue)
	{
		#doom_winds
		Spell(doom_winds)

		unless Talent(crashing_storm_talent) and Enemies(tagged=1) >= 3 and { not Talent(hailstorm_talent) or BuffRemaining(frostbrand_buff) > GCD() } and Spell(crash_lightning) or Spell(earthen_spike) or { Talent(overcharge_talent) and Maelstrom() >= 40 and not Talent(fury_of_air_talent) or Talent(overcharge_talent) and Talent(fury_of_air_talent) and Maelstrom() > 46 } and Spell(lightning_bolt) or BuffRemaining(crash_lightning_buff) < GCD() and Enemies(tagged=1) >= 2 and Spell(crash_lightning)
		{
			#windsong
			Spell(windsong)
		}
	}
}

AddFunction EnhancementDefaultShortCdPostConditions
{
	ArtifactTraitRank(alpha_wolf) and PreviousGCDSpell(feral_spirit) and Spell(crash_lightning) or { BuffRemaining(boulderfist_buff) < GCD() or Maelstrom() <= 50 and Enemies(tagged=1) >= 3 } and Spell(boulderfist) or { BuffRemaining(boulderfist_buff) < GCD() or Charges(boulderfist count=0) > 1.75 and Maelstrom() <= 100 and Enemies(tagged=1) <= 2 } and Spell(boulderfist) or Talent(landslide_talent) and BuffRemaining(landslide_buff) < GCD() and Spell(rockbiter) or not target.DebuffPresent(fury_of_air_debuff) and Maelstrom() > 22 and Spell(fury_of_air) or Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < GCD() and Spell(frostbrand) or { BuffRemaining(flametongue_buff) < GCD() or SpellCooldown(doom_winds) < 6 and BuffRemaining(flametongue_buff) < 4 } and Spell(flametongue) or Talent(crashing_storm_talent) and Enemies(tagged=1) >= 3 and { not Talent(hailstorm_talent) or BuffRemaining(frostbrand_buff) > GCD() } and Spell(crash_lightning) or Spell(earthen_spike) or { Talent(overcharge_talent) and Maelstrom() >= 40 and not Talent(fury_of_air_talent) or Talent(overcharge_talent) and Talent(fury_of_air_talent) and Maelstrom() > 46 } and Spell(lightning_bolt) or BuffRemaining(crash_lightning_buff) < GCD() and Enemies(tagged=1) >= 2 and Spell(crash_lightning) or BuffPresent(stormbringer_buff) and { Talent(fury_of_air_talent) and Maelstrom() >= 26 or not Talent(fury_of_air_talent) } and Spell(windstrike) or BuffPresent(stormbringer_buff) and { Talent(fury_of_air_talent) and Maelstrom() >= 26 or not Talent(fury_of_air_talent) } and Spell(stormstrike) or Talent(hot_hand_talent) and BuffPresent(hot_hand_buff) and Spell(lava_lash) or Enemies(tagged=1) >= 4 and Spell(crash_lightning) or Spell(windstrike) or Talent(overcharge_talent) and SpellCooldown(lightning_bolt) < GCD() and Maelstrom() > 80 and Spell(stormstrike) or Talent(fury_of_air_talent) and Maelstrom() > 46 and { SpellCooldown(lightning_bolt) > GCD() or not Talent(overcharge_talent) } and Spell(stormstrike) or not Talent(overcharge_talent) and not Talent(fury_of_air_talent) and Spell(stormstrike) or { { Enemies(tagged=1) > 1 or Talent(crashing_storm_talent) or Talent(boulderfist_talent) } and not ArmorSetBonus(T19 4) or TotemRemaining(sprit_wolf) > 5 } and Spell(crash_lightning) or Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < 4.8 and Spell(frostbrand) or Talent(fury_of_air_talent) and Talent(overcharge_talent) and ArmorSetBonus(T19 4) and Maelstrom() >= 80 and Spell(lava_lash) or Talent(fury_of_air_talent) and not Talent(overcharge_talent) and ArmorSetBonus(T19 4) and Maelstrom() >= 53 and Spell(lava_lash) or { not ArmorSetBonus(T19 4) and Maelstrom() >= 120 or not Talent(fury_of_air_talent) and ArmorSetBonus(T19 4) and Maelstrom() >= 40 } and Spell(lava_lash) or BuffRemaining(flametongue_buff) < 4.8 and Spell(flametongue) or Spell(sundering) or Spell(rockbiter) or Spell(flametongue) or Spell(boulderfist)
}

AddFunction EnhancementDefaultCdActions
{
	#wind_shear
	# EnhancementInterruptActions()
	#bloodlust,if=target.health.pct<25|time>0.500
	# if target.HealthPercent() < 25 or TimeInCombat() > 0.5 EnhancementBloodlust()
	#feral_spirit,if=!artifact.alpha_wolf.rank|(maelstrom>=20&cooldown.crash_lightning.remains<=gcd)
	if not ArtifactTraitRank(alpha_wolf) or Maelstrom() >= 20 and SpellCooldown(crash_lightning) <= GCD() Spell(feral_spirit)

	unless ArtifactTraitRank(alpha_wolf) and PreviousGCDSpell(feral_spirit) and Spell(crash_lightning)
	{
		#berserking,if=buff.ascendance.up|!talent.ascendance.enabled|level<100
		if BuffPresent(ascendance_melee_buff) or not Talent(ascendance_talent) or Level() < 100 Spell(berserking)
		#blood_fury
		Spell(blood_fury_apsp)

		unless { BuffRemaining(boulderfist_buff) < GCD() or Maelstrom() <= 50 and Enemies(tagged=1) >= 3 } and Spell(boulderfist) or { BuffRemaining(boulderfist_buff) < GCD() or Charges(boulderfist count=0) > 1.75 and Maelstrom() <= 100 and Enemies(tagged=1) <= 2 } and Spell(boulderfist) or Talent(landslide_talent) and BuffRemaining(landslide_buff) < GCD() and Spell(rockbiter) or not target.DebuffPresent(fury_of_air_debuff) and Maelstrom() > 22 and Spell(fury_of_air) or Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < GCD() and Spell(frostbrand) or { BuffRemaining(flametongue_buff) < GCD() or SpellCooldown(doom_winds) < 6 and BuffRemaining(flametongue_buff) < 4 } and Spell(flametongue) or Talent(crashing_storm_talent) and Enemies(tagged=1) >= 3 and { not Talent(hailstorm_talent) or BuffRemaining(frostbrand_buff) > GCD() } and Spell(crash_lightning) or Spell(earthen_spike) or { Talent(overcharge_talent) and Maelstrom() >= 40 and not Talent(fury_of_air_talent) or Talent(overcharge_talent) and Talent(fury_of_air_talent) and Maelstrom() > 46 } and Spell(lightning_bolt) or BuffRemaining(crash_lightning_buff) < GCD() and Enemies(tagged=1) >= 2 and Spell(crash_lightning) or Spell(windsong)
		{
			#ascendance,if=buff.stormbringer.react
			if BuffPresent(stormbringer_buff) and BuffExpires(ascendance_melee_buff) Spell(ascendance_melee)
		}
	}
}

AddFunction EnhancementDefaultCdPostConditions
{
	ArtifactTraitRank(alpha_wolf) and PreviousGCDSpell(feral_spirit) and Spell(crash_lightning) or { BuffRemaining(boulderfist_buff) < GCD() or Maelstrom() <= 50 and Enemies(tagged=1) >= 3 } and Spell(boulderfist) or { BuffRemaining(boulderfist_buff) < GCD() or Charges(boulderfist count=0) > 1.75 and Maelstrom() <= 100 and Enemies(tagged=1) <= 2 } and Spell(boulderfist) or Talent(landslide_talent) and BuffRemaining(landslide_buff) < GCD() and Spell(rockbiter) or not target.DebuffPresent(fury_of_air_debuff) and Maelstrom() > 22 and Spell(fury_of_air) or Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < GCD() and Spell(frostbrand) or { BuffRemaining(flametongue_buff) < GCD() or SpellCooldown(doom_winds) < 6 and BuffRemaining(flametongue_buff) < 4 } and Spell(flametongue) or Talent(crashing_storm_talent) and Enemies(tagged=1) >= 3 and { not Talent(hailstorm_talent) or BuffRemaining(frostbrand_buff) > GCD() } and Spell(crash_lightning) or Spell(earthen_spike) or { Talent(overcharge_talent) and Maelstrom() >= 40 and not Talent(fury_of_air_talent) or Talent(overcharge_talent) and Talent(fury_of_air_talent) and Maelstrom() > 46 } and Spell(lightning_bolt) or BuffRemaining(crash_lightning_buff) < GCD() and Enemies(tagged=1) >= 2 and Spell(crash_lightning) or Spell(windsong) or BuffPresent(stormbringer_buff) and { Talent(fury_of_air_talent) and Maelstrom() >= 26 or not Talent(fury_of_air_talent) } and Spell(windstrike) or BuffPresent(stormbringer_buff) and { Talent(fury_of_air_talent) and Maelstrom() >= 26 or not Talent(fury_of_air_talent) } and Spell(stormstrike) or Talent(hot_hand_talent) and BuffPresent(hot_hand_buff) and Spell(lava_lash) or Enemies(tagged=1) >= 4 and Spell(crash_lightning) or Spell(windstrike) or Talent(overcharge_talent) and SpellCooldown(lightning_bolt) < GCD() and Maelstrom() > 80 and Spell(stormstrike) or Talent(fury_of_air_talent) and Maelstrom() > 46 and { SpellCooldown(lightning_bolt) > GCD() or not Talent(overcharge_talent) } and Spell(stormstrike) or not Talent(overcharge_talent) and not Talent(fury_of_air_talent) and Spell(stormstrike) or { { Enemies(tagged=1) > 1 or Talent(crashing_storm_talent) or Talent(boulderfist_talent) } and not ArmorSetBonus(T19 4) or TotemRemaining(sprit_wolf) > 5 } and Spell(crash_lightning) or Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < 4.8 and Spell(frostbrand) or Talent(fury_of_air_talent) and Talent(overcharge_talent) and ArmorSetBonus(T19 4) and Maelstrom() >= 80 and Spell(lava_lash) or Talent(fury_of_air_talent) and not Talent(overcharge_talent) and ArmorSetBonus(T19 4) and Maelstrom() >= 53 and Spell(lava_lash) or { not ArmorSetBonus(T19 4) and Maelstrom() >= 120 or not Talent(fury_of_air_talent) and ArmorSetBonus(T19 4) and Maelstrom() >= 40 } and Spell(lava_lash) or BuffRemaining(flametongue_buff) < 4.8 and Spell(flametongue) or Spell(sundering) or Spell(rockbiter) or Spell(flametongue) or Spell(boulderfist)
}

### actions.precombat

AddFunction EnhancementPrecombatMainActions
{
	#flask,type=seventh_demon
	#augmentation,type=defiled
	Spell(augmentation)
	#food,name=nightborne_delicacy_platter
	#snapshot_stats
	#potion,name=prolonged_power
	#lightning_shield
	Spell(lightning_shield)
}

AddFunction EnhancementPrecombatMainPostConditions
{
}

AddFunction EnhancementPrecombatShortCdActions
{
}

AddFunction EnhancementPrecombatShortCdPostConditions
{
	Spell(augmentation) or Spell(lightning_shield)
}

AddFunction EnhancementPrecombatCdActions
{
}

AddFunction EnhancementPrecombatCdPostConditions
{
	Spell(augmentation) or Spell(lightning_shield)
}
]]

	OvaleScripts:RegisterScript("SHAMAN", "enhancement", name, desc, code, "script")
end
