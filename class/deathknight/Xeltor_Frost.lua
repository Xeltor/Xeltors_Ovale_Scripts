local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_frost"
	local desc = "[Xel][7.3] Death Knight: Frost"
	local code = [[
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
		if Boss() FrostDefaultCdActions()
		
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
        if target.InRange(mind_freeze) and target.IsInterruptible() Spell(mind_freeze)
        if target.Distance(less 12) and not target.Classification(worldboss) Spell(blinding_sleet)
        if target.Distance(less 8) and target.IsInterruptible() Spell(arcane_torrent_runicpower)
        if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
	}
}

### actions.default

AddFunction FrostDefaultMainActions
{
    #call_action_list,name=cds
    FrostCdsMainActions()

    unless FrostCdsMainPostConditions()
    {
        #run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains<15
        if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) < 15 FrostBosPoolingMainActions()

        unless Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) < 15 and FrostBosPoolingMainPostConditions()
        {
            #run_action_list,name=bos_ticking,if=dot.breath_of_sindragosa.ticking
            if BuffPresent(breath_of_sindragosa_buff) FrostBosTickingMainActions()

            unless BuffPresent(breath_of_sindragosa_buff) and FrostBosTickingMainPostConditions()
            {
                #run_action_list,name=obliteration,if=buff.obliteration.up
                if BuffPresent(obliteration_buff) FrostObliterationMainActions()

                unless BuffPresent(obliteration_buff) and FrostObliterationMainPostConditions()
                {
                    #call_action_list,name=standard
                    FrostStandardMainActions()
                }
            }
        }
    }
}

AddFunction FrostDefaultMainPostConditions
{
    FrostCdsMainPostConditions() or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) < 15 and FrostBosPoolingMainPostConditions() or BuffPresent(breath_of_sindragosa_buff) and FrostBosTickingMainPostConditions() or BuffPresent(obliteration_buff) and FrostObliterationMainPostConditions() or FrostStandardMainPostConditions()
}

AddFunction FrostDefaultShortCdActions
{
    #auto_attack
    # FrostGetInMeleeRange()
    #call_action_list,name=cds
    FrostCdsShortCdActions()

    unless FrostCdsShortCdPostConditions()
    {
        #run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains<15
        if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) < 15 FrostBosPoolingShortCdActions()

        unless Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) < 15 and FrostBosPoolingShortCdPostConditions()
        {
            #run_action_list,name=bos_ticking,if=dot.breath_of_sindragosa.ticking
            if BuffPresent(breath_of_sindragosa_buff) FrostBosTickingShortCdActions()

            unless BuffPresent(breath_of_sindragosa_buff) and FrostBosTickingShortCdPostConditions()
            {
                #run_action_list,name=obliteration,if=buff.obliteration.up
                if BuffPresent(obliteration_buff) FrostObliterationShortCdActions()

                unless BuffPresent(obliteration_buff) and FrostObliterationShortCdPostConditions()
                {
                    #call_action_list,name=standard
                    FrostStandardShortCdActions()
                }
            }
        }
    }
}

AddFunction FrostDefaultShortCdPostConditions
{
    FrostCdsShortCdPostConditions() or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) < 15 and FrostBosPoolingShortCdPostConditions() or BuffPresent(breath_of_sindragosa_buff) and FrostBosTickingShortCdPostConditions() or BuffPresent(obliteration_buff) and FrostObliterationShortCdPostConditions() or FrostStandardShortCdPostConditions()
}

AddFunction FrostDefaultCdActions
{
    #mind_freeze
    # FrostInterruptActions()
    #call_action_list,name=cds
    FrostCdsCdActions()

    unless FrostCdsCdPostConditions()
    {
        #run_action_list,name=bos_pooling,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains<15
        if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) < 15 FrostBosPoolingCdActions()

        unless Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) < 15 and FrostBosPoolingCdPostConditions()
        {
            #run_action_list,name=bos_ticking,if=dot.breath_of_sindragosa.ticking
            if BuffPresent(breath_of_sindragosa_buff) FrostBosTickingCdActions()

            unless BuffPresent(breath_of_sindragosa_buff) and FrostBosTickingCdPostConditions()
            {
                #run_action_list,name=obliteration,if=buff.obliteration.up
                if BuffPresent(obliteration_buff) FrostObliterationCdActions()

                unless BuffPresent(obliteration_buff) and FrostObliterationCdPostConditions()
                {
                    #call_action_list,name=standard
                    FrostStandardCdActions()
                }
            }
        }
    }
}

AddFunction FrostDefaultCdPostConditions
{
    FrostCdsCdPostConditions() or Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) < 15 and FrostBosPoolingCdPostConditions() or BuffPresent(breath_of_sindragosa_buff) and FrostBosTickingCdPostConditions() or BuffPresent(obliteration_buff) and FrostObliterationCdPostConditions() or FrostStandardCdPostConditions()
}

### actions.bos_pooling

AddFunction FrostBosPoolingMainActions
{
    #remorseless_winter,if=talent.gathering_storm.enabled
    if Talent(gathering_storm_talent) Spell(remorseless_winter)
    #howling_blast,if=buff.rime.react&rune.time_to_4<(gcd*2)
    if BuffPresent(rime_buff) and TimeToRunes(4) < GCD() * 2 Spell(howling_blast)
    #obliterate,if=rune.time_to_6<gcd&!talent.gathering_storm.enabled
    if TimeToRunes(6) < GCD() and not Talent(gathering_storm_talent) Spell(obliterate)
    #obliterate,if=rune.time_to_4<gcd&(cooldown.breath_of_sindragosa.remains|runic_power.deficit>=30)
    if TimeToRunes(4) < GCD() and { SpellCooldown(breath_of_sindragosa) > 0 or RunicPowerDeficit() >= 30 } Spell(obliterate)
    #frost_strike,if=runic_power.deficit<5&set_bonus.tier19_4pc&cooldown.breath_of_sindragosa.remains&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>6)
    if RunicPowerDeficit() < 5 and ArmorSetBonus(T19 4) and SpellCooldown(breath_of_sindragosa) > 0 and { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 or SpellCooldown(breath_of_sindragosa) > 6 } Spell(frost_strike)
    #remorseless_winter,if=buff.rime.react&equipped.perseverance_of_the_ebon_martyr
    if BuffPresent(rime_buff) and HasEquippedItem(perseverance_of_the_ebon_martyr) Spell(remorseless_winter)
    #howling_blast,if=buff.rime.react&(buff.remorseless_winter.up|cooldown.remorseless_winter.remains>gcd|(!equipped.perseverance_of_the_ebon_martyr&!talent.gathering_storm.enabled))
    if BuffPresent(rime_buff) and { BuffPresent(remorseless_winter_buff) or SpellCooldown(remorseless_winter) > GCD() or not HasEquippedItem(perseverance_of_the_ebon_martyr) and not Talent(gathering_storm_talent) } Spell(howling_blast)
    #obliterate,if=!buff.rime.react&!(talent.gathering_storm.enabled&!(cooldown.remorseless_winter.remains>(gcd*2)|rune>4))&rune>3
    if not BuffPresent(rime_buff) and not { Talent(gathering_storm_talent) and not { SpellCooldown(remorseless_winter) > GCD() * 2 or Rune() >= 5 } } and Rune() >= 4 Spell(obliterate)
    #frost_strike,if=runic_power.deficit<30&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>rune.time_to_4)
    if RunicPowerDeficit() < 30 and { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 or SpellCooldown(breath_of_sindragosa) > TimeToRunes(4) } Spell(frost_strike)
    #frostscythe,if=buff.killing_machine.up&(!equipped.koltiras_newfound_will|spell_targets.frostscythe>=2)
    if BuffPresent(killing_machine_buff) and { not HasEquippedItem(koltiras_newfound_will) or Enemies(tagged=1) >= 2 } Spell(frostscythe)
    #glacial_advance,if=spell_targets.glacial_advance>=2
    if Enemies(tagged=1) >= 2 Spell(glacial_advance)
    #remorseless_winter,if=spell_targets.remorseless_winter>=2
    if Enemies(tagged=1) >= 2 Spell(remorseless_winter)
    #frostscythe,if=spell_targets.frostscythe>=3
    if Enemies(tagged=1) >= 3 Spell(frostscythe)
    #frost_strike,if=(cooldown.remorseless_winter.remains<(gcd*2)|buff.gathering_storm.stack=10)&cooldown.breath_of_sindragosa.remains>rune.time_to_4&talent.gathering_storm.enabled&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>6)
    if { SpellCooldown(remorseless_winter) < GCD() * 2 or BuffStacks(gathering_storm_buff) == 10 } and SpellCooldown(breath_of_sindragosa) > TimeToRunes(4) and Talent(gathering_storm_talent) and { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 or SpellCooldown(breath_of_sindragosa) > 6 } Spell(frost_strike)
    #obliterate,if=!buff.rime.react&(!talent.gathering_storm.enabled|cooldown.remorseless_winter.remains>gcd)
    if not BuffPresent(rime_buff) and { not Talent(gathering_storm_talent) or SpellCooldown(remorseless_winter) > GCD() } Spell(obliterate)
    #frost_strike,if=cooldown.breath_of_sindragosa.remains>rune.time_to_4&(!talent.shattering_strikes.enabled|debuff.razorice.stack<5|cooldown.breath_of_sindragosa.remains>6)
    if SpellCooldown(breath_of_sindragosa) > TimeToRunes(4) and { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 or SpellCooldown(breath_of_sindragosa) > 6 } Spell(frost_strike)
}

AddFunction FrostBosPoolingMainPostConditions
{
}

AddFunction FrostBosPoolingShortCdActions
{
}

AddFunction FrostBosPoolingShortCdPostConditions
{
    Talent(gathering_storm_talent) and Spell(remorseless_winter) or BuffPresent(rime_buff) and TimeToRunes(4) < GCD() * 2 and Spell(howling_blast) or TimeToRunes(6) < GCD() and not Talent(gathering_storm_talent) and Spell(obliterate) or TimeToRunes(4) < GCD() and { SpellCooldown(breath_of_sindragosa) > 0 or RunicPowerDeficit() >= 30 } and Spell(obliterate) or RunicPowerDeficit() < 5 and ArmorSetBonus(T19 4) and SpellCooldown(breath_of_sindragosa) > 0 and { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 or SpellCooldown(breath_of_sindragosa) > 6 } and Spell(frost_strike) or BuffPresent(rime_buff) and HasEquippedItem(perseverance_of_the_ebon_martyr) and Spell(remorseless_winter) or BuffPresent(rime_buff) and { BuffPresent(remorseless_winter_buff) or SpellCooldown(remorseless_winter) > GCD() or not HasEquippedItem(perseverance_of_the_ebon_martyr) and not Talent(gathering_storm_talent) } and Spell(howling_blast) or not BuffPresent(rime_buff) and not { Talent(gathering_storm_talent) and not { SpellCooldown(remorseless_winter) > GCD() * 2 or Rune() >= 5 } } and Rune() >= 4 and Spell(obliterate) or RunicPowerDeficit() < 30 and { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 or SpellCooldown(breath_of_sindragosa) > TimeToRunes(4) } and Spell(frost_strike) or BuffPresent(killing_machine_buff) and { not HasEquippedItem(koltiras_newfound_will) or Enemies(tagged=1) >= 2 } and Spell(frostscythe) or Enemies(tagged=1) >= 2 and Spell(glacial_advance) or Enemies(tagged=1) >= 2 and Spell(remorseless_winter) or Enemies(tagged=1) >= 3 and Spell(frostscythe) or { SpellCooldown(remorseless_winter) < GCD() * 2 or BuffStacks(gathering_storm_buff) == 10 } and SpellCooldown(breath_of_sindragosa) > TimeToRunes(4) and Talent(gathering_storm_talent) and { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 or SpellCooldown(breath_of_sindragosa) > 6 } and Spell(frost_strike) or not BuffPresent(rime_buff) and { not Talent(gathering_storm_talent) or SpellCooldown(remorseless_winter) > GCD() } and Spell(obliterate) or SpellCooldown(breath_of_sindragosa) > TimeToRunes(4) and { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 or SpellCooldown(breath_of_sindragosa) > 6 } and Spell(frost_strike)
}

AddFunction FrostBosPoolingCdActions
{
    unless Talent(gathering_storm_talent) and Spell(remorseless_winter) or BuffPresent(rime_buff) and TimeToRunes(4) < GCD() * 2 and Spell(howling_blast) or TimeToRunes(6) < GCD() and not Talent(gathering_storm_talent) and Spell(obliterate) or TimeToRunes(4) < GCD() and { SpellCooldown(breath_of_sindragosa) > 0 or RunicPowerDeficit() >= 30 } and Spell(obliterate) or RunicPowerDeficit() < 5 and ArmorSetBonus(T19 4) and SpellCooldown(breath_of_sindragosa) > 0 and { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 or SpellCooldown(breath_of_sindragosa) > 6 } and Spell(frost_strike) or BuffPresent(rime_buff) and HasEquippedItem(perseverance_of_the_ebon_martyr) and Spell(remorseless_winter) or BuffPresent(rime_buff) and { BuffPresent(remorseless_winter_buff) or SpellCooldown(remorseless_winter) > GCD() or not HasEquippedItem(perseverance_of_the_ebon_martyr) and not Talent(gathering_storm_talent) } and Spell(howling_blast) or not BuffPresent(rime_buff) and not { Talent(gathering_storm_talent) and not { SpellCooldown(remorseless_winter) > GCD() * 2 or Rune() >= 5 } } and Rune() >= 4 and Spell(obliterate)
    {
        #sindragosas_fury,if=(equipped.consorts_cold_core|buff.pillar_of_frost.up)&buff.unholy_strength.up&debuff.razorice.stack=5
        if { HasEquippedItem(consorts_cold_core) or BuffPresent(pillar_of_frost_buff) } and BuffPresent(unholy_strength_buff) and target.DebuffStacks(razorice_debuff) == 5 Spell(sindragosas_fury)
    }
}

AddFunction FrostBosPoolingCdPostConditions
{
    Talent(gathering_storm_talent) and Spell(remorseless_winter) or BuffPresent(rime_buff) and TimeToRunes(4) < GCD() * 2 and Spell(howling_blast) or TimeToRunes(6) < GCD() and not Talent(gathering_storm_talent) and Spell(obliterate) or TimeToRunes(4) < GCD() and { SpellCooldown(breath_of_sindragosa) > 0 or RunicPowerDeficit() >= 30 } and Spell(obliterate) or RunicPowerDeficit() < 5 and ArmorSetBonus(T19 4) and SpellCooldown(breath_of_sindragosa) > 0 and { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 or SpellCooldown(breath_of_sindragosa) > 6 } and Spell(frost_strike) or BuffPresent(rime_buff) and HasEquippedItem(perseverance_of_the_ebon_martyr) and Spell(remorseless_winter) or BuffPresent(rime_buff) and { BuffPresent(remorseless_winter_buff) or SpellCooldown(remorseless_winter) > GCD() or not HasEquippedItem(perseverance_of_the_ebon_martyr) and not Talent(gathering_storm_talent) } and Spell(howling_blast) or not BuffPresent(rime_buff) and not { Talent(gathering_storm_talent) and not { SpellCooldown(remorseless_winter) > GCD() * 2 or Rune() >= 5 } } and Rune() >= 4 and Spell(obliterate) or RunicPowerDeficit() < 30 and { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 or SpellCooldown(breath_of_sindragosa) > TimeToRunes(4) } and Spell(frost_strike) or BuffPresent(killing_machine_buff) and { not HasEquippedItem(koltiras_newfound_will) or Enemies(tagged=1) >= 2 } and Spell(frostscythe) or Enemies(tagged=1) >= 2 and Spell(glacial_advance) or Enemies(tagged=1) >= 2 and Spell(remorseless_winter) or Enemies(tagged=1) >= 3 and Spell(frostscythe) or { SpellCooldown(remorseless_winter) < GCD() * 2 or BuffStacks(gathering_storm_buff) == 10 } and SpellCooldown(breath_of_sindragosa) > TimeToRunes(4) and Talent(gathering_storm_talent) and { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 or SpellCooldown(breath_of_sindragosa) > 6 } and Spell(frost_strike) or not BuffPresent(rime_buff) and { not Talent(gathering_storm_talent) or SpellCooldown(remorseless_winter) > GCD() } and Spell(obliterate) or SpellCooldown(breath_of_sindragosa) > TimeToRunes(4) and { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 or SpellCooldown(breath_of_sindragosa) > 6 } and Spell(frost_strike)
}

### actions.bos_ticking

AddFunction FrostBosTickingMainActions
{
    #frost_strike,if=talent.shattering_strikes.enabled&runic_power<40&rune.time_to_2>2&cooldown.empower_rune_weapon.remains&debuff.razorice.stack=5&(cooldown.horn_of_winter.remains|!talent.horn_of_winter.enabled)
    if Talent(shattering_strikes_talent) and RunicPower() < 40 and TimeToRunes(2) > 2 and SpellCooldown(empower_rune_weapon) > 0 and target.DebuffStacks(razorice_debuff) == 5 and { SpellCooldown(horn_of_winter) > 0 or not Talent(horn_of_winter_talent) } Spell(frost_strike)
    #remorseless_winter,if=runic_power>=30&((buff.rime.react&equipped.perseverance_of_the_ebon_martyr)|(talent.gathering_storm.enabled&(buff.remorseless_winter.remains<=gcd|!buff.remorseless_winter.remains)))
    if RunicPower() >= 30 and { BuffPresent(rime_buff) and HasEquippedItem(perseverance_of_the_ebon_martyr) or Talent(gathering_storm_talent) and { BuffRemaining(remorseless_winter_buff) <= GCD() or not BuffPresent(remorseless_winter_buff) } } Spell(remorseless_winter)
    #howling_blast,if=((runic_power>=20&set_bonus.tier19_4pc)|runic_power>=30)&buff.rime.react
    if { RunicPower() >= 20 and ArmorSetBonus(T19 4) or RunicPower() >= 30 } and BuffPresent(rime_buff) Spell(howling_blast)
    #frost_strike,if=set_bonus.tier20_2pc&runic_power.deficit<=15&rune<=3&buff.pillar_of_frost.up&!talent.shattering_strikes.enabled
    if ArmorSetBonus(T20 2) and RunicPowerDeficit() <= 15 and Rune() < 4 and BuffPresent(pillar_of_frost_buff) and not Talent(shattering_strikes_talent) Spell(frost_strike)
    #obliterate,if=runic_power<=45|rune.time_to_5<gcd
    if RunicPower() <= 45 or TimeToRunes(5) < GCD() Spell(obliterate)
    #horn_of_winter,if=runic_power.deficit>=30&rune.time_to_3>gcd
    if RunicPowerDeficit() >= 30 and TimeToRunes(3) > GCD() Spell(horn_of_winter)
    #frostscythe,if=buff.killing_machine.up&(!equipped.koltiras_newfound_will|talent.gathering_storm.enabled|spell_targets.frostscythe>=2)
    if BuffPresent(killing_machine_buff) and { not HasEquippedItem(koltiras_newfound_will) or Talent(gathering_storm_talent) or Enemies(tagged=1) >= 2 } Spell(frostscythe)
    #glacial_advance,if=spell_targets.glacial_advance>=2
    if Enemies(tagged=1) >= 2 Spell(glacial_advance)
    #remorseless_winter,if=spell_targets.remorseless_winter>=2
    if Enemies(tagged=1) >= 2 Spell(remorseless_winter)
    #obliterate,if=runic_power.deficit>25|rune>3
    if RunicPowerDeficit() > 25 or Rune() >= 4 Spell(obliterate)
}

AddFunction FrostBosTickingMainPostConditions
{
}

AddFunction FrostBosTickingShortCdActions
{
}

AddFunction FrostBosTickingShortCdPostConditions
{
    Talent(shattering_strikes_talent) and RunicPower() < 40 and TimeToRunes(2) > 2 and SpellCooldown(empower_rune_weapon) > 0 and target.DebuffStacks(razorice_debuff) == 5 and { SpellCooldown(horn_of_winter) > 0 or not Talent(horn_of_winter_talent) } and Spell(frost_strike) or RunicPower() >= 30 and { BuffPresent(rime_buff) and HasEquippedItem(perseverance_of_the_ebon_martyr) or Talent(gathering_storm_talent) and { BuffRemaining(remorseless_winter_buff) <= GCD() or not BuffPresent(remorseless_winter_buff) } } and Spell(remorseless_winter) or { RunicPower() >= 20 and ArmorSetBonus(T19 4) or RunicPower() >= 30 } and BuffPresent(rime_buff) and Spell(howling_blast) or ArmorSetBonus(T20 2) and RunicPowerDeficit() <= 15 and Rune() < 4 and BuffPresent(pillar_of_frost_buff) and not Talent(shattering_strikes_talent) and Spell(frost_strike) or { RunicPower() <= 45 or TimeToRunes(5) < GCD() } and Spell(obliterate) or RunicPowerDeficit() >= 30 and TimeToRunes(3) > GCD() and Spell(horn_of_winter) or BuffPresent(killing_machine_buff) and { not HasEquippedItem(koltiras_newfound_will) or Talent(gathering_storm_talent) or Enemies(tagged=1) >= 2 } and Spell(frostscythe) or Enemies(tagged=1) >= 2 and Spell(glacial_advance) or Enemies(tagged=1) >= 2 and Spell(remorseless_winter) or { RunicPowerDeficit() > 25 or Rune() >= 4 } and Spell(obliterate)
}

AddFunction FrostBosTickingCdActions
{
    unless Talent(shattering_strikes_talent) and RunicPower() < 40 and TimeToRunes(2) > 2 and SpellCooldown(empower_rune_weapon) > 0 and target.DebuffStacks(razorice_debuff) == 5 and { SpellCooldown(horn_of_winter) > 0 or not Talent(horn_of_winter_talent) } and Spell(frost_strike) or RunicPower() >= 30 and { BuffPresent(rime_buff) and HasEquippedItem(perseverance_of_the_ebon_martyr) or Talent(gathering_storm_talent) and { BuffRemaining(remorseless_winter_buff) <= GCD() or not BuffPresent(remorseless_winter_buff) } } and Spell(remorseless_winter) or { RunicPower() >= 20 and ArmorSetBonus(T19 4) or RunicPower() >= 30 } and BuffPresent(rime_buff) and Spell(howling_blast) or ArmorSetBonus(T20 2) and RunicPowerDeficit() <= 15 and Rune() < 4 and BuffPresent(pillar_of_frost_buff) and not Talent(shattering_strikes_talent) and Spell(frost_strike) or { RunicPower() <= 45 or TimeToRunes(5) < GCD() } and Spell(obliterate)
    {
        #sindragosas_fury,if=(equipped.consorts_cold_core|buff.pillar_of_frost.up)&buff.unholy_strength.up&debuff.razorice.stack=5
        if { HasEquippedItem(consorts_cold_core) or BuffPresent(pillar_of_frost_buff) } and BuffPresent(unholy_strength_buff) and target.DebuffStacks(razorice_debuff) == 5 Spell(sindragosas_fury)

        unless RunicPowerDeficit() >= 30 and TimeToRunes(3) > GCD() and Spell(horn_of_winter) or BuffPresent(killing_machine_buff) and { not HasEquippedItem(koltiras_newfound_will) or Talent(gathering_storm_talent) or Enemies(tagged=1) >= 2 } and Spell(frostscythe) or Enemies(tagged=1) >= 2 and Spell(glacial_advance) or Enemies(tagged=1) >= 2 and Spell(remorseless_winter) or { RunicPowerDeficit() > 25 or Rune() >= 4 } and Spell(obliterate)
        {
            #empower_rune_weapon,if=runic_power<30&rune.time_to_2>gcd
            if RunicPower() < 30 and TimeToRunes(2) > GCD() Spell(empower_rune_weapon)
        }
    }
}

AddFunction FrostBosTickingCdPostConditions
{
    Talent(shattering_strikes_talent) and RunicPower() < 40 and TimeToRunes(2) > 2 and SpellCooldown(empower_rune_weapon) > 0 and target.DebuffStacks(razorice_debuff) == 5 and { SpellCooldown(horn_of_winter) > 0 or not Talent(horn_of_winter_talent) } and Spell(frost_strike) or RunicPower() >= 30 and { BuffPresent(rime_buff) and HasEquippedItem(perseverance_of_the_ebon_martyr) or Talent(gathering_storm_talent) and { BuffRemaining(remorseless_winter_buff) <= GCD() or not BuffPresent(remorseless_winter_buff) } } and Spell(remorseless_winter) or { RunicPower() >= 20 and ArmorSetBonus(T19 4) or RunicPower() >= 30 } and BuffPresent(rime_buff) and Spell(howling_blast) or ArmorSetBonus(T20 2) and RunicPowerDeficit() <= 15 and Rune() < 4 and BuffPresent(pillar_of_frost_buff) and not Talent(shattering_strikes_talent) and Spell(frost_strike) or { RunicPower() <= 45 or TimeToRunes(5) < GCD() } and Spell(obliterate) or RunicPowerDeficit() >= 30 and TimeToRunes(3) > GCD() and Spell(horn_of_winter) or BuffPresent(killing_machine_buff) and { not HasEquippedItem(koltiras_newfound_will) or Talent(gathering_storm_talent) or Enemies(tagged=1) >= 2 } and Spell(frostscythe) or Enemies(tagged=1) >= 2 and Spell(glacial_advance) or Enemies(tagged=1) >= 2 and Spell(remorseless_winter) or { RunicPowerDeficit() > 25 or Rune() >= 4 } and Spell(obliterate)
}

### actions.cds

AddFunction FrostCdsMainActions
{
    #call_action_list,name=cold_heart,if=equipped.cold_heart&((buff.cold_heart.stack>=10&!buff.obliteration.up)|target.time_to_die<=gcd)
    if HasEquippedItem(cold_heart) and { BuffStacks(cold_heart_buff) >= 10 and not BuffPresent(obliteration_buff) or target.TimeToDie() <= GCD() } FrostColdHeartMainActions()
}

AddFunction FrostCdsMainPostConditions
{
    HasEquippedItem(cold_heart) and { BuffStacks(cold_heart_buff) >= 10 and not BuffPresent(obliteration_buff) or target.TimeToDie() <= GCD() } and FrostColdHeartMainPostConditions()
}

AddFunction FrostCdsShortCdActions
{
    #pillar_of_frost,if=talent.obliteration.enabled&(cooldown.obliteration.remains>20|cooldown.obliteration.remains<10|!talent.icecap.enabled)
    if Talent(obliteration_talent) and { SpellCooldown(obliteration) > 20 or SpellCooldown(obliteration) < 10 or not Talent(icecap_talent) } Spell(pillar_of_frost)
    #pillar_of_frost,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.ready&runic_power>50
    if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) == 0 and RunicPower() > 50 Spell(pillar_of_frost)
    #pillar_of_frost,if=talent.breath_of_sindragosa.enabled&cooldown.breath_of_sindragosa.remains>40
    if Talent(breath_of_sindragosa_talent) and SpellCooldown(breath_of_sindragosa) > 40 Spell(pillar_of_frost)
    #pillar_of_frost,if=talent.hungering_rune_weapon.enabled
    if Talent(hungering_rune_weapon_talent) Spell(pillar_of_frost)
    #call_action_list,name=cold_heart,if=equipped.cold_heart&((buff.cold_heart.stack>=10&!buff.obliteration.up)|target.time_to_die<=gcd)
    if HasEquippedItem(cold_heart) and { BuffStacks(cold_heart_buff) >= 10 and not BuffPresent(obliteration_buff) or target.TimeToDie() <= GCD() } FrostColdHeartShortCdActions()
}

AddFunction FrostCdsShortCdPostConditions
{
    HasEquippedItem(cold_heart) and { BuffStacks(cold_heart_buff) >= 10 and not BuffPresent(obliteration_buff) or target.TimeToDie() <= GCD() } and FrostColdHeartShortCdPostConditions()
}

AddFunction FrostCdsCdActions
{
    #arcane_torrent,if=runic_power.deficit>=20&!talent.breath_of_sindragosa.enabled
    if RunicPowerDeficit() >= 20 and not Talent(breath_of_sindragosa_talent) Spell(arcane_torrent_runicpower)
    #arcane_torrent,if=dot.breath_of_sindragosa.ticking&runic_power.deficit>=50&rune<2
    if BuffPresent(breath_of_sindragosa_buff) and RunicPowerDeficit() >= 50 and Rune() < 2 Spell(arcane_torrent_runicpower)
    #blood_fury,if=buff.pillar_of_frost.up
    if BuffPresent(pillar_of_frost_buff) Spell(blood_fury_ap)
    #berserking,if=buff.pillar_of_frost.up
    if BuffPresent(pillar_of_frost_buff) Spell(berserking)
    #use_items
    # FrostUseItemActions()
    #use_item,name=ring_of_collapsing_futures,if=(buff.temptation.stack=0&target.time_to_die>60)|target.time_to_die<60
    # if BuffStacks(temptation_buff) == 0 and target.TimeToDie() > 60 or target.TimeToDie() < 60 FrostUseItemActions()
    #use_item,name=horn_of_valor,if=buff.pillar_of_frost.up&(!talent.breath_of_sindragosa.enabled|!cooldown.breath_of_sindragosa.remains)
    # if BuffPresent(pillar_of_frost_buff) and { not Talent(breath_of_sindragosa_talent) or not SpellCooldown(breath_of_sindragosa) > 0 } FrostUseItemActions()
    #use_item,name=draught_of_souls,if=rune.time_to_5<3&(!dot.breath_of_sindragosa.ticking|runic_power>60)
    # if TimeToRunes(5) < 3 and { not BuffPresent(breath_of_sindragosa_buff) or RunicPower() > 60 } FrostUseItemActions()
    #use_item,name=feloiled_infernal_machine,if=!talent.obliteration.enabled|buff.obliteration.up
    # if not Talent(obliteration_talent) or BuffPresent(obliteration_buff) FrostUseItemActions()
    #potion,if=buff.pillar_of_frost.up&(dot.breath_of_sindragosa.ticking|buff.obliteration.up|talent.hungering_rune_weapon.enabled)
    # if BuffPresent(pillar_of_frost_buff) and { BuffPresent(breath_of_sindragosa_buff) or BuffPresent(obliteration_buff) or Talent(hungering_rune_weapon_talent) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
    #breath_of_sindragosa,if=buff.pillar_of_frost.up
    if BuffPresent(pillar_of_frost_buff) Spell(breath_of_sindragosa)
    #call_action_list,name=cold_heart,if=equipped.cold_heart&((buff.cold_heart.stack>=10&!buff.obliteration.up)|target.time_to_die<=gcd)
    if HasEquippedItem(cold_heart) and { BuffStacks(cold_heart_buff) >= 10 and not BuffPresent(obliteration_buff) or target.TimeToDie() <= GCD() } FrostColdHeartCdActions()

    unless HasEquippedItem(cold_heart) and { BuffStacks(cold_heart_buff) >= 10 and not BuffPresent(obliteration_buff) or target.TimeToDie() <= GCD() } and FrostColdHeartCdPostConditions()
    {
        #obliteration,if=rune>=1&runic_power>=20&(!talent.frozen_pulse.enabled|rune<2|buff.pillar_of_frost.remains<=12)&(!talent.gathering_storm.enabled|!cooldown.remorseless_winter.ready)&(buff.pillar_of_frost.up|!talent.icecap.enabled)
        if Rune() >= 1 and RunicPower() >= 20 and { not Talent(frozen_pulse_talent) or Rune() < 2 or BuffRemaining(pillar_of_frost_buff) <= 12 } and { not Talent(gathering_storm_talent) or not SpellCooldown(remorseless_winter) == 0 } and { BuffPresent(pillar_of_frost_buff) or not Talent(icecap_talent) } Spell(obliteration)
        #hungering_rune_weapon,if=!buff.hungering_rune_weapon.up&rune.time_to_2>gcd&runic_power<40
        if not BuffPresent(hungering_rune_weapon_buff) and TimeToRunes(2) > GCD() and RunicPower() < 40 Spell(hungering_rune_weapon)
    }
}

AddFunction FrostCdsCdPostConditions
{
    HasEquippedItem(cold_heart) and { BuffStacks(cold_heart_buff) >= 10 and not BuffPresent(obliteration_buff) or target.TimeToDie() <= GCD() } and FrostColdHeartCdPostConditions()
}

### actions.cold_heart

AddFunction FrostColdHeartMainActions
{
    #chains_of_ice,if=buff.cold_heart.stack=20&buff.unholy_strength.up&cooldown.pillar_of_frost.remains>6
    if BuffStacks(cold_heart_buff) == 20 and BuffPresent(unholy_strength_buff) and SpellCooldown(pillar_of_frost) > 6 Spell(chains_of_ice)
    #chains_of_ice,if=buff.pillar_of_frost.up&buff.pillar_of_frost.remains<gcd&(buff.cold_heart.stack>=11|(buff.cold_heart.stack>=10&set_bonus.tier20_4pc))
    if BuffPresent(pillar_of_frost_buff) and BuffRemaining(pillar_of_frost_buff) < GCD() and { BuffStacks(cold_heart_buff) >= 11 or BuffStacks(cold_heart_buff) >= 10 and ArmorSetBonus(T20 4) } Spell(chains_of_ice)
    #chains_of_ice,if=buff.unholy_strength.up&buff.unholy_strength.remains<gcd&buff.cold_heart.stack>16&cooldown.pillar_of_frost.remains>6
    if BuffPresent(unholy_strength_buff) and BuffRemaining(unholy_strength_buff) < GCD() and BuffStacks(cold_heart_buff) > 16 and SpellCooldown(pillar_of_frost) > 6 Spell(chains_of_ice)
    #chains_of_ice,if=buff.cold_heart.stack>=4&target.time_to_die<=gcd
    if BuffStacks(cold_heart_buff) >= 4 and target.TimeToDie() <= GCD() Spell(chains_of_ice)
}

AddFunction FrostColdHeartMainPostConditions
{
}

AddFunction FrostColdHeartShortCdActions
{
}

AddFunction FrostColdHeartShortCdPostConditions
{
    BuffStacks(cold_heart_buff) == 20 and BuffPresent(unholy_strength_buff) and SpellCooldown(pillar_of_frost) > 6 and Spell(chains_of_ice) or BuffPresent(pillar_of_frost_buff) and BuffRemaining(pillar_of_frost_buff) < GCD() and { BuffStacks(cold_heart_buff) >= 11 or BuffStacks(cold_heart_buff) >= 10 and ArmorSetBonus(T20 4) } and Spell(chains_of_ice) or BuffPresent(unholy_strength_buff) and BuffRemaining(unholy_strength_buff) < GCD() and BuffStacks(cold_heart_buff) > 16 and SpellCooldown(pillar_of_frost) > 6 and Spell(chains_of_ice) or BuffStacks(cold_heart_buff) >= 4 and target.TimeToDie() <= GCD() and Spell(chains_of_ice)
}

AddFunction FrostColdHeartCdActions
{
}

AddFunction FrostColdHeartCdPostConditions
{
    BuffStacks(cold_heart_buff) == 20 and BuffPresent(unholy_strength_buff) and SpellCooldown(pillar_of_frost) > 6 and Spell(chains_of_ice) or BuffPresent(pillar_of_frost_buff) and BuffRemaining(pillar_of_frost_buff) < GCD() and { BuffStacks(cold_heart_buff) >= 11 or BuffStacks(cold_heart_buff) >= 10 and ArmorSetBonus(T20 4) } and Spell(chains_of_ice) or BuffPresent(unholy_strength_buff) and BuffRemaining(unholy_strength_buff) < GCD() and BuffStacks(cold_heart_buff) > 16 and SpellCooldown(pillar_of_frost) > 6 and Spell(chains_of_ice) or BuffStacks(cold_heart_buff) >= 4 and target.TimeToDie() <= GCD() and Spell(chains_of_ice)
}

### actions.obliteration

AddFunction FrostObliterationMainActions
{
    #remorseless_winter,if=talent.gathering_storm.enabled
    if Talent(gathering_storm_talent) Spell(remorseless_winter)
    #frostscythe,if=buff.killing_machine.up&spell_targets.frostscythe>1
    if BuffPresent(killing_machine_buff) and Enemies(tagged=1) > 1 Spell(frostscythe)
    #obliterate,if=buff.killing_machine.up|(spell_targets.howling_blast>=3&!buff.rime.up)
    if BuffPresent(killing_machine_buff) or Enemies(tagged=1) >= 3 and not BuffPresent(rime_buff) Spell(obliterate)
    #howling_blast,if=buff.rime.up&spell_targets.howling_blast>1
    if BuffPresent(rime_buff) and Enemies(tagged=1) > 1 Spell(howling_blast)
    #howling_blast,if=!buff.rime.up&spell_targets.howling_blast>2&rune>3&talent.freezing_fog.enabled&talent.gathering_storm.enabled
    if not BuffPresent(rime_buff) and Enemies(tagged=1) > 2 and Rune() >= 4 and Talent(freezing_fog_talent) and Talent(gathering_storm_talent) Spell(howling_blast)
    #frost_strike,if=!buff.rime.up|rune.time_to_1>=gcd|runic_power.deficit<20
    if not BuffPresent(rime_buff) or TimeToRunes(1) >= GCD() or RunicPowerDeficit() < 20 Spell(frost_strike)
    #howling_blast,if=buff.rime.up
    if BuffPresent(rime_buff) Spell(howling_blast)
    #obliterate
    Spell(obliterate)
}

AddFunction FrostObliterationMainPostConditions
{
}

AddFunction FrostObliterationShortCdActions
{
}

AddFunction FrostObliterationShortCdPostConditions
{
    Talent(gathering_storm_talent) and Spell(remorseless_winter) or BuffPresent(killing_machine_buff) and Enemies(tagged=1) > 1 and Spell(frostscythe) or { BuffPresent(killing_machine_buff) or Enemies(tagged=1) >= 3 and not BuffPresent(rime_buff) } and Spell(obliterate) or BuffPresent(rime_buff) and Enemies(tagged=1) > 1 and Spell(howling_blast) or not BuffPresent(rime_buff) and Enemies(tagged=1) > 2 and Rune() >= 4 and Talent(freezing_fog_talent) and Talent(gathering_storm_talent) and Spell(howling_blast) or { not BuffPresent(rime_buff) or TimeToRunes(1) >= GCD() or RunicPowerDeficit() < 20 } and Spell(frost_strike) or BuffPresent(rime_buff) and Spell(howling_blast) or Spell(obliterate)
}

AddFunction FrostObliterationCdActions
{
}

AddFunction FrostObliterationCdPostConditions
{
    Talent(gathering_storm_talent) and Spell(remorseless_winter) or BuffPresent(killing_machine_buff) and Enemies(tagged=1) > 1 and Spell(frostscythe) or { BuffPresent(killing_machine_buff) or Enemies(tagged=1) >= 3 and not BuffPresent(rime_buff) } and Spell(obliterate) or BuffPresent(rime_buff) and Enemies(tagged=1) > 1 and Spell(howling_blast) or not BuffPresent(rime_buff) and Enemies(tagged=1) > 2 and Rune() >= 4 and Talent(freezing_fog_talent) and Talent(gathering_storm_talent) and Spell(howling_blast) or { not BuffPresent(rime_buff) or TimeToRunes(1) >= GCD() or RunicPowerDeficit() < 20 } and Spell(frost_strike) or BuffPresent(rime_buff) and Spell(howling_blast) or Spell(obliterate)
}

### actions.precombat

AddFunction FrostPrecombatMainActions
{
}

AddFunction FrostPrecombatMainPostConditions
{
}

AddFunction FrostPrecombatShortCdActions
{
}

AddFunction FrostPrecombatShortCdPostConditions
{
}

AddFunction FrostPrecombatCdActions
{
    #flask
    #food
    #augmentation
    #snapshot_stats
    #potion
    # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
}

AddFunction FrostPrecombatCdPostConditions
{
}

### actions.standard

AddFunction FrostStandardMainActions
{
    #frost_strike,if=talent.icy_talons.enabled&buff.icy_talons.remains<=gcd
    if Talent(icy_talons_talent) and BuffRemaining(icy_talons_buff) <= GCD() Spell(frost_strike)
    #frost_strike,if=talent.shattering_strikes.enabled&debuff.razorice.stack=5&buff.gathering_storm.stack<2&!buff.rime.up
    if Talent(shattering_strikes_talent) and target.DebuffStacks(razorice_debuff) == 5 and BuffStacks(gathering_storm_buff) < 2 and not BuffPresent(rime_buff) Spell(frost_strike)
    #remorseless_winter,if=(buff.rime.react&equipped.perseverance_of_the_ebon_martyr)|talent.gathering_storm.enabled
    if BuffPresent(rime_buff) and HasEquippedItem(perseverance_of_the_ebon_martyr) or Talent(gathering_storm_talent) Spell(remorseless_winter)
    #obliterate,if=(equipped.koltiras_newfound_will&talent.frozen_pulse.enabled&set_bonus.tier19_2pc=1)|rune.time_to_4<gcd&buff.hungering_rune_weapon.up
    if HasEquippedItem(koltiras_newfound_will) and Talent(frozen_pulse_talent) and ArmorSetBonus(T19 2) == 1 or TimeToRunes(4) < GCD() and BuffPresent(hungering_rune_weapon_buff) Spell(obliterate)
    #frost_strike,if=(!talent.shattering_strikes.enabled|debuff.razorice.stack<5)&runic_power.deficit<10
    if { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 } and RunicPowerDeficit() < 10 Spell(frost_strike)
    #howling_blast,if=buff.rime.react
    if BuffPresent(rime_buff) Spell(howling_blast)
    #obliterate,if=(equipped.koltiras_newfound_will&talent.frozen_pulse.enabled&set_bonus.tier19_2pc=1)|rune.time_to_5<gcd
    if HasEquippedItem(koltiras_newfound_will) and Talent(frozen_pulse_talent) and ArmorSetBonus(T19 2) == 1 or TimeToRunes(5) < GCD() Spell(obliterate)
    #frost_strike,if=runic_power.deficit<10&!buff.hungering_rune_weapon.up
    if RunicPowerDeficit() < 10 and not BuffPresent(hungering_rune_weapon_buff) Spell(frost_strike)
    #frostscythe,if=buff.killing_machine.up&(!equipped.koltiras_newfound_will|spell_targets.frostscythe>=2)
    if BuffPresent(killing_machine_buff) and { not HasEquippedItem(koltiras_newfound_will) or Enemies(tagged=1) >= 2 } Spell(frostscythe)
    #obliterate,if=buff.killing_machine.react
    if BuffPresent(killing_machine_buff) Spell(obliterate)
    #frost_strike,if=runic_power.deficit<20
    if RunicPowerDeficit() < 20 Spell(frost_strike)
    #remorseless_winter,if=spell_targets.remorseless_winter>=2
    if Enemies(tagged=1) >= 2 Spell(remorseless_winter)
    #glacial_advance,if=spell_targets.glacial_advance>=2
    if Enemies(tagged=1) >= 2 Spell(glacial_advance)
    #frostscythe,if=spell_targets.frostscythe>=3
    if Enemies(tagged=1) >= 3 Spell(frostscythe)
    #obliterate,if=!talent.gathering_storm.enabled|cooldown.remorseless_winter.remains>(gcd*2)
    if not Talent(gathering_storm_talent) or SpellCooldown(remorseless_winter) > GCD() * 2 Spell(obliterate)
    #horn_of_winter,if=!buff.hungering_rune_weapon.up&(rune.time_to_2>gcd|!talent.frozen_pulse.enabled)
    if not BuffPresent(hungering_rune_weapon_buff) and { TimeToRunes(2) > GCD() or not Talent(frozen_pulse_talent) } Spell(horn_of_winter)
    #frost_strike,if=!(runic_power<50&talent.obliteration.enabled&cooldown.obliteration.remains<=gcd)
    if not { RunicPower() < 50 and Talent(obliteration_talent) and SpellCooldown(obliteration) <= GCD() } Spell(frost_strike)
    #obliterate,if=!talent.gathering_storm.enabled|talent.icy_talons.enabled
    if not Talent(gathering_storm_talent) or Talent(icy_talons_talent) Spell(obliterate)
}

AddFunction FrostStandardMainPostConditions
{
}

AddFunction FrostStandardShortCdActions
{
}

AddFunction FrostStandardShortCdPostConditions
{
    Talent(icy_talons_talent) and BuffRemaining(icy_talons_buff) <= GCD() and Spell(frost_strike) or Talent(shattering_strikes_talent) and target.DebuffStacks(razorice_debuff) == 5 and BuffStacks(gathering_storm_buff) < 2 and not BuffPresent(rime_buff) and Spell(frost_strike) or { BuffPresent(rime_buff) and HasEquippedItem(perseverance_of_the_ebon_martyr) or Talent(gathering_storm_talent) } and Spell(remorseless_winter) or { HasEquippedItem(koltiras_newfound_will) and Talent(frozen_pulse_talent) and ArmorSetBonus(T19 2) == 1 or TimeToRunes(4) < GCD() and BuffPresent(hungering_rune_weapon_buff) } and Spell(obliterate) or { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 } and RunicPowerDeficit() < 10 and Spell(frost_strike) or BuffPresent(rime_buff) and Spell(howling_blast) or { HasEquippedItem(koltiras_newfound_will) and Talent(frozen_pulse_talent) and ArmorSetBonus(T19 2) == 1 or TimeToRunes(5) < GCD() } and Spell(obliterate) or RunicPowerDeficit() < 10 and not BuffPresent(hungering_rune_weapon_buff) and Spell(frost_strike) or BuffPresent(killing_machine_buff) and { not HasEquippedItem(koltiras_newfound_will) or Enemies(tagged=1) >= 2 } and Spell(frostscythe) or BuffPresent(killing_machine_buff) and Spell(obliterate) or RunicPowerDeficit() < 20 and Spell(frost_strike) or Enemies(tagged=1) >= 2 and Spell(remorseless_winter) or Enemies(tagged=1) >= 2 and Spell(glacial_advance) or Enemies(tagged=1) >= 3 and Spell(frostscythe) or { not Talent(gathering_storm_talent) or SpellCooldown(remorseless_winter) > GCD() * 2 } and Spell(obliterate) or not BuffPresent(hungering_rune_weapon_buff) and { TimeToRunes(2) > GCD() or not Talent(frozen_pulse_talent) } and Spell(horn_of_winter) or not { RunicPower() < 50 and Talent(obliteration_talent) and SpellCooldown(obliteration) <= GCD() } and Spell(frost_strike) or { not Talent(gathering_storm_talent) or Talent(icy_talons_talent) } and Spell(obliterate)
}

AddFunction FrostStandardCdActions
{
    unless Talent(icy_talons_talent) and BuffRemaining(icy_talons_buff) <= GCD() and Spell(frost_strike) or Talent(shattering_strikes_talent) and target.DebuffStacks(razorice_debuff) == 5 and BuffStacks(gathering_storm_buff) < 2 and not BuffPresent(rime_buff) and Spell(frost_strike) or { BuffPresent(rime_buff) and HasEquippedItem(perseverance_of_the_ebon_martyr) or Talent(gathering_storm_talent) } and Spell(remorseless_winter) or { HasEquippedItem(koltiras_newfound_will) and Talent(frozen_pulse_talent) and ArmorSetBonus(T19 2) == 1 or TimeToRunes(4) < GCD() and BuffPresent(hungering_rune_weapon_buff) } and Spell(obliterate) or { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 } and RunicPowerDeficit() < 10 and Spell(frost_strike) or BuffPresent(rime_buff) and Spell(howling_blast) or { HasEquippedItem(koltiras_newfound_will) and Talent(frozen_pulse_talent) and ArmorSetBonus(T19 2) == 1 or TimeToRunes(5) < GCD() } and Spell(obliterate)
    {
        #sindragosas_fury,if=(equipped.consorts_cold_core|buff.pillar_of_frost.up)&buff.unholy_strength.up&debuff.razorice.stack=5
        if { HasEquippedItem(consorts_cold_core) or BuffPresent(pillar_of_frost_buff) } and BuffPresent(unholy_strength_buff) and target.DebuffStacks(razorice_debuff) == 5 Spell(sindragosas_fury)

        unless RunicPowerDeficit() < 10 and not BuffPresent(hungering_rune_weapon_buff) and Spell(frost_strike) or BuffPresent(killing_machine_buff) and { not HasEquippedItem(koltiras_newfound_will) or Enemies(tagged=1) >= 2 } and Spell(frostscythe) or BuffPresent(killing_machine_buff) and Spell(obliterate) or RunicPowerDeficit() < 20 and Spell(frost_strike) or Enemies(tagged=1) >= 2 and Spell(remorseless_winter) or Enemies(tagged=1) >= 2 and Spell(glacial_advance) or Enemies(tagged=1) >= 3 and Spell(frostscythe) or { not Talent(gathering_storm_talent) or SpellCooldown(remorseless_winter) > GCD() * 2 } and Spell(obliterate) or not BuffPresent(hungering_rune_weapon_buff) and { TimeToRunes(2) > GCD() or not Talent(frozen_pulse_talent) } and Spell(horn_of_winter) or not { RunicPower() < 50 and Talent(obliteration_talent) and SpellCooldown(obliteration) <= GCD() } and Spell(frost_strike) or { not Talent(gathering_storm_talent) or Talent(icy_talons_talent) } and Spell(obliterate)
        {
            #empower_rune_weapon,if=!talent.breath_of_sindragosa.enabled|target.time_to_die<cooldown.breath_of_sindragosa.remains
            if not Talent(breath_of_sindragosa_talent) or target.TimeToDie() < SpellCooldown(breath_of_sindragosa) Spell(empower_rune_weapon)
        }
    }
}

AddFunction FrostStandardCdPostConditions
{
    Talent(icy_talons_talent) and BuffRemaining(icy_talons_buff) <= GCD() and Spell(frost_strike) or Talent(shattering_strikes_talent) and target.DebuffStacks(razorice_debuff) == 5 and BuffStacks(gathering_storm_buff) < 2 and not BuffPresent(rime_buff) and Spell(frost_strike) or { BuffPresent(rime_buff) and HasEquippedItem(perseverance_of_the_ebon_martyr) or Talent(gathering_storm_talent) } and Spell(remorseless_winter) or { HasEquippedItem(koltiras_newfound_will) and Talent(frozen_pulse_talent) and ArmorSetBonus(T19 2) == 1 or TimeToRunes(4) < GCD() and BuffPresent(hungering_rune_weapon_buff) } and Spell(obliterate) or { not Talent(shattering_strikes_talent) or target.DebuffStacks(razorice_debuff) < 5 } and RunicPowerDeficit() < 10 and Spell(frost_strike) or BuffPresent(rime_buff) and Spell(howling_blast) or { HasEquippedItem(koltiras_newfound_will) and Talent(frozen_pulse_talent) and ArmorSetBonus(T19 2) == 1 or TimeToRunes(5) < GCD() } and Spell(obliterate) or RunicPowerDeficit() < 10 and not BuffPresent(hungering_rune_weapon_buff) and Spell(frost_strike) or BuffPresent(killing_machine_buff) and { not HasEquippedItem(koltiras_newfound_will) or Enemies(tagged=1) >= 2 } and Spell(frostscythe) or BuffPresent(killing_machine_buff) and Spell(obliterate) or RunicPowerDeficit() < 20 and Spell(frost_strike) or Enemies(tagged=1) >= 2 and Spell(remorseless_winter) or Enemies(tagged=1) >= 2 and Spell(glacial_advance) or Enemies(tagged=1) >= 3 and Spell(frostscythe) or { not Talent(gathering_storm_talent) or SpellCooldown(remorseless_winter) > GCD() * 2 } and Spell(obliterate) or not BuffPresent(hungering_rune_weapon_buff) and { TimeToRunes(2) > GCD() or not Talent(frozen_pulse_talent) } and Spell(horn_of_winter) or not { RunicPower() < 50 and Talent(obliteration_talent) and SpellCooldown(obliteration) <= GCD() } and Spell(frost_strike) or { not Talent(gathering_storm_talent) or Talent(icy_talons_talent) } and Spell(obliterate)
}
]]

	OvaleScripts:RegisterScript("DEATHKNIGHT", "frost", name, desc, code, "script")
end
