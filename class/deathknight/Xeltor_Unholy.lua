local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_unholy"
	local desc = "[Xel][7.2.5] Death Knight: Unholy"
	local code = [[
# Include Ovale Defaults (racials & trinkets).
Include(ovale_common)

Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_deathknight_spells)

Define(path_of_frost 3714)
Define(path_of_frost_buff 3714)
Define(virulent_plague_debuff 191587)
	SpellInfo(virulent_plague_debuff duration=21)

# Unholy
AddIcon specialization=3 help=main
{
	# Interrupt
	if InCombat() InterruptActions()
	
    if target.InRange(festering_strike) and HasFullControl()
    {
		if not pet.Present() Spell(raise_dead)
		if BuffStacks(dark_succor_buff) Spell(death_strike)
		
		# Cooldown
		if Boss()
		{
			UnholyDefaultCdActions()
		}

		# Short cooldown
		UnholyDefaultShortCdActions()
		
		# Rotation
		UnholyDefaultMainActions()
	}
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

# Common functions.
AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and InCombat()
	{
		if target.InRange(mind_freeze) Spell(mind_freeze)
		if not target.Classification(worldboss)
		{
			if target.InRange(asphyxiate) Spell(asphyxiate)
			if target.InRange(strangulate) Spell(strangulate)
			if target.Distance(less 8) Spell(arcane_torrent_runicpower)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}

### actions.default

AddFunction UnholyDefaultMainActions
{
    #outbreak,target_if=!dot.virulent_plague.ticking
    if not target.DebuffPresent(virulent_plague_debuff) Spell(outbreak)
    #run_action_list,name=valkyr,if=talent.dark_arbiter.enabled&pet.valkyr_battlemaiden.active
    if Talent(dark_arbiter_talent) and pet.Present() UnholyValkyrMainActions()

    unless Talent(dark_arbiter_talent) and pet.Present() and UnholyValkyrMainPostConditions()
    {
        #call_action_list,name=generic
        UnholyGenericMainActions()
    }
}

AddFunction UnholyDefaultMainPostConditions
{
    Talent(dark_arbiter_talent) and pet.Present() and UnholyValkyrMainPostConditions() or UnholyGenericMainPostConditions()
}

AddFunction UnholyDefaultShortCdActions
{
    #auto_attack
    # UnholyGetInMeleeRange()

    unless not target.DebuffPresent(virulent_plague_debuff) and Spell(outbreak)
    {
        #dark_transformation,if=equipped.137075&cooldown.dark_arbiter.remains>165
        if HasEquippedItem(137075) and SpellCooldown(dark_arbiter) > 165 Spell(dark_transformation)
        #dark_transformation,if=equipped.137075&!talent.shadow_infusion.enabled&cooldown.dark_arbiter.remains>55
        if HasEquippedItem(137075) and not Talent(shadow_infusion_talent) and SpellCooldown(dark_arbiter) > 55 Spell(dark_transformation)
        #dark_transformation,if=equipped.137075&talent.shadow_infusion.enabled&cooldown.dark_arbiter.remains>35
        if HasEquippedItem(137075) and Talent(shadow_infusion_talent) and SpellCooldown(dark_arbiter) > 35 Spell(dark_transformation)
        #dark_transformation,if=equipped.137075&target.time_to_die<cooldown.dark_arbiter.remains-8
        if HasEquippedItem(137075) and target.TimeToDie() < SpellCooldown(dark_arbiter) - 8 Spell(dark_transformation)
        #dark_transformation,if=equipped.137075&cooldown.summon_gargoyle.remains>160
        if HasEquippedItem(137075) and SpellCooldown(summon_gargoyle) > 160 Spell(dark_transformation)
        #dark_transformation,if=equipped.137075&!talent.shadow_infusion.enabled&cooldown.summon_gargoyle.remains>55
        if HasEquippedItem(137075) and not Talent(shadow_infusion_talent) and SpellCooldown(summon_gargoyle) > 55 Spell(dark_transformation)
        #dark_transformation,if=equipped.137075&talent.shadow_infusion.enabled&cooldown.summon_gargoyle.remains>35
        if HasEquippedItem(137075) and Talent(shadow_infusion_talent) and SpellCooldown(summon_gargoyle) > 35 Spell(dark_transformation)
        #dark_transformation,if=equipped.137075&target.time_to_die<cooldown.summon_gargoyle.remains-8
        if HasEquippedItem(137075) and target.TimeToDie() < SpellCooldown(summon_gargoyle) - 8 Spell(dark_transformation)
        #dark_transformation,if=!equipped.137075&rune<=3
        if not HasEquippedItem(137075) and Rune() < 4 Spell(dark_transformation)
        #blighted_rune_weapon,if=rune<=3
        if Rune() < 4 Spell(blighted_rune_weapon)
        #run_action_list,name=valkyr,if=talent.dark_arbiter.enabled&pet.valkyr_battlemaiden.active
        if Talent(dark_arbiter_talent) and pet.Present() UnholyValkyrShortCdActions()

        unless Talent(dark_arbiter_talent) and pet.Present() and UnholyValkyrShortCdPostConditions()
        {
            #call_action_list,name=generic
            UnholyGenericShortCdActions()
        }
    }
}

AddFunction UnholyDefaultShortCdPostConditions
{
    not target.DebuffPresent(virulent_plague_debuff) and Spell(outbreak) or Talent(dark_arbiter_talent) and pet.Present() and UnholyValkyrShortCdPostConditions() or UnholyGenericShortCdPostConditions()
}

AddFunction UnholyDefaultCdActions
{
    #mind_freeze
    # UnholyInterruptActions()
    #arcane_torrent,if=runic_power.deficit>20
    if RunicPowerDeficit() > 20 Spell(arcane_torrent_runicpower)
    #blood_fury
    Spell(blood_fury_ap)
    #berserking
    Spell(berserking)
    #use_items
    # UnholyUseItemActions()
    #potion,if=buff.unholy_strength.react
    # if BuffPresent(unholy_strength_buff) and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)

    unless not target.DebuffPresent(virulent_plague_debuff) and Spell(outbreak)
    {
        #army_of_the_dead
        Spell(army_of_the_dead)

        unless HasEquippedItem(137075) and SpellCooldown(dark_arbiter) > 165 and Spell(dark_transformation) or HasEquippedItem(137075) and not Talent(shadow_infusion_talent) and SpellCooldown(dark_arbiter) > 55 and Spell(dark_transformation) or HasEquippedItem(137075) and Talent(shadow_infusion_talent) and SpellCooldown(dark_arbiter) > 35 and Spell(dark_transformation) or HasEquippedItem(137075) and target.TimeToDie() < SpellCooldown(dark_arbiter) - 8 and Spell(dark_transformation) or HasEquippedItem(137075) and SpellCooldown(summon_gargoyle) > 160 and Spell(dark_transformation) or HasEquippedItem(137075) and not Talent(shadow_infusion_talent) and SpellCooldown(summon_gargoyle) > 55 and Spell(dark_transformation) or HasEquippedItem(137075) and Talent(shadow_infusion_talent) and SpellCooldown(summon_gargoyle) > 35 and Spell(dark_transformation) or HasEquippedItem(137075) and target.TimeToDie() < SpellCooldown(summon_gargoyle) - 8 and Spell(dark_transformation) or not HasEquippedItem(137075) and Rune() < 4 and Spell(dark_transformation) or Rune() < 4 and Spell(blighted_rune_weapon)
        {
            #run_action_list,name=valkyr,if=talent.dark_arbiter.enabled&pet.valkyr_battlemaiden.active
            if Talent(dark_arbiter_talent) and pet.Present() UnholyValkyrCdActions()

            unless Talent(dark_arbiter_talent) and pet.Present() and UnholyValkyrCdPostConditions()
            {
                #call_action_list,name=generic
                UnholyGenericCdActions()
            }
        }
    }
}

AddFunction UnholyDefaultCdPostConditions
{
    not target.DebuffPresent(virulent_plague_debuff) and Spell(outbreak) or HasEquippedItem(137075) and SpellCooldown(dark_arbiter) > 165 and Spell(dark_transformation) or HasEquippedItem(137075) and not Talent(shadow_infusion_talent) and SpellCooldown(dark_arbiter) > 55 and Spell(dark_transformation) or HasEquippedItem(137075) and Talent(shadow_infusion_talent) and SpellCooldown(dark_arbiter) > 35 and Spell(dark_transformation) or HasEquippedItem(137075) and target.TimeToDie() < SpellCooldown(dark_arbiter) - 8 and Spell(dark_transformation) or HasEquippedItem(137075) and SpellCooldown(summon_gargoyle) > 160 and Spell(dark_transformation) or HasEquippedItem(137075) and not Talent(shadow_infusion_talent) and SpellCooldown(summon_gargoyle) > 55 and Spell(dark_transformation) or HasEquippedItem(137075) and Talent(shadow_infusion_talent) and SpellCooldown(summon_gargoyle) > 35 and Spell(dark_transformation) or HasEquippedItem(137075) and target.TimeToDie() < SpellCooldown(summon_gargoyle) - 8 and Spell(dark_transformation) or not HasEquippedItem(137075) and Rune() < 4 and Spell(dark_transformation) or Rune() < 4 and Spell(blighted_rune_weapon) or Talent(dark_arbiter_talent) and pet.Present() and UnholyValkyrCdPostConditions() or UnholyGenericCdPostConditions()
}

### actions.aoe

AddFunction UnholyAoeMainActions
{
    #epidemic,if=spell_targets.epidemic>4
    if Enemies(tagged=1) > 4 Spell(epidemic)
    #scourge_strike,if=spell_targets.scourge_strike>=2&(dot.death_and_decay.ticking|dot.defile.ticking)
    if Enemies(tagged=1) >= 2 and { target.DebuffPresent(death_and_decay_debuff) or target.DebuffPresent(defile_debuff) } Spell(scourge_strike)
    #clawing_shadows,if=spell_targets.clawing_shadows>=2&(dot.death_and_decay.ticking|dot.defile.ticking)
    if Enemies(tagged=1) >= 2 and { target.DebuffPresent(death_and_decay_debuff) or target.DebuffPresent(defile_debuff) } Spell(clawing_shadows)
    #epidemic,if=spell_targets.epidemic>2
    if Enemies(tagged=1) > 2 Spell(epidemic)
}

AddFunction UnholyAoeMainPostConditions
{
}

AddFunction UnholyAoeShortCdActions
{
    #death_and_decay,if=spell_targets.death_and_decay>=2
    if Enemies(tagged=1) >= 2 Spell(death_and_decay)
}

AddFunction UnholyAoeShortCdPostConditions
{
    Enemies(tagged=1) > 4 and Spell(epidemic) or Enemies(tagged=1) >= 2 and { target.DebuffPresent(death_and_decay_debuff) or target.DebuffPresent(defile_debuff) } and Spell(scourge_strike) or Enemies(tagged=1) >= 2 and { target.DebuffPresent(death_and_decay_debuff) or target.DebuffPresent(defile_debuff) } and Spell(clawing_shadows) or Enemies(tagged=1) > 2 and Spell(epidemic)
}

AddFunction UnholyAoeCdActions
{
}

AddFunction UnholyAoeCdPostConditions
{
    Enemies(tagged=1) >= 2 and Spell(death_and_decay) or Enemies(tagged=1) > 4 and Spell(epidemic) or Enemies(tagged=1) >= 2 and { target.DebuffPresent(death_and_decay_debuff) or target.DebuffPresent(defile_debuff) } and Spell(scourge_strike) or Enemies(tagged=1) >= 2 and { target.DebuffPresent(death_and_decay_debuff) or target.DebuffPresent(defile_debuff) } and Spell(clawing_shadows) or Enemies(tagged=1) > 2 and Spell(epidemic)
}

### actions.castigator

AddFunction UnholyCastigatorMainActions
{
    #festering_strike,if=debuff.festering_wound.stack<=4&runic_power.deficit>23
    if target.DebuffStacks(festering_wound_debuff) <= 4 and RunicPowerDeficit() > 23 Spell(festering_strike)
    #death_coil,if=!buff.necrosis.up&talent.necrosis.enabled&rune<=3
    if not BuffPresent(necrosis_buff) and Talent(necrosis_talent) and Rune() < 4 Spell(death_coil)
    #scourge_strike,if=buff.necrosis.react&debuff.festering_wound.stack>=3&runic_power.deficit>23
    if BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 23 Spell(scourge_strike)
    #scourge_strike,if=buff.unholy_strength.react&debuff.festering_wound.stack>=3&runic_power.deficit>23
    if BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 23 Spell(scourge_strike)
    #scourge_strike,if=rune>=2&debuff.festering_wound.stack>=3&runic_power.deficit>23
    if Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 23 Spell(scourge_strike)
    #death_coil,if=talent.shadow_infusion.enabled&talent.dark_arbiter.enabled&!buff.dark_transformation.up&cooldown.dark_arbiter.remains>15
    if Talent(shadow_infusion_talent) and Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and SpellCooldown(dark_arbiter) > 15 Spell(death_coil)
    #death_coil,if=talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled&!buff.dark_transformation.up
    if Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) Spell(death_coil)
    #death_coil,if=talent.dark_arbiter.enabled&cooldown.dark_arbiter.remains>15
    if Talent(dark_arbiter_talent) and SpellCooldown(dark_arbiter) > 15 Spell(death_coil)
    #death_coil,if=!talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled
    if not Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) Spell(death_coil)
}

AddFunction UnholyCastigatorMainPostConditions
{
}

AddFunction UnholyCastigatorShortCdActions
{
}

AddFunction UnholyCastigatorShortCdPostConditions
{
    target.DebuffStacks(festering_wound_debuff) <= 4 and RunicPowerDeficit() > 23 and Spell(festering_strike) or not BuffPresent(necrosis_buff) and Talent(necrosis_talent) and Rune() < 4 and Spell(death_coil) or BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 23 and Spell(scourge_strike) or BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 23 and Spell(scourge_strike) or Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 23 and Spell(scourge_strike) or Talent(shadow_infusion_talent) and Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and SpellCooldown(dark_arbiter) > 15 and Spell(death_coil) or Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and Spell(death_coil) or Talent(dark_arbiter_talent) and SpellCooldown(dark_arbiter) > 15 and Spell(death_coil) or not Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and Spell(death_coil)
}

AddFunction UnholyCastigatorCdActions
{
}

AddFunction UnholyCastigatorCdPostConditions
{
    target.DebuffStacks(festering_wound_debuff) <= 4 and RunicPowerDeficit() > 23 and Spell(festering_strike) or not BuffPresent(necrosis_buff) and Talent(necrosis_talent) and Rune() < 4 and Spell(death_coil) or BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 23 and Spell(scourge_strike) or BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 23 and Spell(scourge_strike) or Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 23 and Spell(scourge_strike) or Talent(shadow_infusion_talent) and Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and SpellCooldown(dark_arbiter) > 15 and Spell(death_coil) or Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and Spell(death_coil) or Talent(dark_arbiter_talent) and SpellCooldown(dark_arbiter) > 15 and Spell(death_coil) or not Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and Spell(death_coil)
}

### actions.generic

AddFunction UnholyGenericMainActions
{
    #chains_of_ice,if=buff.unholy_strength.up&buff.cold_heart.stack>19
    if BuffPresent(unholy_strength_buff) and BuffStacks(cold_heart_buff) > 19 Spell(chains_of_ice)
    #death_coil,if=runic_power.deficit<10
    if RunicPowerDeficit() < 10 Spell(death_coil)
    #death_coil,if=!talent.dark_arbiter.enabled&buff.sudden_doom.up&!buff.necrosis.up&rune<=3
    if not Talent(dark_arbiter_talent) and BuffPresent(sudden_doom_buff) and not BuffPresent(necrosis_buff) and Rune() < 4 Spell(death_coil)
    #death_coil,if=talent.dark_arbiter.enabled&buff.sudden_doom.up&cooldown.dark_arbiter.remains>5&rune<=3
    if Talent(dark_arbiter_talent) and BuffPresent(sudden_doom_buff) and SpellCooldown(dark_arbiter) > 5 and Rune() < 4 Spell(death_coil)
    #festering_strike,if=debuff.festering_wound.stack<6&cooldown.apocalypse.remains<=6
    if target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) <= 6 Spell(festering_strike)
    #festering_strike,if=debuff.soul_reaper.up&!debuff.festering_wound.up
    if target.DebuffPresent(soul_reaper_unholy_debuff) and not target.DebuffPresent(festering_wound_debuff) Spell(festering_strike)
    #scourge_strike,if=debuff.soul_reaper.up&debuff.festering_wound.stack>=1
    if target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffStacks(festering_wound_debuff) >= 1 Spell(scourge_strike)
    #clawing_shadows,if=debuff.soul_reaper.up&debuff.festering_wound.stack>=1
    if target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffStacks(festering_wound_debuff) >= 1 Spell(clawing_shadows)
    #call_action_list,name=aoe,if=active_enemies>=2
    if Enemies(tagged=1) >= 2 UnholyAoeMainActions()

    unless Enemies(tagged=1) >= 2 and UnholyAoeMainPostConditions()
    {
        #call_action_list,name=instructors,if=equipped.132448
        if HasEquippedItem(132448) UnholyInstructorsMainActions()

        unless HasEquippedItem(132448) and UnholyInstructorsMainPostConditions()
        {
            #call_action_list,name=standard,if=!talent.castigator.enabled&!equipped.132448
            if not Talent(castigator_talent) and not HasEquippedItem(132448) UnholyStandardMainActions()

            unless not Talent(castigator_talent) and not HasEquippedItem(132448) and UnholyStandardMainPostConditions()
            {
                #call_action_list,name=castigator,if=talent.castigator.enabled&!equipped.132448
                if Talent(castigator_talent) and not HasEquippedItem(132448) UnholyCastigatorMainActions()
            }
        }
    }
}

AddFunction UnholyGenericMainPostConditions
{
    Enemies(tagged=1) >= 2 and UnholyAoeMainPostConditions() or HasEquippedItem(132448) and UnholyInstructorsMainPostConditions() or not Talent(castigator_talent) and not HasEquippedItem(132448) and UnholyStandardMainPostConditions() or Talent(castigator_talent) and not HasEquippedItem(132448) and UnholyCastigatorMainPostConditions()
}

AddFunction UnholyGenericShortCdActions
{
    #apocalypse,if=equipped.137075&debuff.festering_wound.stack>=6&talent.dark_arbiter.enabled
    if HasEquippedItem(137075) and target.DebuffStacks(festering_wound_debuff) >= 6 and Talent(dark_arbiter_talent) Spell(apocalypse)

    unless BuffPresent(unholy_strength_buff) and BuffStacks(cold_heart_buff) > 19 and Spell(chains_of_ice)
    {
        #soul_reaper,if=debuff.festering_wound.stack>=6&cooldown.apocalypse.remains<4
        if target.DebuffStacks(festering_wound_debuff) >= 6 and SpellCooldown(apocalypse) < 4 Spell(soul_reaper_unholy)
        #apocalypse,if=debuff.festering_wound.stack>=6
        if target.DebuffStacks(festering_wound_debuff) >= 6 Spell(apocalypse)

        unless RunicPowerDeficit() < 10 and Spell(death_coil) or not Talent(dark_arbiter_talent) and BuffPresent(sudden_doom_buff) and not BuffPresent(necrosis_buff) and Rune() < 4 and Spell(death_coil) or Talent(dark_arbiter_talent) and BuffPresent(sudden_doom_buff) and SpellCooldown(dark_arbiter) > 5 and Rune() < 4 and Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) <= 6 and Spell(festering_strike)
        {
            #soul_reaper,if=debuff.festering_wound.stack>=3
            if target.DebuffStacks(festering_wound_debuff) >= 3 Spell(soul_reaper_unholy)

            unless target.DebuffPresent(soul_reaper_unholy_debuff) and not target.DebuffPresent(festering_wound_debuff) and Spell(festering_strike) or target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffStacks(festering_wound_debuff) >= 1 and Spell(scourge_strike) or target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffStacks(festering_wound_debuff) >= 1 and Spell(clawing_shadows)
            {
                #defile
                Spell(defile)
                #call_action_list,name=aoe,if=active_enemies>=2
                if Enemies(tagged=1) >= 2 UnholyAoeShortCdActions()

                unless Enemies(tagged=1) >= 2 and UnholyAoeShortCdPostConditions()
                {
                    #call_action_list,name=instructors,if=equipped.132448
                    if HasEquippedItem(132448) UnholyInstructorsShortCdActions()

                    unless HasEquippedItem(132448) and UnholyInstructorsShortCdPostConditions()
                    {
                        #call_action_list,name=standard,if=!talent.castigator.enabled&!equipped.132448
                        if not Talent(castigator_talent) and not HasEquippedItem(132448) UnholyStandardShortCdActions()

                        unless not Talent(castigator_talent) and not HasEquippedItem(132448) and UnholyStandardShortCdPostConditions()
                        {
                            #call_action_list,name=castigator,if=talent.castigator.enabled&!equipped.132448
                            if Talent(castigator_talent) and not HasEquippedItem(132448) UnholyCastigatorShortCdActions()
                        }
                    }
                }
            }
        }
    }
}

AddFunction UnholyGenericShortCdPostConditions
{
    BuffPresent(unholy_strength_buff) and BuffStacks(cold_heart_buff) > 19 and Spell(chains_of_ice) or RunicPowerDeficit() < 10 and Spell(death_coil) or not Talent(dark_arbiter_talent) and BuffPresent(sudden_doom_buff) and not BuffPresent(necrosis_buff) and Rune() < 4 and Spell(death_coil) or Talent(dark_arbiter_talent) and BuffPresent(sudden_doom_buff) and SpellCooldown(dark_arbiter) > 5 and Rune() < 4 and Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) <= 6 and Spell(festering_strike) or target.DebuffPresent(soul_reaper_unholy_debuff) and not target.DebuffPresent(festering_wound_debuff) and Spell(festering_strike) or target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffStacks(festering_wound_debuff) >= 1 and Spell(scourge_strike) or target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffStacks(festering_wound_debuff) >= 1 and Spell(clawing_shadows) or Enemies(tagged=1) >= 2 and UnholyAoeShortCdPostConditions() or HasEquippedItem(132448) and UnholyInstructorsShortCdPostConditions() or not Talent(castigator_talent) and not HasEquippedItem(132448) and UnholyStandardShortCdPostConditions() or Talent(castigator_talent) and not HasEquippedItem(132448) and UnholyCastigatorShortCdPostConditions()
}

AddFunction UnholyGenericCdActions
{
    #dark_arbiter,if=!equipped.137075&runic_power.deficit<30
    if not HasEquippedItem(137075) and RunicPowerDeficit() < 30 Spell(dark_arbiter)

    unless HasEquippedItem(137075) and target.DebuffStacks(festering_wound_debuff) >= 6 and Talent(dark_arbiter_talent) and Spell(apocalypse)
    {
        #dark_arbiter,if=equipped.137075&runic_power.deficit<30&cooldown.dark_transformation.remains<2
        if HasEquippedItem(137075) and RunicPowerDeficit() < 30 and SpellCooldown(dark_transformation) < 2 Spell(dark_arbiter)
        #summon_gargoyle,if=!equipped.137075,if=rune<=3
        if Rune() < 4 Spell(summon_gargoyle)

        unless BuffPresent(unholy_strength_buff) and BuffStacks(cold_heart_buff) > 19 and Spell(chains_of_ice)
        {
            #summon_gargoyle,if=equipped.137075&cooldown.dark_transformation.remains<10&rune<=3
            if HasEquippedItem(137075) and SpellCooldown(dark_transformation) < 10 and Rune() < 4 Spell(summon_gargoyle)

            unless target.DebuffStacks(festering_wound_debuff) >= 6 and SpellCooldown(apocalypse) < 4 and Spell(soul_reaper_unholy) or target.DebuffStacks(festering_wound_debuff) >= 6 and Spell(apocalypse) or RunicPowerDeficit() < 10 and Spell(death_coil) or not Talent(dark_arbiter_talent) and BuffPresent(sudden_doom_buff) and not BuffPresent(necrosis_buff) and Rune() < 4 and Spell(death_coil) or Talent(dark_arbiter_talent) and BuffPresent(sudden_doom_buff) and SpellCooldown(dark_arbiter) > 5 and Rune() < 4 and Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) <= 6 and Spell(festering_strike) or target.DebuffStacks(festering_wound_debuff) >= 3 and Spell(soul_reaper_unholy) or target.DebuffPresent(soul_reaper_unholy_debuff) and not target.DebuffPresent(festering_wound_debuff) and Spell(festering_strike) or target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffStacks(festering_wound_debuff) >= 1 and Spell(scourge_strike) or target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffStacks(festering_wound_debuff) >= 1 and Spell(clawing_shadows) or Spell(defile)
            {
                #call_action_list,name=aoe,if=active_enemies>=2
                if Enemies(tagged=1) >= 2 UnholyAoeCdActions()

                unless Enemies(tagged=1) >= 2 and UnholyAoeCdPostConditions()
                {
                    #call_action_list,name=instructors,if=equipped.132448
                    if HasEquippedItem(132448) UnholyInstructorsCdActions()

                    unless HasEquippedItem(132448) and UnholyInstructorsCdPostConditions()
                    {
                        #call_action_list,name=standard,if=!talent.castigator.enabled&!equipped.132448
                        if not Talent(castigator_talent) and not HasEquippedItem(132448) UnholyStandardCdActions()

                        unless not Talent(castigator_talent) and not HasEquippedItem(132448) and UnholyStandardCdPostConditions()
                        {
                            #call_action_list,name=castigator,if=talent.castigator.enabled&!equipped.132448
                            if Talent(castigator_talent) and not HasEquippedItem(132448) UnholyCastigatorCdActions()
                        }
                    }
                }
            }
        }
    }
}

AddFunction UnholyGenericCdPostConditions
{
    HasEquippedItem(137075) and target.DebuffStacks(festering_wound_debuff) >= 6 and Talent(dark_arbiter_talent) and Spell(apocalypse) or BuffPresent(unholy_strength_buff) and BuffStacks(cold_heart_buff) > 19 and Spell(chains_of_ice) or target.DebuffStacks(festering_wound_debuff) >= 6 and SpellCooldown(apocalypse) < 4 and Spell(soul_reaper_unholy) or target.DebuffStacks(festering_wound_debuff) >= 6 and Spell(apocalypse) or RunicPowerDeficit() < 10 and Spell(death_coil) or not Talent(dark_arbiter_talent) and BuffPresent(sudden_doom_buff) and not BuffPresent(necrosis_buff) and Rune() < 4 and Spell(death_coil) or Talent(dark_arbiter_talent) and BuffPresent(sudden_doom_buff) and SpellCooldown(dark_arbiter) > 5 and Rune() < 4 and Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) <= 6 and Spell(festering_strike) or target.DebuffStacks(festering_wound_debuff) >= 3 and Spell(soul_reaper_unholy) or target.DebuffPresent(soul_reaper_unholy_debuff) and not target.DebuffPresent(festering_wound_debuff) and Spell(festering_strike) or target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffStacks(festering_wound_debuff) >= 1 and Spell(scourge_strike) or target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffStacks(festering_wound_debuff) >= 1 and Spell(clawing_shadows) or Spell(defile) or Enemies(tagged=1) >= 2 and UnholyAoeCdPostConditions() or HasEquippedItem(132448) and UnholyInstructorsCdPostConditions() or not Talent(castigator_talent) and not HasEquippedItem(132448) and UnholyStandardCdPostConditions() or Talent(castigator_talent) and not HasEquippedItem(132448) and UnholyCastigatorCdPostConditions()
}

### actions.instructors

AddFunction UnholyInstructorsMainActions
{
    #festering_strike,if=debuff.festering_wound.stack<=2&runic_power.deficit>5
    if target.DebuffStacks(festering_wound_debuff) <= 2 and RunicPowerDeficit() > 5 Spell(festering_strike)
    #death_coil,if=!buff.necrosis.up&talent.necrosis.enabled&rune<=3
    if not BuffPresent(necrosis_buff) and Talent(necrosis_talent) and Rune() < 4 Spell(death_coil)
    #scourge_strike,if=buff.necrosis.react&debuff.festering_wound.stack>=3&runic_power.deficit>9
    if BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 Spell(scourge_strike)
    #clawing_shadows,if=buff.necrosis.react&debuff.festering_wound.stack>=3&runic_power.deficit>9
    if BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 Spell(clawing_shadows)
    #scourge_strike,if=buff.unholy_strength.react&debuff.festering_wound.stack>=3&runic_power.deficit>9
    if BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 Spell(scourge_strike)
    #clawing_shadows,if=buff.unholy_strength.react&debuff.festering_wound.stack>=3&runic_power.deficit>9
    if BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 Spell(clawing_shadows)
    #scourge_strike,if=rune>=2&debuff.festering_wound.stack>=3&runic_power.deficit>9
    if Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 Spell(scourge_strike)
    #clawing_shadows,if=rune>=2&debuff.festering_wound.stack>=3&runic_power.deficit>9
    if Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 Spell(clawing_shadows)
    #death_coil,if=talent.shadow_infusion.enabled&talent.dark_arbiter.enabled&!buff.dark_transformation.up&cooldown.dark_arbiter.remains>10
    if Talent(shadow_infusion_talent) and Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and SpellCooldown(dark_arbiter) > 10 Spell(death_coil)
    #death_coil,if=talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled&!buff.dark_transformation.up
    if Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) Spell(death_coil)
    #death_coil,if=talent.dark_arbiter.enabled&cooldown.dark_arbiter.remains>10
    if Talent(dark_arbiter_talent) and SpellCooldown(dark_arbiter) > 10 Spell(death_coil)
    #death_coil,if=!talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled
    if not Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) Spell(death_coil)
}

AddFunction UnholyInstructorsMainPostConditions
{
}

AddFunction UnholyInstructorsShortCdActions
{
}

AddFunction UnholyInstructorsShortCdPostConditions
{
    target.DebuffStacks(festering_wound_debuff) <= 2 and RunicPowerDeficit() > 5 and Spell(festering_strike) or not BuffPresent(necrosis_buff) and Talent(necrosis_talent) and Rune() < 4 and Spell(death_coil) or BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 and Spell(scourge_strike) or BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 and Spell(clawing_shadows) or BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 and Spell(scourge_strike) or BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 and Spell(clawing_shadows) or Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 and Spell(scourge_strike) or Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 and Spell(clawing_shadows) or Talent(shadow_infusion_talent) and Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and SpellCooldown(dark_arbiter) > 10 and Spell(death_coil) or Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and Spell(death_coil) or Talent(dark_arbiter_talent) and SpellCooldown(dark_arbiter) > 10 and Spell(death_coil) or not Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and Spell(death_coil)
}

AddFunction UnholyInstructorsCdActions
{
}

AddFunction UnholyInstructorsCdPostConditions
{
    target.DebuffStacks(festering_wound_debuff) <= 2 and RunicPowerDeficit() > 5 and Spell(festering_strike) or not BuffPresent(necrosis_buff) and Talent(necrosis_talent) and Rune() < 4 and Spell(death_coil) or BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 and Spell(scourge_strike) or BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 and Spell(clawing_shadows) or BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 and Spell(scourge_strike) or BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 and Spell(clawing_shadows) or Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 and Spell(scourge_strike) or Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 3 and RunicPowerDeficit() > 9 and Spell(clawing_shadows) or Talent(shadow_infusion_talent) and Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and SpellCooldown(dark_arbiter) > 10 and Spell(death_coil) or Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and Spell(death_coil) or Talent(dark_arbiter_talent) and SpellCooldown(dark_arbiter) > 10 and Spell(death_coil) or not Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and Spell(death_coil)
}

### actions.precombat

AddFunction UnholyPrecombatMainActions
{
}

AddFunction UnholyPrecombatMainPostConditions
{
}

AddFunction UnholyPrecombatShortCdActions
{
    #raise_dead
    Spell(raise_dead)
}

AddFunction UnholyPrecombatShortCdPostConditions
{
}

AddFunction UnholyPrecombatCdActions
{
    #flask
    #food
    #augmentation
    #snapshot_stats
    #potion
    # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)

    unless Spell(raise_dead)
    {
        #army_of_the_dead
        Spell(army_of_the_dead)
    }
}

AddFunction UnholyPrecombatCdPostConditions
{
    Spell(raise_dead)
}

### actions.standard

AddFunction UnholyStandardMainActions
{
    #festering_strike,if=debuff.festering_wound.stack<=2&runic_power.deficit>5
    if target.DebuffStacks(festering_wound_debuff) <= 2 and RunicPowerDeficit() > 5 Spell(festering_strike)
    #death_coil,if=!buff.necrosis.up&talent.necrosis.enabled&rune<=3
    if not BuffPresent(necrosis_buff) and Talent(necrosis_talent) and Rune() < 4 Spell(death_coil)
    #scourge_strike,if=buff.necrosis.react&debuff.festering_wound.stack>=1&runic_power.deficit>9
    if BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 Spell(scourge_strike)
    #clawing_shadows,if=buff.necrosis.react&debuff.festering_wound.stack>=1&runic_power.deficit>9
    if BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 Spell(clawing_shadows)
    #scourge_strike,if=buff.unholy_strength.react&debuff.festering_wound.stack>=1&runic_power.deficit>9
    if BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 Spell(scourge_strike)
    #clawing_shadows,if=buff.unholy_strength.react&debuff.festering_wound.stack>=1&runic_power.deficit>9
    if BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 Spell(clawing_shadows)
    #scourge_strike,if=rune>=2&debuff.festering_wound.stack>=1&runic_power.deficit>9
    if Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 Spell(scourge_strike)
    #clawing_shadows,if=rune>=2&debuff.festering_wound.stack>=1&runic_power.deficit>9
    if Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 Spell(clawing_shadows)
    #death_coil,if=talent.shadow_infusion.enabled&talent.dark_arbiter.enabled&!buff.dark_transformation.up&cooldown.dark_arbiter.remains>10
    if Talent(shadow_infusion_talent) and Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and SpellCooldown(dark_arbiter) > 10 Spell(death_coil)
    #death_coil,if=talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled&!buff.dark_transformation.up
    if Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) Spell(death_coil)
    #death_coil,if=talent.dark_arbiter.enabled&cooldown.dark_arbiter.remains>10
    if Talent(dark_arbiter_talent) and SpellCooldown(dark_arbiter) > 10 Spell(death_coil)
    #death_coil,if=!talent.shadow_infusion.enabled&!talent.dark_arbiter.enabled
    if not Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) Spell(death_coil)
}

AddFunction UnholyStandardMainPostConditions
{
}

AddFunction UnholyStandardShortCdActions
{
}

AddFunction UnholyStandardShortCdPostConditions
{
    target.DebuffStacks(festering_wound_debuff) <= 2 and RunicPowerDeficit() > 5 and Spell(festering_strike) or not BuffPresent(necrosis_buff) and Talent(necrosis_talent) and Rune() < 4 and Spell(death_coil) or BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 and Spell(scourge_strike) or BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 and Spell(clawing_shadows) or BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 and Spell(scourge_strike) or BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 and Spell(clawing_shadows) or Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 and Spell(scourge_strike) or Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 and Spell(clawing_shadows) or Talent(shadow_infusion_talent) and Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and SpellCooldown(dark_arbiter) > 10 and Spell(death_coil) or Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and Spell(death_coil) or Talent(dark_arbiter_talent) and SpellCooldown(dark_arbiter) > 10 and Spell(death_coil) or not Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and Spell(death_coil)
}

AddFunction UnholyStandardCdActions
{
}

AddFunction UnholyStandardCdPostConditions
{
    target.DebuffStacks(festering_wound_debuff) <= 2 and RunicPowerDeficit() > 5 and Spell(festering_strike) or not BuffPresent(necrosis_buff) and Talent(necrosis_talent) and Rune() < 4 and Spell(death_coil) or BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 and Spell(scourge_strike) or BuffPresent(necrosis_buff) and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 and Spell(clawing_shadows) or BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 and Spell(scourge_strike) or BuffPresent(unholy_strength_buff) and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 and Spell(clawing_shadows) or Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 and Spell(scourge_strike) or Rune() >= 2 and target.DebuffStacks(festering_wound_debuff) >= 1 and RunicPowerDeficit() > 9 and Spell(clawing_shadows) or Talent(shadow_infusion_talent) and Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and SpellCooldown(dark_arbiter) > 10 and Spell(death_coil) or Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and not pet.BuffPresent(dark_transformation_buff) and Spell(death_coil) or Talent(dark_arbiter_talent) and SpellCooldown(dark_arbiter) > 10 and Spell(death_coil) or not Talent(shadow_infusion_talent) and not Talent(dark_arbiter_talent) and Spell(death_coil)
}

### actions.valkyr

AddFunction UnholyValkyrMainActions
{
    #death_coil
    Spell(death_coil)
    #festering_strike,if=debuff.festering_wound.stack<6&cooldown.apocalypse.remains<3
    if target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) < 3 Spell(festering_strike)
    #call_action_list,name=aoe,if=active_enemies>=2
    if Enemies(tagged=1) >= 2 UnholyAoeMainActions()

    unless Enemies(tagged=1) >= 2 and UnholyAoeMainPostConditions()
    {
        #festering_strike,if=debuff.festering_wound.stack<=4
        if target.DebuffStacks(festering_wound_debuff) <= 4 Spell(festering_strike)
        #scourge_strike,if=debuff.festering_wound.up
        if target.DebuffPresent(festering_wound_debuff) Spell(scourge_strike)
        #clawing_shadows,if=debuff.festering_wound.up
        if target.DebuffPresent(festering_wound_debuff) Spell(clawing_shadows)
    }
}

AddFunction UnholyValkyrMainPostConditions
{
    Enemies(tagged=1) >= 2 and UnholyAoeMainPostConditions()
}

AddFunction UnholyValkyrShortCdActions
{
    unless Spell(death_coil)
    {
        #apocalypse,if=debuff.festering_wound.stack>=6
        if target.DebuffStacks(festering_wound_debuff) >= 6 Spell(apocalypse)

        unless target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) < 3 and Spell(festering_strike)
        {
            #call_action_list,name=aoe,if=active_enemies>=2
            if Enemies(tagged=1) >= 2 UnholyAoeShortCdActions()
        }
    }
}

AddFunction UnholyValkyrShortCdPostConditions
{
    Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) < 3 and Spell(festering_strike) or Enemies(tagged=1) >= 2 and UnholyAoeShortCdPostConditions() or target.DebuffStacks(festering_wound_debuff) <= 4 and Spell(festering_strike) or target.DebuffPresent(festering_wound_debuff) and Spell(scourge_strike) or target.DebuffPresent(festering_wound_debuff) and Spell(clawing_shadows)
}

AddFunction UnholyValkyrCdActions
{
    unless Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) >= 6 and Spell(apocalypse) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) < 3 and Spell(festering_strike)
    {
        #call_action_list,name=aoe,if=active_enemies>=2
        if Enemies(tagged=1) >= 2 UnholyAoeCdActions()
    }
}

AddFunction UnholyValkyrCdPostConditions
{
    Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) >= 6 and Spell(apocalypse) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) < 3 and Spell(festering_strike) or Enemies(tagged=1) >= 2 and UnholyAoeCdPostConditions() or target.DebuffStacks(festering_wound_debuff) <= 4 and Spell(festering_strike) or target.DebuffPresent(festering_wound_debuff) and Spell(scourge_strike) or target.DebuffPresent(festering_wound_debuff) and Spell(clawing_shadows)
}
]]

	OvaleScripts:RegisterScript("DEATHKNIGHT", "unholy", name, desc, code, "script")
end
