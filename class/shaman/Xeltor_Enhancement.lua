local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_enhancement"
	local desc = "[Xel][7.3.5] Shaman: Enhancement"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_shaman_spells)

Define(ghost_wolf 2645)
Define(ghost_wolf_buff 2645)
Define(rainfall 215864)
	SpellInfo(rainfall cd=10)
Define(rainfall_buff 215864)

# Enhancement
AddIcon specialization=2 help=main
{
	# Interrupt
	if InCombat() InterruptActions()
	
	if { Talent(ascendance_talent) and target.InRange(rockbiter) or not Talent(ascendance_talent) and target.InRange(stormstrike) } and HasFullControl()
    {
		if InCombat() and Spell(rainfall) and not BuffPresent(rainfall_buff) Spell(rainfall)
	
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
	if InCombat() and not target.InRange(rockbiter) and target.Present() and not target.IsFriend() and not target.IsDead() and not BuffPresent(ghost_wolf_buff) Spell(ghost_wolf)
}

AddFunction Boss
{
	IsBossFight() or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		if target.InRange(wind_shear) and target.IsInterruptible() Spell(wind_shear)
        if target.Distance(less 5) and not target.Classification(worldboss) Spell(sundering)
        # if not target.Classification(worldboss) and target.RemainingCastTime() > 2 Spell(lightning_surge_totem)
        if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
        if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
	}
}

### checks

AddFunction OCPool60
{
    not Talent(overcharge_talent) or Talent(overcharge_talent) and Maelstrom() > 60
}

AddFunction furyCheck70
{
    not Talent(fury_of_air_talent) or Talent(fury_of_air_talent) and Maelstrom() > 70
}

AddFunction akainuEquipped
{
    HasEquippedItem(137084)
}

AddFunction heartEquipped
{
    HasEquippedItem(151819)
}

AddFunction akainuAS
{
    akainuEquipped() and BuffPresent(hot_hand_buff) and not BuffPresent(frostbrand_buff)
}

AddFunction LightningCrashNotUp
{
    not BuffPresent(lightning_crash_buff) and ArmorSetBonus(T20 2)
}

AddFunction OCPool70
{
    not Talent(overcharge_talent) or Talent(overcharge_talent) and Maelstrom() > 70
}

AddFunction furyCheck80
{
    not Talent(fury_of_air_talent) or Talent(fury_of_air_talent) and Maelstrom() > 80
}

AddFunction furyCheck45
{
    not Talent(fury_of_air_talent) or Talent(fury_of_air_talent) and Maelstrom() > 45
}

AddFunction furyCheck25
{
    not Talent(fury_of_air_talent) or Talent(fury_of_air_talent) and Maelstrom() > 25
}

AddFunction alphaWolfCheck
{
    pet.BuffRemaining(frost_wolf_alpha_wolf_buff) < 2 and pet.BuffRemaining(fiery_wolf_alpha_wolf_buff) < 2 and pet.BuffRemaining(lightning_wolf_alpha_wolf_buff) < 2 and TotemRemaining(sprit_wolf) > 4
}

AddFunction hailstormCheck
{
    Talent(hailstorm_talent) and not BuffPresent(frostbrand_buff) or not Talent(hailstorm_talent)
}

### actions.default

AddFunction EnhancementDefaultMainActions
{
    #call_action_list,name=opener
    EnhancementOpenerMainActions()

    unless EnhancementOpenerMainPostConditions()
    {
        #call_action_list,name=asc,if=buff.ascendance.up
        if BuffPresent(ascendance_enhancement_buff) EnhancementAscMainActions()

        unless BuffPresent(ascendance_enhancement_buff) and EnhancementAscMainPostConditions()
        {
            #call_action_list,name=buffs
            EnhancementBuffsMainActions()

            unless EnhancementBuffsMainPostConditions()
            {
                #call_action_list,name=cds
                EnhancementCdsMainActions()

                unless EnhancementCdsMainPostConditions()
                {
                    #call_action_list,name=core
                    EnhancementCoreMainActions()

                    unless EnhancementCoreMainPostConditions()
                    {
                        #call_action_list,name=filler
                        EnhancementFillerMainActions()
                    }
                }
            }
        }
    }
}

AddFunction EnhancementDefaultMainPostConditions
{
    EnhancementOpenerMainPostConditions() or BuffPresent(ascendance_enhancement_buff) and EnhancementAscMainPostConditions() or EnhancementBuffsMainPostConditions() or EnhancementCdsMainPostConditions() or EnhancementCoreMainPostConditions() or EnhancementFillerMainPostConditions()
}

AddFunction EnhancementDefaultShortCdActions
{
    #variable,name=hailstormCheck,value=((talent.hailstorm.enabled&!buff.frostbrand.up)|!talent.hailstorm.enabled)
    #variable,name=furyCheck80,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>80))
    #variable,name=furyCheck70,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>70))
    #variable,name=furyCheck45,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>45))
    #variable,name=furyCheck25,value=(!talent.fury_of_air.enabled|(talent.fury_of_air.enabled&maelstrom>25))
    #variable,name=OCPool70,value=(!talent.overcharge.enabled|(talent.overcharge.enabled&maelstrom>70))
    #variable,name=OCPool60,value=(!talent.overcharge.enabled|(talent.overcharge.enabled&maelstrom>60))
    #variable,name=heartEquipped,value=(equipped.151819)
    #variable,name=akainuEquipped,value=(equipped.137084)
    #variable,name=akainuAS,value=(variable.akainuEquipped&buff.hot_hand.react&!buff.frostbrand.up)
    #variable,name=LightningCrashNotUp,value=(!buff.lightning_crash.up&set_bonus.tier20_2pc)
    #variable,name=alphaWolfCheck,value=((pet.frost_wolf.buff.alpha_wolf.remains<2&pet.fiery_wolf.buff.alpha_wolf.remains<2&pet.lightning_wolf.buff.alpha_wolf.remains<2)&feral_spirit.remains>4)
    #auto_attack
    # EnhancementGetInMeleeRange()
    #call_action_list,name=opener
    EnhancementOpenerShortCdActions()

    unless EnhancementOpenerShortCdPostConditions()
    {
        #call_action_list,name=asc,if=buff.ascendance.up
        if BuffPresent(ascendance_enhancement_buff) EnhancementAscShortCdActions()

        unless BuffPresent(ascendance_enhancement_buff) and EnhancementAscShortCdPostConditions()
        {
            #call_action_list,name=buffs
            EnhancementBuffsShortCdActions()

            unless EnhancementBuffsShortCdPostConditions()
            {
                #call_action_list,name=cds
                EnhancementCdsShortCdActions()

                unless EnhancementCdsShortCdPostConditions()
                {
                    #call_action_list,name=core
                    EnhancementCoreShortCdActions()

                    unless EnhancementCoreShortCdPostConditions()
                    {
                        #call_action_list,name=filler
                        EnhancementFillerShortCdActions()
                    }
                }
            }
        }
    }
}

AddFunction EnhancementDefaultShortCdPostConditions
{
    EnhancementOpenerShortCdPostConditions() or BuffPresent(ascendance_enhancement_buff) and EnhancementAscShortCdPostConditions() or EnhancementBuffsShortCdPostConditions() or EnhancementCdsShortCdPostConditions() or EnhancementCoreShortCdPostConditions() or EnhancementFillerShortCdPostConditions()
}

AddFunction EnhancementDefaultCdActions
{
    #wind_shear
    # EnhancementInterruptActions()
    #use_items
    # EnhancementUseItemActions()
    #call_action_list,name=opener
    EnhancementOpenerCdActions()

    unless EnhancementOpenerCdPostConditions()
    {
        #call_action_list,name=asc,if=buff.ascendance.up
        if BuffPresent(ascendance_enhancement_buff) EnhancementAscCdActions()

        unless BuffPresent(ascendance_enhancement_buff) and EnhancementAscCdPostConditions()
        {
            #call_action_list,name=buffs
            EnhancementBuffsCdActions()

            unless EnhancementBuffsCdPostConditions()
            {
                #call_action_list,name=cds
                EnhancementCdsCdActions()

                unless EnhancementCdsCdPostConditions()
                {
                    #call_action_list,name=core
                    EnhancementCoreCdActions()

                    unless EnhancementCoreCdPostConditions()
                    {
                        #call_action_list,name=filler
                        EnhancementFillerCdActions()
                    }
                }
            }
        }
    }
}

AddFunction EnhancementDefaultCdPostConditions
{
    EnhancementOpenerCdPostConditions() or BuffPresent(ascendance_enhancement_buff) and EnhancementAscCdPostConditions() or EnhancementBuffsCdPostConditions() or EnhancementCdsCdPostConditions() or EnhancementCoreCdPostConditions() or EnhancementFillerCdPostConditions()
}

### actions.asc

AddFunction EnhancementAscMainActions
{
    #earthen_spike
    Spell(earthen_spike)
    #windstrike
    Spell(windstrike)
}

AddFunction EnhancementAscMainPostConditions
{
}

AddFunction EnhancementAscShortCdActions
{
    unless Spell(earthen_spike)
    {
        #doom_winds
        Spell(doom_winds)
    }
}

AddFunction EnhancementAscShortCdPostConditions
{
    Spell(earthen_spike) or Spell(windstrike)
}

AddFunction EnhancementAscCdActions
{
}

AddFunction EnhancementAscCdPostConditions
{
    Spell(earthen_spike) or Spell(windstrike)
}

### actions.buffs

AddFunction EnhancementBuffsMainActions
{
    #rockbiter,if=talent.landslide.enabled&!buff.landslide.up
    if Talent(landslide_talent) and not BuffPresent(landslide_buff) Spell(rockbiter)
    #fury_of_air,if=!ticking&maelstrom>22
    if not target.DebuffPresent(fury_of_air_debuff) and Maelstrom() > 22 Spell(fury_of_air)
    #crash_lightning,if=artifact.alpha_wolf.rank&prev_gcd.1.feral_spirit
    if ArtifactTraitRank(alpha_wolf) and PreviousGCDSpell(feral_spirit) Spell(crash_lightning)
    #flametongue,if=!buff.flametongue.up
    if not BuffPresent(flametongue_buff) Spell(flametongue)
    #frostbrand,if=talent.hailstorm.enabled&!buff.frostbrand.up&variable.furyCheck45
    if Talent(hailstorm_talent) and not BuffPresent(frostbrand_buff) and furyCheck45() Spell(frostbrand)
    #flametongue,if=buff.flametongue.remains<6+gcd&cooldown.doom_winds.remains<gcd*2
    if BuffRemaining(flametongue_buff) < 6 + GCD() and SpellCooldown(doom_winds) < GCD() * 2 Spell(flametongue)
    #frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<6+gcd&cooldown.doom_winds.remains<gcd*2
    if Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < 6 + GCD() and SpellCooldown(doom_winds) < GCD() * 2 Spell(frostbrand)
}

AddFunction EnhancementBuffsMainPostConditions
{
}

AddFunction EnhancementBuffsShortCdActions
{
}

AddFunction EnhancementBuffsShortCdPostConditions
{
    Talent(landslide_talent) and not BuffPresent(landslide_buff) and Spell(rockbiter) or not target.DebuffPresent(fury_of_air_debuff) and Maelstrom() > 22 and Spell(fury_of_air) or ArtifactTraitRank(alpha_wolf) and PreviousGCDSpell(feral_spirit) and Spell(crash_lightning) or not BuffPresent(flametongue_buff) and Spell(flametongue) or Talent(hailstorm_talent) and not BuffPresent(frostbrand_buff) and furyCheck45() and Spell(frostbrand) or BuffRemaining(flametongue_buff) < 6 + GCD() and SpellCooldown(doom_winds) < GCD() * 2 and Spell(flametongue) or Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < 6 + GCD() and SpellCooldown(doom_winds) < GCD() * 2 and Spell(frostbrand)
}

AddFunction EnhancementBuffsCdActions
{
}

AddFunction EnhancementBuffsCdPostConditions
{
    Talent(landslide_talent) and not BuffPresent(landslide_buff) and Spell(rockbiter) or not target.DebuffPresent(fury_of_air_debuff) and Maelstrom() > 22 and Spell(fury_of_air) or ArtifactTraitRank(alpha_wolf) and PreviousGCDSpell(feral_spirit) and Spell(crash_lightning) or not BuffPresent(flametongue_buff) and Spell(flametongue) or Talent(hailstorm_talent) and not BuffPresent(frostbrand_buff) and furyCheck45() and Spell(frostbrand) or BuffRemaining(flametongue_buff) < 6 + GCD() and SpellCooldown(doom_winds) < GCD() * 2 and Spell(flametongue) or Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < 6 + GCD() and SpellCooldown(doom_winds) < GCD() * 2 and Spell(frostbrand)
}

### actions.cds

AddFunction EnhancementCdsMainActions
{
}

AddFunction EnhancementCdsMainPostConditions
{
}

AddFunction EnhancementCdsShortCdActions
{
    #doom_winds,if=cooldown.ascendance.remains>6|talent.boulderfist.enabled|debuff.earthen_spike.up
    if SpellCooldown(ascendance_enhancement) > 6 or Talent(boulderfist_talent) or target.DebuffPresent(earthen_spike_debuff) Spell(doom_winds)
}

AddFunction EnhancementCdsShortCdPostConditions
{
}

AddFunction EnhancementCdsCdActions
{
    #bloodlust,if=target.health.pct<25|time>0.500
    # if target.HealthPercent() < 25 or TimeInCombat() > 0.5 EnhancementBloodlust()
    #berserking,if=buff.ascendance.up|(feral_spirit.remains>5)|level<100
    if BuffPresent(ascendance_enhancement_buff) or TotemRemaining(sprit_wolf) > 5 or Level() < 100 Spell(berserking)
    #blood_fury,if=buff.ascendance.up|(feral_spirit.remains>5)|level<100
    if BuffPresent(ascendance_enhancement_buff) or TotemRemaining(sprit_wolf) > 5 or Level() < 100 Spell(blood_fury_apsp)
    #potion,if=buff.ascendance.up|!talent.ascendance.enabled&feral_spirit.remains>5|target.time_to_die<=60
    # if { BuffPresent(ascendance_enhancement_buff) or not Talent(ascendance_talent) and TotemRemaining(sprit_wolf) > 5 or target.TimeToDie() <= 60 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
    #feral_spirit
    Spell(feral_spirit)
    #ascendance,if=buff.ascendance.down
    if BuffExpires(ascendance_enhancement_buff) and BuffExpires(ascendance_enhancement_buff) Spell(ascendance_enhancement)
}

AddFunction EnhancementCdsCdPostConditions
{
}

### actions.core

AddFunction EnhancementCoreMainActions
{
    #earthen_spike,if=variable.furyCheck25
    if furyCheck25() Spell(earthen_spike)
    #crash_lightning,if=!buff.crash_lightning.up&active_enemies>=2
    if not BuffPresent(crash_lightning_buff) and Enemies(tagged=1) >= 2 Spell(crash_lightning)
    #crash_lightning,if=active_enemies>=8|(active_enemies>=6&talent.crashing_storm.enabled)
    if Enemies(tagged=1) >= 8 or Enemies(tagged=1) >= 6 and Talent(crashing_storm_talent) Spell(crash_lightning)
    #windstrike
    Spell(windstrike)
    #stormstrike,if=buff.stormbringer.up&variable.furyCheck25
    if BuffPresent(stormbringer_buff) and furyCheck25() Spell(stormstrike)
    #crash_lightning,if=active_enemies>=4|(active_enemies>=2&talent.crashing_storm.enabled)
    if Enemies(tagged=1) >= 4 or Enemies(tagged=1) >= 2 and Talent(crashing_storm_talent) Spell(crash_lightning)
    #lightning_bolt,if=talent.overcharge.enabled&variable.furyCheck45&maelstrom>=40
    if Talent(overcharge_talent) and furyCheck45() and Maelstrom() >= 40 Spell(lightning_bolt_enhancement)
    #stormstrike,if=(!talent.overcharge.enabled&variable.furyCheck45)|(talent.overcharge.enabled&variable.furyCheck80)
    if not Talent(overcharge_talent) and furyCheck45() or Talent(overcharge_talent) and furyCheck80() Spell(stormstrike)
    #frostbrand,if=variable.akainuAS
    if akainuAS() Spell(frostbrand)
    #lava_lash,if=buff.hot_hand.react&((variable.akainuEquipped&buff.frostbrand.up)|!variable.akainuEquipped)
    if BuffPresent(hot_hand_buff) and { akainuEquipped() and BuffPresent(frostbrand_buff) or not akainuEquipped() } Spell(lava_lash)
    #sundering,if=active_enemies>=3
    if Enemies(tagged=1) >= 3 Spell(sundering)
    #crash_lightning,if=active_enemies>=3|variable.LightningCrashNotUp|variable.alphaWolfCheck
    if Enemies(tagged=1) >= 3 or LightningCrashNotUp() or alphaWolfCheck() Spell(crash_lightning)
}

AddFunction EnhancementCoreMainPostConditions
{
}

AddFunction EnhancementCoreShortCdActions
{
    unless furyCheck25() and Spell(earthen_spike) or not BuffPresent(crash_lightning_buff) and Enemies(tagged=1) >= 2 and Spell(crash_lightning)
    {
        #windsong
        Spell(windsong)
    }
}

AddFunction EnhancementCoreShortCdPostConditions
{
    furyCheck25() and Spell(earthen_spike) or not BuffPresent(crash_lightning_buff) and Enemies(tagged=1) >= 2 and Spell(crash_lightning) or { Enemies(tagged=1) >= 8 or Enemies(tagged=1) >= 6 and Talent(crashing_storm_talent) } and Spell(crash_lightning) or Spell(windstrike) or BuffPresent(stormbringer_buff) and furyCheck25() and Spell(stormstrike) or { Enemies(tagged=1) >= 4 or Enemies(tagged=1) >= 2 and Talent(crashing_storm_talent) } and Spell(crash_lightning) or Talent(overcharge_talent) and furyCheck45() and Maelstrom() >= 40 and Spell(lightning_bolt_enhancement) or { not Talent(overcharge_talent) and furyCheck45() or Talent(overcharge_talent) and furyCheck80() } and Spell(stormstrike) or akainuAS() and Spell(frostbrand) or BuffPresent(hot_hand_buff) and { akainuEquipped() and BuffPresent(frostbrand_buff) or not akainuEquipped() } and Spell(lava_lash) or Enemies(tagged=1) >= 3 and Spell(sundering) or { Enemies(tagged=1) >= 3 or LightningCrashNotUp() or alphaWolfCheck() } and Spell(crash_lightning)
}

AddFunction EnhancementCoreCdActions
{
}

AddFunction EnhancementCoreCdPostConditions
{
    furyCheck25() and Spell(earthen_spike) or not BuffPresent(crash_lightning_buff) and Enemies(tagged=1) >= 2 and Spell(crash_lightning) or Spell(windsong) or { Enemies(tagged=1) >= 8 or Enemies(tagged=1) >= 6 and Talent(crashing_storm_talent) } and Spell(crash_lightning) or Spell(windstrike) or BuffPresent(stormbringer_buff) and furyCheck25() and Spell(stormstrike) or { Enemies(tagged=1) >= 4 or Enemies(tagged=1) >= 2 and Talent(crashing_storm_talent) } and Spell(crash_lightning) or Talent(overcharge_talent) and furyCheck45() and Maelstrom() >= 40 and Spell(lightning_bolt_enhancement) or { not Talent(overcharge_talent) and furyCheck45() or Talent(overcharge_talent) and furyCheck80() } and Spell(stormstrike) or akainuAS() and Spell(frostbrand) or BuffPresent(hot_hand_buff) and { akainuEquipped() and BuffPresent(frostbrand_buff) or not akainuEquipped() } and Spell(lava_lash) or Enemies(tagged=1) >= 3 and Spell(sundering) or { Enemies(tagged=1) >= 3 or LightningCrashNotUp() or alphaWolfCheck() } and Spell(crash_lightning)
}

### actions.filler

AddFunction EnhancementFillerMainActions
{
    #rockbiter,if=maelstrom<120
    if Maelstrom() < 120 Spell(rockbiter)
    #flametongue,if=buff.flametongue.remains<4.8
    if BuffRemaining(flametongue_buff) < 4.8 Spell(flametongue)
    #crash_lightning,if=(talent.crashing_storm.enabled|active_enemies>=2)&debuff.earthen_spike.up&maelstrom>=40&variable.OCPool60
    if { Talent(crashing_storm_talent) or Enemies(tagged=1) >= 2 } and target.DebuffPresent(earthen_spike_debuff) and Maelstrom() >= 40 and OCPool60() Spell(crash_lightning)
    #frostbrand,if=talent.hailstorm.enabled&buff.frostbrand.remains<4.8&maelstrom>40
    if Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < 4.8 and Maelstrom() > 40 Spell(frostbrand)
    #frostbrand,if=variable.akainuEquipped&!buff.frostbrand.up&maelstrom>=75
    if akainuEquipped() and not BuffPresent(frostbrand_buff) and Maelstrom() >= 75 Spell(frostbrand)
    #sundering
    Spell(sundering)
    #lava_lash,if=maelstrom>=50&variable.OCPool70&variable.furyCheck80
    if Maelstrom() >= 50 and OCPool70() and furyCheck80() Spell(lava_lash)
    #rockbiter
    Spell(rockbiter)
    #crash_lightning,if=(maelstrom>=65|talent.crashing_storm.enabled|active_enemies>=2)&variable.OCPool60&variable.furyCheck45
    if { Maelstrom() >= 65 or Talent(crashing_storm_talent) or Enemies(tagged=1) >= 2 } and OCPool60() and furyCheck45() Spell(crash_lightning)
    #flametongue
    Spell(flametongue)
}

AddFunction EnhancementFillerMainPostConditions
{
}

AddFunction EnhancementFillerShortCdActions
{
}

AddFunction EnhancementFillerShortCdPostConditions
{
    Maelstrom() < 120 and Spell(rockbiter) or BuffRemaining(flametongue_buff) < 4.8 and Spell(flametongue) or { Talent(crashing_storm_talent) or Enemies(tagged=1) >= 2 } and target.DebuffPresent(earthen_spike_debuff) and Maelstrom() >= 40 and OCPool60() and Spell(crash_lightning) or Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < 4.8 and Maelstrom() > 40 and Spell(frostbrand) or akainuEquipped() and not BuffPresent(frostbrand_buff) and Maelstrom() >= 75 and Spell(frostbrand) or Spell(sundering) or Maelstrom() >= 50 and OCPool70() and furyCheck80() and Spell(lava_lash) or Spell(rockbiter) or { Maelstrom() >= 65 or Talent(crashing_storm_talent) or Enemies(tagged=1) >= 2 } and OCPool60() and furyCheck45() and Spell(crash_lightning) or Spell(flametongue)
}

AddFunction EnhancementFillerCdActions
{
}

AddFunction EnhancementFillerCdPostConditions
{
    Maelstrom() < 120 and Spell(rockbiter) or BuffRemaining(flametongue_buff) < 4.8 and Spell(flametongue) or { Talent(crashing_storm_talent) or Enemies(tagged=1) >= 2 } and target.DebuffPresent(earthen_spike_debuff) and Maelstrom() >= 40 and OCPool60() and Spell(crash_lightning) or Talent(hailstorm_talent) and BuffRemaining(frostbrand_buff) < 4.8 and Maelstrom() > 40 and Spell(frostbrand) or akainuEquipped() and not BuffPresent(frostbrand_buff) and Maelstrom() >= 75 and Spell(frostbrand) or Spell(sundering) or Maelstrom() >= 50 and OCPool70() and furyCheck80() and Spell(lava_lash) or Spell(rockbiter) or { Maelstrom() >= 65 or Talent(crashing_storm_talent) or Enemies(tagged=1) >= 2 } and OCPool60() and furyCheck45() and Spell(crash_lightning) or Spell(flametongue)
}

### actions.opener

AddFunction EnhancementOpenerMainActions
{
    #rockbiter,if=maelstrom<15&time<gcd
    if Maelstrom() < 15 and TimeInCombat() < GCD() Spell(rockbiter)
}

AddFunction EnhancementOpenerMainPostConditions
{
}

AddFunction EnhancementOpenerShortCdActions
{
}

AddFunction EnhancementOpenerShortCdPostConditions
{
    Maelstrom() < 15 and TimeInCombat() < GCD() and Spell(rockbiter)
}

AddFunction EnhancementOpenerCdActions
{
}

AddFunction EnhancementOpenerCdPostConditions
{
    Maelstrom() < 15 and TimeInCombat() < GCD() and Spell(rockbiter)
}

### actions.precombat

AddFunction EnhancementPrecombatMainActions
{
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
    Spell(lightning_shield)
}

AddFunction EnhancementPrecombatCdActions
{
    #flask
    #food
    #augmentation
    #snapshot_stats
    #potion
    # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
}

AddFunction EnhancementPrecombatCdPostConditions
{
    Spell(lightning_shield)
}
]]

	OvaleScripts:RegisterScript("SHAMAN", "enhancement", name, desc, code, "script")
end
