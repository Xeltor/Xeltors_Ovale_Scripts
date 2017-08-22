local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "xeltor_survival"
	local desc = "[Xel][7.1.5] Hunter: Survival"
	local code = [[
# Based on SimulationCraft profile "Hunter_SV_T18M".
#	class=hunter
#	spec=survival
#	talents=3202022

Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_hunter_spells)

Define(mend_pet 136)
	SpellInfo(mend_pet duration=10)
	SpellAddBuff(mend_pet mend_pet=1)

# Survival
AddIcon specialization=3 help=main
{
	# Silence
	if InCombat() and target.Casting(interrupt) InterruptActions()
	
	if InCombat() and HasFullControl() and target.Present() and target.InRange(raptor_strike)
	{
		# Pet we needs it.
		SurvivalSummonPet()
	
		# Cooldowns
		if Boss()
		{
			SurvivalDefaultCdActions()
		}
		
		# Short Cooldowns
		SurvivalDefaultShortCdActions()
		
		# Default Actions
		SurvivalDefaultMainActions()
	}
	
	# Go forth and murder
	if InCombat() and HasFullControl() and target.Present() and not target.InRange(raptor_strike) and { TimeInCombat() < 6 or Falling() }
	{
		if target.InRange(harpoon) Spell(harpoon)
	}
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction SurvivalSummonPet
{
    if not Talent(lone_wolf_talent)
    {
        if pet.IsDead()
        {
            if not DebuffPresent(heart_of_the_phoenix_debuff) Spell(heart_of_the_phoenix)
            if Speed() == 0 Spell(revive_pet)
        }
        # if not pet.Present() and not pet.IsDead() and not PreviousSpell(revive_pet) Texture(ability_hunter_beastcall)
    }
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(muzzle) Spell(muzzle)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_focus)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}

### actions.CDs

AddFunction SurvivalCdsMainActions
{
}

AddFunction SurvivalCdsMainPostConditions
{
}

AddFunction SurvivalCdsShortCdActions
{
    #snake_hunter,if=cooldown.mongoose_bite.charges=0&buff.mongoose_fury.remains>3*gcd&buff.aspect_of_the_eagle.down
    if SpellCharges(mongoose_bite) == 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and BuffExpires(aspect_of_the_eagle_buff) Spell(snake_hunter)
}

AddFunction SurvivalCdsShortCdPostConditions
{
}

AddFunction SurvivalCdsCdActions
{
    #arcane_torrent,if=focus<=30
    if Focus() <= 30 Spell(arcane_torrent_focus)
    #berserking,if=buff.aspect_of_the_eagle.up
    if BuffPresent(aspect_of_the_eagle_buff) Spell(berserking)
    #blood_fury,if=buff.aspect_of_the_eagle.up
    if BuffPresent(aspect_of_the_eagle_buff) Spell(blood_fury_ap)
    #potion,if=buff.aspect_of_the_eagle.up
    # if BuffPresent(aspect_of_the_eagle_buff) and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)

    unless SpellCharges(mongoose_bite) == 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and BuffExpires(aspect_of_the_eagle_buff) and Spell(snake_hunter)
    {
        #aspect_of_the_eagle,if=buff.mongoose_fury.stack>=2&buff.mongoose_fury.remains>3*gcd
        if BuffStacks(mongoose_fury_buff) >= 2 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() Spell(aspect_of_the_eagle)
    }
}

AddFunction SurvivalCdsCdPostConditions
{
    SpellCharges(mongoose_bite) == 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and BuffExpires(aspect_of_the_eagle_buff) and Spell(snake_hunter)
}

### actions.default

AddFunction SurvivalDefaultMainActions
{
    #call_action_list,name=mokMaintain,if=talent.way_of_the_moknathal.enabled
    if Talent(way_of_the_moknathal_talent) SurvivalMokmaintainMainActions()

    unless Talent(way_of_the_moknathal_talent) and SurvivalMokmaintainMainPostConditions()
    {
        #call_action_list,name=CDs
        SurvivalCdsMainActions()

        unless SurvivalCdsMainPostConditions()
        {
            #call_action_list,name=preBitePhase,if=!buff.mongoose_fury.up
            if not BuffPresent(mongoose_fury_buff) SurvivalPrebitephaseMainActions()

            unless not BuffPresent(mongoose_fury_buff) and SurvivalPrebitephaseMainPostConditions()
            {
                #call_action_list,name=aoe,if=active_enemies>=3
                if Enemies(tagged=1) >= 3 SurvivalAoeMainActions()

                unless Enemies(tagged=1) >= 3 and SurvivalAoeMainPostConditions()
                {
                    #call_action_list,name=bitePhase
                    SurvivalBitephaseMainActions()

                    unless SurvivalBitephaseMainPostConditions()
                    {
                        #call_action_list,name=biteFill
                        SurvivalBitefillMainActions()

                        unless SurvivalBitefillMainPostConditions()
                        {
                            #call_action_list,name=fillers
                            SurvivalFillersMainActions()
                        }
                    }
                }
            }
        }
    }
}

AddFunction SurvivalDefaultMainPostConditions
{
    Talent(way_of_the_moknathal_talent) and SurvivalMokmaintainMainPostConditions() or SurvivalCdsMainPostConditions() or not BuffPresent(mongoose_fury_buff) and SurvivalPrebitephaseMainPostConditions() or Enemies(tagged=1) >= 3 and SurvivalAoeMainPostConditions() or SurvivalBitephaseMainPostConditions() or SurvivalBitefillMainPostConditions() or SurvivalFillersMainPostConditions()
}

AddFunction SurvivalDefaultShortCdActions
{
    #auto_attack
    # SurvivalGetInMeleeRange()
    #call_action_list,name=mokMaintain,if=talent.way_of_the_moknathal.enabled
    if Talent(way_of_the_moknathal_talent) SurvivalMokmaintainShortCdActions()

    unless Talent(way_of_the_moknathal_talent) and SurvivalMokmaintainShortCdPostConditions()
    {
        #call_action_list,name=CDs
        SurvivalCdsShortCdActions()

        unless SurvivalCdsShortCdPostConditions()
        {
            #call_action_list,name=preBitePhase,if=!buff.mongoose_fury.up
            if not BuffPresent(mongoose_fury_buff) SurvivalPrebitephaseShortCdActions()

            unless not BuffPresent(mongoose_fury_buff) and SurvivalPrebitephaseShortCdPostConditions()
            {
                #call_action_list,name=aoe,if=active_enemies>=3
                if Enemies(tagged=1) >= 3 SurvivalAoeShortCdActions()

                unless Enemies(tagged=1) >= 3 and SurvivalAoeShortCdPostConditions()
                {
                    #call_action_list,name=bitePhase
                    SurvivalBitephaseShortCdActions()

                    unless SurvivalBitephaseShortCdPostConditions()
                    {
                        #call_action_list,name=biteFill
                        SurvivalBitefillShortCdActions()

                        unless SurvivalBitefillShortCdPostConditions()
                        {
                            #call_action_list,name=fillers
                            SurvivalFillersShortCdActions()
                        }
                    }
                }
            }
        }
    }
}

AddFunction SurvivalDefaultShortCdPostConditions
{
    Talent(way_of_the_moknathal_talent) and SurvivalMokmaintainShortCdPostConditions() or SurvivalCdsShortCdPostConditions() or not BuffPresent(mongoose_fury_buff) and SurvivalPrebitephaseShortCdPostConditions() or Enemies(tagged=1) >= 3 and SurvivalAoeShortCdPostConditions() or SurvivalBitephaseShortCdPostConditions() or SurvivalBitefillShortCdPostConditions() or SurvivalFillersShortCdPostConditions()
}

AddFunction SurvivalDefaultCdActions
{
    #muzzle,if=target.debuff.casting.react
    # if target.IsInterruptible() SurvivalInterruptActions()
    #use_items
    # SurvivalUseItemActions()
    #call_action_list,name=mokMaintain,if=talent.way_of_the_moknathal.enabled
    if Talent(way_of_the_moknathal_talent) SurvivalMokmaintainCdActions()

    unless Talent(way_of_the_moknathal_talent) and SurvivalMokmaintainCdPostConditions()
    {
        #call_action_list,name=CDs
        SurvivalCdsCdActions()

        unless SurvivalCdsCdPostConditions()
        {
            #call_action_list,name=preBitePhase,if=!buff.mongoose_fury.up
            if not BuffPresent(mongoose_fury_buff) SurvivalPrebitephaseCdActions()

            unless not BuffPresent(mongoose_fury_buff) and SurvivalPrebitephaseCdPostConditions()
            {
                #call_action_list,name=aoe,if=active_enemies>=3
                if Enemies(tagged=1) >= 3 SurvivalAoeCdActions()

                unless Enemies(tagged=1) >= 3 and SurvivalAoeCdPostConditions()
                {
                    #call_action_list,name=bitePhase
                    SurvivalBitephaseCdActions()

                    unless SurvivalBitephaseCdPostConditions()
                    {
                        #call_action_list,name=biteFill
                        SurvivalBitefillCdActions()

                        unless SurvivalBitefillCdPostConditions()
                        {
                            #call_action_list,name=fillers
                            SurvivalFillersCdActions()
                        }
                    }
                }
            }
        }
    }
}

AddFunction SurvivalDefaultCdPostConditions
{
    Talent(way_of_the_moknathal_talent) and SurvivalMokmaintainCdPostConditions() or SurvivalCdsCdPostConditions() or not BuffPresent(mongoose_fury_buff) and SurvivalPrebitephaseCdPostConditions() or Enemies(tagged=1) >= 3 and SurvivalAoeCdPostConditions() or SurvivalBitephaseCdPostConditions() or SurvivalBitefillCdPostConditions() or SurvivalFillersCdPostConditions()
}

### actions.aoe

AddFunction SurvivalAoeMainActions
{
    #butchery
    Spell(butchery)
    #caltrops,if=!ticking
    if not target.DebuffPresent(caltrops_debuff) Spell(caltrops)
    #carve,if=(talent.serpent_sting.enabled&dot.serpent_sting.refreshable)|(active_enemies>5)
    if Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) or Enemies(tagged=1) > 5 Spell(carve)
}

AddFunction SurvivalAoeMainPostConditions
{
}

AddFunction SurvivalAoeShortCdActions
{
    unless Spell(butchery) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops)
    {
        #explosive_trap
        Spell(explosive_trap)
    }
}

AddFunction SurvivalAoeShortCdPostConditions
{
    Spell(butchery) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or { Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) or Enemies(tagged=1) > 5 } and Spell(carve)
}

AddFunction SurvivalAoeCdActions
{
}

AddFunction SurvivalAoeCdPostConditions
{
    Spell(butchery) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or Spell(explosive_trap) or { Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) or Enemies(tagged=1) > 5 } and Spell(carve)
}

### actions.biteFill

AddFunction SurvivalBitefillMainActions
{
    #butchery,if=equipped.frizzos_fingertrap&dot.lacerate.refreshable
    if HasEquippedItem(frizzos_fingertrap) and target.DebuffRefreshable(lacerate_debuff) Spell(butchery)
    #carve,if=equipped.frizzos_fingertrap&dot.lacerate.refreshable
    if HasEquippedItem(frizzos_fingertrap) and target.DebuffRefreshable(lacerate_debuff) Spell(carve)
    #lacerate,if=refreshable
    if target.Refreshable(lacerate_debuff) Spell(lacerate)
    #raptor_strike,if=active_enemies=1&talent.serpent_sting.enabled&dot.serpent_sting.refreshable
    if Enemies(tagged=1) == 1 and Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) Spell(raptor_strike)
    #caltrops,if=!ticking
    if not target.DebuffPresent(caltrops_debuff) Spell(caltrops)
}

AddFunction SurvivalBitefillMainPostConditions
{
}

AddFunction SurvivalBitefillShortCdActions
{
    #spitting_cobra
    Spell(spitting_cobra)

    unless HasEquippedItem(frizzos_fingertrap) and target.DebuffRefreshable(lacerate_debuff) and Spell(butchery) or HasEquippedItem(frizzos_fingertrap) and target.DebuffRefreshable(lacerate_debuff) and Spell(carve) or target.Refreshable(lacerate_debuff) and Spell(lacerate) or Enemies(tagged=1) == 1 and Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) and Spell(raptor_strike)
    {
        #steel_trap
        Spell(steel_trap)
        #a_murder_of_crows
        Spell(a_murder_of_crows)
        #dragonsfire_grenade
        Spell(dragonsfire_grenade)
        #explosive_trap
        Spell(explosive_trap)
    }
}

AddFunction SurvivalBitefillShortCdPostConditions
{
    HasEquippedItem(frizzos_fingertrap) and target.DebuffRefreshable(lacerate_debuff) and Spell(butchery) or HasEquippedItem(frizzos_fingertrap) and target.DebuffRefreshable(lacerate_debuff) and Spell(carve) or target.Refreshable(lacerate_debuff) and Spell(lacerate) or Enemies(tagged=1) == 1 and Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) and Spell(raptor_strike) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops)
}

AddFunction SurvivalBitefillCdActions
{
}

AddFunction SurvivalBitefillCdPostConditions
{
    Spell(spitting_cobra) or HasEquippedItem(frizzos_fingertrap) and target.DebuffRefreshable(lacerate_debuff) and Spell(butchery) or HasEquippedItem(frizzos_fingertrap) and target.DebuffRefreshable(lacerate_debuff) and Spell(carve) or target.Refreshable(lacerate_debuff) and Spell(lacerate) or Enemies(tagged=1) == 1 and Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) and Spell(raptor_strike) or Spell(steel_trap) or Spell(a_murder_of_crows) or Spell(dragonsfire_grenade) or Spell(explosive_trap) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops)
}

### actions.bitePhase

AddFunction SurvivalBitephaseMainActions
{
    #lacerate,if=!dot.lacerate.ticking&set_bonus.tier20_4pc&buff.mongoose_fury.duration>cooldown.mongoose_bite.charges*gcd
    if not target.DebuffPresent(lacerate_debuff) and ArmorSetBonus(T20 4) and BaseDuration(mongoose_fury_buff) > SpellCharges(mongoose_bite) * GCD() Spell(lacerate)
    #mongoose_bite,if=charges>=2&cooldown.mongoose_bite.remains<gcd*2
    if Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) < GCD() * 2 Spell(mongoose_bite)
    #flanking_strike,if=((buff.mongoose_fury.remains>(gcd*(cooldown.mongoose_bite.charges+2)))&cooldown.mongoose_bite.charges<=1)&(!set_bonus.tier19_4pc|(set_bonus.tier19_4pc&!buff.aspect_of_the_eagle.up))
    if BuffRemaining(mongoose_fury_buff) > GCD() * { SpellCharges(mongoose_bite) + 2 } and SpellCharges(mongoose_bite) <= 1 and { not ArmorSetBonus(T19 4) or ArmorSetBonus(T19 4) and not BuffPresent(aspect_of_the_eagle_buff) } Spell(flanking_strike)
    #mongoose_bite,if=buff.mongoose_fury.up
    if BuffPresent(mongoose_fury_buff) Spell(mongoose_bite)
    #flanking_strike
    Spell(flanking_strike)
}

AddFunction SurvivalBitephaseMainPostConditions
{
}

AddFunction SurvivalBitephaseShortCdActions
{
    #fury_of_the_eagle,if=(!talent.way_of_the_moknathal.enabled|buff.moknathal_tactics.remains>(gcd*(8%3)))&buff.mongoose_fury.stack>3&cooldown.mongoose_bite.charges<1&!buff.aspect_of_the_eagle.up,interrupt_if=(talent.way_of_the_moknathal.enabled&buff.moknathal_tactics.remains<=tick_time)|(cooldown.mongoose_bite.charges=3)
    if { not Talent(way_of_the_moknathal_talent) or BuffRemaining(moknathal_tactics_buff) > GCD() * { 8 / 3 } } and BuffStacks(mongoose_fury_buff) > 3 and SpellCharges(mongoose_bite) < 1 and not BuffPresent(aspect_of_the_eagle_buff) Spell(fury_of_the_eagle)
}

AddFunction SurvivalBitephaseShortCdPostConditions
{
    not target.DebuffPresent(lacerate_debuff) and ArmorSetBonus(T20 4) and BaseDuration(mongoose_fury_buff) > SpellCharges(mongoose_bite) * GCD() and Spell(lacerate) or Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) < GCD() * 2 and Spell(mongoose_bite) or BuffRemaining(mongoose_fury_buff) > GCD() * { SpellCharges(mongoose_bite) + 2 } and SpellCharges(mongoose_bite) <= 1 and { not ArmorSetBonus(T19 4) or ArmorSetBonus(T19 4) and not BuffPresent(aspect_of_the_eagle_buff) } and Spell(flanking_strike) or BuffPresent(mongoose_fury_buff) and Spell(mongoose_bite) or Spell(flanking_strike)
}

AddFunction SurvivalBitephaseCdActions
{
}

AddFunction SurvivalBitephaseCdPostConditions
{
    { not Talent(way_of_the_moknathal_talent) or BuffRemaining(moknathal_tactics_buff) > GCD() * { 8 / 3 } } and BuffStacks(mongoose_fury_buff) > 3 and SpellCharges(mongoose_bite) < 1 and not BuffPresent(aspect_of_the_eagle_buff) and Spell(fury_of_the_eagle) or not target.DebuffPresent(lacerate_debuff) and ArmorSetBonus(T20 4) and BaseDuration(mongoose_fury_buff) > SpellCharges(mongoose_bite) * GCD() and Spell(lacerate) or Charges(mongoose_bite) >= 2 and SpellCooldown(mongoose_bite) < GCD() * 2 and Spell(mongoose_bite) or BuffRemaining(mongoose_fury_buff) > GCD() * { SpellCharges(mongoose_bite) + 2 } and SpellCharges(mongoose_bite) <= 1 and { not ArmorSetBonus(T19 4) or ArmorSetBonus(T19 4) and not BuffPresent(aspect_of_the_eagle_buff) } and Spell(flanking_strike) or BuffPresent(mongoose_fury_buff) and Spell(mongoose_bite) or Spell(flanking_strike)
}

### actions.fillers

AddFunction SurvivalFillersMainActions
{
    #carve,if=active_enemies>1&talent.serpent_sting.enabled&dot.serpent_sting.refreshable
    if Enemies(tagged=1) > 1 and Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) Spell(carve)
    #throwing_axes
    Spell(throwing_axes)
    #carve,if=active_enemies>2
    if Enemies(tagged=1) > 2 Spell(carve)
    #raptor_strike,if=(talent.way_of_the_moknathal.enabled&buff.moknathal_tactics.remains<gcd*4)|(focus>((25-focus.regen*gcd)+55))
    if Talent(way_of_the_moknathal_talent) and BuffRemaining(moknathal_tactics_buff) < GCD() * 4 or Focus() > 25 - FocusRegenRate() * GCD() + 55 Spell(raptor_strike)
}

AddFunction SurvivalFillersMainPostConditions
{
}

AddFunction SurvivalFillersShortCdActions
{
}

AddFunction SurvivalFillersShortCdPostConditions
{
    Enemies(tagged=1) > 1 and Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) and Spell(carve) or Spell(throwing_axes) or Enemies(tagged=1) > 2 and Spell(carve) or { Talent(way_of_the_moknathal_talent) and BuffRemaining(moknathal_tactics_buff) < GCD() * 4 or Focus() > 25 - FocusRegenRate() * GCD() + 55 } and Spell(raptor_strike)
}

AddFunction SurvivalFillersCdActions
{
}

AddFunction SurvivalFillersCdPostConditions
{
    Enemies(tagged=1) > 1 and Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) and Spell(carve) or Spell(throwing_axes) or Enemies(tagged=1) > 2 and Spell(carve) or { Talent(way_of_the_moknathal_talent) and BuffRemaining(moknathal_tactics_buff) < GCD() * 4 or Focus() > 25 - FocusRegenRate() * GCD() + 55 } and Spell(raptor_strike)
}

### actions.mokMaintain

AddFunction SurvivalMokmaintainMainActions
{
    #raptor_strike,if=(buff.moknathal_tactics.remains<gcd)|(buff.moknathal_tactics.stack<2)
    if BuffRemaining(moknathal_tactics_buff) < GCD() or BuffStacks(moknathal_tactics_buff) < 2 Spell(raptor_strike)
}

AddFunction SurvivalMokmaintainMainPostConditions
{
}

AddFunction SurvivalMokmaintainShortCdActions
{
}

AddFunction SurvivalMokmaintainShortCdPostConditions
{
    { BuffRemaining(moknathal_tactics_buff) < GCD() or BuffStacks(moknathal_tactics_buff) < 2 } and Spell(raptor_strike)
}

AddFunction SurvivalMokmaintainCdActions
{
}

AddFunction SurvivalMokmaintainCdPostConditions
{
    { BuffRemaining(moknathal_tactics_buff) < GCD() or BuffStacks(moknathal_tactics_buff) < 2 } and Spell(raptor_strike)
}

### actions.preBitePhase

AddFunction SurvivalPrebitephaseMainActions
{
    #flanking_strike,if=cooldown.mongoose_bite.charges<3
    if SpellCharges(mongoose_bite) < 3 Spell(flanking_strike)
    #raptor_strike,if=active_enemies=1&talent.serpent_sting.enabled&dot.serpent_sting.refreshable
    if Enemies(tagged=1) == 1 and Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) Spell(raptor_strike)
    #lacerate,if=refreshable
    if target.Refreshable(lacerate_debuff) Spell(lacerate)
    #butchery,if=equipped.frizzos_fingertrap&dot.lacerate.refreshable
    if HasEquippedItem(frizzos_fingertrap) and target.DebuffRefreshable(lacerate_debuff) Spell(butchery)
    #carve,if=equipped.frizzos_fingertrap&dot.lacerate.refreshable
    if HasEquippedItem(frizzos_fingertrap) and target.DebuffRefreshable(lacerate_debuff) Spell(carve)
    #mongoose_bite,if=charges=3&cooldown.flanking_strike.remains>=gcd
    if Charges(mongoose_bite) == 3 and SpellCooldown(flanking_strike) >= GCD() Spell(mongoose_bite)
    #caltrops,if=!ticking
    if not target.DebuffPresent(caltrops_debuff) Spell(caltrops)
    #flanking_strike
    Spell(flanking_strike)
    #lacerate,if=remains<14&set_bonus.tier20_2pc
    if target.DebuffRemaining(lacerate_debuff) < 14 and ArmorSetBonus(T20 2) Spell(lacerate)
}

AddFunction SurvivalPrebitephaseMainPostConditions
{
}

AddFunction SurvivalPrebitephaseShortCdActions
{
    unless SpellCharges(mongoose_bite) < 3 and Spell(flanking_strike)
    {
        #spitting_cobra
        Spell(spitting_cobra)
        #dragonsfire_grenade
        Spell(dragonsfire_grenade)

        unless Enemies(tagged=1) == 1 and Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) and Spell(raptor_strike)
        {
            #steel_trap
            Spell(steel_trap)
            #a_murder_of_crows
            Spell(a_murder_of_crows)
            #explosive_trap
            Spell(explosive_trap)
        }
    }
}

AddFunction SurvivalPrebitephaseShortCdPostConditions
{
    SpellCharges(mongoose_bite) < 3 and Spell(flanking_strike) or Enemies(tagged=1) == 1 and Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) and Spell(raptor_strike) or target.Refreshable(lacerate_debuff) and Spell(lacerate) or HasEquippedItem(frizzos_fingertrap) and target.DebuffRefreshable(lacerate_debuff) and Spell(butchery) or HasEquippedItem(frizzos_fingertrap) and target.DebuffRefreshable(lacerate_debuff) and Spell(carve) or Charges(mongoose_bite) == 3 and SpellCooldown(flanking_strike) >= GCD() and Spell(mongoose_bite) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or Spell(flanking_strike) or target.DebuffRemaining(lacerate_debuff) < 14 and ArmorSetBonus(T20 2) and Spell(lacerate)
}

AddFunction SurvivalPrebitephaseCdActions
{
}

AddFunction SurvivalPrebitephaseCdPostConditions
{
    SpellCharges(mongoose_bite) < 3 and Spell(flanking_strike) or Spell(spitting_cobra) or Spell(dragonsfire_grenade) or Enemies(tagged=1) == 1 and Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) and Spell(raptor_strike) or Spell(steel_trap) or Spell(a_murder_of_crows) or Spell(explosive_trap) or target.Refreshable(lacerate_debuff) and Spell(lacerate) or HasEquippedItem(frizzos_fingertrap) and target.DebuffRefreshable(lacerate_debuff) and Spell(butchery) or HasEquippedItem(frizzos_fingertrap) and target.DebuffRefreshable(lacerate_debuff) and Spell(carve) or Charges(mongoose_bite) == 3 and SpellCooldown(flanking_strike) >= GCD() and Spell(mongoose_bite) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or Spell(flanking_strike) or target.DebuffRemaining(lacerate_debuff) < 14 and ArmorSetBonus(T20 2) and Spell(lacerate)
}

### actions.precombat

AddFunction SurvivalPrecombatMainActions
{
    #harpoon
    Spell(harpoon)
}

AddFunction SurvivalPrecombatMainPostConditions
{
}

AddFunction SurvivalPrecombatShortCdActions
{
    #flask
    #augmentation
    #food
    #summon_pet
    # SurvivalSummonPet()
    #explosive_trap
    Spell(explosive_trap)
    #steel_trap
    Spell(steel_trap)
    #dragonsfire_grenade
    Spell(dragonsfire_grenade)
}

AddFunction SurvivalPrecombatShortCdPostConditions
{
    Spell(harpoon)
}

AddFunction SurvivalPrecombatCdActions
{
    #snapshot_stats
    #potion
    # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
}

AddFunction SurvivalPrecombatCdPostConditions
{
    Spell(explosive_trap) or Spell(steel_trap) or Spell(dragonsfire_grenade) or Spell(harpoon)
}
]]

	OvaleScripts:RegisterScript("HUNTER", "survival", name, desc, code, "script")
end
