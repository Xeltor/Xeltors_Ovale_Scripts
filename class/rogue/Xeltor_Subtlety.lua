local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_shanky"
	local desc = "[Xel][7.3] Blush: Shanky"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_rogue_spells)

Define(tricks_of_the_trade 57934)
	SpellInfo(tricks_of_the_trade cd=30 gcd=0)
Define(crimson_vial 185311)
	SpellInfo(crimson_vial cd=30 gcd=0 energy=30)

# Subtlety (Shanky)
AddIcon specialization=3 help=main
{
	if not mounted() and not Stealthed() and not InCombat() and HealthPercent() > 0 and Enemies(tagged=1) > 0 Spell(stealth)
	if not InCombat() and target.Present() and target.Exists() and not target.IsFriend() and not mounted()
	{
		#marked_for_death
		if target.InRange(marked_for_death) Spell(marked_for_death)
		#symbols_of_death
		if not BuffPresent(symbols_of_death_buff) Spell(symbols_of_death)
		#nightblade
		if target.InRange(nightblade) Spell(nightblade)
	}
	
	if InCombat() InterruptActions()
	if HealthPercent() <= 40 and not Boss() Spell(crimson_vial)
	
	if target.InRange(backstab) and HasFullControl()
	{
		# Cooldowns
		if Boss() SubtletyDefaultCdActions()
		
		# Short Cooldowns
		SubtletyDefaultShortCdActions()
	
		# Default Actions
		SubtletyDefaultMainActions()
	}
	
	if InCombat() and target.Present() and not target.IsFriend() and { TimeInCombat() < 6 or Falling() } GetInMeleeRange()
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction position_front
{
	target.istargetingplayer()
}

AddFunction GetInMeleeRange
{
	if not target.InRange(kick)
	{
		if target.InRange(shadowstep) Spell(shadowstep)
		if Stealthed() and target.InRange(shadowstrike) Spell(shadowstrike)
		if target.InRange(shadowstrike) and not Stealthed() SubtletyStealthCdsShortCdActions()
		# Texture(misc_arrowlup help=L(not_in_melee_range))
	}
}

AddFunction InterruptActions
{
	if target.IsFriend(no) and target.IsInterruptible()
	{
		if target.InRange(kick) and not Stealthed() Spell(kick)
		if target.Classification(worldboss no)
		{
			# if target.InRange(cheap_shot) and Stealthed() Spell(cheap_shot)
			# if target.InRange(deadly_throw) and ComboPoints() == 5 and not {BuffPresent(stealthed_buff any=1) and BuffPresent(vanish_buff)} Spell(deadly_throw)
			if target.InRange(kidney_shot) and not Stealthed() Spell(kidney_shot)
			if target.InRange(kidney_shot) and not Stealthed() Spell(arcane_torrent_energy)
			if target.InRange(quaking_palm) and not Stealthed() Spell(quaking_palm)
		}
	}
}

AddFunction shd_fractional
{
    1.725 + 0.725 * TalentPoints(enveloping_shadows_talent)
}

AddFunction ssw_refund
{
    HasEquippedItem(shadow_satyrs_walk) * { 6 + { target.Distance() % 3 - 1 } }
}

AddFunction stealth_threshold
{
    65 + TalentPoints(vigor_talent) * 35 + TalentPoints(master_of_shadows_talent) * 10 + ssw_refund()
}

AddFunction dsh_dfa
{
    Talent(death_from_above_talent) and Talent(dark_shadow_talent) and Enemies(tagged=1) < 4
}

### actions.default

AddFunction SubtletyDefaultMainActions
{
    #wait,sec=0.1,if=buff.shadow_dance.up&gcd.remains>0
    #call_action_list,name=cds
    SubtletyCdsMainActions()

    unless SubtletyCdsMainPostConditions()
    {
        #run_action_list,name=stealthed,if=stealthed.all
        if Stealthed() SubtletyStealthedMainActions()

        unless Stealthed() and SubtletyStealthedMainPostConditions()
        {
            #nightblade,if=target.time_to_die>6&remains<gcd.max&combo_points>=4-(time<10)*2
            if target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 Spell(nightblade)
            #call_action_list,name=stealth_als,if=talent.dark_shadow.enabled&combo_points.deficit>=2+buff.shadow_blades.up&(dot.nightblade.remains>4+talent.subterfuge.enabled|cooldown.shadow_dance.charges_fractional>=1.9&(!equipped.denial_of_the_halfgiants|time>10))
            if Talent(dark_shadow_talent) and ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } SubtletyStealthAlsMainActions()

            unless Talent(dark_shadow_talent) and ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } and SubtletyStealthAlsMainPostConditions()
            {
                #call_action_list,name=stealth_als,if=!talent.dark_shadow.enabled&(combo_points.deficit>=2+buff.shadow_blades.up|cooldown.shadow_dance.charges_fractional>=1.9+talent.enveloping_shadows.enabled)
                if not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } SubtletyStealthAlsMainActions()

                unless not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } and SubtletyStealthAlsMainPostConditions()
                {
                    #call_action_list,name=finish,if=combo_points>=5+(talent.deeper_stratagem.enabled&!buff.shadow_blades.up&(mantle_duration=0|set_bonus.tier20_4pc)&(!buff.the_first_of_the_dead.up|variable.dsh_dfa))|(combo_points>=4&combo_points.deficit<=2&spell_targets.shuriken_storm>=3&spell_targets.shuriken_storm<=4)|(target.time_to_die<=1&combo_points>=3)
                    if ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and not BuffPresent(shadow_blades_buff) and { BuffRemaining(master_assassins_initiative) == 0 or ArmorSetBonus(T20 4) } and { not BuffPresent(the_first_of_the_dead_buff) or dsh_dfa() } } or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies(tagged=1) >= 3 and Enemies(tagged=1) <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 SubtletyFinishMainActions()

                    unless { ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and not BuffPresent(shadow_blades_buff) and { BuffRemaining(master_assassins_initiative) == 0 or ArmorSetBonus(T20 4) } and { not BuffPresent(the_first_of_the_dead_buff) or dsh_dfa() } } or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies(tagged=1) >= 3 and Enemies(tagged=1) <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishMainPostConditions()
                    {
                        #call_action_list,name=finish,if=variable.dsh_dfa&cooldown.symbols_of_death.remains<=1&combo_points>=2&equipped.the_first_of_the_dead&spell_targets.shuriken_storm<2
                        if dsh_dfa() and SpellCooldown(symbols_of_death) <= 1 and ComboPoints() >= 2 and HasEquippedItem(the_first_of_the_dead) and Enemies(tagged=1) < 2 SubtletyFinishMainActions()

                        unless dsh_dfa() and SpellCooldown(symbols_of_death) <= 1 and ComboPoints() >= 2 and HasEquippedItem(the_first_of_the_dead) and Enemies(tagged=1) < 2 and SubtletyFinishMainPostConditions()
                        {
                            #call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold
                            if EnergyDeficit() <= stealth_threshold() SubtletyBuildMainActions()
                        }
                    }
                }
            }
        }
    }
}

AddFunction SubtletyDefaultMainPostConditions
{
    SubtletyCdsMainPostConditions() or Stealthed() and SubtletyStealthedMainPostConditions() or Talent(dark_shadow_talent) and ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } and SubtletyStealthAlsMainPostConditions() or not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } and SubtletyStealthAlsMainPostConditions() or { ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and not BuffPresent(shadow_blades_buff) and { BuffRemaining(master_assassins_initiative) == 0 or ArmorSetBonus(T20 4) } and { not BuffPresent(the_first_of_the_dead_buff) or dsh_dfa() } } or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies(tagged=1) >= 3 and Enemies(tagged=1) <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishMainPostConditions() or dsh_dfa() and SpellCooldown(symbols_of_death) <= 1 and ComboPoints() >= 2 and HasEquippedItem(the_first_of_the_dead) and Enemies(tagged=1) < 2 and SubtletyFinishMainPostConditions() or EnergyDeficit() <= stealth_threshold() and SubtletyBuildMainPostConditions()
}

AddFunction SubtletyDefaultShortCdActions
{
    #variable,name=dsh_dfa,value=talent.death_from_above.enabled&talent.dark_shadow.enabled&spell_targets.death_from_above<4
    #shadow_dance,if=talent.dark_shadow.enabled&(!stealthed.all|buff.subterfuge.up)&buff.death_from_above.up&buff.death_from_above.remains<=0.15
    if Talent(dark_shadow_talent) and { not Stealthed() or BuffPresent(subterfuge_buff) } and BuffPresent(death_from_above_buff) and BuffRemaining(death_from_above_buff) <= 0.15 Spell(shadow_dance)
    #wait,sec=0.1,if=buff.shadow_dance.up&gcd.remains>0
    #call_action_list,name=cds
    SubtletyCdsShortCdActions()

    unless SubtletyCdsShortCdPostConditions()
    {
        #run_action_list,name=stealthed,if=stealthed.all
        if Stealthed() SubtletyStealthedShortCdActions()

        unless Stealthed() and SubtletyStealthedShortCdPostConditions() or target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 and Spell(nightblade)
        {
            #call_action_list,name=stealth_als,if=talent.dark_shadow.enabled&combo_points.deficit>=2+buff.shadow_blades.up&(dot.nightblade.remains>4+talent.subterfuge.enabled|cooldown.shadow_dance.charges_fractional>=1.9&(!equipped.denial_of_the_halfgiants|time>10))
            if Talent(dark_shadow_talent) and ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } SubtletyStealthAlsShortCdActions()

            unless Talent(dark_shadow_talent) and ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } and SubtletyStealthAlsShortCdPostConditions()
            {
                #call_action_list,name=stealth_als,if=!talent.dark_shadow.enabled&(combo_points.deficit>=2+buff.shadow_blades.up|cooldown.shadow_dance.charges_fractional>=1.9+talent.enveloping_shadows.enabled)
                if not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } SubtletyStealthAlsShortCdActions()

                unless not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } and SubtletyStealthAlsShortCdPostConditions()
                {
                    #call_action_list,name=finish,if=combo_points>=5+(talent.deeper_stratagem.enabled&!buff.shadow_blades.up&(mantle_duration=0|set_bonus.tier20_4pc)&(!buff.the_first_of_the_dead.up|variable.dsh_dfa))|(combo_points>=4&combo_points.deficit<=2&spell_targets.shuriken_storm>=3&spell_targets.shuriken_storm<=4)|(target.time_to_die<=1&combo_points>=3)
                    if ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and not BuffPresent(shadow_blades_buff) and { BuffRemaining(master_assassins_initiative) == 0 or ArmorSetBonus(T20 4) } and { not BuffPresent(the_first_of_the_dead_buff) or dsh_dfa() } } or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies(tagged=1) >= 3 and Enemies(tagged=1) <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 SubtletyFinishShortCdActions()

                    unless { ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and not BuffPresent(shadow_blades_buff) and { BuffRemaining(master_assassins_initiative) == 0 or ArmorSetBonus(T20 4) } and { not BuffPresent(the_first_of_the_dead_buff) or dsh_dfa() } } or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies(tagged=1) >= 3 and Enemies(tagged=1) <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishShortCdPostConditions()
                    {
                        #call_action_list,name=finish,if=variable.dsh_dfa&cooldown.symbols_of_death.remains<=1&combo_points>=2&equipped.the_first_of_the_dead&spell_targets.shuriken_storm<2
                        if dsh_dfa() and SpellCooldown(symbols_of_death) <= 1 and ComboPoints() >= 2 and HasEquippedItem(the_first_of_the_dead) and Enemies(tagged=1) < 2 SubtletyFinishShortCdActions()

                        unless dsh_dfa() and SpellCooldown(symbols_of_death) <= 1 and ComboPoints() >= 2 and HasEquippedItem(the_first_of_the_dead) and Enemies(tagged=1) < 2 and SubtletyFinishShortCdPostConditions()
                        {
                            #call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold
                            if EnergyDeficit() <= stealth_threshold() SubtletyBuildShortCdActions()
                        }
                    }
                }
            }
        }
    }
}

AddFunction SubtletyDefaultShortCdPostConditions
{
    SubtletyCdsShortCdPostConditions() or Stealthed() and SubtletyStealthedShortCdPostConditions() or target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 and Spell(nightblade) or Talent(dark_shadow_talent) and ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } and SubtletyStealthAlsShortCdPostConditions() or not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } and SubtletyStealthAlsShortCdPostConditions() or { ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and not BuffPresent(shadow_blades_buff) and { BuffRemaining(master_assassins_initiative) == 0 or ArmorSetBonus(T20 4) } and { not BuffPresent(the_first_of_the_dead_buff) or dsh_dfa() } } or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies(tagged=1) >= 3 and Enemies(tagged=1) <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishShortCdPostConditions() or dsh_dfa() and SpellCooldown(symbols_of_death) <= 1 and ComboPoints() >= 2 and HasEquippedItem(the_first_of_the_dead) and Enemies(tagged=1) < 2 and SubtletyFinishShortCdPostConditions() or EnergyDeficit() <= stealth_threshold() and SubtletyBuildShortCdPostConditions()
}

AddFunction SubtletyDefaultCdActions
{
    #wait,sec=0.1,if=buff.shadow_dance.up&gcd.remains>0
    #call_action_list,name=cds
    SubtletyCdsCdActions()

    unless SubtletyCdsCdPostConditions()
    {
        #run_action_list,name=stealthed,if=stealthed.all
        if Stealthed() SubtletyStealthedCdActions()

        unless Stealthed() and SubtletyStealthedCdPostConditions() or target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 and Spell(nightblade)
        {
            #call_action_list,name=stealth_als,if=talent.dark_shadow.enabled&combo_points.deficit>=2+buff.shadow_blades.up&(dot.nightblade.remains>4+talent.subterfuge.enabled|cooldown.shadow_dance.charges_fractional>=1.9&(!equipped.denial_of_the_halfgiants|time>10))
            if Talent(dark_shadow_talent) and ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } SubtletyStealthAlsCdActions()

            unless Talent(dark_shadow_talent) and ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } and SubtletyStealthAlsCdPostConditions()
            {
                #call_action_list,name=stealth_als,if=!talent.dark_shadow.enabled&(combo_points.deficit>=2+buff.shadow_blades.up|cooldown.shadow_dance.charges_fractional>=1.9+talent.enveloping_shadows.enabled)
                if not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } SubtletyStealthAlsCdActions()

                unless not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } and SubtletyStealthAlsCdPostConditions()
                {
                    #call_action_list,name=finish,if=combo_points>=5+(talent.deeper_stratagem.enabled&!buff.shadow_blades.up&(mantle_duration=0|set_bonus.tier20_4pc)&(!buff.the_first_of_the_dead.up|variable.dsh_dfa))|(combo_points>=4&combo_points.deficit<=2&spell_targets.shuriken_storm>=3&spell_targets.shuriken_storm<=4)|(target.time_to_die<=1&combo_points>=3)
                    if ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and not BuffPresent(shadow_blades_buff) and { BuffRemaining(master_assassins_initiative) == 0 or ArmorSetBonus(T20 4) } and { not BuffPresent(the_first_of_the_dead_buff) or dsh_dfa() } } or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies(tagged=1) >= 3 and Enemies(tagged=1) <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 SubtletyFinishCdActions()

                    unless { ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and not BuffPresent(shadow_blades_buff) and { BuffRemaining(master_assassins_initiative) == 0 or ArmorSetBonus(T20 4) } and { not BuffPresent(the_first_of_the_dead_buff) or dsh_dfa() } } or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies(tagged=1) >= 3 and Enemies(tagged=1) <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishCdPostConditions()
                    {
                        #call_action_list,name=finish,if=variable.dsh_dfa&cooldown.symbols_of_death.remains<=1&combo_points>=2&equipped.the_first_of_the_dead&spell_targets.shuriken_storm<2
                        if dsh_dfa() and SpellCooldown(symbols_of_death) <= 1 and ComboPoints() >= 2 and HasEquippedItem(the_first_of_the_dead) and Enemies(tagged=1) < 2 SubtletyFinishCdActions()

                        unless dsh_dfa() and SpellCooldown(symbols_of_death) <= 1 and ComboPoints() >= 2 and HasEquippedItem(the_first_of_the_dead) and Enemies(tagged=1) < 2 and SubtletyFinishCdPostConditions()
                        {
                            #call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold
                            if EnergyDeficit() <= stealth_threshold() SubtletyBuildCdActions()
                        }
                    }
                }
            }
        }
    }
}

AddFunction SubtletyDefaultCdPostConditions
{
    SubtletyCdsCdPostConditions() or Stealthed() and SubtletyStealthedCdPostConditions() or target.TimeToDie() > 6 and target.DebuffRemaining(nightblade_debuff) < GCD() and ComboPoints() >= 4 - { TimeInCombat() < 10 } * 2 and Spell(nightblade) or Talent(dark_shadow_talent) and ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) and { target.DebuffRemaining(nightblade_debuff) > 4 + TalentPoints(subterfuge_talent) or SpellCharges(shadow_dance count=0) >= 1.9 and { not HasEquippedItem(denial_of_the_halfgiants) or TimeInCombat() > 10 } } and SubtletyStealthAlsCdPostConditions() or not Talent(dark_shadow_talent) and { ComboPointsDeficit() >= 2 + BuffPresent(shadow_blades_buff) or SpellCharges(shadow_dance count=0) >= 1.9 + TalentPoints(enveloping_shadows_talent) } and SubtletyStealthAlsCdPostConditions() or { ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and not BuffPresent(shadow_blades_buff) and { BuffRemaining(master_assassins_initiative) == 0 or ArmorSetBonus(T20 4) } and { not BuffPresent(the_first_of_the_dead_buff) or dsh_dfa() } } or ComboPoints() >= 4 and ComboPointsDeficit() <= 2 and Enemies(tagged=1) >= 3 and Enemies(tagged=1) <= 4 or target.TimeToDie() <= 1 and ComboPoints() >= 3 } and SubtletyFinishCdPostConditions() or dsh_dfa() and SpellCooldown(symbols_of_death) <= 1 and ComboPoints() >= 2 and HasEquippedItem(the_first_of_the_dead) and Enemies(tagged=1) < 2 and SubtletyFinishCdPostConditions() or EnergyDeficit() <= stealth_threshold() and SubtletyBuildCdPostConditions()
}

### actions.build

AddFunction SubtletyBuildMainActions
{
    #shuriken_storm,if=spell_targets.shuriken_storm>=2+buff.the_first_of_the_dead.up
    if Enemies(tagged=1) >= 2 + BuffPresent(the_first_of_the_dead_buff) Spell(shuriken_storm)
    #gloomblade
    Spell(gloomblade)
    #backstab
    Spell(backstab)
}

AddFunction SubtletyBuildMainPostConditions
{
}

AddFunction SubtletyBuildShortCdActions
{
}

AddFunction SubtletyBuildShortCdPostConditions
{
    Enemies(tagged=1) >= 2 + BuffPresent(the_first_of_the_dead_buff) and Spell(shuriken_storm) or Spell(gloomblade) or Spell(backstab)
}

AddFunction SubtletyBuildCdActions
{
}

AddFunction SubtletyBuildCdPostConditions
{
    Enemies(tagged=1) >= 2 + BuffPresent(the_first_of_the_dead_buff) and Spell(shuriken_storm) or Spell(gloomblade) or Spell(backstab)
}

### actions.cds

AddFunction SubtletyCdsMainActions
{
}

AddFunction SubtletyCdsMainPostConditions
{
}

AddFunction SubtletyCdsShortCdActions
{
    #symbols_of_death,if=!talent.death_from_above.enabled&((time>10&energy.deficit>=40-stealthed.all*30)|(time<10&dot.nightblade.ticking))
    if not Talent(death_from_above_talent) and { TimeInCombat() > 10 and EnergyDeficit() >= 40 - Stealthed() * 30 or TimeInCombat() < 10 and target.DebuffPresent(nightblade_debuff) } Spell(symbols_of_death)
    #symbols_of_death,if=(talent.death_from_above.enabled&cooldown.death_from_above.remains<=3&(dot.nightblade.remains>=cooldown.death_from_above.remains+3|target.time_to_die-dot.nightblade.remains<=6)&(time>=3|set_bonus.tier20_4pc|equipped.the_first_of_the_dead))|target.time_to_die-remains<=10
    if Talent(death_from_above_talent) and SpellCooldown(death_from_above) <= 3 and { target.DebuffRemaining(nightblade_debuff) >= SpellCooldown(death_from_above) + 3 or target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) <= 6 } and { TimeInCombat() >= 3 or ArmorSetBonus(T20 4) or HasEquippedItem(the_first_of_the_dead) } or target.TimeToDie() - BuffRemaining(symbols_of_death_buff) <= 10 Spell(symbols_of_death)
    #marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit
    if target.TimeToDie() < ComboPointsDeficit() Spell(marked_for_death)
    #marked_for_death,if=raid_event.adds.in>40&!stealthed.all&combo_points.deficit>=cp_max_spend
    if 600 > 40 and not Stealthed() and ComboPointsDeficit() >= MaxComboPoints() Spell(marked_for_death)
    #goremaws_bite,if=!stealthed.all&cooldown.shadow_dance.charges_fractional<=variable.shd_fractional&((combo_points.deficit>=4-(time<10)*2&energy.deficit>50+talent.vigor.enabled*25-(time>=10)*15)|(combo_points.deficit>=1&target.time_to_die<8))
    if not Stealthed() and SpellCharges(shadow_dance count=0) <= shd_fractional() and { ComboPointsDeficit() >= 4 - { TimeInCombat() < 10 } * 2 and EnergyDeficit() > 50 + TalentPoints(vigor_talent) * 25 - { TimeInCombat() >= 10 } * 15 or ComboPointsDeficit() >= 1 and target.TimeToDie() < 8 } Spell(goremaws_bite)
    #pool_resource,for_next=1,extra_amount=55-talent.shadow_focus.enabled*10
    #vanish,if=energy>=55-talent.shadow_focus.enabled*10&variable.dsh_dfa&(!equipped.mantle_of_the_master_assassin|buff.symbols_of_death.up)&cooldown.shadow_dance.charges_fractional<=variable.shd_fractional&!buff.shadow_dance.up&!buff.stealth.up&mantle_duration=0&(dot.nightblade.remains>=cooldown.death_from_above.remains+6|target.time_to_die-dot.nightblade.remains<=6)&cooldown.death_from_above.remains<=1|target.time_to_die<=7
    if Energy() >= 55 - TalentPoints(shadow_focus_talent) * 10 and dsh_dfa() and { not HasEquippedItem(mantle_of_the_master_assassin) or BuffPresent(symbols_of_death_buff) } and SpellCharges(shadow_dance count=0) <= shd_fractional() and not BuffPresent(shadow_dance_buff) and not BuffPresent(stealthed_buff any=1) and BuffRemaining(master_assassins_initiative) == 0 and { target.DebuffRemaining(nightblade_debuff) >= SpellCooldown(death_from_above) + 6 or target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) <= 6 } and SpellCooldown(death_from_above) <= 1 or target.TimeToDie() <= 7 Spell(vanish)
}

AddFunction SubtletyCdsShortCdPostConditions
{
}

AddFunction SubtletyCdsCdActions
{
    #potion,if=buff.bloodlust.react|target.time_to_die<=60|(buff.vanish.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=30))
    # if { BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 60 or BuffPresent(vanish_buff) and { BuffPresent(shadow_blades_buff) or SpellCooldown(shadow_blades) <= 30 } } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
    #use_item,name=specter_of_betrayal,if=talent.dark_shadow.enabled&buff.shadow_dance.up&(!set_bonus.tier20_4pc|buff.symbols_of_death.up|(!talent.death_from_above.enabled&((mantle_duration>=3|!equipped.mantle_of_the_master_assassin)|cooldown.vanish.remains>=43)))
    # if Talent(dark_shadow_talent) and BuffPresent(shadow_dance_buff) and { not ArmorSetBonus(T20 4) or BuffPresent(symbols_of_death_buff) or not Talent(death_from_above_talent) and { BuffRemaining(master_assassins_initiative) >= 3 or not HasEquippedItem(mantle_of_the_master_assassin) or SpellCooldown(vanish) >= 43 } } SubtletyUseItemActions()
    #use_item,name=specter_of_betrayal,if=!talent.dark_shadow.enabled&!buff.stealth.up&!buff.vanish.up&(mantle_duration>=3|!equipped.mantle_of_the_master_assassin)
    # if not Talent(dark_shadow_talent) and not BuffPresent(stealthed_buff any=1) and not BuffPresent(vanish_buff) and { BuffRemaining(master_assassins_initiative) >= 3 or not HasEquippedItem(mantle_of_the_master_assassin) } SubtletyUseItemActions()
    #blood_fury,if=stealthed.rogue
    if Stealthed() Spell(blood_fury_ap)
    #berserking,if=stealthed.rogue
    if Stealthed() Spell(berserking)
    #arcane_torrent,if=stealthed.rogue&energy.deficit>70
    if Stealthed() and EnergyDeficit() > 70 Spell(arcane_torrent_energy)

    unless not Talent(death_from_above_talent) and { TimeInCombat() > 10 and EnergyDeficit() >= 40 - Stealthed() * 30 or TimeInCombat() < 10 and target.DebuffPresent(nightblade_debuff) } and Spell(symbols_of_death) or { Talent(death_from_above_talent) and SpellCooldown(death_from_above) <= 3 and { target.DebuffRemaining(nightblade_debuff) >= SpellCooldown(death_from_above) + 3 or target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) <= 6 } and { TimeInCombat() >= 3 or ArmorSetBonus(T20 4) or HasEquippedItem(the_first_of_the_dead) } or target.TimeToDie() - BuffRemaining(symbols_of_death_buff) <= 10 } and Spell(symbols_of_death)
    {
        #shadow_blades,if=(time>10&combo_points.deficit>=2+stealthed.all-equipped.mantle_of_the_master_assassin)|(time<10&(!talent.marked_for_death.enabled|combo_points.deficit>=3|dot.nightblade.ticking))
        if TimeInCombat() > 10 and ComboPointsDeficit() >= 2 + Stealthed() - HasEquippedItem(mantle_of_the_master_assassin) or TimeInCombat() < 10 and { not Talent(marked_for_death_talent) or ComboPointsDeficit() >= 3 or target.DebuffPresent(nightblade_debuff) } Spell(shadow_blades)
    }
}

AddFunction SubtletyCdsCdPostConditions
{
    not Talent(death_from_above_talent) and { TimeInCombat() > 10 and EnergyDeficit() >= 40 - Stealthed() * 30 or TimeInCombat() < 10 and target.DebuffPresent(nightblade_debuff) } and Spell(symbols_of_death) or { Talent(death_from_above_talent) and SpellCooldown(death_from_above) <= 3 and { target.DebuffRemaining(nightblade_debuff) >= SpellCooldown(death_from_above) + 3 or target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) <= 6 } and { TimeInCombat() >= 3 or ArmorSetBonus(T20 4) or HasEquippedItem(the_first_of_the_dead) } or target.TimeToDie() - BuffRemaining(symbols_of_death_buff) <= 10 } and Spell(symbols_of_death) or not Stealthed() and SpellCharges(shadow_dance count=0) <= shd_fractional() and { ComboPointsDeficit() >= 4 - { TimeInCombat() < 10 } * 2 and EnergyDeficit() > 50 + TalentPoints(vigor_talent) * 25 - { TimeInCombat() >= 10 } * 15 or ComboPointsDeficit() >= 1 and target.TimeToDie() < 8 } and Spell(goremaws_bite)
}

### actions.finish

AddFunction SubtletyFinishMainActions
{
    #nightblade,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>6&(mantle_duration=0|remains<=mantle_duration)&((refreshable&(!finality|buff.finality_nightblade.up|variable.dsh_dfa))|remains<tick_time*2)&(spell_targets.shuriken_storm<4&!variable.dsh_dfa|!buff.symbols_of_death.up)
    if { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 6 and { BuffRemaining(master_assassins_initiative) == 0 or target.DebuffRemaining(nightblade_debuff) <= BuffRemaining(master_assassins_initiative) } and { target.Refreshable(nightblade_debuff) and { not HasArtifactTrait(finality) or DebuffPresent(finality_nightblade_debuff) or dsh_dfa() } or target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 } and { Enemies(tagged=1) < 4 and not dsh_dfa() or not BuffPresent(symbols_of_death_buff) } Spell(nightblade)
    #nightblade,cycle_targets=1,if=(!talent.death_from_above.enabled|set_bonus.tier19_2pc)&(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>12&mantle_duration=0&((refreshable&(!finality|buff.finality_nightblade.up|variable.dsh_dfa))|remains<tick_time*2)&(spell_targets.shuriken_storm<4&!variable.dsh_dfa|!buff.symbols_of_death.up)
    if { not Talent(death_from_above_talent) or ArmorSetBonus(T19 2) } and { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 12 and BuffRemaining(master_assassins_initiative) == 0 and { target.Refreshable(nightblade_debuff) and { not HasArtifactTrait(finality) or DebuffPresent(finality_nightblade_debuff) or dsh_dfa() } or target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 } and { Enemies(tagged=1) < 4 and not dsh_dfa() or not BuffPresent(symbols_of_death_buff) } Spell(nightblade)
    #nightblade,if=remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5+(combo_points=6)
    if target.DebuffRemaining(nightblade_debuff) < SpellCooldown(symbols_of_death) + 10 and SpellCooldown(symbols_of_death) <= 5 + { ComboPoints() == 6 } Spell(nightblade)
    #death_from_above,if=!talent.dark_shadow.enabled|!cooldown.vanish.up&(!buff.shadow_dance.up|spell_targets>=4)&(buff.symbols_of_death.up|cooldown.symbols_of_death.remains>=10+set_bonus.tier20_4pc*5)&buff.the_first_of_the_dead.remains<1&(buff.finality_eviscerate.up|spell_targets.shuriken_storm<4)
    if not Talent(dark_shadow_talent) or not { not SpellCooldown(vanish) > 0 } and { not BuffPresent(shadow_dance_buff) or Enemies(tagged=1) >= 4 } and { BuffPresent(symbols_of_death_buff) or SpellCooldown(symbols_of_death) >= 10 + ArmorSetBonus(T20 4) * 5 } and BuffRemaining(the_first_of_the_dead_buff) < 1 and { BuffPresent(finality_eviscerate_buff) or Enemies(tagged=1) < 4 } Spell(death_from_above)
    #eviscerate
    Spell(eviscerate)
}

AddFunction SubtletyFinishMainPostConditions
{
}

AddFunction SubtletyFinishShortCdActions
{
}

AddFunction SubtletyFinishShortCdPostConditions
{
    { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 6 and { BuffRemaining(master_assassins_initiative) == 0 or target.DebuffRemaining(nightblade_debuff) <= BuffRemaining(master_assassins_initiative) } and { target.Refreshable(nightblade_debuff) and { not HasArtifactTrait(finality) or DebuffPresent(finality_nightblade_debuff) or dsh_dfa() } or target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 } and { Enemies(tagged=1) < 4 and not dsh_dfa() or not BuffPresent(symbols_of_death_buff) } and Spell(nightblade) or { not Talent(death_from_above_talent) or ArmorSetBonus(T19 2) } and { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 12 and BuffRemaining(master_assassins_initiative) == 0 and { target.Refreshable(nightblade_debuff) and { not HasArtifactTrait(finality) or DebuffPresent(finality_nightblade_debuff) or dsh_dfa() } or target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 } and { Enemies(tagged=1) < 4 and not dsh_dfa() or not BuffPresent(symbols_of_death_buff) } and Spell(nightblade) or target.DebuffRemaining(nightblade_debuff) < SpellCooldown(symbols_of_death) + 10 and SpellCooldown(symbols_of_death) <= 5 + { ComboPoints() == 6 } and Spell(nightblade) or { not Talent(dark_shadow_talent) or not { not SpellCooldown(vanish) > 0 } and { not BuffPresent(shadow_dance_buff) or Enemies(tagged=1) >= 4 } and { BuffPresent(symbols_of_death_buff) or SpellCooldown(symbols_of_death) >= 10 + ArmorSetBonus(T20 4) * 5 } and BuffRemaining(the_first_of_the_dead_buff) < 1 and { BuffPresent(finality_eviscerate_buff) or Enemies(tagged=1) < 4 } } and Spell(death_from_above) or Spell(eviscerate)
}

AddFunction SubtletyFinishCdActions
{
}

AddFunction SubtletyFinishCdPostConditions
{
    { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 6 and { BuffRemaining(master_assassins_initiative) == 0 or target.DebuffRemaining(nightblade_debuff) <= BuffRemaining(master_assassins_initiative) } and { target.Refreshable(nightblade_debuff) and { not HasArtifactTrait(finality) or DebuffPresent(finality_nightblade_debuff) or dsh_dfa() } or target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 } and { Enemies(tagged=1) < 4 and not dsh_dfa() or not BuffPresent(symbols_of_death_buff) } and Spell(nightblade) or { not Talent(death_from_above_talent) or ArmorSetBonus(T19 2) } and { not Talent(dark_shadow_talent) or not BuffPresent(shadow_dance_buff) } and target.TimeToDie() - target.DebuffRemaining(nightblade_debuff) > 12 and BuffRemaining(master_assassins_initiative) == 0 and { target.Refreshable(nightblade_debuff) and { not HasArtifactTrait(finality) or DebuffPresent(finality_nightblade_debuff) or dsh_dfa() } or target.DebuffRemaining(nightblade_debuff) < target.TickTime(nightblade_debuff) * 2 } and { Enemies(tagged=1) < 4 and not dsh_dfa() or not BuffPresent(symbols_of_death_buff) } and Spell(nightblade) or target.DebuffRemaining(nightblade_debuff) < SpellCooldown(symbols_of_death) + 10 and SpellCooldown(symbols_of_death) <= 5 + { ComboPoints() == 6 } and Spell(nightblade) or { not Talent(dark_shadow_talent) or not { not SpellCooldown(vanish) > 0 } and { not BuffPresent(shadow_dance_buff) or Enemies(tagged=1) >= 4 } and { BuffPresent(symbols_of_death_buff) or SpellCooldown(symbols_of_death) >= 10 + ArmorSetBonus(T20 4) * 5 } and BuffRemaining(the_first_of_the_dead_buff) < 1 and { BuffPresent(finality_eviscerate_buff) or Enemies(tagged=1) < 4 } } and Spell(death_from_above) or Spell(eviscerate)
}

### actions.precombat

AddFunction SubtletyPrecombatMainActions
{
    #flask
    #augmentation
    #food
    #snapshot_stats
    #variable,name=ssw_refund,value=equipped.shadow_satyrs_walk*(6+ssw_refund_offset)
    #variable,name=stealth_threshold,value=(65+talent.vigor.enabled*35+talent.master_of_shadows.enabled*10+variable.ssw_refund)
    #variable,name=shd_fractional,value=1.725+0.725*talent.enveloping_shadows.enabled
    #stealth
    Spell(stealth)
}

AddFunction SubtletyPrecombatMainPostConditions
{
}

AddFunction SubtletyPrecombatShortCdActions
{
    unless Spell(stealth)
    {
        #marked_for_death,precombat=1
        if not InCombat() Spell(marked_for_death)
    }
}

AddFunction SubtletyPrecombatShortCdPostConditions
{
    Spell(stealth)
}

AddFunction SubtletyPrecombatCdActions
{
    unless Spell(stealth)
    {
        #potion
        # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
    }
}

AddFunction SubtletyPrecombatCdPostConditions
{
    Spell(stealth)
}

### actions.stealth_als

AddFunction SubtletyStealthAlsMainActions
{
    #call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold-25*(!cooldown.goremaws_bite.up&!buff.feeding_frenzy.up)&(!equipped.shadow_satyrs_walk|cooldown.shadow_dance.charges_fractional>=variable.shd_fractional|energy.deficit>=10)
    if EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } SubtletyStealthCdsMainActions()

    unless EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } and SubtletyStealthCdsMainPostConditions()
    {
        #call_action_list,name=stealth_cds,if=mantle_duration>2.3
        if BuffRemaining(master_assassins_initiative) > 2.3 SubtletyStealthCdsMainActions()

        unless BuffRemaining(master_assassins_initiative) > 2.3 and SubtletyStealthCdsMainPostConditions()
        {
            #call_action_list,name=stealth_cds,if=spell_targets.shuriken_storm>=4
            if Enemies(tagged=1) >= 4 SubtletyStealthCdsMainActions()

            unless Enemies(tagged=1) >= 4 and SubtletyStealthCdsMainPostConditions()
            {
                #call_action_list,name=stealth_cds,if=(cooldown.shadowmeld.up&!cooldown.vanish.up&cooldown.shadow_dance.charges<=1)
                if not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 SubtletyStealthCdsMainActions()

                unless not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 and SubtletyStealthCdsMainPostConditions()
                {
                    #call_action_list,name=stealth_cds,if=target.time_to_die<12*cooldown.shadow_dance.charges_fractional*(1+equipped.shadow_satyrs_walk*0.5)
                    if target.TimeToDie() < 12 * SpellCharges(shadow_dance count=0) * { 1 + HasEquippedItem(shadow_satyrs_walk) * 0.5 } SubtletyStealthCdsMainActions()
                }
            }
        }
    }
}

AddFunction SubtletyStealthAlsMainPostConditions
{
    EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } and SubtletyStealthCdsMainPostConditions() or BuffRemaining(master_assassins_initiative) > 2.3 and SubtletyStealthCdsMainPostConditions() or Enemies(tagged=1) >= 4 and SubtletyStealthCdsMainPostConditions() or not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 and SubtletyStealthCdsMainPostConditions() or target.TimeToDie() < 12 * SpellCharges(shadow_dance count=0) * { 1 + HasEquippedItem(shadow_satyrs_walk) * 0.5 } and SubtletyStealthCdsMainPostConditions()
}

AddFunction SubtletyStealthAlsShortCdActions
{
    #call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold-25*(!cooldown.goremaws_bite.up&!buff.feeding_frenzy.up)&(!equipped.shadow_satyrs_walk|cooldown.shadow_dance.charges_fractional>=variable.shd_fractional|energy.deficit>=10)
    if EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } SubtletyStealthCdsShortCdActions()

    unless EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } and SubtletyStealthCdsShortCdPostConditions()
    {
        #call_action_list,name=stealth_cds,if=mantle_duration>2.3
        if BuffRemaining(master_assassins_initiative) > 2.3 SubtletyStealthCdsShortCdActions()

        unless BuffRemaining(master_assassins_initiative) > 2.3 and SubtletyStealthCdsShortCdPostConditions()
        {
            #call_action_list,name=stealth_cds,if=spell_targets.shuriken_storm>=4
            if Enemies(tagged=1) >= 4 SubtletyStealthCdsShortCdActions()

            unless Enemies(tagged=1) >= 4 and SubtletyStealthCdsShortCdPostConditions()
            {
                #call_action_list,name=stealth_cds,if=(cooldown.shadowmeld.up&!cooldown.vanish.up&cooldown.shadow_dance.charges<=1)
                if not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 SubtletyStealthCdsShortCdActions()

                unless not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 and SubtletyStealthCdsShortCdPostConditions()
                {
                    #call_action_list,name=stealth_cds,if=target.time_to_die<12*cooldown.shadow_dance.charges_fractional*(1+equipped.shadow_satyrs_walk*0.5)
                    if target.TimeToDie() < 12 * SpellCharges(shadow_dance count=0) * { 1 + HasEquippedItem(shadow_satyrs_walk) * 0.5 } SubtletyStealthCdsShortCdActions()
                }
            }
        }
    }
}

AddFunction SubtletyStealthAlsShortCdPostConditions
{
    EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } and SubtletyStealthCdsShortCdPostConditions() or BuffRemaining(master_assassins_initiative) > 2.3 and SubtletyStealthCdsShortCdPostConditions() or Enemies(tagged=1) >= 4 and SubtletyStealthCdsShortCdPostConditions() or not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 and SubtletyStealthCdsShortCdPostConditions() or target.TimeToDie() < 12 * SpellCharges(shadow_dance count=0) * { 1 + HasEquippedItem(shadow_satyrs_walk) * 0.5 } and SubtletyStealthCdsShortCdPostConditions()
}

AddFunction SubtletyStealthAlsCdActions
{
    #call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold-25*(!cooldown.goremaws_bite.up&!buff.feeding_frenzy.up)&(!equipped.shadow_satyrs_walk|cooldown.shadow_dance.charges_fractional>=variable.shd_fractional|energy.deficit>=10)
    if EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } SubtletyStealthCdsCdActions()

    unless EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } and SubtletyStealthCdsCdPostConditions()
    {
        #call_action_list,name=stealth_cds,if=mantle_duration>2.3
        if BuffRemaining(master_assassins_initiative) > 2.3 SubtletyStealthCdsCdActions()

        unless BuffRemaining(master_assassins_initiative) > 2.3 and SubtletyStealthCdsCdPostConditions()
        {
            #call_action_list,name=stealth_cds,if=spell_targets.shuriken_storm>=4
            if Enemies(tagged=1) >= 4 SubtletyStealthCdsCdActions()

            unless Enemies(tagged=1) >= 4 and SubtletyStealthCdsCdPostConditions()
            {
                #call_action_list,name=stealth_cds,if=(cooldown.shadowmeld.up&!cooldown.vanish.up&cooldown.shadow_dance.charges<=1)
                if not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 SubtletyStealthCdsCdActions()

                unless not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 and SubtletyStealthCdsCdPostConditions()
                {
                    #call_action_list,name=stealth_cds,if=target.time_to_die<12*cooldown.shadow_dance.charges_fractional*(1+equipped.shadow_satyrs_walk*0.5)
                    if target.TimeToDie() < 12 * SpellCharges(shadow_dance count=0) * { 1 + HasEquippedItem(shadow_satyrs_walk) * 0.5 } SubtletyStealthCdsCdActions()
                }
            }
        }
    }
}

AddFunction SubtletyStealthAlsCdPostConditions
{
    EnergyDeficit() <= stealth_threshold() - 25 * { not { not SpellCooldown(goremaws_bite) > 0 } and not BuffPresent(feeding_frenzy_buff) } and { not HasEquippedItem(shadow_satyrs_walk) or SpellCharges(shadow_dance count=0) >= shd_fractional() or EnergyDeficit() >= 10 } and SubtletyStealthCdsCdPostConditions() or BuffRemaining(master_assassins_initiative) > 2.3 and SubtletyStealthCdsCdPostConditions() or Enemies(tagged=1) >= 4 and SubtletyStealthCdsCdPostConditions() or not SpellCooldown(shadowmeld) > 0 and not { not SpellCooldown(vanish) > 0 } and SpellCharges(shadow_dance) <= 1 and SubtletyStealthCdsCdPostConditions() or target.TimeToDie() < 12 * SpellCharges(shadow_dance count=0) * { 1 + HasEquippedItem(shadow_satyrs_walk) * 0.5 } and SubtletyStealthCdsCdPostConditions()
}

### actions.stealth_cds

AddFunction SubtletyStealthCdsMainActions
{
}

AddFunction SubtletyStealthCdsMainPostConditions
{
}

AddFunction SubtletyStealthCdsShortCdActions
{
    #vanish,if=!variable.dsh_dfa&mantle_duration=0&cooldown.shadow_dance.charges_fractional<variable.shd_fractional+(equipped.mantle_of_the_master_assassin&time<30)*0.3&(!equipped.mantle_of_the_master_assassin|buff.symbols_of_death.up)
    if not dsh_dfa() and BuffRemaining(master_assassins_initiative) == 0 and SpellCharges(shadow_dance count=0) < shd_fractional() + { HasEquippedItem(mantle_of_the_master_assassin) and TimeInCombat() < 30 } * 0.3 and { not HasEquippedItem(mantle_of_the_master_assassin) or BuffPresent(symbols_of_death_buff) } Spell(vanish)
    #shadow_dance,if=charges_fractional>=variable.shd_fractional|target.time_to_die<cooldown.symbols_of_death.remains
    if Charges(shadow_dance count=0) >= shd_fractional() or target.TimeToDie() < SpellCooldown(symbols_of_death) Spell(shadow_dance)
    #pool_resource,for_next=1,extra_amount=40
    #shadowmeld,if=energy>=40&energy.deficit>=10+variable.ssw_refund
    unless True(pool_energy 40) and EnergyDeficit() >= 10 + ssw_refund() and SpellUsable(shadowmeld) and SpellCooldown(shadowmeld) < TimeToEnergy(40)
    {
        #shadow_dance,if=!variable.dsh_dfa&combo_points.deficit>=2+talent.subterfuge.enabled*2&(buff.symbols_of_death.remains>=1.2+gcd.remains|cooldown.symbols_of_death.remains>=12+(talent.dark_shadow.enabled&set_bonus.tier20_4pc)*3-(!talent.dark_shadow.enabled&set_bonus.tier20_4pc)*4|mantle_duration>0)&(spell_targets.shuriken_storm>=4|!buff.the_first_of_the_dead.up)
        if not dsh_dfa() and ComboPointsDeficit() >= 2 + TalentPoints(subterfuge_talent) * 2 and { BuffRemaining(symbols_of_death_buff) >= 1.2 + GCDRemaining() or SpellCooldown(symbols_of_death) >= 12 + { Talent(dark_shadow_talent) and ArmorSetBonus(T20 4) } * 3 - { not Talent(dark_shadow_talent) and ArmorSetBonus(T20 4) } * 4 or BuffRemaining(master_assassins_initiative) > 0 } and { Enemies(tagged=1) >= 4 or not BuffPresent(the_first_of_the_dead_buff) } Spell(shadow_dance)
    }
}

AddFunction SubtletyStealthCdsShortCdPostConditions
{
}

AddFunction SubtletyStealthCdsCdActions
{
    #pool_resource,for_next=1,extra_amount=40
    #shadowmeld,if=energy>=40&energy.deficit>=10+variable.ssw_refund
    if Energy() >= 40 and EnergyDeficit() >= 10 + ssw_refund() Spell(shadowmeld)
}

AddFunction SubtletyStealthCdsCdPostConditions
{
}

### actions.stealthed

AddFunction SubtletyStealthedMainActions
{
    #shadowstrike,if=buff.stealth.up
    if BuffPresent(stealthed_buff any=1) Spell(shadowstrike)
    #call_action_list,name=finish,if=combo_points>=5+(talent.deeper_stratagem.enabled&buff.vanish.up)&(spell_targets.shuriken_storm>=3+equipped.shadow_satyrs_walk|(mantle_duration<=1.3&mantle_duration-gcd.remains>=0.3))
    if ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and { Enemies(tagged=1) >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } SubtletyFinishMainActions()

    unless ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and { Enemies(tagged=1) >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } and SubtletyFinishMainPostConditions()
    {
        #shuriken_storm,if=buff.shadowmeld.down&((combo_points.deficit>=2+equipped.insignia_of_ravenholdt&spell_targets.shuriken_storm>=3+equipped.shadow_satyrs_walk)|(combo_points.deficit>=1&buff.the_dreadlords_deceit.stack>=29))
        if BuffExpires(shadowmeld_buff) and { ComboPointsDeficit() >= 2 + HasEquippedItem(insignia_of_ravenholdt) and Enemies(tagged=1) >= 3 + HasEquippedItem(shadow_satyrs_walk) or ComboPointsDeficit() >= 1 and BuffStacks(the_dreadlords_deceit_buff) >= 29 } Spell(shuriken_storm)
        #call_action_list,name=finish,if=combo_points>=5+(talent.deeper_stratagem.enabled&buff.vanish.up)&combo_points.deficit<3+buff.shadow_blades.up-equipped.mantle_of_the_master_assassin
        if ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and ComboPointsDeficit() < 3 + BuffPresent(shadow_blades_buff) - HasEquippedItem(mantle_of_the_master_assassin) SubtletyFinishMainActions()

        unless ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and ComboPointsDeficit() < 3 + BuffPresent(shadow_blades_buff) - HasEquippedItem(mantle_of_the_master_assassin) and SubtletyFinishMainPostConditions()
        {
            #shadowstrike
            Spell(shadowstrike)
        }
    }
}

AddFunction SubtletyStealthedMainPostConditions
{
    ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and { Enemies(tagged=1) >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } and SubtletyFinishMainPostConditions() or ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and ComboPointsDeficit() < 3 + BuffPresent(shadow_blades_buff) - HasEquippedItem(mantle_of_the_master_assassin) and SubtletyFinishMainPostConditions()
}

AddFunction SubtletyStealthedShortCdActions
{
    unless BuffPresent(stealthed_buff any=1) and Spell(shadowstrike)
    {
        #call_action_list,name=finish,if=combo_points>=5+(talent.deeper_stratagem.enabled&buff.vanish.up)&(spell_targets.shuriken_storm>=3+equipped.shadow_satyrs_walk|(mantle_duration<=1.3&mantle_duration-gcd.remains>=0.3))
        if ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and { Enemies(tagged=1) >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } SubtletyFinishShortCdActions()

        unless ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and { Enemies(tagged=1) >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } and SubtletyFinishShortCdPostConditions() or BuffExpires(shadowmeld_buff) and { ComboPointsDeficit() >= 2 + HasEquippedItem(insignia_of_ravenholdt) and Enemies(tagged=1) >= 3 + HasEquippedItem(shadow_satyrs_walk) or ComboPointsDeficit() >= 1 and BuffStacks(the_dreadlords_deceit_buff) >= 29 } and Spell(shuriken_storm)
        {
            #call_action_list,name=finish,if=combo_points>=5+(talent.deeper_stratagem.enabled&buff.vanish.up)&combo_points.deficit<3+buff.shadow_blades.up-equipped.mantle_of_the_master_assassin
            if ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and ComboPointsDeficit() < 3 + BuffPresent(shadow_blades_buff) - HasEquippedItem(mantle_of_the_master_assassin) SubtletyFinishShortCdActions()
        }
    }
}

AddFunction SubtletyStealthedShortCdPostConditions
{
    BuffPresent(stealthed_buff any=1) and Spell(shadowstrike) or ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and { Enemies(tagged=1) >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } and SubtletyFinishShortCdPostConditions() or BuffExpires(shadowmeld_buff) and { ComboPointsDeficit() >= 2 + HasEquippedItem(insignia_of_ravenholdt) and Enemies(tagged=1) >= 3 + HasEquippedItem(shadow_satyrs_walk) or ComboPointsDeficit() >= 1 and BuffStacks(the_dreadlords_deceit_buff) >= 29 } and Spell(shuriken_storm) or ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and ComboPointsDeficit() < 3 + BuffPresent(shadow_blades_buff) - HasEquippedItem(mantle_of_the_master_assassin) and SubtletyFinishShortCdPostConditions() or Spell(shadowstrike)
}

AddFunction SubtletyStealthedCdActions
{
    unless BuffPresent(stealthed_buff any=1) and Spell(shadowstrike)
    {
        #call_action_list,name=finish,if=combo_points>=5+(talent.deeper_stratagem.enabled&buff.vanish.up)&(spell_targets.shuriken_storm>=3+equipped.shadow_satyrs_walk|(mantle_duration<=1.3&mantle_duration-gcd.remains>=0.3))
        if ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and { Enemies(tagged=1) >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } SubtletyFinishCdActions()

        unless ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and { Enemies(tagged=1) >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } and SubtletyFinishCdPostConditions() or BuffExpires(shadowmeld_buff) and { ComboPointsDeficit() >= 2 + HasEquippedItem(insignia_of_ravenholdt) and Enemies(tagged=1) >= 3 + HasEquippedItem(shadow_satyrs_walk) or ComboPointsDeficit() >= 1 and BuffStacks(the_dreadlords_deceit_buff) >= 29 } and Spell(shuriken_storm)
        {
            #call_action_list,name=finish,if=combo_points>=5+(talent.deeper_stratagem.enabled&buff.vanish.up)&combo_points.deficit<3+buff.shadow_blades.up-equipped.mantle_of_the_master_assassin
            if ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and ComboPointsDeficit() < 3 + BuffPresent(shadow_blades_buff) - HasEquippedItem(mantle_of_the_master_assassin) SubtletyFinishCdActions()
        }
    }
}

AddFunction SubtletyStealthedCdPostConditions
{
    BuffPresent(stealthed_buff any=1) and Spell(shadowstrike) or ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and { Enemies(tagged=1) >= 3 + HasEquippedItem(shadow_satyrs_walk) or BuffRemaining(master_assassins_initiative) <= 1.3 and BuffRemaining(master_assassins_initiative) - GCDRemaining() >= 0.3 } and SubtletyFinishCdPostConditions() or BuffExpires(shadowmeld_buff) and { ComboPointsDeficit() >= 2 + HasEquippedItem(insignia_of_ravenholdt) and Enemies(tagged=1) >= 3 + HasEquippedItem(shadow_satyrs_walk) or ComboPointsDeficit() >= 1 and BuffStacks(the_dreadlords_deceit_buff) >= 29 } and Spell(shuriken_storm) or ComboPoints() >= 5 + { Talent(deeper_stratagem_talent) and BuffPresent(vanish_buff) } and ComboPointsDeficit() < 3 + BuffPresent(shadow_blades_buff) - HasEquippedItem(mantle_of_the_master_assassin) and SubtletyFinishCdPostConditions() or Spell(shadowstrike)
}
]]

	OvaleScripts:RegisterScript("ROGUE", "subtlety", name, desc, code, "script")
end
