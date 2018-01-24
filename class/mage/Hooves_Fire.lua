local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "hooves_fire"
	local desc = "[Hooves][7.1] Mage: Fire"
	local code = [[
# Based on SimulationCraft profile "Mage_Fire_T19M".
#    class=mage
#    spec=fire
#    talents=1022021

Include(ovale_common)

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

AddIcon specialization=2 help=main
{
	if InCombat() InterruptActions()
	
	#cold_snap,if=health.pct<30
	if HealthPercent() < 30 and not mounted() and not DebuffPresent(hypothermia_debuff) and not BuffPresent(ice_block_buff) and InCombat() Spell(ice_block)
	if BuffExpires(ice_barrier) and not mounted() and InCombat() and target.istargetingplayer() Spell(ice_barrier)
	
	if InCombat() and target.InRange(fireball) and HasFullControl()
	{
		if BuffExpires(ice_floes_buff) and not NotMoving() Spell(ice_floes)
		
		# Cooldowns
		if Boss()
		{
			if NotMoving() FireDefaultCdActions()
		}
		
		if NotMoving() FireDefaultShortCdActions()
		if target.Distance(less 8) and not BuffPresent(ice_barrier) and target.istargetingplayer() Spell(dragons_breath)
		if NotMoving() FireDefaultMainActions()
		
		#scorch,moving=1
		if Speed() > 0 and BuffPresent(hot_streak_buff) Spell(pyroblast)
		if Speed() > 0 Spell(scorch)
	}
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
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

# Based on SimulationCraft profile "Mage_Fire_T19P".
#    class=mage
#    spec=fire
#    talents=1022021

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_mage_spells)


AddFunction FireInterruptActions
{
    if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.IsInterruptible()
    {
        Spell(counterspell)
        if not target.Classification(worldboss)
        {
            Spell(arcane_torrent_mana)
            if target.InRange(quaking_palm) Spell(quaking_palm)
        }
    }
}

### actions.default

AddFunction FireDefaultMainActions
{
    #time_warp,if=(time=0&buff.bloodlust.down)|(buff.bloodlust.down&equipped.132410&(cooldown.combustion.remains<1|target.time_to_die.remains<50))
    if { TimeInCombat() == 0 and BuffExpires(burst_haste_buff any=1) or BuffExpires(burst_haste_buff any=1) and HasEquippedItem(132410) and { SpellCooldown(combustion) < 1 or target.TimeToDie() < 50 } } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) Spell(time_warp)
    #mirror_image,if=buff.combustion.down
    if BuffExpires(combustion_buff) Spell(mirror_image)
    #rune_of_power,if=cooldown.combustion.remains>40&buff.combustion.down&!talent.kindling.enabled|target.time_to_die.remains<11|talent.kindling.enabled&(charges_fractional>1.8|time<40)&cooldown.combustion.remains>40
    if SpellCooldown(combustion) > 40 and BuffExpires(combustion_buff) and not Talent(kindling_talent) or target.TimeToDie() < 11 or Talent(kindling_talent) and { Charges(rune_of_power count=0) > 1.8 or TimeInCombat() < 40 } and SpellCooldown(combustion) > 40 Spell(rune_of_power)
    #call_action_list,name=combustion_phase,if=cooldown.combustion.remains<=action.rune_of_power.cast_time+(!talent.kindling.enabled*gcd)|buff.combustion.up
    if SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() or BuffPresent(combustion_buff) FireCombustionPhaseMainActions()

    unless { SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() or BuffPresent(combustion_buff) } and FireCombustionPhaseMainPostConditions()
    {
        #call_action_list,name=rop_phase,if=buff.rune_of_power.up&buff.combustion.down
        if BuffPresent(rune_of_power_buff) and BuffExpires(combustion_buff) FireRopPhaseMainActions()

        unless BuffPresent(rune_of_power_buff) and BuffExpires(combustion_buff) and FireRopPhaseMainPostConditions()
        {
            #call_action_list,name=standard_rotation
            FireStandardRotationMainActions()
        }
    }
}

AddFunction FireDefaultMainPostConditions
{
    { SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() or BuffPresent(combustion_buff) } and FireCombustionPhaseMainPostConditions() or BuffPresent(rune_of_power_buff) and BuffExpires(combustion_buff) and FireRopPhaseMainPostConditions() or FireStandardRotationMainPostConditions()
}

AddFunction FireDefaultShortCdActions
{
    unless { TimeInCombat() == 0 and BuffExpires(burst_haste_buff any=1) or BuffExpires(burst_haste_buff any=1) and HasEquippedItem(132410) and { SpellCooldown(combustion) < 1 or target.TimeToDie() < 50 } } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) and Spell(time_warp) or BuffExpires(combustion_buff) and Spell(mirror_image) or { SpellCooldown(combustion) > 40 and BuffExpires(combustion_buff) and not Talent(kindling_talent) or target.TimeToDie() < 11 or Talent(kindling_talent) and { Charges(rune_of_power count=0) > 1.8 or TimeInCombat() < 40 } and SpellCooldown(combustion) > 40 } and Spell(rune_of_power)
    {
        #call_action_list,name=combustion_phase,if=cooldown.combustion.remains<=action.rune_of_power.cast_time+(!talent.kindling.enabled*gcd)|buff.combustion.up
        if SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() or BuffPresent(combustion_buff) FireCombustionPhaseShortCdActions()

        unless { SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() or BuffPresent(combustion_buff) } and FireCombustionPhaseShortCdPostConditions()
        {
            #call_action_list,name=rop_phase,if=buff.rune_of_power.up&buff.combustion.down
            if BuffPresent(rune_of_power_buff) and BuffExpires(combustion_buff) FireRopPhaseShortCdActions()

            unless BuffPresent(rune_of_power_buff) and BuffExpires(combustion_buff) and FireRopPhaseShortCdPostConditions()
            {
                #call_action_list,name=standard_rotation
                FireStandardRotationShortCdActions()
            }
        }
    }
}

AddFunction FireDefaultShortCdPostConditions
{
    { TimeInCombat() == 0 and BuffExpires(burst_haste_buff any=1) or BuffExpires(burst_haste_buff any=1) and HasEquippedItem(132410) and { SpellCooldown(combustion) < 1 or target.TimeToDie() < 50 } } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) and Spell(time_warp) or BuffExpires(combustion_buff) and Spell(mirror_image) or { SpellCooldown(combustion) > 40 and BuffExpires(combustion_buff) and not Talent(kindling_talent) or target.TimeToDie() < 11 or Talent(kindling_talent) and { Charges(rune_of_power count=0) > 1.8 or TimeInCombat() < 40 } and SpellCooldown(combustion) > 40 } and Spell(rune_of_power) or { SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() or BuffPresent(combustion_buff) } and FireCombustionPhaseShortCdPostConditions() or BuffPresent(rune_of_power_buff) and BuffExpires(combustion_buff) and FireRopPhaseShortCdPostConditions() or FireStandardRotationShortCdPostConditions()
}

AddFunction FireDefaultCdActions
{
    #counterspell,if=target.debuff.casting.react
    if target.IsInterruptible() FireInterruptActions()

    unless { TimeInCombat() == 0 and BuffExpires(burst_haste_buff any=1) or BuffExpires(burst_haste_buff any=1) and HasEquippedItem(132410) and { SpellCooldown(combustion) < 1 or target.TimeToDie() < 50 } } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) and Spell(time_warp) or BuffExpires(combustion_buff) and Spell(mirror_image) or { SpellCooldown(combustion) > 40 and BuffExpires(combustion_buff) and not Talent(kindling_talent) or target.TimeToDie() < 11 or Talent(kindling_talent) and { Charges(rune_of_power count=0) > 1.8 or TimeInCombat() < 40 } and SpellCooldown(combustion) > 40 } and Spell(rune_of_power)
    {
        #call_action_list,name=combustion_phase,if=cooldown.combustion.remains<=action.rune_of_power.cast_time+(!talent.kindling.enabled*gcd)|buff.combustion.up
        if SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() or BuffPresent(combustion_buff) FireCombustionPhaseCdActions()

        unless { SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() or BuffPresent(combustion_buff) } and FireCombustionPhaseCdPostConditions()
        {
            #call_action_list,name=rop_phase,if=buff.rune_of_power.up&buff.combustion.down
            if BuffPresent(rune_of_power_buff) and BuffExpires(combustion_buff) FireRopPhaseCdActions()

            unless BuffPresent(rune_of_power_buff) and BuffExpires(combustion_buff) and FireRopPhaseCdPostConditions()
            {
                #call_action_list,name=standard_rotation
                FireStandardRotationCdActions()
            }
        }
    }
}

AddFunction FireDefaultCdPostConditions
{
    { TimeInCombat() == 0 and BuffExpires(burst_haste_buff any=1) or BuffExpires(burst_haste_buff any=1) and HasEquippedItem(132410) and { SpellCooldown(combustion) < 1 or target.TimeToDie() < 50 } } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) and Spell(time_warp) or BuffExpires(combustion_buff) and Spell(mirror_image) or { SpellCooldown(combustion) > 40 and BuffExpires(combustion_buff) and not Talent(kindling_talent) or target.TimeToDie() < 11 or Talent(kindling_talent) and { Charges(rune_of_power count=0) > 1.8 or TimeInCombat() < 40 } and SpellCooldown(combustion) > 40 } and Spell(rune_of_power) or { SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() or BuffPresent(combustion_buff) } and FireCombustionPhaseCdPostConditions() or BuffPresent(rune_of_power_buff) and BuffExpires(combustion_buff) and FireRopPhaseCdPostConditions() or FireStandardRotationCdPostConditions()
}

### actions.active_talents

AddFunction FireActiveTalentsMainActions
{
    #blast_wave,if=(buff.combustion.down)|(buff.combustion.up&action.fire_blast.charges<1&action.phoenixs_flames.charges<1)
    if BuffExpires(combustion_buff) or BuffPresent(combustion_buff) and Charges(fire_blast) < 1 and Charges(phoenixs_flames) < 1 Spell(blast_wave)
    #meteor,if=cooldown.combustion.remains>15|(cooldown.combustion.remains>target.time_to_die)|buff.rune_of_power.up
    if SpellCooldown(combustion) > 15 or SpellCooldown(combustion) > target.TimeToDie() or BuffPresent(rune_of_power_buff) Spell(meteor)
    #cinderstorm,if=cooldown.combustion.remains<cast_time&(buff.rune_of_power.up|!talent.rune_on_power.enabled)|cooldown.combustion.remains>10*spell_haste&!buff.combustion.up
    if SpellCooldown(combustion) < CastTime(cinderstorm) and { BuffPresent(rune_of_power_buff) or not Talent(rune_on_power_talent) } or SpellCooldown(combustion) > 10 * { 100 / { 100 + SpellHaste() } } and not BuffPresent(combustion_buff) Spell(cinderstorm)
    #dragons_breath,if=equipped.132863|(talent.alexstraszas_fury.enabled&buff.hot_streak.down)
    if HasEquippedItem(132863) or Talent(alexstraszas_fury_talent) and BuffExpires(hot_streak_buff) Spell(dragons_breath)
    #living_bomb,if=active_enemies>1&buff.combustion.down
    if Enemies(tagged=1) > 1 and BuffExpires(combustion_buff) Spell(living_bomb)
}

AddFunction FireActiveTalentsMainPostConditions
{
}

AddFunction FireActiveTalentsShortCdActions
{
}

AddFunction FireActiveTalentsShortCdPostConditions
{
    { BuffExpires(combustion_buff) or BuffPresent(combustion_buff) and Charges(fire_blast) < 1 and Charges(phoenixs_flames) < 1 } and Spell(blast_wave) or { SpellCooldown(combustion) > 15 or SpellCooldown(combustion) > target.TimeToDie() or BuffPresent(rune_of_power_buff) } and Spell(meteor) or { SpellCooldown(combustion) < CastTime(cinderstorm) and { BuffPresent(rune_of_power_buff) or not Talent(rune_on_power_talent) } or SpellCooldown(combustion) > 10 * { 100 / { 100 + SpellHaste() } } and not BuffPresent(combustion_buff) } and Spell(cinderstorm) or { HasEquippedItem(132863) or Talent(alexstraszas_fury_talent) and BuffExpires(hot_streak_buff) } and Spell(dragons_breath) or Enemies(tagged=1) > 1 and BuffExpires(combustion_buff) and Spell(living_bomb)
}

AddFunction FireActiveTalentsCdActions
{
}

AddFunction FireActiveTalentsCdPostConditions
{
    { BuffExpires(combustion_buff) or BuffPresent(combustion_buff) and Charges(fire_blast) < 1 and Charges(phoenixs_flames) < 1 } and Spell(blast_wave) or { SpellCooldown(combustion) > 15 or SpellCooldown(combustion) > target.TimeToDie() or BuffPresent(rune_of_power_buff) } and Spell(meteor) or { SpellCooldown(combustion) < CastTime(cinderstorm) and { BuffPresent(rune_of_power_buff) or not Talent(rune_on_power_talent) } or SpellCooldown(combustion) > 10 * { 100 / { 100 + SpellHaste() } } and not BuffPresent(combustion_buff) } and Spell(cinderstorm) or { HasEquippedItem(132863) or Talent(alexstraszas_fury_talent) and BuffExpires(hot_streak_buff) } and Spell(dragons_breath) or Enemies(tagged=1) > 1 and BuffExpires(combustion_buff) and Spell(living_bomb)
}

### actions.combustion_phase

AddFunction FireCombustionPhaseMainActions
{
    #rune_of_power,if=buff.combustion.down
    if BuffExpires(combustion_buff) Spell(rune_of_power)
    #call_action_list,name=active_talents
    FireActiveTalentsMainActions()

    unless FireActiveTalentsMainPostConditions()
    {
        #combustion
		if Boss()
		{		
		Spell(combustion)
		}
        #potion,name=deadly_grace
        #blood_fury
        Spell(blood_fury_sp)
        #berserking
        Spell(berserking)
        #arcane_torrent
        Spell(arcane_torrent_mana)
        #pyroblast,if=buff.kaelthas_ultimate_ability.react&buff.combustion.remains>execute_time
        if BuffPresent(kaelthas_ultimate_ability_buff) and BuffRemaining(combustion_buff) > ExecuteTime(pyroblast) Spell(pyroblast)
        #pyroblast,if=buff.hot_streak.up
        if BuffPresent(hot_streak_buff) Spell(pyroblast)
        #fire_blast,if=buff.heating_up.up
        if BuffPresent(heating_up_buff) Spell(fire_blast)
        #phoenixs_flames
        Spell(phoenixs_flames)
        #scorch,if=buff.combustion.remains>cast_time
        if BuffRemaining(combustion_buff) > CastTime(scorch) Spell(scorch)
        #dragons_breath,if=buff.hot_streak.down&action.fire_blast.charges<1&action.phoenixs_flames.charges<1
        if BuffExpires(hot_streak_buff) and Charges(fire_blast) < 1 and Charges(phoenixs_flames) < 1 Spell(dragons_breath)
        #scorch,if=target.health.pct<=30&equipped.132454
        if target.HealthPercent() <= 30 and HasEquippedItem(132454) Spell(scorch)
    }
}

AddFunction FireCombustionPhaseMainPostConditions
{
    FireActiveTalentsMainPostConditions()
}

AddFunction FireCombustionPhaseShortCdActions
{
    unless BuffExpires(combustion_buff) and Spell(rune_of_power)
    {
        #call_action_list,name=active_talents
        FireActiveTalentsShortCdActions()
    }
}

AddFunction FireCombustionPhaseShortCdPostConditions
{
    BuffExpires(combustion_buff) and Spell(rune_of_power) or FireActiveTalentsShortCdPostConditions() or Spell(combustion) or Spell(blood_fury_sp) or Spell(berserking) or Spell(arcane_torrent_mana) or BuffPresent(kaelthas_ultimate_ability_buff) and BuffRemaining(combustion_buff) > ExecuteTime(pyroblast) and Spell(pyroblast) or BuffPresent(hot_streak_buff) and Spell(pyroblast) or BuffPresent(heating_up_buff) and Spell(fire_blast) or Spell(phoenixs_flames) or BuffRemaining(combustion_buff) > CastTime(scorch) and Spell(scorch) or BuffExpires(hot_streak_buff) and Charges(fire_blast) < 1 and Charges(phoenixs_flames) < 1 and Spell(dragons_breath) or target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(scorch)
}

AddFunction FireCombustionPhaseCdActions
{
    unless BuffExpires(combustion_buff) and Spell(rune_of_power)
    {
        #call_action_list,name=active_talents
        FireActiveTalentsCdActions()
    }
}

AddFunction FireCombustionPhaseCdPostConditions
{
    BuffExpires(combustion_buff) and Spell(rune_of_power) or FireActiveTalentsCdPostConditions() or Spell(combustion) or Spell(blood_fury_sp) or Spell(berserking) or Spell(arcane_torrent_mana) or BuffPresent(kaelthas_ultimate_ability_buff) and BuffRemaining(combustion_buff) > ExecuteTime(pyroblast) and Spell(pyroblast) or BuffPresent(hot_streak_buff) and Spell(pyroblast) or BuffPresent(heating_up_buff) and Spell(fire_blast) or Spell(phoenixs_flames) or BuffRemaining(combustion_buff) > CastTime(scorch) and Spell(scorch) or BuffExpires(hot_streak_buff) and Charges(fire_blast) < 1 and Charges(phoenixs_flames) < 1 and Spell(dragons_breath) or target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(scorch)
}

### actions.precombat

AddFunction FirePrecombatMainActions
{
    #flask,type=flask_of_the_whispered_pact
    #food,type=the_hungry_magister
    #augmentation,type=defiled
    Spell(augmentation)
    #snapshot_stats
    #mirror_image
    Spell(mirror_image)
    #potion,name=deadly_grace
    #pyroblast
    Spell(pyroblast)
}

AddFunction FirePrecombatMainPostConditions
{
}

AddFunction FirePrecombatShortCdActions
{
}

AddFunction FirePrecombatShortCdPostConditions
{
    Spell(augmentation) or Spell(mirror_image) or Spell(pyroblast)
}

AddFunction FirePrecombatCdActions
{
}

AddFunction FirePrecombatCdPostConditions
{
    Spell(augmentation) or Spell(mirror_image) or Spell(pyroblast)
}

### actions.rop_phase

AddFunction FireRopPhaseMainActions
{
    #rune_of_power
    Spell(rune_of_power)
    #flamestrike,if=((talent.flame_patch.enabled&active_enemies>1)|(active_enemies>3))&buff.hot_streak.up
    if { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) Spell(flamestrike)
    #pyroblast,if=buff.hot_streak.up
    if BuffPresent(hot_streak_buff) Spell(pyroblast)
    #call_action_list,name=active_talents
    FireActiveTalentsMainActions()

    unless FireActiveTalentsMainPostConditions()
    {
        #pyroblast,if=buff.kaelthas_ultimate_ability.react&execute_time<buff.kaelthas_ultimate_ability.remains
        if BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) Spell(pyroblast)
        #fire_blast,if=!prev_off_gcd.fire_blast
        if not PreviousOffGCDSpell(fire_blast) Spell(fire_blast)
        #phoenixs_flames,if=!prev_gcd.1.phoenixs_flames
        if not PreviousGCDSpell(phoenixs_flames) Spell(phoenixs_flames)
        #scorch,if=target.health.pct<=30&equipped.132454
        if target.HealthPercent() <= 30 and HasEquippedItem(132454) Spell(scorch)
        #dragons_breath,if=active_enemies>2
        if Enemies(tagged=1) > 2 Spell(dragons_breath)
        #flamestrike,if=(talent.flame_patch.enabled&active_enemies>2)|active_enemies>5
        if Talent(flame_patch_talent) and Enemies(tagged=1) > 2 or Enemies(tagged=1) > 5 Spell(flamestrike)
        #fireball
        Spell(fireball)
    }
}

AddFunction FireRopPhaseMainPostConditions
{
    FireActiveTalentsMainPostConditions()
}

AddFunction FireRopPhaseShortCdActions
{
    unless Spell(rune_of_power) or { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and Spell(flamestrike) or BuffPresent(hot_streak_buff) and Spell(pyroblast)
    {
        #call_action_list,name=active_talents
        FireActiveTalentsShortCdActions()
    }
}

AddFunction FireRopPhaseShortCdPostConditions
{
    Spell(rune_of_power) or { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and Spell(flamestrike) or BuffPresent(hot_streak_buff) and Spell(pyroblast) or FireActiveTalentsShortCdPostConditions() or BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) and Spell(pyroblast) or not PreviousOffGCDSpell(fire_blast) and Spell(fire_blast) or not PreviousGCDSpell(phoenixs_flames) and Spell(phoenixs_flames) or target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(scorch) or Enemies(tagged=1) > 2 and Spell(dragons_breath) or { Talent(flame_patch_talent) and Enemies(tagged=1) > 2 or Enemies(tagged=1) > 5 } and Spell(flamestrike) or Spell(fireball)
}

AddFunction FireRopPhaseCdActions
{
    unless Spell(rune_of_power) or { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and Spell(flamestrike) or BuffPresent(hot_streak_buff) and Spell(pyroblast)
    {
        #call_action_list,name=active_talents
        FireActiveTalentsCdActions()
    }
}

AddFunction FireRopPhaseCdPostConditions
{
    Spell(rune_of_power) or { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and Spell(flamestrike) or BuffPresent(hot_streak_buff) and Spell(pyroblast) or FireActiveTalentsCdPostConditions() or BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) and Spell(pyroblast) or not PreviousOffGCDSpell(fire_blast) and Spell(fire_blast) or not PreviousGCDSpell(phoenixs_flames) and Spell(phoenixs_flames) or target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(scorch) or Enemies(tagged=1) > 2 and Spell(dragons_breath) or { Talent(flame_patch_talent) and Enemies(tagged=1) > 2 or Enemies(tagged=1) > 5 } and Spell(flamestrike) or Spell(fireball)
}

### actions.standard_rotation

AddFunction FireStandardRotationMainActions
{
    #flamestrike,if=((talent.flame_patch.enabled&active_enemies>1)|active_enemies>3)&buff.hot_streak.up
    if { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) Spell(flamestrike)
    #pyroblast,if=buff.hot_streak.up&buff.hot_streak.remains<action.fireball.execute_time
    if BuffPresent(hot_streak_buff) and BuffRemaining(hot_streak_buff) < ExecuteTime(fireball) Spell(pyroblast)
    #phoenixs_flames,if=charges_fractional>2.7&active_enemies>2
    if Charges(phoenixs_flames count=0) > 2.7 and Enemies(tagged=1) > 2 Spell(phoenixs_flames)
    #pyroblast,if=buff.hot_streak.up&!prev_gcd.1.pyroblast
    if BuffPresent(hot_streak_buff) and not PreviousGCDSpell(pyroblast) Spell(pyroblast)
    #pyroblast,if=buff.hot_streak.react&target.health.pct<=30&equipped.132454
    if BuffPresent(hot_streak_buff) and target.HealthPercent() <= 30 and HasEquippedItem(132454) Spell(pyroblast)
    #pyroblast,if=buff.kaelthas_ultimate_ability.react&execute_time<buff.kaelthas_ultimate_ability.remains
    if BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) Spell(pyroblast)
    #call_action_list,name=active_talents
    FireActiveTalentsMainActions()

    unless FireActiveTalentsMainPostConditions()
    {
        #fire_blast,if=!talent.kindling.enabled&buff.heating_up.up&(!talent.rune_of_power.enabled|charges_fractional>1.4|cooldown.combustion.remains<40)&(3-charges_fractional)*(12*spell_haste)<cooldown.combustion.remains+3|target.time_to_die.remains<4
        if not Talent(kindling_talent) and BuffPresent(heating_up_buff) and { not Talent(rune_of_power_talent) or Charges(fire_blast count=0) > 1.4 or SpellCooldown(combustion) < 40 } and { 3 - Charges(fire_blast count=0) } * 12 * { 100 / { 100 + SpellHaste() } } < SpellCooldown(combustion) + 3 or target.TimeToDie() < 4 Spell(fire_blast)
        #fire_blast,if=talent.kindling.enabled&buff.heating_up.up&(!talent.rune_of_power.enabled|charges_fractional>1.5|cooldown.combustion.remains<40)&(3-charges_fractional)*(18*spell_haste)<cooldown.combustion.remains+3|target.time_to_die.remains<4
        if Talent(kindling_talent) and BuffPresent(heating_up_buff) and { not Talent(rune_of_power_talent) or Charges(fire_blast count=0) > 1.5 or SpellCooldown(combustion) < 40 } and { 3 - Charges(fire_blast count=0) } * 18 * { 100 / { 100 + SpellHaste() } } < SpellCooldown(combustion) + 3 or target.TimeToDie() < 4 Spell(fire_blast)
        #phoenixs_flames,if=(buff.combustion.up|buff.rune_of_power.up|buff.incanters_flow.stack>3|talent.mirror_image.enabled)&artifact.phoenix_reborn.enabled&(4-charges_fractional)*13<cooldown.combustion.remains+5|target.time_to_die.remains<10
        if { BuffPresent(combustion_buff) or BuffPresent(rune_of_power_buff) or BuffStacks(incanters_flow_buff) > 3 or Talent(mirror_image_talent) } and HasArtifactTrait(phoenix_reborn) and { 4 - Charges(phoenixs_flames count=0) } * 13 < SpellCooldown(combustion) + 5 or target.TimeToDie() < 10 Spell(phoenixs_flames)
        #phoenixs_flames,if=(buff.combustion.up|buff.rune_of_power.up)&(4-charges_fractional)*30<cooldown.combustion.remains+5
        if { BuffPresent(combustion_buff) or BuffPresent(rune_of_power_buff) } and { 4 - Charges(phoenixs_flames count=0) } * 30 < SpellCooldown(combustion) + 5 Spell(phoenixs_flames)
        #flamestrike,if=(talent.flame_patch.enabled&active_enemies>1)|active_enemies>5
        if Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 5 Spell(flamestrike)
        #scorch,if=target.health.pct<=30&equipped.132454
        if target.HealthPercent() <= 30 and HasEquippedItem(132454) Spell(scorch)
        #fireball
        Spell(fireball)
    }
}

AddFunction FireStandardRotationMainPostConditions
{
    FireActiveTalentsMainPostConditions()
}

AddFunction FireStandardRotationShortCdActions
{
    unless { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and Spell(flamestrike) or BuffPresent(hot_streak_buff) and BuffRemaining(hot_streak_buff) < ExecuteTime(fireball) and Spell(pyroblast) or Charges(phoenixs_flames count=0) > 2.7 and Enemies(tagged=1) > 2 and Spell(phoenixs_flames) or BuffPresent(hot_streak_buff) and not PreviousGCDSpell(pyroblast) and Spell(pyroblast) or BuffPresent(hot_streak_buff) and target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(pyroblast) or BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) and Spell(pyroblast)
    {
        #call_action_list,name=active_talents
        FireActiveTalentsShortCdActions()
    }
}

AddFunction FireStandardRotationShortCdPostConditions
{
    { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and Spell(flamestrike) or BuffPresent(hot_streak_buff) and BuffRemaining(hot_streak_buff) < ExecuteTime(fireball) and Spell(pyroblast) or Charges(phoenixs_flames count=0) > 2.7 and Enemies(tagged=1) > 2 and Spell(phoenixs_flames) or BuffPresent(hot_streak_buff) and not PreviousGCDSpell(pyroblast) and Spell(pyroblast) or BuffPresent(hot_streak_buff) and target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(pyroblast) or BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) and Spell(pyroblast) or FireActiveTalentsShortCdPostConditions() or { not Talent(kindling_talent) and BuffPresent(heating_up_buff) and { not Talent(rune_of_power_talent) or Charges(fire_blast count=0) > 1.4 or SpellCooldown(combustion) < 40 } and { 3 - Charges(fire_blast count=0) } * 12 * { 100 / { 100 + SpellHaste() } } < SpellCooldown(combustion) + 3 or target.TimeToDie() < 4 } and Spell(fire_blast) or { Talent(kindling_talent) and BuffPresent(heating_up_buff) and { not Talent(rune_of_power_talent) or Charges(fire_blast count=0) > 1.5 or SpellCooldown(combustion) < 40 } and { 3 - Charges(fire_blast count=0) } * 18 * { 100 / { 100 + SpellHaste() } } < SpellCooldown(combustion) + 3 or target.TimeToDie() < 4 } and Spell(fire_blast) or { { BuffPresent(combustion_buff) or BuffPresent(rune_of_power_buff) or BuffStacks(incanters_flow_buff) > 3 or Talent(mirror_image_talent) } and HasArtifactTrait(phoenix_reborn) and { 4 - Charges(phoenixs_flames count=0) } * 13 < SpellCooldown(combustion) + 5 or target.TimeToDie() < 10 } and Spell(phoenixs_flames) or { BuffPresent(combustion_buff) or BuffPresent(rune_of_power_buff) } and { 4 - Charges(phoenixs_flames count=0) } * 30 < SpellCooldown(combustion) + 5 and Spell(phoenixs_flames) or { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 5 } and Spell(flamestrike) or target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(scorch) or Spell(fireball)
}

AddFunction FireStandardRotationCdActions
{
    unless { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and Spell(flamestrike) or BuffPresent(hot_streak_buff) and BuffRemaining(hot_streak_buff) < ExecuteTime(fireball) and Spell(pyroblast) or Charges(phoenixs_flames count=0) > 2.7 and Enemies(tagged=1) > 2 and Spell(phoenixs_flames) or BuffPresent(hot_streak_buff) and not PreviousGCDSpell(pyroblast) and Spell(pyroblast) or BuffPresent(hot_streak_buff) and target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(pyroblast) or BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) and Spell(pyroblast)
    {
        #call_action_list,name=active_talents
        FireActiveTalentsCdActions()
    }
}

AddFunction FireStandardRotationCdPostConditions
{
    { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and Spell(flamestrike) or BuffPresent(hot_streak_buff) and BuffRemaining(hot_streak_buff) < ExecuteTime(fireball) and Spell(pyroblast) or Charges(phoenixs_flames count=0) > 2.7 and Enemies(tagged=1) > 2 and Spell(phoenixs_flames) or BuffPresent(hot_streak_buff) and not PreviousGCDSpell(pyroblast) and Spell(pyroblast) or BuffPresent(hot_streak_buff) and target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(pyroblast) or BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) and Spell(pyroblast) or FireActiveTalentsCdPostConditions() or { not Talent(kindling_talent) and BuffPresent(heating_up_buff) and { not Talent(rune_of_power_talent) or Charges(fire_blast count=0) > 1.4 or SpellCooldown(combustion) < 40 } and { 3 - Charges(fire_blast count=0) } * 12 * { 100 / { 100 + SpellHaste() } } < SpellCooldown(combustion) + 3 or target.TimeToDie() < 4 } and Spell(fire_blast) or { Talent(kindling_talent) and BuffPresent(heating_up_buff) and { not Talent(rune_of_power_talent) or Charges(fire_blast count=0) > 1.5 or SpellCooldown(combustion) < 40 } and { 3 - Charges(fire_blast count=0) } * 18 * { 100 / { 100 + SpellHaste() } } < SpellCooldown(combustion) + 3 or target.TimeToDie() < 4 } and Spell(fire_blast) or { { BuffPresent(combustion_buff) or BuffPresent(rune_of_power_buff) or BuffStacks(incanters_flow_buff) > 3 or Talent(mirror_image_talent) } and HasArtifactTrait(phoenix_reborn) and { 4 - Charges(phoenixs_flames count=0) } * 13 < SpellCooldown(combustion) + 5 or target.TimeToDie() < 10 } and Spell(phoenixs_flames) or { BuffPresent(combustion_buff) or BuffPresent(rune_of_power_buff) } and { 4 - Charges(phoenixs_flames count=0) } * 30 < SpellCooldown(combustion) + 5 and Spell(phoenixs_flames) or { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 5 } and Spell(flamestrike) or target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(scorch) or Spell(fireball)
}

]]

	OvaleScripts:RegisterScript("MAGE", "fire", name, desc, code, "script")
end
