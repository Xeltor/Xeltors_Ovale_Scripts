local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_frost"
	local desc = "[Xel][7.3] Mage: Frost"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_mage_spells)

Define(frostjaw 102051)
Define(ice_block_buff 45438)

AddIcon specialization=3 help=main
{
	if InCombat() InterruptActions()
	
	if BuffExpires(ice_barrier) and IncomingDamage(5) > 0 and not mounted() and not { target.Classification(worldboss) or BuffPresent(burst_haste_buff any=1) } Spell(ice_barrier)
	
	if InCombat() and target.InRange(frostbolt) and HasFullControl()
	{
		if BuffExpires(ice_floes_buff) and not { Speed() == 0 or CanMove() > 0 } Spell(ice_floes)
		
		# Cooldowns
		if Boss()
		{
			if Speed() == 0 or CanMove() > 0 FrostDefaultCdActions()
		}
		if Speed() == 0 or CanMove() > 0 FrostDefaultShortCdActions()
		if Speed() == 0 or CanMove() > 0 FrostDefaultMainActions()
		#ice_lance,moving=1
		if Speed() > 0 Spell(ice_lance)
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
		if target.InRange(counterspell) Spell(counterspell)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_mana)
			if target.InRange(quaking_palm) Spell(quaking_palm)
		}
	}
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
    if HasEquippedItem(lady_vashjs_grasp) and BuffPresent(icy_veins_buff) and time_until_fof() > 9 or PreviousOffGCDSpell(freeze) BuffPresent(fingers_of_frost_buff)
    BuffPresent(fingers_of_frost_buff)
}

### actions.default

AddFunction FrostDefaultMainActions
{
    #variable,name=iv_start,value=time,if=prev_off_gcd.icy_veins
    #variable,name=time_until_fof,value=10-(time-variable.iv_start-floor((time-variable.iv_start)%10)*10)
    #variable,name=fof_react,value=buff.fingers_of_frost.react
    #variable,name=fof_react,value=buff.fingers_of_frost.stack,if=equipped.lady_vashjs_grasp&buff.icy_veins.up&variable.time_until_fof>9|prev_off_gcd.freeze
    #ice_lance,if=variable.fof_react=0&prev_gcd.1.flurry
    if fof_react() == 0 and PreviousGCDSpell(flurry) Spell(ice_lance)
    #call_action_list,name=movement
    # FrostMovementMainActions()

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

AddFunction FrostDefaultMainPostConditions
{
    FrostCooldownsMainPostConditions() or Enemies(tagged=1) >= 4 and FrostAoeMainPostConditions() or FrostSingleMainPostConditions()
}

AddFunction FrostDefaultShortCdActions
{
    unless fof_react() == 0 and PreviousGCDSpell(flurry) and Spell(ice_lance)
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

AddFunction FrostDefaultShortCdPostConditions
{
    fof_react() == 0 and PreviousGCDSpell(flurry) and Spell(ice_lance) or FrostCooldownsShortCdPostConditions() or Enemies(tagged=1) >= 4 and FrostAoeShortCdPostConditions() or FrostSingleShortCdPostConditions()
}

AddFunction FrostDefaultCdActions
{
    #counterspell,if=target.debuff.casting.react
    # if target.IsInterruptible() FrostInterruptActions()

    unless fof_react() == 0 and PreviousGCDSpell(flurry) and Spell(ice_lance)
    {
        #time_warp,if=buff.bloodlust.down&equipped.shard_of_the_exodar&(time=0|cooldown.icy_veins.remains<1|target.time_to_die<50)
        if BuffExpires(burst_haste_buff any=1) and HasEquippedItem(shard_of_the_exodar) and { TimeInCombat() == 0 or SpellCooldown(icy_veins) < 1 or target.TimeToDie() < 50 } and DebuffExpires(burst_haste_debuff any=1) Spell(time_warp)
        #call_action_list,name=movement
        # FrostMovementCdActions()
		
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

AddFunction FrostDefaultCdPostConditions
{
    fof_react() == 0 and PreviousGCDSpell(flurry) and Spell(ice_lance) or FrostCooldownsCdPostConditions() or Enemies(tagged=1) >= 4 and FrostAoeCdPostConditions() or FrostSingleCdPostConditions()
}

### actions.aoe

AddFunction FrostAoeMainActions
{
    #frostbolt,if=prev_off_gcd.water_jet
    if PreviousOffGCDSpell(water_elemental_water_jet) Spell(frostbolt)
    #blizzard
    Spell(blizzard)
    #ice_nova
    Spell(ice_nova)
    #flurry,if=prev_gcd.1.ebonbolt|(prev_gcd.1.glacial_spike|prev_gcd.1.frostbolt)&buff.brain_freeze.react
    if PreviousGCDSpell(ebonbolt) or { PreviousGCDSpell(glacial_spike) or PreviousGCDSpell(frostbolt) } and BuffPresent(brain_freeze_buff) Spell(flurry)
    #ice_lance,if=variable.fof_react>0
    if fof_react() > 0 Spell(ice_lance)
    #ebonbolt,if=buff.brain_freeze.react=0
    if BuffStacks(brain_freeze_buff) == 0 Spell(ebonbolt)
    #glacial_spike
    Spell(glacial_spike)
    #frostbolt
    Spell(frostbolt)
    #ice_lance
    Spell(ice_lance)
}

AddFunction FrostAoeMainPostConditions
{
}

AddFunction FrostAoeShortCdActions
{
    unless PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt)
    {
        #frozen_orb
        Spell(frozen_orb)

        unless Spell(blizzard)
        {
            #comet_storm
            Spell(comet_storm)

            unless Spell(ice_nova)
            {
                #water_jet,if=prev_gcd.1.frostbolt&buff.fingers_of_frost.stack<(2+artifact.icy_hand.enabled)&buff.brain_freeze.react=0
                if PreviousGCDSpell(frostbolt) and BuffStacks(fingers_of_frost_buff) < 2 + HasArtifactTrait(icy_hand) and BuffStacks(brain_freeze_buff) == 0 and pet.Present() Spell(water_elemental_water_jet)

                unless { PreviousGCDSpell(ebonbolt) or { PreviousGCDSpell(glacial_spike) or PreviousGCDSpell(frostbolt) } and BuffPresent(brain_freeze_buff) } and Spell(flurry)
                {
                    #frost_bomb,if=debuff.frost_bomb.remains<action.ice_lance.travel_time&variable.fof_react>0
                    if target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and fof_react() > 0 Spell(frost_bomb)
                }
            }
        }
    }
}

AddFunction FrostAoeShortCdPostConditions
{
    PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or Spell(blizzard) or Spell(ice_nova) or { PreviousGCDSpell(ebonbolt) or { PreviousGCDSpell(glacial_spike) or PreviousGCDSpell(frostbolt) } and BuffPresent(brain_freeze_buff) } and Spell(flurry) or fof_react() > 0 and Spell(ice_lance) or BuffStacks(brain_freeze_buff) == 0 and Spell(ebonbolt) or Spell(glacial_spike) or Spell(frostbolt) or Spell(ice_lance)
}

AddFunction FrostAoeCdActions
{
}

AddFunction FrostAoeCdPostConditions
{
    PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or Spell(frozen_orb) or Spell(blizzard) or Spell(comet_storm) or Spell(ice_nova) or { PreviousGCDSpell(ebonbolt) or { PreviousGCDSpell(glacial_spike) or PreviousGCDSpell(frostbolt) } and BuffPresent(brain_freeze_buff) } and Spell(flurry) or target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and fof_react() > 0 and Spell(frost_bomb) or fof_react() > 0 and Spell(ice_lance) or BuffStacks(brain_freeze_buff) == 0 and Spell(ebonbolt) or Spell(glacial_spike) or Spell(frostbolt) or Spell(ice_lance)
}

### actions.cooldowns

AddFunction FrostCooldownsMainActions
{
}

AddFunction FrostCooldownsMainPostConditions
{
}

AddFunction FrostCooldownsShortCdActions
{
    #rune_of_power,if=cooldown.icy_veins.remains<cast_time|charges_fractional>1.9&cooldown.icy_veins.remains>10|buff.icy_veins.up|target.time_to_die.remains+5<charges_fractional*10
    if SpellCooldown(icy_veins) < CastTime(rune_of_power) or Charges(rune_of_power count=0) > 1.9 and SpellCooldown(icy_veins) > 10 or BuffPresent(icy_veins_buff) or target.TimeToDie() + 5 < Charges(rune_of_power count=0) * 10 Spell(rune_of_power)
}

AddFunction FrostCooldownsShortCdPostConditions
{
}

AddFunction FrostCooldownsCdActions
{
    unless { SpellCooldown(icy_veins) < CastTime(rune_of_power) or Charges(rune_of_power count=0) > 1.9 and SpellCooldown(icy_veins) > 10 or BuffPresent(icy_veins_buff) or target.TimeToDie() + 5 < Charges(rune_of_power count=0) * 10 } and Spell(rune_of_power)
    {
        #potion,if=cooldown.icy_veins.remains<1
        # if SpellCooldown(icy_veins) < 1 and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
        #icy_veins,if=buff.icy_veins.down
        if BuffExpires(icy_veins_buff) Spell(icy_veins)
        #mirror_image
        Spell(mirror_image)
        #use_items
        # FrostUseItemActions()
        #blood_fury
        Spell(blood_fury_sp)
        #berserking
        Spell(berserking)
        #arcane_torrent
        Spell(arcane_torrent_mana)
    }
}

AddFunction FrostCooldownsCdPostConditions
{
    { SpellCooldown(icy_veins) < CastTime(rune_of_power) or Charges(rune_of_power count=0) > 1.9 and SpellCooldown(icy_veins) > 10 or BuffPresent(icy_veins_buff) or target.TimeToDie() + 5 < Charges(rune_of_power count=0) * 10 } and Spell(rune_of_power)
}

### actions.movement

AddFunction FrostMovementMainActions
{
}

AddFunction FrostMovementMainPostConditions
{
}

AddFunction FrostMovementShortCdActions
{
    #blink,if=movement.distance>10
    # if target.Distance() > 10 Spell(blink)
    #ice_floes,if=buff.ice_floes.down&movement.distance>0&variable.fof_react=0
    # if BuffExpires(ice_floes_buff) and target.Distance() > 0 and fof_react() == 0 Spell(ice_floes)
}

AddFunction FrostMovementShortCdPostConditions
{
}

AddFunction FrostMovementCdActions
{
}

AddFunction FrostMovementCdPostConditions
{
    # target.Distance() > 10 and Spell(blink) or BuffExpires(ice_floes_buff) and target.Distance() > 0 and fof_react() == 0 and Spell(ice_floes)
}

### actions.precombat

AddFunction FrostPrecombatMainActions
{
    #frostbolt
    Spell(frostbolt)
}

AddFunction FrostPrecombatMainPostConditions
{
}

AddFunction FrostPrecombatShortCdActions
{
    #flask
    #food
    #augmentation
    #water_elemental
    if not pet.Present() Spell(water_elemental)
}

AddFunction FrostPrecombatShortCdPostConditions
{
    Spell(frostbolt)
}

AddFunction FrostPrecombatCdActions
{
    unless not pet.Present() and Spell(water_elemental)
    {
        #snapshot_stats
        #mirror_image
        Spell(mirror_image)
        #potion
        # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
    }
}

AddFunction FrostPrecombatCdPostConditions
{
    not pet.Present() and Spell(water_elemental) or Spell(frostbolt)
}

### actions.single

AddFunction FrostSingleMainActions
{
    #ice_nova,if=debuff.winters_chill.up
    if target.DebuffPresent(winters_chill_debuff) Spell(ice_nova)
    #frostbolt,if=prev_off_gcd.water_jet
    if PreviousOffGCDSpell(water_elemental_water_jet) Spell(frostbolt)
    #ray_of_frost,if=buff.icy_veins.up|(cooldown.icy_veins.remains>action.ray_of_frost.cooldown&buff.rune_of_power.down)
    if BuffPresent(icy_veins_buff) or SpellCooldown(icy_veins) > SpellCooldown(ray_of_frost) and BuffExpires(rune_of_power_buff) Spell(ray_of_frost)
    #flurry,if=prev_gcd.1.ebonbolt|buff.brain_freeze.react&(!talent.glacial_spike.enabled&prev_gcd.1.frostbolt|talent.glacial_spike.enabled&(prev_gcd.1.glacial_spike|prev_gcd.1.frostbolt&(buff.icicles.stack<=3|cooldown.frozen_orb.remains<=10&set_bonus.tier20_2pc)))
    if PreviousGCDSpell(ebonbolt) or BuffPresent(brain_freeze_buff) and { not Talent(glacial_spike_talent) and PreviousGCDSpell(frostbolt) or Talent(glacial_spike_talent) and { PreviousGCDSpell(glacial_spike) or PreviousGCDSpell(frostbolt) and { BuffStacks(icicles_buff) <= 3 or SpellCooldown(frozen_orb) <= 10 and ArmorSetBonus(T20 2) } } } Spell(flurry)
    #blizzard,if=cast_time=0&active_enemies>1&variable.fof_react<3
    if CastTime(blizzard) == 0 and Enemies(tagged=1) > 1 and fof_react() < 3 Spell(blizzard)
    #ice_lance,if=variable.fof_react>0&cooldown.icy_veins.remains>10|variable.fof_react>2
    if fof_react() > 0 and SpellCooldown(icy_veins) > 10 or fof_react() > 2 Spell(ice_lance)
    #ebonbolt,if=buff.brain_freeze.react=0
    if BuffStacks(brain_freeze_buff) == 0 Spell(ebonbolt)
    #ice_nova
    Spell(ice_nova)
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
    unless target.DebuffPresent(winters_chill_debuff) and Spell(ice_nova)
    {
        #frozen_orb,if=set_bonus.tier20_2pc
        if ArmorSetBonus(T20 2) Spell(frozen_orb)

        unless PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt)
        {
            #water_jet,if=prev_gcd.1.frostbolt&buff.fingers_of_frost.stack<(2+artifact.icy_hand.enabled)&buff.brain_freeze.react=0
            if PreviousGCDSpell(frostbolt) and BuffStacks(fingers_of_frost_buff) < 2 + HasArtifactTrait(icy_hand) and BuffStacks(brain_freeze_buff) == 0 and pet.Present() Spell(water_elemental_water_jet)

            unless { BuffPresent(icy_veins_buff) or SpellCooldown(icy_veins) > SpellCooldown(ray_of_frost) and BuffExpires(rune_of_power_buff) } and Spell(ray_of_frost) or { PreviousGCDSpell(ebonbolt) or BuffPresent(brain_freeze_buff) and { not Talent(glacial_spike_talent) and PreviousGCDSpell(frostbolt) or Talent(glacial_spike_talent) and { PreviousGCDSpell(glacial_spike) or PreviousGCDSpell(frostbolt) and { BuffStacks(icicles_buff) <= 3 or SpellCooldown(frozen_orb) <= 10 and ArmorSetBonus(T20 2) } } } } and Spell(flurry) or CastTime(blizzard) == 0 and Enemies(tagged=1) > 1 and fof_react() < 3 and Spell(blizzard)
            {
                #frost_bomb,if=debuff.frost_bomb.remains<action.ice_lance.travel_time&variable.fof_react>0
                if target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and fof_react() > 0 Spell(frost_bomb)

                unless { fof_react() > 0 and SpellCooldown(icy_veins) > 10 or fof_react() > 2 } and Spell(ice_lance) or BuffStacks(brain_freeze_buff) == 0 and Spell(ebonbolt)
                {
                    #frozen_orb
                    Spell(frozen_orb)

                    unless Spell(ice_nova)
                    {
                        #comet_storm
                        Spell(comet_storm)
                    }
                }
            }
        }
    }
}

AddFunction FrostSingleShortCdPostConditions
{
    target.DebuffPresent(winters_chill_debuff) and Spell(ice_nova) or PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or { BuffPresent(icy_veins_buff) or SpellCooldown(icy_veins) > SpellCooldown(ray_of_frost) and BuffExpires(rune_of_power_buff) } and Spell(ray_of_frost) or { PreviousGCDSpell(ebonbolt) or BuffPresent(brain_freeze_buff) and { not Talent(glacial_spike_talent) and PreviousGCDSpell(frostbolt) or Talent(glacial_spike_talent) and { PreviousGCDSpell(glacial_spike) or PreviousGCDSpell(frostbolt) and { BuffStacks(icicles_buff) <= 3 or SpellCooldown(frozen_orb) <= 10 and ArmorSetBonus(T20 2) } } } } and Spell(flurry) or CastTime(blizzard) == 0 and Enemies(tagged=1) > 1 and fof_react() < 3 and Spell(blizzard) or { fof_react() > 0 and SpellCooldown(icy_veins) > 10 or fof_react() > 2 } and Spell(ice_lance) or BuffStacks(brain_freeze_buff) == 0 and Spell(ebonbolt) or Spell(ice_nova) or { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 1 and not { Talent(glacial_spike_talent) and Talent(splitting_ice_talent) } or BuffStacks(zannesu_journey_buff) == 5 and BuffRemaining(zannesu_journey_buff) > CastTime(blizzard) } and Spell(blizzard) or BuffRemaining(frozen_mass_buff) > ExecuteTime(frostbolt) + ExecuteTime(glacial_spike) + TravelTime(glacial_spike) and BuffStacks(brain_freeze_buff) == 0 and Talent(glacial_spike_talent) and Spell(frostbolt) or { SpellCooldown(frozen_orb) > 10 or not ArmorSetBonus(T20 2) } and Spell(glacial_spike) or Spell(frostbolt) or CastTime(blizzard) == 0 and Spell(blizzard) or Spell(ice_lance)
}

AddFunction FrostSingleCdActions
{
}

AddFunction FrostSingleCdPostConditions
{
    target.DebuffPresent(winters_chill_debuff) and Spell(ice_nova) or ArmorSetBonus(T20 2) and Spell(frozen_orb) or PreviousOffGCDSpell(water_elemental_water_jet) and Spell(frostbolt) or { BuffPresent(icy_veins_buff) or SpellCooldown(icy_veins) > SpellCooldown(ray_of_frost) and BuffExpires(rune_of_power_buff) } and Spell(ray_of_frost) or { PreviousGCDSpell(ebonbolt) or BuffPresent(brain_freeze_buff) and { not Talent(glacial_spike_talent) and PreviousGCDSpell(frostbolt) or Talent(glacial_spike_talent) and { PreviousGCDSpell(glacial_spike) or PreviousGCDSpell(frostbolt) and { BuffStacks(icicles_buff) <= 3 or SpellCooldown(frozen_orb) <= 10 and ArmorSetBonus(T20 2) } } } } and Spell(flurry) or CastTime(blizzard) == 0 and Enemies(tagged=1) > 1 and fof_react() < 3 and Spell(blizzard) or target.DebuffRemaining(frost_bomb_debuff) < TravelTime(ice_lance) and fof_react() > 0 and Spell(frost_bomb) or { fof_react() > 0 and SpellCooldown(icy_veins) > 10 or fof_react() > 2 } and Spell(ice_lance) or BuffStacks(brain_freeze_buff) == 0 and Spell(ebonbolt) or Spell(frozen_orb) or Spell(ice_nova) or Spell(comet_storm) or { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 1 and not { Talent(glacial_spike_talent) and Talent(splitting_ice_talent) } or BuffStacks(zannesu_journey_buff) == 5 and BuffRemaining(zannesu_journey_buff) > CastTime(blizzard) } and Spell(blizzard) or BuffRemaining(frozen_mass_buff) > ExecuteTime(frostbolt) + ExecuteTime(glacial_spike) + TravelTime(glacial_spike) and BuffStacks(brain_freeze_buff) == 0 and Talent(glacial_spike_talent) and Spell(frostbolt) or { SpellCooldown(frozen_orb) > 10 or not ArmorSetBonus(T20 2) } and Spell(glacial_spike) or Spell(frostbolt) or CastTime(blizzard) == 0 and Spell(blizzard) or Spell(ice_lance)
}
]]

	OvaleScripts:RegisterScript("MAGE", "frost", name, desc, code, "script")
end
