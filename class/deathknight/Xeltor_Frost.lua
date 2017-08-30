local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_frost"
	local desc = "[Xel][7.1] Death Knight: Frost"
	local code = [[
# Based on SimulationCraft profile "Death_Knight_Frost_T19H".
#    class=deathknight
#    spec=frost
#    talents=2330021

# Include Ovale Defaults (racials & trinkets).
Include(ovale_common)

Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_deathknight_spells)

# Frost
AddIcon specialization=2 help=main
{
	# Interrupt
	if InCombat() InterruptActions()
	
    if target.InRange(frost_strike) and HasFullControl()
    {
		# Custom - DO NOT REMOVE
		if BuffStacks(dark_succor_buff) Spell(death_strike)
		
		# Cooldown
		if Boss()
		{
			FrostDefaultCdActions()
		}
		
		# Short Cooldown
		FrostDefaultShortCdActions()
		
		# Main rotation
		FrostDefaultMainActions()
    }
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

# Common functions.
AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible()
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

AddFunction FrostDefaultMainActions
{
    #run_action_list,name=bos,if=dot.breath_of_sindragosa.ticking
    if BuffPresent(breath_of_sindragosa_buff) FrostBosMainActions()

    unless BuffPresent(breath_of_sindragosa_buff) and FrostBosMainPostConditions()
    {
        #call_action_list,name=shatter,if=talent.shattering_strikes.enabled
        if Talent(shattering_strikes_talent) FrostShatterMainActions()

        unless Talent(shattering_strikes_talent) and FrostShatterMainPostConditions()
        {
            #call_action_list,name=icytalons,if=talent.icy_talons.enabled
            if Talent(icy_talons_talent) FrostIcytalonsMainActions()

            unless Talent(icy_talons_talent) and FrostIcytalonsMainPostConditions()
            {
                #call_action_list,name=generic,if=(!talent.shattering_strikes.enabled&!talent.icy_talons.enabled)
                if not Talent(shattering_strikes_talent) and not Talent(icy_talons_talent) FrostGenericMainActions()
            }
        }
    }
}

AddFunction FrostDefaultMainPostConditions
{
    BuffPresent(breath_of_sindragosa_buff) and FrostBosMainPostConditions() or Talent(shattering_strikes_talent) and FrostShatterMainPostConditions() or Talent(icy_talons_talent) and FrostIcytalonsMainPostConditions() or not Talent(shattering_strikes_talent) and not Talent(icy_talons_talent) and FrostGenericMainPostConditions()
}

AddFunction FrostDefaultShortCdActions
{
    #auto_attack
    # FrostGetInMeleeRange()
    #pillar_of_frost
    Spell(pillar_of_frost)
    #obliteration
    Spell(obliteration)
    #run_action_list,name=bos,if=dot.breath_of_sindragosa.ticking
    if BuffPresent(breath_of_sindragosa_buff) FrostBosShortCdActions()

    unless BuffPresent(breath_of_sindragosa_buff) and FrostBosShortCdPostConditions()
    {
        #call_action_list,name=shatter,if=talent.shattering_strikes.enabled
        if Talent(shattering_strikes_talent) FrostShatterShortCdActions()

        unless Talent(shattering_strikes_talent) and FrostShatterShortCdPostConditions()
        {
            #call_action_list,name=icytalons,if=talent.icy_talons.enabled
            if Talent(icy_talons_talent) FrostIcytalonsShortCdActions()

            unless Talent(icy_talons_talent) and FrostIcytalonsShortCdPostConditions()
            {
                #call_action_list,name=generic,if=(!talent.shattering_strikes.enabled&!talent.icy_talons.enabled)
                if not Talent(shattering_strikes_talent) and not Talent(icy_talons_talent) FrostGenericShortCdActions()
            }
        }
    }
}

AddFunction FrostDefaultShortCdPostConditions
{
    BuffPresent(breath_of_sindragosa_buff) and FrostBosShortCdPostConditions() or Talent(shattering_strikes_talent) and FrostShatterShortCdPostConditions() or Talent(icy_talons_talent) and FrostIcytalonsShortCdPostConditions() or not Talent(shattering_strikes_talent) and not Talent(icy_talons_talent) and FrostGenericShortCdPostConditions()
}

AddFunction FrostDefaultCdActions
{
    #arcane_torrent,if=runic_power.deficit>20
    if RunicPowerDeficit() > 20 Spell(arcane_torrent_runicpower)
    #blood_fury,if=!talent.breath_of_sindragosa.enabled|dot.breath_of_sindragosa.ticking
    if not Talent(breath_of_sindragosa_talent) or BuffPresent(breath_of_sindragosa_buff) Spell(blood_fury_ap)
    #berserking,if=buff.pillar_of_frost.up
    if BuffPresent(pillar_of_frost_buff) Spell(berserking)
    #use_item,slot=finger2
    # if CheckBoxOn(opt_legendary_ring_strength) Item(legendary_ring_strength usable=1)
    #use_item,slot=trinket1
    # FrostUseItemActions()
    #potion,name=old_war
    #sindragosas_fury,if=buff.pillar_of_frost.up
    if BuffPresent(pillar_of_frost_buff) Spell(sindragosas_fury)

    unless Spell(obliteration)
    {
        #breath_of_sindragosa,if=runic_power>=50
        if RunicPower() >= 50 Spell(breath_of_sindragosa)
        #run_action_list,name=bos,if=dot.breath_of_sindragosa.ticking
        if BuffPresent(breath_of_sindragosa_buff) FrostBosCdActions()

        unless BuffPresent(breath_of_sindragosa_buff) and FrostBosCdPostConditions()
        {
            #call_action_list,name=shatter,if=talent.shattering_strikes.enabled
            if Talent(shattering_strikes_talent) FrostShatterCdActions()

            unless Talent(shattering_strikes_talent) and FrostShatterCdPostConditions()
            {
                #call_action_list,name=icytalons,if=talent.icy_talons.enabled
                if Talent(icy_talons_talent) FrostIcytalonsCdActions()

                unless Talent(icy_talons_talent) and FrostIcytalonsCdPostConditions()
                {
                    #call_action_list,name=generic,if=(!talent.shattering_strikes.enabled&!talent.icy_talons.enabled)
                    if not Talent(shattering_strikes_talent) and not Talent(icy_talons_talent) FrostGenericCdActions()
                }
            }
        }
    }
}

AddFunction FrostDefaultCdPostConditions
{
    Spell(obliteration) or BuffPresent(breath_of_sindragosa_buff) and FrostBosCdPostConditions() or Talent(shattering_strikes_talent) and FrostShatterCdPostConditions() or Talent(icy_talons_talent) and FrostIcytalonsCdPostConditions() or not Talent(shattering_strikes_talent) and not Talent(icy_talons_talent) and FrostGenericCdPostConditions()
}

### actions.bos

AddFunction FrostBosMainActions
{
    #howling_blast,target_if=!dot.frost_fever.ticking
    if not target.DebuffPresent(frost_fever_debuff) Spell(howling_blast)
    #call_action_list,name=core
    FrostCoreMainActions()

    unless FrostCoreMainPostConditions()
    {
        #howling_blast,if=buff.rime.react
        if BuffPresent(rime_buff) Spell(howling_blast)
    }
}

AddFunction FrostBosMainPostConditions
{
    FrostCoreMainPostConditions()
}

AddFunction FrostBosShortCdActions
{
    unless not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast)
    {
        #call_action_list,name=core
        FrostCoreShortCdActions()

        unless FrostCoreShortCdPostConditions()
        {
            #horn_of_winter
            if BuffExpires(attack_power_multiplier_buff any=1) Spell(horn_of_winter)
        }
    }
}

AddFunction FrostBosShortCdPostConditions
{
    not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast) or FrostCoreShortCdPostConditions() or BuffPresent(rime_buff) and Spell(howling_blast)
}

AddFunction FrostBosCdActions
{
    unless not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast)
    {
        #call_action_list,name=core
        FrostCoreCdActions()

        unless FrostCoreCdPostConditions() or BuffExpires(attack_power_multiplier_buff any=1) and Spell(horn_of_winter)
        {
            #empower_rune_weapon,if=runic_power<=70
            if RunicPower() <= 70 Spell(empower_rune_weapon)
            #hungering_rune_weapon
            Spell(hungering_rune_weapon)
        }
    }
}

AddFunction FrostBosCdPostConditions
{
    not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast) or FrostCoreCdPostConditions() or BuffExpires(attack_power_multiplier_buff any=1) and Spell(horn_of_winter) or BuffPresent(rime_buff) and Spell(howling_blast)
}

### actions.core

AddFunction FrostCoreMainActions
{
    #remorseless_winter,if=artifact.frozen_soul.enabled
    if BuffPresent(frozen_soul_buff) Spell(remorseless_winter)
    #glacial_advance
    Spell(glacial_advance)
    #frost_strike,if=buff.obliteration.up&!buff.killing_machine.react
    if BuffPresent(obliteration_buff) and not BuffPresent(killing_machine_buff) Spell(frost_strike)
    #remorseless_winter,if=spell_targets.remorseless_winter>=2|talent.gathering_storm.enabled
    if Enemies(tagged=1) >= 2 or Talent(gathering_storm_talent) Spell(remorseless_winter)
    #frostscythe,if=!talent.breath_of_sindragosa.enabled&(buff.killing_machine.react|spell_targets.frostscythe>=4)
    if not Talent(breath_of_sindragosa_talent) and { BuffPresent(killing_machine_buff) or Enemies(tagged=1) >= 4 } Spell(frostscythe)
    #obliterate,if=buff.killing_machine.react
    if BuffPresent(killing_machine_buff) Spell(obliterate)
    #obliterate
    Spell(obliterate)
    #remorseless_winter
    Spell(remorseless_winter)
    #frostscythe,if=talent.frozen_pulse.enabled
    if Talent(frozen_pulse_talent) Spell(frostscythe)
    #howling_blast,if=talent.frozen_pulse.enabled
    if Talent(frozen_pulse_talent) Spell(howling_blast)
}

AddFunction FrostCoreMainPostConditions
{
}

AddFunction FrostCoreShortCdActions
{
}

AddFunction FrostCoreShortCdPostConditions
{
    BuffPresent(frozen_soul_buff) and Spell(remorseless_winter) or Spell(glacial_advance) or BuffPresent(obliteration_buff) and not BuffPresent(killing_machine_buff) and Spell(frost_strike) or { Enemies(tagged=1) >= 2 or Talent(gathering_storm_talent) } and Spell(remorseless_winter) or not Talent(breath_of_sindragosa_talent) and { BuffPresent(killing_machine_buff) or Enemies(tagged=1) >= 4 } and Spell(frostscythe) or BuffPresent(killing_machine_buff) and Spell(obliterate) or Spell(obliterate) or Spell(remorseless_winter) or Talent(frozen_pulse_talent) and Spell(frostscythe) or Talent(frozen_pulse_talent) and Spell(howling_blast)
}

AddFunction FrostCoreCdActions
{
}

AddFunction FrostCoreCdPostConditions
{
    BuffPresent(frozen_soul_buff) and Spell(remorseless_winter) or Spell(glacial_advance) or BuffPresent(obliteration_buff) and not BuffPresent(killing_machine_buff) and Spell(frost_strike) or { Enemies(tagged=1) >= 2 or Talent(gathering_storm_talent) } and Spell(remorseless_winter) or not Talent(breath_of_sindragosa_talent) and { BuffPresent(killing_machine_buff) or Enemies(tagged=1) >= 4 } and Spell(frostscythe) or BuffPresent(killing_machine_buff) and Spell(obliterate) or Spell(obliterate) or Spell(remorseless_winter) or Talent(frozen_pulse_talent) and Spell(frostscythe) or Talent(frozen_pulse_talent) and Spell(howling_blast)
}

### actions.generic

AddFunction FrostGenericMainActions
{
    #howling_blast,target_if=!dot.frost_fever.ticking
    if not target.DebuffPresent(frost_fever_debuff) Spell(howling_blast)
    #howling_blast,if=buff.rime.react
    if BuffPresent(rime_buff) Spell(howling_blast)
    #frost_strike,if=runic_power>=80
    if RunicPower() >= 80 Spell(frost_strike)
    #call_action_list,name=core
    FrostCoreMainActions()

    unless FrostCoreMainPostConditions()
    {
        #frost_strike,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
        if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 Spell(frost_strike)
        #frost_strike,if=!talent.breath_of_sindragosa.enabled
        if not Talent(breath_of_sindragosa_talent) Spell(frost_strike)
    }
}

AddFunction FrostGenericMainPostConditions
{
    FrostCoreMainPostConditions()
}

AddFunction FrostGenericShortCdActions
{
    unless not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast) or BuffPresent(rime_buff) and Spell(howling_blast) or RunicPower() >= 80 and Spell(frost_strike)
    {
        #call_action_list,name=core
        FrostCoreShortCdActions()

        unless FrostCoreShortCdPostConditions()
        {
            #horn_of_winter,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
            if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and BuffExpires(attack_power_multiplier_buff any=1) Spell(horn_of_winter)
            #horn_of_winter,if=!talent.breath_of_sindragosa.enabled
            if not Talent(breath_of_sindragosa_talent) and BuffExpires(attack_power_multiplier_buff any=1) Spell(horn_of_winter)
        }
    }
}

AddFunction FrostGenericShortCdPostConditions
{
    not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast) or BuffPresent(rime_buff) and Spell(howling_blast) or RunicPower() >= 80 and Spell(frost_strike) or FrostCoreShortCdPostConditions() or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and Spell(frost_strike) or not Talent(breath_of_sindragosa_talent) and Spell(frost_strike)
}

AddFunction FrostGenericCdActions
{
    unless not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast) or BuffPresent(rime_buff) and Spell(howling_blast) or RunicPower() >= 80 and Spell(frost_strike)
    {
        #call_action_list,name=core
        FrostCoreCdActions()

        unless FrostCoreCdPostConditions() or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and BuffExpires(attack_power_multiplier_buff any=1) and Spell(horn_of_winter) or not Talent(breath_of_sindragosa_talent) and BuffExpires(attack_power_multiplier_buff any=1) and Spell(horn_of_winter) or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and Spell(frost_strike) or not Talent(breath_of_sindragosa_talent) and Spell(frost_strike)
        {
            #empower_rune_weapon,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
            if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 Spell(empower_rune_weapon)
            #hungering_rune_weapon,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
            if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 Spell(hungering_rune_weapon)
            #empower_rune_weapon,if=!talent.breath_of_sindragosa.enabled
            if not Talent(breath_of_sindragosa_talent) Spell(empower_rune_weapon)
            #hungering_rune_weapon,if=!talent.breath_of_sindragosa.enabled
            if not Talent(breath_of_sindragosa_talent) Spell(hungering_rune_weapon)
        }
    }
}

AddFunction FrostGenericCdPostConditions
{
    not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast) or BuffPresent(rime_buff) and Spell(howling_blast) or RunicPower() >= 80 and Spell(frost_strike) or FrostCoreCdPostConditions() or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and BuffExpires(attack_power_multiplier_buff any=1) and Spell(horn_of_winter) or not Talent(breath_of_sindragosa_talent) and BuffExpires(attack_power_multiplier_buff any=1) and Spell(horn_of_winter) or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and Spell(frost_strike) or not Talent(breath_of_sindragosa_talent) and Spell(frost_strike)
}

### actions.icytalons

AddFunction FrostIcytalonsMainActions
{
    #frost_strike,if=buff.icy_talons.remains<1.5
    if BuffRemaining(icy_talons_buff) < 1.5 Spell(frost_strike)
    #howling_blast,target_if=!dot.frost_fever.ticking
    if not target.DebuffPresent(frost_fever_debuff) Spell(howling_blast)
    #howling_blast,if=buff.rime.react
    if BuffPresent(rime_buff) Spell(howling_blast)
    #frost_strike,if=runic_power>=80|buff.icy_talons.stack<3
    if RunicPower() >= 80 or BuffStacks(icy_talons_buff) < 3 Spell(frost_strike)
    #call_action_list,name=core
    FrostCoreMainActions()

    unless FrostCoreMainPostConditions()
    {
        #frost_strike,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
        if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 Spell(frost_strike)
        #frost_strike,if=!talent.breath_of_sindragosa.enabled
        if not Talent(breath_of_sindragosa_talent) Spell(frost_strike)
    }
}

AddFunction FrostIcytalonsMainPostConditions
{
    FrostCoreMainPostConditions()
}

AddFunction FrostIcytalonsShortCdActions
{
    unless BuffRemaining(icy_talons_buff) < 1.5 and Spell(frost_strike) or not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast) or BuffPresent(rime_buff) and Spell(howling_blast) or { RunicPower() >= 80 or BuffStacks(icy_talons_buff) < 3 } and Spell(frost_strike)
    {
        #call_action_list,name=core
        FrostCoreShortCdActions()

        unless FrostCoreShortCdPostConditions()
        {
            #horn_of_winter,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
            if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and BuffExpires(attack_power_multiplier_buff any=1) Spell(horn_of_winter)
            #horn_of_winter,if=!talent.breath_of_sindragosa.enabled
            if not Talent(breath_of_sindragosa_talent) and BuffExpires(attack_power_multiplier_buff any=1) Spell(horn_of_winter)
        }
    }
}

AddFunction FrostIcytalonsShortCdPostConditions
{
    BuffRemaining(icy_talons_buff) < 1.5 and Spell(frost_strike) or not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast) or BuffPresent(rime_buff) and Spell(howling_blast) or { RunicPower() >= 80 or BuffStacks(icy_talons_buff) < 3 } and Spell(frost_strike) or FrostCoreShortCdPostConditions() or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and Spell(frost_strike) or not Talent(breath_of_sindragosa_talent) and Spell(frost_strike)
}

AddFunction FrostIcytalonsCdActions
{
    unless BuffRemaining(icy_talons_buff) < 1.5 and Spell(frost_strike) or not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast) or BuffPresent(rime_buff) and Spell(howling_blast) or { RunicPower() >= 80 or BuffStacks(icy_talons_buff) < 3 } and Spell(frost_strike)
    {
        #call_action_list,name=core
        FrostCoreCdActions()

        unless FrostCoreCdPostConditions() or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and BuffExpires(attack_power_multiplier_buff any=1) and Spell(horn_of_winter) or not Talent(breath_of_sindragosa_talent) and BuffExpires(attack_power_multiplier_buff any=1) and Spell(horn_of_winter) or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and Spell(frost_strike) or not Talent(breath_of_sindragosa_talent) and Spell(frost_strike)
        {
            #empower_rune_weapon,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
            if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 Spell(empower_rune_weapon)
            #hungering_rune_weapon,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
            if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 Spell(hungering_rune_weapon)
            #empower_rune_weapon,if=!talent.breath_of_sindragosa.enabled
            if not Talent(breath_of_sindragosa_talent) Spell(empower_rune_weapon)
            #hungering_rune_weapon,if=!talent.breath_of_sindragosa.enabled
            if not Talent(breath_of_sindragosa_talent) Spell(hungering_rune_weapon)
        }
    }
}

AddFunction FrostIcytalonsCdPostConditions
{
    BuffRemaining(icy_talons_buff) < 1.5 and Spell(frost_strike) or not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast) or BuffPresent(rime_buff) and Spell(howling_blast) or { RunicPower() >= 80 or BuffStacks(icy_talons_buff) < 3 } and Spell(frost_strike) or FrostCoreCdPostConditions() or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and BuffExpires(attack_power_multiplier_buff any=1) and Spell(horn_of_winter) or not Talent(breath_of_sindragosa_talent) and BuffExpires(attack_power_multiplier_buff any=1) and Spell(horn_of_winter) or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and Spell(frost_strike) or not Talent(breath_of_sindragosa_talent) and Spell(frost_strike)
}

### actions.precombat

AddFunction FrostPrecombatMainActions
{
    #flask,name=countless_armies
    #food,name=the_hungry_magister
    #augmentation,name=defiled
    # Spell(augmentation)
}

AddFunction FrostPrecombatMainPostConditions
{
}

AddFunction FrostPrecombatShortCdActions
{
}

AddFunction FrostPrecombatShortCdPostConditions
{
    # Spell(augmentation)
}

AddFunction FrostPrecombatCdActions
{
}

AddFunction FrostPrecombatCdPostConditions
{
    # Spell(augmentation)
}

### actions.shatter

AddFunction FrostShatterMainActions
{
    #frost_strike,if=debuff.razorice.stack=5
    if target.DebuffStacks(razorice_debuff) == 5 Spell(frost_strike)
    #howling_blast,target_if=!dot.frost_fever.ticking
    if not target.DebuffPresent(frost_fever_debuff) Spell(howling_blast)
    #howling_blast,if=buff.rime.react
    if BuffPresent(rime_buff) Spell(howling_blast)
    #frost_strike,if=runic_power>=80
    if RunicPower() >= 80 Spell(frost_strike)
    #call_action_list,name=core
    FrostCoreMainActions()

    unless FrostCoreMainPostConditions()
    {
        #frost_strike,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
        if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 Spell(frost_strike)
        #frost_strike,if=!talent.breath_of_sindragosa.enabled
        if not Talent(breath_of_sindragosa_talent) Spell(frost_strike)
    }
}

AddFunction FrostShatterMainPostConditions
{
    FrostCoreMainPostConditions()
}

AddFunction FrostShatterShortCdActions
{
    unless target.DebuffStacks(razorice_debuff) == 5 and Spell(frost_strike) or not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast) or BuffPresent(rime_buff) and Spell(howling_blast) or RunicPower() >= 80 and Spell(frost_strike)
    {
        #call_action_list,name=core
        FrostCoreShortCdActions()

        unless FrostCoreShortCdPostConditions()
        {
            #horn_of_winter,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
            if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and BuffExpires(attack_power_multiplier_buff any=1) Spell(horn_of_winter)
            #horn_of_winter,if=!talent.breath_of_sindragosa.enabled
            if not Talent(breath_of_sindragosa_talent) and BuffExpires(attack_power_multiplier_buff any=1) Spell(horn_of_winter)
        }
    }
}

AddFunction FrostShatterShortCdPostConditions
{
    target.DebuffStacks(razorice_debuff) == 5 and Spell(frost_strike) or not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast) or BuffPresent(rime_buff) and Spell(howling_blast) or RunicPower() >= 80 and Spell(frost_strike) or FrostCoreShortCdPostConditions() or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and Spell(frost_strike) or not Talent(breath_of_sindragosa_talent) and Spell(frost_strike)
}

AddFunction FrostShatterCdActions
{
    unless target.DebuffStacks(razorice_debuff) == 5 and Spell(frost_strike) or not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast) or BuffPresent(rime_buff) and Spell(howling_blast) or RunicPower() >= 80 and Spell(frost_strike)
    {
        #call_action_list,name=core
        FrostCoreCdActions()

        unless FrostCoreCdPostConditions() or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and BuffExpires(attack_power_multiplier_buff any=1) and Spell(horn_of_winter) or not Talent(breath_of_sindragosa_talent) and BuffExpires(attack_power_multiplier_buff any=1) and Spell(horn_of_winter) or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and Spell(frost_strike) or not Talent(breath_of_sindragosa_talent) and Spell(frost_strike)
        {
            #empower_rune_weapon,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
            if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 Spell(empower_rune_weapon)
            #hungering_rune_weapon,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>15
            if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 Spell(hungering_rune_weapon)
            #empower_rune_weapon,if=!talent.breath_of_sindragosa.enabled
            if not Talent(breath_of_sindragosa_talent) Spell(empower_rune_weapon)
            #hungering_rune_weapon,if=!talent.breath_of_sindragosa.enabled
            if not Talent(breath_of_sindragosa_talent) Spell(hungering_rune_weapon)
        }
    }
}

AddFunction FrostShatterCdPostConditions
{
    target.DebuffStacks(razorice_debuff) == 5 and Spell(frost_strike) or not target.DebuffPresent(frost_fever_debuff) and Spell(howling_blast) or BuffPresent(rime_buff) and Spell(howling_blast) or RunicPower() >= 80 and Spell(frost_strike) or FrostCoreCdPostConditions() or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and BuffExpires(attack_power_multiplier_buff any=1) and Spell(horn_of_winter) or not Talent(breath_of_sindragosa_talent) and BuffExpires(attack_power_multiplier_buff any=1) and Spell(horn_of_winter) or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 15 and Spell(frost_strike) or not Talent(breath_of_sindragosa_talent) and Spell(frost_strike)
}
]]

	OvaleScripts:RegisterScript("DEATHKNIGHT", "frost", name, desc, code, "script")
end
