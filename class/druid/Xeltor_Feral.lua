local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_feral"
	local desc = "[Xel][7.3] Druid: Feral"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_druid_spells)

Define(travel_form 783)
Define(travel_form_buff 783)

# Feral
AddIcon specialization=2 help=main
{
	# Pre-combat stuff
	if not mounted() and not BuffPresent(travel_form)
	{
		#mark_of_the_wild,if=!aura.str_agi_int.up
		# if not BuffPresent(str_agi_int_buff any=1) Spell(mark_of_the_wild)
		# CHANGE: Cast Healing Touch to gain Bloodtalons buff if less than 20s remaining on the buff.
		#healing_touch,if=talent.bloodtalons.enabled
		#if Talent(bloodtalons_talent) Spell(healing_touch)
		# if Talent(bloodtalons_talent) and BuffRemaining(bloodtalons_buff) < 20 and not InCombat() and Speed() == 0 Spell(healing_touch)
		if target.Present() and target.Exists() and not target.IsFriend()
		{
			#cat_form
			if not BuffPresent(cat_form) Spell(cat_form)
			#prowl
			if not (BuffPresent(prowl_buff) or BuffPresent(shadowmeld_buff)) and not InCombat() Spell(prowl)
		}
	}
	
	# Interrupt
	if InCombat() and not mounted() and not BuffPresent(travel_form) InterruptActions()
	
	# Rotation
	if target.InRange(rake) and HasFullControl() and target.Present()
	{
		# Cooldowns
		if Boss()
		{
			FeralDefaultCdActions()
		}
		
		# Short Cooldowns
		FeralDefaultShortCdActions()
		
		# Default Actions
		FeralDefaultMainActions()
	}
	if InCombat() and target.Present() and not target.IsFriend() and not target.InRange(rake) and target.InRange(wild_charge) and { TimeInCombat() < 6 or Falling() } Spell(wild_charge)
	if CheckBoxOn(travers) Travel()
}
AddCheckBox(travers "Auto-travel")

AddFunction Boss
{
	IsBossFight() or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

# Travel!
AddFunction Travel
{
	if not InCombat() and Speed() > 0 and {not target.Present() or target.IsFriend()}
	{
		if not BuffPresent(travel_form) and not Indoors() and { Wet() or Falling() } Spell(travel_form)
	}
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		if target.InRange(skull_bash) Spell(skull_bash)
		if not target.Classification(worldboss)
		{
			if target.InRange(mighty_bash) Spell(mighty_bash)
			if target.Distance(less 18) Spell(typhoon)
			if target.InRange(maim) Spell(war_stomp)
		}
	}
}

AddFunction use_thrash
{
    if HasEquippedItem(luffa_wrappings) 1
    0
}

### actions.default

AddFunction FeralDefaultMainActions
{
    #run_action_list,name=single_target,if=dot.rip.ticking|time>15
    if target.DebuffPresent(rip_debuff) or TimeInCombat() > 15 FeralSingleTargetMainActions()

    unless { target.DebuffPresent(rip_debuff) or TimeInCombat() > 15 } and FeralSingleTargetMainPostConditions()
    {
        #rake,if=!ticking|buff.prowl.up
        if not target.DebuffPresent(rake_debuff) or BuffPresent(prowl_buff) Spell(rake)
        #moonfire_cat,if=talent.lunar_inspiration.enabled&!ticking
        if Talent(lunar_inspiration_talent) and not target.DebuffPresent(moonfire_cat_debuff) Spell(moonfire_cat)
        #savage_roar,if=!buff.savage_roar.up
        if not BuffPresent(savage_roar_buff) Spell(savage_roar)
        #regrowth,if=(talent.sabertooth.enabled|buff.predatory_swiftness.up)&talent.bloodtalons.enabled&buff.bloodtalons.down&combo_points=5
        if BuffPresent(predatory_swiftness_buff) and Talent(bloodtalons_talent) and BuffExpires(bloodtalons_buff) and ComboPoints() == 5 Spell(regrowth)
        #rip,if=combo_points=5
        if ComboPoints() == 5 Spell(rip)
        #thrash_cat,if=!ticking&variable.use_thrash>0
        if not target.DebuffPresent(thrash_cat_debuff) and use_thrash() > 0 Spell(thrash_cat)
        #shred
        Spell(shred)
    }
}

AddFunction FeralDefaultMainPostConditions
{
    { target.DebuffPresent(rip_debuff) or TimeInCombat() > 15 } and FeralSingleTargetMainPostConditions()
}

AddFunction FeralDefaultShortCdActions
{
    #run_action_list,name=single_target,if=dot.rip.ticking|time>15
    if target.DebuffPresent(rip_debuff) or TimeInCombat() > 15 FeralSingleTargetShortCdActions()

    unless { target.DebuffPresent(rip_debuff) or TimeInCombat() > 15 } and FeralSingleTargetShortCdPostConditions() or { not target.DebuffPresent(rake_debuff) or BuffPresent(prowl_buff) } and Spell(rake)
    {
        #auto_attack
        # FeralGetInMeleeRange()

        unless Talent(lunar_inspiration_talent) and not target.DebuffPresent(moonfire_cat_debuff) and Spell(moonfire_cat) or not BuffPresent(savage_roar_buff) and Spell(savage_roar)
        {
            #tigers_fury
            Spell(tigers_fury)
            #ashamanes_frenzy
            Spell(ashamanes_frenzy)
        }
    }
}

AddFunction FeralDefaultShortCdPostConditions
{
    { target.DebuffPresent(rip_debuff) or TimeInCombat() > 15 } and FeralSingleTargetShortCdPostConditions() or { not target.DebuffPresent(rake_debuff) or BuffPresent(prowl_buff) } and Spell(rake) or Talent(lunar_inspiration_talent) and not target.DebuffPresent(moonfire_cat_debuff) and Spell(moonfire_cat) or not BuffPresent(savage_roar_buff) and Spell(savage_roar) or { Talent(sabertooth_talent) or BuffPresent(predatory_swiftness_buff) } and Talent(bloodtalons_talent) and BuffExpires(bloodtalons_buff) and ComboPoints() == 5 and Spell(regrowth) or ComboPoints() == 5 and Spell(rip) or not target.DebuffPresent(thrash_cat_debuff) and use_thrash() > 0 and Spell(thrash_cat) or Spell(shred)
}

AddFunction FeralDefaultCdActions
{
    #run_action_list,name=single_target,if=dot.rip.ticking|time>15
    if target.DebuffPresent(rip_debuff) or TimeInCombat() > 15 FeralSingleTargetCdActions()

    unless { target.DebuffPresent(rip_debuff) or TimeInCombat() > 15 } and FeralSingleTargetCdPostConditions() or { not target.DebuffPresent(rake_debuff) or BuffPresent(prowl_buff) } and Spell(rake)
    {
        #dash,if=!buff.cat_form.up
        if not BuffPresent(cat_form_buff) Spell(dash)

        unless Talent(lunar_inspiration_talent) and not target.DebuffPresent(moonfire_cat_debuff) and Spell(moonfire_cat) or not BuffPresent(savage_roar_buff) and Spell(savage_roar)
        {
            #berserk
            Spell(berserk_cat)
            #incarnation
            Spell(incarnation_king_of_the_jungle)
        }
    }
}

AddFunction FeralDefaultCdPostConditions
{
    { target.DebuffPresent(rip_debuff) or TimeInCombat() > 15 } and FeralSingleTargetCdPostConditions() or { not target.DebuffPresent(rake_debuff) or BuffPresent(prowl_buff) } and Spell(rake) or Talent(lunar_inspiration_talent) and not target.DebuffPresent(moonfire_cat_debuff) and Spell(moonfire_cat) or not BuffPresent(savage_roar_buff) and Spell(savage_roar) or Spell(ashamanes_frenzy) or { Talent(sabertooth_talent) or BuffPresent(predatory_swiftness_buff) } and Talent(bloodtalons_talent) and BuffExpires(bloodtalons_buff) and ComboPoints() == 5 and Spell(regrowth) or ComboPoints() == 5 and Spell(rip) or not target.DebuffPresent(thrash_cat_debuff) and use_thrash() > 0 and Spell(thrash_cat) or Spell(shred)
}

### actions.cooldowns

AddFunction FeralCooldownsMainActions
{
}

AddFunction FeralCooldownsMainPostConditions
{
}

AddFunction FeralCooldownsShortCdActions
{
    #tigers_fury,if=energy.deficit>=60
    if EnergyDeficit() >= 60 Spell(tigers_fury)
    #elunes_guidance,if=combo_points=0&energy>=50
    if ComboPoints() == 0 and Energy() >= 50 Spell(elunes_guidance)
    #ashamanes_frenzy,if=combo_points>=2&(!talent.bloodtalons.enabled|buff.bloodtalons.up)
    if ComboPoints() >= 2 and { not Talent(bloodtalons_talent) or BuffPresent(bloodtalons_buff) } Spell(ashamanes_frenzy)
}

AddFunction FeralCooldownsShortCdPostConditions
{
}

AddFunction FeralCooldownsCdActions
{
    #dash,if=!buff.cat_form.up
    if not BuffPresent(cat_form_buff) Spell(dash)
    #berserk,if=energy>=30&(cooldown.tigers_fury.remains>5|buff.tigers_fury.up)
    if Energy() >= 30 and { SpellCooldown(tigers_fury) > 5 or BuffPresent(tigers_fury_buff) } Spell(berserk_cat)

    unless ComboPoints() == 0 and Energy() >= 50 and Spell(elunes_guidance)
    {
        #incarnation,if=energy>=30&(cooldown.tigers_fury.remains>15|buff.tigers_fury.up)
        if Energy() >= 30 and { SpellCooldown(tigers_fury) > 15 or BuffPresent(tigers_fury_buff) } Spell(incarnation_king_of_the_jungle)
        #potion,name=prolonged_power,if=target.time_to_die<65|(time_to_die<180&(buff.berserk.up|buff.incarnation.up))
        # if { target.TimeToDie() < 65 or target.TimeToDie() < 180 and { BuffPresent(berserk_cat_buff) or BuffPresent(incarnation_king_of_the_jungle_buff) } } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)

        unless ComboPoints() >= 2 and { not Talent(bloodtalons_talent) or BuffPresent(bloodtalons_buff) } and Spell(ashamanes_frenzy)
        {
            #shadowmeld,if=combo_points<5&energy>=action.rake.cost&dot.rake.pmultiplier<2.1&buff.tigers_fury.up&(buff.bloodtalons.up|!talent.bloodtalons.enabled)&(!talent.incarnation.enabled|cooldown.incarnation.remains>18)&!buff.incarnation.up
            if ComboPoints() < 5 and Energy() >= PowerCost(rake) and target.DebuffPersistentMultiplier(rake_debuff) < 2.1 and BuffPresent(tigers_fury_buff) and { BuffPresent(bloodtalons_buff) or not Talent(bloodtalons_talent) } and { not Talent(incarnation_talent) or SpellCooldown(incarnation_king_of_the_jungle) > 18 } and not BuffPresent(incarnation_king_of_the_jungle_buff) Spell(shadowmeld)
            #use_items
            # FeralUseItemActions()
        }
    }
}

AddFunction FeralCooldownsCdPostConditions
{
    ComboPoints() == 0 and Energy() >= 50 and Spell(elunes_guidance) or ComboPoints() >= 2 and { not Talent(bloodtalons_talent) or BuffPresent(bloodtalons_buff) } and Spell(ashamanes_frenzy)
}

### actions.precombat

AddFunction FeralPrecombatMainActions
{
    #flask
    #food
    #augmentation
    #regrowth,if=talent.bloodtalons.enabled
    if Talent(bloodtalons_talent) Spell(regrowth)
    #variable,name=use_thrash,value=0
    #variable,name=use_thrash,value=1,if=equipped.luffa_wrappings
    #cat_form
    Spell(cat_form)
}

AddFunction FeralPrecombatMainPostConditions
{
}

AddFunction FeralPrecombatShortCdActions
{
    unless Talent(bloodtalons_talent) and Spell(regrowth) or Spell(cat_form)
    {
        #prowl
        Spell(prowl)
    }
}

AddFunction FeralPrecombatShortCdPostConditions
{
    Talent(bloodtalons_talent) and Spell(regrowth) or Spell(cat_form)
}

AddFunction FeralPrecombatCdActions
{
    unless Talent(bloodtalons_talent) and Spell(regrowth) or Spell(cat_form)
    {
        #snapshot_stats
        #potion
        # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(old_war_potion usable=1)
    }
}

AddFunction FeralPrecombatCdPostConditions
{
    Talent(bloodtalons_talent) and Spell(regrowth) or Spell(cat_form)
}

### actions.single_target

AddFunction FeralSingleTargetMainActions
{
    #cat_form,if=!buff.cat_form.up
    if not BuffPresent(cat_form_buff) Spell(cat_form)
    #rake,if=buff.prowl.up|buff.shadowmeld.up
    if BuffPresent(prowl_buff) or BuffPresent(shadowmeld_buff) Spell(rake)
    #call_action_list,name=cooldowns
    FeralCooldownsMainActions()

    unless FeralCooldownsMainPostConditions()
    {
        #regrowth,if=combo_points=5&talent.bloodtalons.enabled&buff.bloodtalons.down&(!buff.incarnation.up|dot.rip.remains<8|dot.rake.remains<5)
        # if ComboPoints() == 5 and Talent(bloodtalons_talent) and BuffExpires(bloodtalons_buff) and { not BuffPresent(incarnation_king_of_the_jungle_buff) or target.DebuffRemaining(rip_debuff) < 8 or target.DebuffRemaining(rake_debuff) < 5 } Spell(regrowth)
        #run_action_list,name=st_finishers,if=combo_points>4
        if ComboPoints() > 4 FeralStFinishersMainActions()

        unless ComboPoints() > 4 and FeralStFinishersMainPostConditions()
        {
            #run_action_list,name=st_generators
            FeralStGeneratorsMainActions()
        }
    }
}

AddFunction FeralSingleTargetMainPostConditions
{
    FeralCooldownsMainPostConditions() or ComboPoints() > 4 and FeralStFinishersMainPostConditions() or FeralStGeneratorsMainPostConditions()
}

AddFunction FeralSingleTargetShortCdActions
{
    unless not BuffPresent(cat_form_buff) and Spell(cat_form)
    {
        #auto_attack
        # FeralGetInMeleeRange()

        unless { BuffPresent(prowl_buff) or BuffPresent(shadowmeld_buff) } and Spell(rake)
        {
            #call_action_list,name=cooldowns
            FeralCooldownsShortCdActions()

            unless FeralCooldownsShortCdPostConditions()
            {
                #run_action_list,name=st_finishers,if=combo_points>4
                if ComboPoints() > 4 FeralStFinishersShortCdActions()

                unless ComboPoints() > 4 and FeralStFinishersShortCdPostConditions()
                {
                    #run_action_list,name=st_generators
                    FeralStGeneratorsShortCdActions()
                }
            }
        }
    }
}

AddFunction FeralSingleTargetShortCdPostConditions
{
    not BuffPresent(cat_form_buff) and Spell(cat_form) or { BuffPresent(prowl_buff) or BuffPresent(shadowmeld_buff) } and Spell(rake) or FeralCooldownsShortCdPostConditions() or ComboPoints() > 4 and FeralStFinishersShortCdPostConditions() or FeralStGeneratorsShortCdPostConditions()
}

AddFunction FeralSingleTargetCdActions
{
    unless not BuffPresent(cat_form_buff) and Spell(cat_form) or { BuffPresent(prowl_buff) or BuffPresent(shadowmeld_buff) } and Spell(rake)
    {
        #call_action_list,name=cooldowns
        FeralCooldownsCdActions()

        unless FeralCooldownsCdPostConditions()
        {
            #run_action_list,name=st_finishers,if=combo_points>4
            if ComboPoints() > 4 FeralStFinishersCdActions()

            unless ComboPoints() > 4 and FeralStFinishersCdPostConditions()
            {
                #run_action_list,name=st_generators
                FeralStGeneratorsCdActions()
            }
        }
    }
}

AddFunction FeralSingleTargetCdPostConditions
{
    not BuffPresent(cat_form_buff) and Spell(cat_form) or { BuffPresent(prowl_buff) or BuffPresent(shadowmeld_buff) } and Spell(rake) or FeralCooldownsCdPostConditions() or ComboPoints() > 4 and FeralStFinishersCdPostConditions() or FeralStGeneratorsCdPostConditions()
}

### actions.st_finishers

AddFunction FeralStFinishersMainActions
{
    #pool_resource,for_next=1
    #savage_roar,if=buff.savage_roar.down
    if BuffExpires(savage_roar_buff) Spell(savage_roar)
    unless BuffExpires(savage_roar_buff) and SpellUsable(savage_roar) and SpellCooldown(savage_roar) < TimeToEnergyFor(savage_roar)
    {
        #pool_resource,for_next=1
        #rip,target_if=!ticking|(remains<=duration*0.3)&(target.health.pct>25&!talent.sabertooth.enabled)|(remains<=duration*0.8&persistent_multiplier>dot.rip.pmultiplier)&target.time_to_die>8
        if not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rip_debuff) <= BaseDuration(rip_debuff) * 0.3 and target.HealthPercent() > 25 and not Talent(sabertooth_talent) or target.DebuffRemaining(rip_debuff) <= BaseDuration(rip_debuff) * 0.8 and PersistentMultiplier(rip_debuff) > target.DebuffPersistentMultiplier(rip_debuff) and target.TimeToDie() > 8 Spell(rip)
        unless { not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rip_debuff) <= BaseDuration(rip_debuff) * 0.3 and target.HealthPercent() > 25 and not Talent(sabertooth_talent) or target.DebuffRemaining(rip_debuff) <= BaseDuration(rip_debuff) * 0.8 and PersistentMultiplier(rip_debuff) > target.DebuffPersistentMultiplier(rip_debuff) and target.TimeToDie() > 8 } and SpellUsable(rip) and SpellCooldown(rip) < TimeToEnergyFor(rip)
        {
            #pool_resource,for_next=1
            #savage_roar,if=buff.savage_roar.remains<12
            if BuffRemaining(savage_roar_buff) < 12 Spell(savage_roar)
            unless BuffRemaining(savage_roar_buff) < 12 and SpellUsable(savage_roar) and SpellCooldown(savage_roar) < TimeToEnergyFor(savage_roar)
            {
                #maim,if=buff.fiery_red_maimers.up
                if BuffPresent(fiery_red_maimers_buff) Spell(maim)
                #ferocious_bite,max_energy=1
                if Energy() >= EnergyCost(ferocious_bite max=1) Spell(ferocious_bite)
            }
        }
    }
}

AddFunction FeralStFinishersMainPostConditions
{
}

AddFunction FeralStFinishersShortCdActions
{
}

AddFunction FeralStFinishersShortCdPostConditions
{
    BuffExpires(savage_roar_buff) and Spell(savage_roar) or not { BuffExpires(savage_roar_buff) and SpellUsable(savage_roar) and SpellCooldown(savage_roar) < TimeToEnergyFor(savage_roar) } and { { not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rip_debuff) <= BaseDuration(rip_debuff) * 0.3 and target.HealthPercent() > 25 and not Talent(sabertooth_talent) or target.DebuffRemaining(rip_debuff) <= BaseDuration(rip_debuff) * 0.8 and PersistentMultiplier(rip_debuff) > target.DebuffPersistentMultiplier(rip_debuff) and target.TimeToDie() > 8 } and Spell(rip) or not { { not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rip_debuff) <= BaseDuration(rip_debuff) * 0.3 and target.HealthPercent() > 25 and not Talent(sabertooth_talent) or target.DebuffRemaining(rip_debuff) <= BaseDuration(rip_debuff) * 0.8 and PersistentMultiplier(rip_debuff) > target.DebuffPersistentMultiplier(rip_debuff) and target.TimeToDie() > 8 } and SpellUsable(rip) and SpellCooldown(rip) < TimeToEnergyFor(rip) } and { BuffRemaining(savage_roar_buff) < 12 and Spell(savage_roar) or not { BuffRemaining(savage_roar_buff) < 12 and SpellUsable(savage_roar) and SpellCooldown(savage_roar) < TimeToEnergyFor(savage_roar) } and { BuffPresent(fiery_red_maimers_buff) and Spell(maim) or Energy() >= EnergyCost(ferocious_bite max=1) and Spell(ferocious_bite) } } }
}

AddFunction FeralStFinishersCdActions
{
}

AddFunction FeralStFinishersCdPostConditions
{
    BuffExpires(savage_roar_buff) and Spell(savage_roar) or not { BuffExpires(savage_roar_buff) and SpellUsable(savage_roar) and SpellCooldown(savage_roar) < TimeToEnergyFor(savage_roar) } and { { not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rip_debuff) <= BaseDuration(rip_debuff) * 0.3 and target.HealthPercent() > 25 and not Talent(sabertooth_talent) or target.DebuffRemaining(rip_debuff) <= BaseDuration(rip_debuff) * 0.8 and PersistentMultiplier(rip_debuff) > target.DebuffPersistentMultiplier(rip_debuff) and target.TimeToDie() > 8 } and Spell(rip) or not { { not target.DebuffPresent(rip_debuff) or target.DebuffRemaining(rip_debuff) <= BaseDuration(rip_debuff) * 0.3 and target.HealthPercent() > 25 and not Talent(sabertooth_talent) or target.DebuffRemaining(rip_debuff) <= BaseDuration(rip_debuff) * 0.8 and PersistentMultiplier(rip_debuff) > target.DebuffPersistentMultiplier(rip_debuff) and target.TimeToDie() > 8 } and SpellUsable(rip) and SpellCooldown(rip) < TimeToEnergyFor(rip) } and { BuffRemaining(savage_roar_buff) < 12 and Spell(savage_roar) or not { BuffRemaining(savage_roar_buff) < 12 and SpellUsable(savage_roar) and SpellCooldown(savage_roar) < TimeToEnergyFor(savage_roar) } and { BuffPresent(fiery_red_maimers_buff) and Spell(maim) or Energy() >= EnergyCost(ferocious_bite max=1) and Spell(ferocious_bite) } } }
}

### actions.st_generators

AddFunction FeralStGeneratorsMainActions
{
    #regrowth,if=talent.bloodtalons.enabled&buff.predatory_swiftness.up&buff.bloodtalons.down&combo_points>=2&cooldown.ashamanes_frenzy.remains<gcd
    if Talent(bloodtalons_talent) and BuffPresent(predatory_swiftness_buff) and BuffExpires(bloodtalons_buff) and ComboPoints() >= 2 and SpellCooldown(ashamanes_frenzy) < GCD() Spell(regrowth)
    #regrowth,if=talent.bloodtalons.enabled&buff.predatory_swiftness.up&buff.bloodtalons.down&combo_points=4&dot.rake.remains<4
    if Talent(bloodtalons_talent) and BuffPresent(predatory_swiftness_buff) and BuffExpires(bloodtalons_buff) and ComboPoints() == 4 and target.DebuffRemaining(rake_debuff) < 4 Spell(regrowth)
    #regrowth,if=equipped.ailuro_pouncers&talent.bloodtalons.enabled&(buff.predatory_swiftness.stack>2|(buff.predatory_swiftness.stack>1&dot.rake.remains<3))&buff.bloodtalons.down
    if HasEquippedItem(ailuro_pouncers) and Talent(bloodtalons_talent) and { BuffStacks(predatory_swiftness_buff) > 2 or BuffStacks(predatory_swiftness_buff) > 1 and target.DebuffRemaining(rake_debuff) < 3 } and BuffExpires(bloodtalons_buff) Spell(regrowth)
    #brutal_slash,if=spell_targets.brutal_slash>desired_targets
    if Enemies(tagged=1) > Enemies(tagged=1) Spell(brutal_slash)
    #pool_resource,for_next=1
    #thrash_cat,if=(!ticking|remains<duration*0.3)&(spell_targets.thrash_cat>2)
    if { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and Enemies(tagged=1) > 2 Spell(thrash_cat)
    unless { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and Enemies(tagged=1) > 2 and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat)
    {
        #pool_resource,for_next=1
        #rake,target_if=!ticking|(!talent.bloodtalons.enabled&remains<duration*0.3)&target.time_to_die>4
        if not target.DebuffPresent(rake_debuff) or not Talent(bloodtalons_talent) and target.DebuffRemaining(rake_debuff) < BaseDuration(rake_debuff) * 0.3 and target.TimeToDie() > 4 Spell(rake)
        unless { not target.DebuffPresent(rake_debuff) or not Talent(bloodtalons_talent) and target.DebuffRemaining(rake_debuff) < BaseDuration(rake_debuff) * 0.3 and target.TimeToDie() > 4 } and SpellUsable(rake) and SpellCooldown(rake) < TimeToEnergyFor(rake)
        {
            #pool_resource,for_next=1
            #rake,target_if=talent.bloodtalons.enabled&buff.bloodtalons.up&((remains<=7)&persistent_multiplier>dot.rake.pmultiplier*0.85)&target.time_to_die>4
            if Talent(bloodtalons_talent) and BuffPresent(bloodtalons_buff) and target.DebuffRemaining(rake_debuff) <= 7 and PersistentMultiplier(rake_debuff) > target.DebuffPersistentMultiplier(rake_debuff) * 0.85 and target.TimeToDie() > 4 Spell(rake)
            unless Talent(bloodtalons_talent) and BuffPresent(bloodtalons_buff) and target.DebuffRemaining(rake_debuff) <= 7 and PersistentMultiplier(rake_debuff) > target.DebuffPersistentMultiplier(rake_debuff) * 0.85 and target.TimeToDie() > 4 and SpellUsable(rake) and SpellCooldown(rake) < TimeToEnergyFor(rake)
            {
                #brutal_slash,if=(buff.tigers_fury.up&(raid_event.adds.in>(1+max_charges-charges_fractional)*recharge_time))
                if BuffPresent(tigers_fury_buff) and 600 > { 1 + SpellMaxCharges(brutal_slash) - Charges(brutal_slash count=0) } * SpellChargeCooldown(brutal_slash) Spell(brutal_slash)
                #moonfire_cat,target_if=remains<=duration*0.3
                if target.DebuffRemaining(moonfire_cat_debuff) <= BaseDuration(moonfire_cat_debuff) * 0.3 Spell(moonfire_cat)
                #pool_resource,for_next=1
                #thrash_cat,if=(!ticking|remains<duration*0.3)&(variable.use_thrash=2|spell_targets.thrash_cat>1)
                if { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and { use_thrash() == 2 or Enemies(tagged=1) > 1 } Spell(thrash_cat)
                unless { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and { use_thrash() == 2 or Enemies(tagged=1) > 1 } and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat)
                {
                    #thrash_cat,if=(!ticking|remains<duration*0.3)&variable.use_thrash=1&buff.clearcasting.react
                    if { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and use_thrash() == 1 and BuffPresent(clearcasting_buff) Spell(thrash_cat)
                    #pool_resource,for_next=1
                    #swipe_cat,if=spell_targets.swipe_cat>1
                    if Enemies(tagged=1) > 1 Spell(swipe_cat)
                    unless Enemies(tagged=1) > 1 and SpellUsable(swipe_cat) and SpellCooldown(swipe_cat) < TimeToEnergyFor(swipe_cat)
                    {
                        #shred
                        Spell(shred)
                    }
                }
            }
        }
    }
}

AddFunction FeralStGeneratorsMainPostConditions
{
}

AddFunction FeralStGeneratorsShortCdActions
{
}

AddFunction FeralStGeneratorsShortCdPostConditions
{
    Talent(bloodtalons_talent) and BuffPresent(predatory_swiftness_buff) and BuffExpires(bloodtalons_buff) and ComboPoints() >= 2 and SpellCooldown(ashamanes_frenzy) < GCD() and Spell(regrowth) or Talent(bloodtalons_talent) and BuffPresent(predatory_swiftness_buff) and BuffExpires(bloodtalons_buff) and ComboPoints() == 4 and target.DebuffRemaining(rake_debuff) < 4 and Spell(regrowth) or HasEquippedItem(ailuro_pouncers) and Talent(bloodtalons_talent) and { BuffStacks(predatory_swiftness_buff) > 2 or BuffStacks(predatory_swiftness_buff) > 1 and target.DebuffRemaining(rake_debuff) < 3 } and BuffExpires(bloodtalons_buff) and Spell(regrowth) or Enemies(tagged=1) > Enemies(tagged=1) and Spell(brutal_slash) or { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and Enemies(tagged=1) > 2 and Spell(thrash_cat) or not { { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and Enemies(tagged=1) > 2 and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat) } and { { not target.DebuffPresent(rake_debuff) or not Talent(bloodtalons_talent) and target.DebuffRemaining(rake_debuff) < BaseDuration(rake_debuff) * 0.3 and target.TimeToDie() > 4 } and Spell(rake) or not { { not target.DebuffPresent(rake_debuff) or not Talent(bloodtalons_talent) and target.DebuffRemaining(rake_debuff) < BaseDuration(rake_debuff) * 0.3 and target.TimeToDie() > 4 } and SpellUsable(rake) and SpellCooldown(rake) < TimeToEnergyFor(rake) } and { Talent(bloodtalons_talent) and BuffPresent(bloodtalons_buff) and target.DebuffRemaining(rake_debuff) <= 7 and PersistentMultiplier(rake_debuff) > target.DebuffPersistentMultiplier(rake_debuff) * 0.85 and target.TimeToDie() > 4 and Spell(rake) or not { Talent(bloodtalons_talent) and BuffPresent(bloodtalons_buff) and target.DebuffRemaining(rake_debuff) <= 7 and PersistentMultiplier(rake_debuff) > target.DebuffPersistentMultiplier(rake_debuff) * 0.85 and target.TimeToDie() > 4 and SpellUsable(rake) and SpellCooldown(rake) < TimeToEnergyFor(rake) } and { BuffPresent(tigers_fury_buff) and 600 > { 1 + SpellMaxCharges(brutal_slash) - Charges(brutal_slash count=0) } * SpellChargeCooldown(brutal_slash) and Spell(brutal_slash) or target.DebuffRemaining(moonfire_cat_debuff) <= BaseDuration(moonfire_cat_debuff) * 0.3 and Spell(moonfire_cat) or { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and { use_thrash() == 2 or Enemies(tagged=1) > 1 } and Spell(thrash_cat) or not { { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and { use_thrash() == 2 or Enemies(tagged=1) > 1 } and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat) } and { { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and use_thrash() == 1 and BuffPresent(clearcasting_buff) and Spell(thrash_cat) or Enemies(tagged=1) > 1 and Spell(swipe_cat) or not { Enemies(tagged=1) > 1 and SpellUsable(swipe_cat) and SpellCooldown(swipe_cat) < TimeToEnergyFor(swipe_cat) } and Spell(shred) } } } }
}

AddFunction FeralStGeneratorsCdActions
{
}

AddFunction FeralStGeneratorsCdPostConditions
{
    Talent(bloodtalons_talent) and BuffPresent(predatory_swiftness_buff) and BuffExpires(bloodtalons_buff) and ComboPoints() >= 2 and SpellCooldown(ashamanes_frenzy) < GCD() and Spell(regrowth) or Talent(bloodtalons_talent) and BuffPresent(predatory_swiftness_buff) and BuffExpires(bloodtalons_buff) and ComboPoints() == 4 and target.DebuffRemaining(rake_debuff) < 4 and Spell(regrowth) or HasEquippedItem(ailuro_pouncers) and Talent(bloodtalons_talent) and { BuffStacks(predatory_swiftness_buff) > 2 or BuffStacks(predatory_swiftness_buff) > 1 and target.DebuffRemaining(rake_debuff) < 3 } and BuffExpires(bloodtalons_buff) and Spell(regrowth) or Enemies(tagged=1) > Enemies(tagged=1) and Spell(brutal_slash) or { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and Enemies(tagged=1) > 2 and Spell(thrash_cat) or not { { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and Enemies(tagged=1) > 2 and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat) } and { { not target.DebuffPresent(rake_debuff) or not Talent(bloodtalons_talent) and target.DebuffRemaining(rake_debuff) < BaseDuration(rake_debuff) * 0.3 and target.TimeToDie() > 4 } and Spell(rake) or not { { not target.DebuffPresent(rake_debuff) or not Talent(bloodtalons_talent) and target.DebuffRemaining(rake_debuff) < BaseDuration(rake_debuff) * 0.3 and target.TimeToDie() > 4 } and SpellUsable(rake) and SpellCooldown(rake) < TimeToEnergyFor(rake) } and { Talent(bloodtalons_talent) and BuffPresent(bloodtalons_buff) and target.DebuffRemaining(rake_debuff) <= 7 and PersistentMultiplier(rake_debuff) > target.DebuffPersistentMultiplier(rake_debuff) * 0.85 and target.TimeToDie() > 4 and Spell(rake) or not { Talent(bloodtalons_talent) and BuffPresent(bloodtalons_buff) and target.DebuffRemaining(rake_debuff) <= 7 and PersistentMultiplier(rake_debuff) > target.DebuffPersistentMultiplier(rake_debuff) * 0.85 and target.TimeToDie() > 4 and SpellUsable(rake) and SpellCooldown(rake) < TimeToEnergyFor(rake) } and { BuffPresent(tigers_fury_buff) and 600 > { 1 + SpellMaxCharges(brutal_slash) - Charges(brutal_slash count=0) } * SpellChargeCooldown(brutal_slash) and Spell(brutal_slash) or target.DebuffRemaining(moonfire_cat_debuff) <= BaseDuration(moonfire_cat_debuff) * 0.3 and Spell(moonfire_cat) or { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and { use_thrash() == 2 or Enemies(tagged=1) > 1 } and Spell(thrash_cat) or not { { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and { use_thrash() == 2 or Enemies(tagged=1) > 1 } and SpellUsable(thrash_cat) and SpellCooldown(thrash_cat) < TimeToEnergyFor(thrash_cat) } and { { not target.DebuffPresent(thrash_cat_debuff) or target.DebuffRemaining(thrash_cat_debuff) < BaseDuration(thrash_cat_debuff) * 0.3 } and use_thrash() == 1 and BuffPresent(clearcasting_buff) and Spell(thrash_cat) or Enemies(tagged=1) > 1 and Spell(swipe_cat) or not { Enemies(tagged=1) > 1 and SpellUsable(swipe_cat) and SpellCooldown(swipe_cat) < TimeToEnergyFor(swipe_cat) } and Spell(shred) } } } }
}
]]
	OvaleScripts:RegisterScript("DRUID", "feral", name, desc, code, "script")
end
