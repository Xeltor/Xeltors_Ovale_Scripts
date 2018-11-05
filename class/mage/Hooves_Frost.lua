local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "hooves_frost"
	local desc = "[Hooves][7.2.5] Mage: Frost"
	local code = [[


Include(ovale_common)
Include(ovale_interrupt)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_mage_spells)

Define(ice_block 45438)
	SpellInfo(ice_block cd=300)
	SpellAddBuff(ice_block ice_block_buff=1)
	SpellAddDebuff(ice_block hypothermia_debuff=1)
Define(ice_block_buff 45438)
	SpellInfo(ice_block_buff duration=10)
Define(hypothermia_debuff 41425)
	SpellInfo(hypothermia_debuff duration=30)

	
	# Based on SimulationCraft profile "Mage_Frost_T20M".
#    class=mage
#    spec=frost
#    talents=2032021

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_mage_spells)


AddIcon specialization=3 help=main
{
	if InCombat() and target.Casting(interrupt) InterruptActions()
	
	#cold_snap,if=health.pct<30
	if HealthPercent() < 30 and not DebuffPresent(hypothermia_debuff) and not BuffPresent(ice_block_buff) and InCombat() Spell(ice_block)
	if BuffExpires(ice_barrier) and InCombat() and target.istargetingplayer() Spell(ice_barrier)
	
	if InCombat() and target.InRange(frostbolt) and HasFullControl()
	{
		if BuffExpires(ice_floes_buff) and not NotMoving() Spell(ice_floes)
		
		# Cooldowns
		if Boss()
		{
			if NotMoving() FrostDefaultCdActions()
		}
		
		if NotMoving() FrostDefaultShortCdActions()
		if NotMoving() FrostDefaultMainActions()

	}
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(counterspell) Spell(counterspell)
		if not target.Classification(worldboss)
		{
			if target.InRange(quaking_palm) Spell(quaking_palm)
		}
	}
}

AddFunction NotMoving
{
	{Speed() ==0 or BuffPresent(ice_floes_buff)}
}


AddFunction time_until_fof
{
    10 - { TimeInCombat() - iv_start() - { TimeInCombat() - iv_start() } / 10 * 10 }
}

AddFunction iv_start
{
    if PreviousOffGCDSpell(icy_veins) TimeInCombat()
}

AddFunction fof_react
{
    if HasEquippedItem(lady_vashjs_grasp) and BuffPresent(icy_veins_buff) and time_until_fof() > 9 BuffPresent(fingers_of_frost_buff)
    BuffPresent(fingers_of_frost_buff)
}

AddCheckBox(opt_interrupt L(interrupt) default specialization=frost)
AddCheckBox(opt_use_consumables L(opt_use_consumables) default specialization=frost)
AddCheckBox(opt_time_warp SpellName(time_warp) specialization=frost)

AddFunction FrostInterruptActions
{
    if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.Casting()
    {
        if target.InRange(counterspell) and target.IsInterruptible() Spell(counterspell)
        if target.Distance(less 8) and target.IsInterruptible() Spell(arcane_torrent_mana)
        if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
    }
}

AddFunction FrostUseItemActions
{
    Item(Trinket0Slot text=13 usable=1)
    Item(Trinket1Slot text=14 usable=1)
}

### actions.default

AddFunction FrostDefaultMainActions
{
    #call_action_list,name=variables
    FrostVariablesMainActions()

    unless FrostVariablesMainPostConditions()
    {
        #ice_lance,if=variable.fof_react=0&prev_gcd.1.flurry
        if fof_react() == 0 and PreviousGCDSpell(flurry) Spell(ice_lance)
        #time_warp,if=buff.bloodlust.down&(buff.exhaustion.down|equipped.shard_of_the_exodar)&(time=0|cooldown.icy_veins.remains<1|target.time_to_die<50)
        if BuffExpires(burst_haste_buff any=1) and { BuffExpires(exhaustion_buff) or HasEquippedItem(shard_of_the_exodar) } and { TimeInCombat() == 0 or SpellCooldown(icy_veins) < 1 or target.TimeToDie() < 50 } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) Spell(time_warp)
        #call_action_list,name=movement
        FrostMovementMainActions()

        unless FrostMovementMainPostConditions()
        {
            #call_action_list,name=cooldowns
            FrostCooldownsMainActions()

            unless FrostCooldownsMainPostConditions()
            {
                #call_action_list,name=aoe,if=active_enemies>=4
                if Enemies(tagged=1) >= 4 FrostAoeMainActions()

                unless Enemies(tagged=1) >= 4 and FrostAoeMainPostConditions()
                {
                    #call_action_list,name=single
                    FrostSingleMainActions()
                }
            }
        }
    }
}

AddFunction FrostDefaultMainPostConditions
{
    FrostVariablesMainPostConditions() or FrostMovementMainPostConditions() or FrostCooldownsMainPostConditions() or Enemies(tagged=1) >= 4 and FrostAoeMainPostConditions() or FrostSingleMainPostConditions()
}

AddFunction FrostDefaultShortCdActions
{
    #call_action_list,name=variables
    FrostVariablesShortCdActions()

    unless FrostVariablesShortCdPostConditions() or fof_react() == 0 and PreviousGCDSpell(flurry) and Spell(ice_lance) or BuffExpires(burst_haste_buff any=1) and { BuffExpires(exhaustion_buff) or HasEquippedItem(shard_of_the_exodar) } and { TimeInCombat() == 0 or SpellCooldown(icy_veins) < 1 or target.TimeToDie() < 50 } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) and Spell(time_warp)
    {
        #call_action_list,name=movement
        FrostMovementShortCdActions()

        unless FrostMovementShortCdPostConditions()
        {
            #call_action_list,name=cooldowns
            FrostCooldownsShortCdActions()

            unless FrostCooldownsShortCdPostConditions()
            {
                #call_action_list,name=aoe,if=active_enemies>=4
                if Enemies(tagged=1) >= 4 FrostAoeShortCdActions()

                unless Enemies(tagged=1) >= 4 and FrostAoeShortCdPostConditions()
                {
                    #call_action_list,name=single
                    FrostSingleShortCdActions()
                }
            }
        }
    }
}

AddFunction FrostDefaultShortCdPostConditions
{
    FrostVariablesShortCdPostConditions() or fof_react() == 0 and PreviousGCDSpell(flurry) and Spell(ice_lance) or BuffExpires(burst_haste_buff any=1) and { BuffExpires(exhaustion_buff) or HasEquippedItem(shard_of_the_exodar) } and { TimeInCombat() == 0 or SpellCooldown(icy_veins) < 1 or target.TimeToDie() < 50 } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) and Spell(time_warp) or FrostMovementShortCdPostConditions() or FrostCooldownsShortCdPostConditions() or Enemies(tagged=1) >= 4 and FrostAoeShortCdPostConditions() or FrostSingleShortCdPostConditions()
}

AddFunction FrostDefaultCdActions
{
    #call_action_list,name=variables
    FrostVariablesCdActions()

    unless FrostVariablesCdPostConditions()
    {
        #counterspell,if=target.debuff.casting.react
        if target.IsInterruptible() FrostInterruptActions()

        unless fof_react() == 0 and PreviousGCDSpell(flurry) and Spell(ice_lance) or BuffExpires(burst_haste_buff any=1) and { BuffExpires(exhaustion_buff) or HasEquippedItem(shard_of_the_exodar) } and { TimeInCombat() == 0 or SpellCooldown(icy_veins) < 1 or target.TimeToDie() < 50 } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) and Spell(time_warp)
        {
            #call_action_list,name=movement
            FrostMovementCdActions()

            unless FrostMovementCdPostConditions()
            {
                #call_action_list,name=cooldowns
                FrostCooldownsCdActions()

                unless FrostCooldownsCdPostConditions()
                {
                    #call_action_list,name=aoe,if=active_enemies>=4
                    if Enemies(tagged=1) >= 4 FrostAoeCdActions()

                    unless Enemies(tagged=1) >= 4 and FrostAoeCdPostConditions()
                    {
                        #call_action_list,name=single
                        FrostSingleCdActions()
                    }
                }
            }
        }
    }
}

AddFunction FrostDefaultCdPostConditions
{
    FrostVariablesCdPostConditions() or fof_react() == 0 and PreviousGCDSpell(flurry) and Spell(ice_lance) or BuffExpires(burst_haste_buff any=1) and { BuffExpires(exhaustion_buff) or HasEquippedItem(shard_of_the_exodar) } and { TimeInCombat() == 0 or SpellCooldown(icy_veins) < 1 or target.TimeToDie() < 50 } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) and Spell(time_warp) or FrostMovementCdPostConditions() or FrostCooldownsCdPostConditions() or Enemies(tagged=1) >= 4 and FrostAoeCdPostConditions() or FrostSingleCdPostConditions()
}

### actions.aoe

AddFunction FrostAoeMainActions
{
    #frostbolt,if=prev_off_gcd.water_jet
    if PreviousOffGCDSpell(water_elemental_water_jet) Spell(frostbolt)
    #frozen_orb
    Spell(frozen_orb)
    #blizzard
    Spell(blizzard)
    #comet_storm
    Spell(comet_storm)
    #ice_nova
    Spell(ice_nova)
    #water_jet,if=prev_gcd.1.frostbolt&buff.fingers_of_frost.stack<(2+artifact.icy_hand.enabled)&buff.brain_freeze.react=0
    if PreviousGCDSpell(frostbolt) and BuffStacks(fingers_of_frost_buff) < 2 + HasArtifactTrait(icy_hand) and BuffStacks(brain_freeze_buff) == 0 Spell(water_elemental_water_jet)
    #flurry,if=prev_gcd.1.ebonbolt|(prev_gcd.1.glacial_spike|prev_gcd.1.frostbolt)&buff.brain_freeze.react
    if PreviousGCDSpell(ebonbolt) or { PreviousGCDSpell(glacial_spike) or PreviousGCDSpell(frostbolt) } and BuffPresent(brain_freeze_buff) Spell(flurry)
    #frost_bomb,if=debuff.frost_bomb.remains<action.ice_lance.travel_time&variable.fof_react>0
    if target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and fof_react() > 0 Spell(frost_bomb)
    #ice_lance,if=variable.fof_react>0
    if fof_react() > 0 Spell(ice_lance)
    #ebonbolt
    Spell(ebonbolt)
    #glacial_spike
    Spell(glacial_spike)
    #frostbolt
    Spell(frostbolt)
    #cone_of_cold
    Spell(cone_of_cold)
    #ice_lance
    Spell(ice_lance)
}

AddFunction FrostAoeMainPostConditions
{
}

AddFunction FrostAoeShortCdActions
{
}

AddFunction FrostAoeShortCdPostConditions
{
    PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or Spell(frozen_orb) or Spell(blizzard) or Spell(comet_storm) or Spell(ice_nova) or PreviousGCDSpell(frostbolt) and BuffStacks(fingers_of_frost_buff) < 2 + HasArtifactTrait(icy_hand) and BuffStacks(brain_freeze_buff) == 0 and Spell(water_elemental_water_jet) or { PreviousGCDSpell(ebonbolt) or { PreviousGCDSpell(glacial_spike) or PreviousGCDSpell(frostbolt) } and BuffPresent(brain_freeze_buff) } and Spell(flurry) or target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and fof_react() > 0 and Spell(frost_bomb) or fof_react() > 0 and Spell(ice_lance) or Spell(ebonbolt) or Spell(glacial_spike) or Spell(frostbolt) or Spell(cone_of_cold) or Spell(ice_lance)
}

AddFunction FrostAoeCdActions
{
}

AddFunction FrostAoeCdPostConditions
{
    PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or Spell(frozen_orb) or Spell(blizzard) or Spell(comet_storm) or Spell(ice_nova) or PreviousGCDSpell(frostbolt) and BuffStacks(fingers_of_frost_buff) < 2 + HasArtifactTrait(icy_hand) and BuffStacks(brain_freeze_buff) == 0 and Spell(water_elemental_water_jet) or { PreviousGCDSpell(ebonbolt) or { PreviousGCDSpell(glacial_spike) or PreviousGCDSpell(frostbolt) } and BuffPresent(brain_freeze_buff) } and Spell(flurry) or target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and fof_react() > 0 and Spell(frost_bomb) or fof_react() > 0 and Spell(ice_lance) or Spell(ebonbolt) or Spell(glacial_spike) or Spell(frostbolt) or Spell(cone_of_cold) or Spell(ice_lance)
}

### actions.cooldowns

AddFunction FrostCooldownsMainActions
{
    #rune_of_power,if=cooldown.icy_veins.remains<cast_time|charges_fractional>1.9&cooldown.icy_veins.remains>10|buff.icy_veins.up|target.time_to_die.remains+5<charges_fractional*10
    if SpellCooldown(icy_veins) < CastTime(rune_of_power) or Charges(rune_of_power count=0) > 1.9 and SpellCooldown(icy_veins) > 10 or BuffPresent(icy_veins_buff) or target.TimeToDie() + 5 < Charges(rune_of_power count=0) * 10 Spell(rune_of_power)
    #potion,if=cooldown.icy_veins.remains<1
    if SpellCooldown(icy_veins) < 1 and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
    #icy_veins,if=buff.icy_veins.down
    if BuffExpires(icy_veins_buff) Spell(icy_veins)
    #mirror_image
    Spell(mirror_image)
    #blood_fury
    Spell(blood_fury_sp)
    #berserking
    Spell(berserking)
    #arcane_torrent
    Spell(arcane_torrent_mana)
}

AddFunction FrostCooldownsMainPostConditions
{
}

AddFunction FrostCooldownsShortCdActions
{
}

AddFunction FrostCooldownsShortCdPostConditions
{
    { SpellCooldown(icy_veins) < CastTime(rune_of_power) or Charges(rune_of_power count=0) > 1.9 and SpellCooldown(icy_veins) > 10 or BuffPresent(icy_veins_buff) or target.TimeToDie() + 5 < Charges(rune_of_power count=0) * 10 } and Spell(rune_of_power) or SpellCooldown(icy_veins) < 1 and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(prolonged_power_potion usable=1) or BuffExpires(icy_veins_buff) and Spell(icy_veins) or Spell(mirror_image) or Spell(blood_fury_sp) or Spell(berserking) or Spell(arcane_torrent_mana)
}

AddFunction FrostCooldownsCdActions
{
    unless { SpellCooldown(icy_veins) < CastTime(rune_of_power) or Charges(rune_of_power count=0) > 1.9 and SpellCooldown(icy_veins) > 10 or BuffPresent(icy_veins_buff) or target.TimeToDie() + 5 < Charges(rune_of_power count=0) * 10 } and Spell(rune_of_power) or SpellCooldown(icy_veins) < 1 and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(prolonged_power_potion usable=1) or BuffExpires(icy_veins_buff) and Spell(icy_veins) or Spell(mirror_image)
    {
        #use_items
        FrostUseItemActions()
    }
}

AddFunction FrostCooldownsCdPostConditions
{
    { SpellCooldown(icy_veins) < CastTime(rune_of_power) or Charges(rune_of_power count=0) > 1.9 and SpellCooldown(icy_veins) > 10 or BuffPresent(icy_veins_buff) or target.TimeToDie() + 5 < Charges(rune_of_power count=0) * 10 } and Spell(rune_of_power) or SpellCooldown(icy_veins) < 1 and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(prolonged_power_potion usable=1) or BuffExpires(icy_veins_buff) and Spell(icy_veins) or Spell(mirror_image) or Spell(blood_fury_sp) or Spell(berserking) or Spell(arcane_torrent_mana)
}

### actions.movement

AddFunction FrostMovementMainActions
{
    #blink,if=movement.distance>10
    if target.Distance() > 10 Spell(blink)
    #ice_floes,if=buff.ice_floes.down&movement.distance>0&variable.fof_react=0
    if BuffExpires(ice_floes_buff) and target.Distance() > 0 and fof_react() == 0 Spell(ice_floes)
}

AddFunction FrostMovementMainPostConditions
{
}

AddFunction FrostMovementShortCdActions
{
}

AddFunction FrostMovementShortCdPostConditions
{
    target.Distance() > 10 and Spell(blink) or BuffExpires(ice_floes_buff) and target.Distance() > 0 and fof_react() == 0 and Spell(ice_floes)
}

AddFunction FrostMovementCdActions
{
}

AddFunction FrostMovementCdPostConditions
{
    target.Distance() > 10 and Spell(blink) or BuffExpires(ice_floes_buff) and target.Distance() > 0 and fof_react() == 0 and Spell(ice_floes)
}

### actions.precombat

AddFunction FrostPrecombatMainActions
{
    #flask
    #food
    #augmentation
    #water_elemental
    if not pet.Present() Spell(water_elemental)
    #snapshot_stats
    #mirror_image
    Spell(mirror_image)
    #potion
    if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
    #frostbolt
    Spell(frostbolt)
}

AddFunction FrostPrecombatMainPostConditions
{
}

AddFunction FrostPrecombatShortCdActions
{
}

AddFunction FrostPrecombatShortCdPostConditions
{
    not pet.Present() and Spell(water_elemental) or Spell(mirror_image) or CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(prolonged_power_potion usable=1) or Spell(frostbolt)
}

AddFunction FrostPrecombatCdActions
{
}

AddFunction FrostPrecombatCdPostConditions
{
    not pet.Present() and Spell(water_elemental) or Spell(mirror_image) or CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(prolonged_power_potion usable=1) or Spell(frostbolt)
}

### actions.single

AddFunction FrostSingleMainActions
{
    #ice_nova,if=debuff.winters_chill.up
    if target.DebuffPresent(winters_chill_debuff) Spell(ice_nova)
    #frozen_orb,if=set_bonus.tier20_2pc
    if ArmorSetBonus(T20 2) Spell(frozen_orb)
    #frostbolt,if=prev_off_gcd.water_jet
    if PreviousOffGCDSpell(water_elemental_water_jet) Spell(frostbolt)
    #water_jet,if=prev_gcd.1.frostbolt&buff.fingers_of_frost.stack<(2+artifact.icy_hand.enabled)&buff.brain_freeze.react=0
    if PreviousGCDSpell(frostbolt) and BuffStacks(fingers_of_frost_buff) < 2 + HasArtifactTrait(icy_hand) and BuffStacks(brain_freeze_buff) == 0 Spell(water_elemental_water_jet)
    #ray_of_frost,if=buff.icy_veins.up|(cooldown.icy_veins.remains>action.ray_of_frost.cooldown&buff.rune_of_power.down)
    if BuffPresent(icy_veins_buff) or SpellCooldown(icy_veins) > SpellCooldown(ray_of_frost) and BuffExpires(rune_of_power_buff) Spell(ray_of_frost)
    #flurry,if=prev_gcd.1.ebonbolt|buff.brain_freeze.react&(!talent.glacial_spike.enabled&prev_gcd.1.frostbolt|talent.glacial_spike.enabled&(prev_gcd.1.glacial_spike|prev_gcd.1.frostbolt&(buff.icicles.stack<=3|cooldown.frozen_orb.remains<=10&set_bonus.tier20_2pc)))
    if PreviousGCDSpell(ebonbolt) or BuffPresent(brain_freeze_buff) and { not Talent(glacial_spike_talent) and PreviousGCDSpell(frostbolt) or Talent(glacial_spike_talent) and { PreviousGCDSpell(glacial_spike) or PreviousGCDSpell(frostbolt) and { BuffStacks(icicles_buff) <= 3 or SpellCooldown(frozen_orb) <= 10 and ArmorSetBonus(T20 2) } } } Spell(flurry)
    #blizzard,if=cast_time=0&active_enemies>1&variable.fof_react<3
    if CastTime(blizzard) == 0 and Enemies(tagged=1) > 1 and fof_react() < 3 Spell(blizzard)
    #frost_bomb,if=debuff.frost_bomb.remains<action.ice_lance.travel_time&variable.fof_react>0
    if target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and fof_react() > 0 Spell(frost_bomb)
    #ice_lance,if=variable.fof_react>0&cooldown.icy_veins.remains>10|variable.fof_react>2
    if fof_react() > 0 and SpellCooldown(icy_veins) > 10 or fof_react() > 2 Spell(ice_lance)
    #ebonbolt
    Spell(ebonbolt)
    #frozen_orb
    Spell(frozen_orb)
    #ice_nova
    Spell(ice_nova)
    #comet_storm
    Spell(comet_storm)
    #blizzard,if=active_enemies>2|active_enemies>1&!(talent.glacial_spike.enabled&talent.splitting_ice.enabled)|(buff.zannesu_journey.stack=5&buff.zannesu_journey.remains>cast_time)
    if Enemies(tagged=1) > 2 or Enemies(tagged=1) > 1 and not { Talent(glacial_spike_talent) and Talent(splitting_ice_talent) } or BuffStacks(zannesu_journey_buff) == 5 and BuffRemaining(zannesu_journey_buff) > CastTime(blizzard) Spell(blizzard)
    #frostbolt,if=buff.frozen_mass.remains>execute_time+action.glacial_spike.execute_time+action.glacial_spike.travel_time&buff.brain_freeze.react=0&talent.glacial_spike.enabled
    if BuffRemaining(frozen_mass_buff) > ExecuteTime(frostbolt) + ExecuteTime(glacial_spike) + TravelTime(glacial_spike) and BuffStacks(brain_freeze_buff) == 0 and Talent(glacial_spike_talent) Spell(frostbolt)
    #glacial_spike,if=cooldown.frozen_orb.remains>10|!set_bonus.tier20_2pc
    if SpellCooldown(frozen_orb) > 10 or not ArmorSetBonus(T20 2) Spell(glacial_spike)
    #frostbolt
    Spell(frostbolt)
    #blizzard,if=cast_time=0
    if CastTime(blizzard) == 0 Spell(blizzard)
    #ice_lance
    Spell(ice_lance)
}

AddFunction FrostSingleMainPostConditions
{
}

AddFunction FrostSingleShortCdActions
{
}

AddFunction FrostSingleShortCdPostConditions
{
    target.DebuffPresent(winters_chill_debuff) and Spell(ice_nova) or ArmorSetBonus(T20 2) and Spell(frozen_orb) or PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or PreviousGCDSpell(frostbolt) and BuffStacks(fingers_of_frost_buff) < 2 + HasArtifactTrait(icy_hand) and BuffStacks(brain_freeze_buff) == 0 and Spell(water_elemental_water_jet) or { BuffPresent(icy_veins_buff) or SpellCooldown(icy_veins) > SpellCooldown(ray_of_frost) and BuffExpires(rune_of_power_buff) } and Spell(ray_of_frost) or { PreviousGCDSpell(ebonbolt) or BuffPresent(brain_freeze_buff) and { not Talent(glacial_spike_talent) and PreviousGCDSpell(frostbolt) or Talent(glacial_spike_talent) and { PreviousGCDSpell(glacial_spike) or PreviousGCDSpell(frostbolt) and { BuffStacks(icicles_buff) <= 3 or SpellCooldown(frozen_orb) <= 10 and ArmorSetBonus(T20 2) } } } } and Spell(flurry) or CastTime(blizzard) == 0 and Enemies(tagged=1) > 1 and fof_react() < 3 and Spell(blizzard) or target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and fof_react() > 0 and Spell(frost_bomb) or { fof_react() > 0 and SpellCooldown(icy_veins) > 10 or fof_react() > 2 } and Spell(ice_lance) or Spell(ebonbolt) or Spell(frozen_orb) or Spell(ice_nova) or Spell(comet_storm) or { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 1 and not { Talent(glacial_spike_talent) and Talent(splitting_ice_talent) } or BuffStacks(zannesu_journey_buff) == 5 and BuffRemaining(zannesu_journey_buff) > CastTime(blizzard) } and Spell(blizzard) or BuffRemaining(frozen_mass_buff) > ExecuteTime(frostbolt) + ExecuteTime(glacial_spike) + TravelTime(glacial_spike) and BuffStacks(brain_freeze_buff) == 0 and Talent(glacial_spike_talent) and Spell(frostbolt) or { SpellCooldown(frozen_orb) > 10 or not ArmorSetBonus(T20 2) } and Spell(glacial_spike) or Spell(frostbolt) or CastTime(blizzard) == 0 and Spell(blizzard) or Spell(ice_lance)
}

AddFunction FrostSingleCdActions
{
}

AddFunction FrostSingleCdPostConditions
{
    target.DebuffPresent(winters_chill_debuff) and Spell(ice_nova) or ArmorSetBonus(T20 2) and Spell(frozen_orb) or PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or PreviousGCDSpell(frostbolt) and BuffStacks(fingers_of_frost_buff) < 2 + HasArtifactTrait(icy_hand) and BuffStacks(brain_freeze_buff) == 0 and Spell(water_elemental_water_jet) or { BuffPresent(icy_veins_buff) or SpellCooldown(icy_veins) > SpellCooldown(ray_of_frost) and BuffExpires(rune_of_power_buff) } and Spell(ray_of_frost) or { PreviousGCDSpell(ebonbolt) or BuffPresent(brain_freeze_buff) and { not Talent(glacial_spike_talent) and PreviousGCDSpell(frostbolt) or Talent(glacial_spike_talent) and { PreviousGCDSpell(glacial_spike) or PreviousGCDSpell(frostbolt) and { BuffStacks(icicles_buff) <= 3 or SpellCooldown(frozen_orb) <= 10 and ArmorSetBonus(T20 2) } } } } and Spell(flurry) or CastTime(blizzard) == 0 and Enemies(tagged=1) > 1 and fof_react() < 3 and Spell(blizzard) or target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and fof_react() > 0 and Spell(frost_bomb) or { fof_react() > 0 and SpellCooldown(icy_veins) > 10 or fof_react() > 2 } and Spell(ice_lance) or Spell(ebonbolt) or Spell(frozen_orb) or Spell(ice_nova) or Spell(comet_storm) or { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 1 and not { Talent(glacial_spike_talent) and Talent(splitting_ice_talent) } or BuffStacks(zannesu_journey_buff) == 5 and BuffRemaining(zannesu_journey_buff) > CastTime(blizzard) } and Spell(blizzard) or BuffRemaining(frozen_mass_buff) > ExecuteTime(frostbolt) + ExecuteTime(glacial_spike) + TravelTime(glacial_spike) and BuffStacks(brain_freeze_buff) == 0 and Talent(glacial_spike_talent) and Spell(frostbolt) or { SpellCooldown(frozen_orb) > 10 or not ArmorSetBonus(T20 2) } and Spell(glacial_spike) or Spell(frostbolt) or CastTime(blizzard) == 0 and Spell(blizzard) or Spell(ice_lance)
}

### actions.variables

AddFunction FrostVariablesMainActions
{
}

AddFunction FrostVariablesMainPostConditions
{
}

AddFunction FrostVariablesShortCdActions
{
}

AddFunction FrostVariablesShortCdPostConditions
{
}

AddFunction FrostVariablesCdActions
{
}

AddFunction FrostVariablesCdPostConditions
{
}	
]]

	OvaleScripts:RegisterScript("MAGE", "frost", name, desc, code, "script")
end
