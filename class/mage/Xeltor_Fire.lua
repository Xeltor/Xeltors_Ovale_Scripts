local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_fire"
	local desc = "[Xel][7.3.5] Mage: Fire"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_mage_spells)

Define(blazing_barrier 235313)
	SpellInfo(blazing_barrier cd=25)
Define(blazing_barrier_buff 235313)
	SpellInfo(blazing_barrier_buff duration=60)
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
	if BuffExpires(blazing_barrier_buff) and not mounted() and InCombat() and target.istargetingplayer() Spell(blazing_barrier)
	
	unless { InFlightToTarget(fireball) or InFlightToTarget(phoenixs_flames) or InFlightToTarget(pyroblast) } and BuffPresent(heating_up_buff)
	{
		if InCombat() and target.InRange(fireball) and HasFullControl()
		{
			if not { Speed() == 0 or CanMove() > 0 } Spell(ice_floes)
			
			# Cooldowns
			if Boss()
			{
				if Speed() == 0 or CanMove() > 0 FireDefaultCdActions()
			}
			
			if Speed() == 0 or CanMove() > 0 FireDefaultShortCdActions()
			if target.Distance(less 8) and not BuffPresent(ice_barrier) and target.istargetingplayer() Spell(dragons_breath)
			if Speed() == 0 or CanMove() > 0 FireDefaultMainActions()
			
			#scorch,moving=1
			if Speed() > 0 and BuffPresent(hot_streak_buff) Spell(pyroblast)
			if Speed() > 0 Spell(scorch)
		}
	}
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		if target.InRange(counterspell) Spell(counterspell)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(dragons_breath)
			if target.Distance(less 8) Spell(arcane_torrent_mana)
			if target.InRange(quaking_palm) Spell(quaking_palm)
		}
	}
}

### actions.default

AddFunction FireDefaultMainActions
{
 #call_action_list,name=combustion_phase,if=cooldown.combustion.remains<=action.rune_of_power.cast_time+(!talent.kindling.enabled*gcd)&(!talent.firestarter.enabled|!firestarter.active|active_enemies>=4|active_enemies>=2&talent.flame_patch.enabled)|buff.combustion.up
 if SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() and { not Talent(firestarter_talent) or not { Talent(firestarter_talent) and target.HealthPercent() >= 90 } or Enemies(tagged=1) >= 4 or Enemies(tagged=1) >= 2 and Talent(flame_patch_talent) } or BuffPresent(combustion_buff) FireCombustionPhaseMainActions()

 unless { SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() and { not Talent(firestarter_talent) or not { Talent(firestarter_talent) and target.HealthPercent() >= 90 } or Enemies(tagged=1) >= 4 or Enemies(tagged=1) >= 2 and Talent(flame_patch_talent) } or BuffPresent(combustion_buff) } and FireCombustionPhaseMainPostConditions()
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
 { SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() and { not Talent(firestarter_talent) or not { Talent(firestarter_talent) and target.HealthPercent() >= 90 } or Enemies(tagged=1) >= 4 or Enemies(tagged=1) >= 2 and Talent(flame_patch_talent) } or BuffPresent(combustion_buff) } and FireCombustionPhaseMainPostConditions() or BuffPresent(rune_of_power_buff) and BuffExpires(combustion_buff) and FireRopPhaseMainPostConditions() or FireStandardRotationMainPostConditions()
}

AddFunction FireDefaultShortCdActions
{
 #rune_of_power,if=firestarter.active&action.rune_of_power.charges=2|cooldown.combustion.remains>40&buff.combustion.down&!talent.kindling.enabled|target.time_to_die<11|talent.kindling.enabled&(charges_fractional>1.8|time<40)&cooldown.combustion.remains>40
 if Talent(firestarter_talent) and target.HealthPercent() >= 90 and Charges(rune_of_power) == 2 or SpellCooldown(combustion) > 40 and BuffExpires(combustion_buff) and not Talent(kindling_talent) or target.TimeToDie() < 11 or Talent(kindling_talent) and { Charges(rune_of_power count=0) > 1.8 or TimeInCombat() < 40 } and SpellCooldown(combustion) > 40 Spell(rune_of_power)
 #rune_of_power,if=(buff.kaelthas_ultimate_ability.react&(cooldown.combustion.remains>40|action.rune_of_power.charges>1))|(buff.erupting_infernal_core.up&(cooldown.combustion.remains>40|action.rune_of_power.charges>1))
 if BuffPresent(kaelthas_ultimate_ability_buff) and { SpellCooldown(combustion) > 40 or Charges(rune_of_power) > 1 } or BuffPresent(erupting_infernal_core_buff) and { SpellCooldown(combustion) > 40 or Charges(rune_of_power) > 1 } Spell(rune_of_power)
 #call_action_list,name=combustion_phase,if=cooldown.combustion.remains<=action.rune_of_power.cast_time+(!talent.kindling.enabled*gcd)&(!talent.firestarter.enabled|!firestarter.active|active_enemies>=4|active_enemies>=2&talent.flame_patch.enabled)|buff.combustion.up
 if SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() and { not Talent(firestarter_talent) or not { Talent(firestarter_talent) and target.HealthPercent() >= 90 } or Enemies(tagged=1) >= 4 or Enemies(tagged=1) >= 2 and Talent(flame_patch_talent) } or BuffPresent(combustion_buff) FireCombustionPhaseShortCdActions()

 unless { SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() and { not Talent(firestarter_talent) or not { Talent(firestarter_talent) and target.HealthPercent() >= 90 } or Enemies(tagged=1) >= 4 or Enemies(tagged=1) >= 2 and Talent(flame_patch_talent) } or BuffPresent(combustion_buff) } and FireCombustionPhaseShortCdPostConditions()
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

AddFunction FireDefaultShortCdPostConditions
{
 { SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() and { not Talent(firestarter_talent) or not { Talent(firestarter_talent) and target.HealthPercent() >= 90 } or Enemies(tagged=1) >= 4 or Enemies(tagged=1) >= 2 and Talent(flame_patch_talent) } or BuffPresent(combustion_buff) } and FireCombustionPhaseShortCdPostConditions() or BuffPresent(rune_of_power_buff) and BuffExpires(combustion_buff) and FireRopPhaseShortCdPostConditions() or FireStandardRotationShortCdPostConditions()
}

AddFunction FireDefaultCdActions
{
 #counterspell,if=target.debuff.casting.react
 # if target.IsInterruptible() FireInterruptActions()
 #time_warp,if=(time=0&buff.bloodlust.down)|(buff.bloodlust.down&equipped.132410&(cooldown.combustion.remains<1|target.time_to_die<50))
 # if { TimeInCombat() == 0 and BuffExpires(burst_haste_buff any=1) or BuffExpires(burst_haste_buff any=1) and HasEquippedItem(132410) and { SpellCooldown(combustion) < 1 or target.TimeToDie() < 50 } } and CheckBoxOn(opt_time_warp) and DebuffExpires(burst_haste_debuff any=1) Spell(time_warp)
 #mirror_image,if=buff.combustion.down
 if BuffExpires(combustion_buff) Spell(mirror_image)

 unless { Talent(firestarter_talent) and target.HealthPercent() >= 90 and Charges(rune_of_power) == 2 or SpellCooldown(combustion) > 40 and BuffExpires(combustion_buff) and not Talent(kindling_talent) or target.TimeToDie() < 11 or Talent(kindling_talent) and { Charges(rune_of_power count=0) > 1.8 or TimeInCombat() < 40 } and SpellCooldown(combustion) > 40 } and Spell(rune_of_power) or { BuffPresent(kaelthas_ultimate_ability_buff) and { SpellCooldown(combustion) > 40 or Charges(rune_of_power) > 1 } or BuffPresent(erupting_infernal_core_buff) and { SpellCooldown(combustion) > 40 or Charges(rune_of_power) > 1 } } and Spell(rune_of_power)
 {
  #call_action_list,name=combustion_phase,if=cooldown.combustion.remains<=action.rune_of_power.cast_time+(!talent.kindling.enabled*gcd)&(!talent.firestarter.enabled|!firestarter.active|active_enemies>=4|active_enemies>=2&talent.flame_patch.enabled)|buff.combustion.up
  if SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() and { not Talent(firestarter_talent) or not { Talent(firestarter_talent) and target.HealthPercent() >= 90 } or Enemies(tagged=1) >= 4 or Enemies(tagged=1) >= 2 and Talent(flame_patch_talent) } or BuffPresent(combustion_buff) FireCombustionPhaseCdActions()

  unless { SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() and { not Talent(firestarter_talent) or not { Talent(firestarter_talent) and target.HealthPercent() >= 90 } or Enemies(tagged=1) >= 4 or Enemies(tagged=1) >= 2 and Talent(flame_patch_talent) } or BuffPresent(combustion_buff) } and FireCombustionPhaseCdPostConditions()
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
 { Talent(firestarter_talent) and target.HealthPercent() >= 90 and Charges(rune_of_power) == 2 or SpellCooldown(combustion) > 40 and BuffExpires(combustion_buff) and not Talent(kindling_talent) or target.TimeToDie() < 11 or Talent(kindling_talent) and { Charges(rune_of_power count=0) > 1.8 or TimeInCombat() < 40 } and SpellCooldown(combustion) > 40 } and Spell(rune_of_power) or { BuffPresent(kaelthas_ultimate_ability_buff) and { SpellCooldown(combustion) > 40 or Charges(rune_of_power) > 1 } or BuffPresent(erupting_infernal_core_buff) and { SpellCooldown(combustion) > 40 or Charges(rune_of_power) > 1 } } and Spell(rune_of_power) or { SpellCooldown(combustion) <= CastTime(rune_of_power) + Talent(kindling_talent no) * GCD() and { not Talent(firestarter_talent) or not { Talent(firestarter_talent) and target.HealthPercent() >= 90 } or Enemies(tagged=1) >= 4 or Enemies(tagged=1) >= 2 and Talent(flame_patch_talent) } or BuffPresent(combustion_buff) } and FireCombustionPhaseCdPostConditions() or BuffPresent(rune_of_power_buff) and BuffExpires(combustion_buff) and FireRopPhaseCdPostConditions() or FireStandardRotationCdPostConditions()
}

### actions.active_talents

AddFunction FireActiveTalentsMainActions
{
 #blast_wave,if=(buff.combustion.down)|(buff.combustion.up&action.fire_blast.charges<1&action.phoenixs_flames.charges<1)
 if BuffExpires(combustion_buff) or BuffPresent(combustion_buff) and Charges(fire_blast) < 1 and Charges(phoenixs_flames) < 1 Spell(blast_wave)
 #cinderstorm,if=cooldown.combustion.remains<cast_time&(buff.rune_of_power.up|!talent.rune_of_power.enabled)|cooldown.combustion.remains>10*spell_haste&!buff.combustion.up
 if SpellCooldown(combustion) < CastTime(cinderstorm) and { BuffPresent(rune_of_power_buff) or not Talent(rune_of_power_talent) } or SpellCooldown(combustion) > 10 * { 100 / { 100 + SpellHaste() } } and not BuffPresent(combustion_buff) Spell(cinderstorm)
 #living_bomb,if=active_enemies>1&buff.combustion.down
 if Enemies(tagged=1) > 1 and BuffExpires(combustion_buff) Spell(living_bomb)
}

AddFunction FireActiveTalentsMainPostConditions
{
}

AddFunction FireActiveTalentsShortCdActions
{
 unless { BuffExpires(combustion_buff) or BuffPresent(combustion_buff) and Charges(fire_blast) < 1 and Charges(phoenixs_flames) < 1 } and Spell(blast_wave)
 {
  #meteor,if=cooldown.combustion.remains>40|(cooldown.combustion.remains>target.time_to_die)|buff.rune_of_power.up|firestarter.active
  if SpellCooldown(combustion) > 40 or SpellCooldown(combustion) > target.TimeToDie() or BuffPresent(rune_of_power_buff) or Talent(firestarter_talent) and target.HealthPercent() >= 90 Spell(meteor)

  unless { SpellCooldown(combustion) < CastTime(cinderstorm) and { BuffPresent(rune_of_power_buff) or not Talent(rune_of_power_talent) } or SpellCooldown(combustion) > 10 * { 100 / { 100 + SpellHaste() } } and not BuffPresent(combustion_buff) } and Spell(cinderstorm)
  {
   #dragons_breath,if=equipped.132863|(talent.alexstraszas_fury.enabled&!buff.hot_streak.react)
   if HasEquippedItem(132863) or Talent(alexstraszas_fury_talent) and not BuffPresent(hot_streak_buff) and target.Distance(less 8) Spell(dragons_breath)
  }
 }
}

AddFunction FireActiveTalentsShortCdPostConditions
{
 { BuffExpires(combustion_buff) or BuffPresent(combustion_buff) and Charges(fire_blast) < 1 and Charges(phoenixs_flames) < 1 } and Spell(blast_wave) or { SpellCooldown(combustion) < CastTime(cinderstorm) and { BuffPresent(rune_of_power_buff) or not Talent(rune_of_power_talent) } or SpellCooldown(combustion) > 10 * { 100 / { 100 + SpellHaste() } } and not BuffPresent(combustion_buff) } and Spell(cinderstorm) or Enemies(tagged=1) > 1 and BuffExpires(combustion_buff) and Spell(living_bomb)
}

AddFunction FireActiveTalentsCdActions
{
}

AddFunction FireActiveTalentsCdPostConditions
{
 { BuffExpires(combustion_buff) or BuffPresent(combustion_buff) and Charges(fire_blast) < 1 and Charges(phoenixs_flames) < 1 } and Spell(blast_wave) or { SpellCooldown(combustion) > 40 or SpellCooldown(combustion) > target.TimeToDie() or BuffPresent(rune_of_power_buff) or Talent(firestarter_talent) and target.HealthPercent() >= 90 } and Spell(meteor) or { SpellCooldown(combustion) < CastTime(cinderstorm) and { BuffPresent(rune_of_power_buff) or not Talent(rune_of_power_talent) } or SpellCooldown(combustion) > 10 * { 100 / { 100 + SpellHaste() } } and not BuffPresent(combustion_buff) } and Spell(cinderstorm) or { HasEquippedItem(132863) or Talent(alexstraszas_fury_talent) and not BuffPresent(hot_streak_buff) } and target.Distance(less 8) and Spell(dragons_breath) or Enemies(tagged=1) > 1 and BuffExpires(combustion_buff) and Spell(living_bomb)
}

### actions.combustion_phase

AddFunction FireCombustionPhaseMainActions
{
 #call_action_list,name=active_talents
 FireActiveTalentsMainActions()

 unless FireActiveTalentsMainPostConditions()
 {
  #flamestrike,if=(talent.flame_patch.enabled&active_enemies>2|active_enemies>4)&buff.hot_streak.react
  if { Talent(flame_patch_talent) and Enemies(tagged=1) > 2 or Enemies(tagged=1) > 4 } and BuffPresent(hot_streak_buff) and mouseover.Present() and not mouseover.IsFriend() Spell(flamestrike)
  #pyroblast,if=buff.kaelthas_ultimate_ability.react&buff.combustion.remains>execute_time
  if BuffPresent(kaelthas_ultimate_ability_buff) and BuffRemaining(combustion_buff) > ExecuteTime(pyroblast) Spell(pyroblast)
  #pyroblast,if=buff.hot_streak.react
  if BuffPresent(hot_streak_buff) Spell(pyroblast)
  #scorch,if=buff.combustion.remains>cast_time
  if BuffRemaining(combustion_buff) > CastTime(scorch) Spell(scorch)
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
 #rune_of_power,if=buff.combustion.down
 if BuffExpires(combustion_buff) Spell(rune_of_power)
 #call_action_list,name=active_talents
 FireActiveTalentsShortCdActions()

 unless FireActiveTalentsShortCdPostConditions() or { Talent(flame_patch_talent) and Enemies(tagged=1) > 2 or Enemies(tagged=1) > 4 } and BuffPresent(hot_streak_buff) and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or BuffPresent(kaelthas_ultimate_ability_buff) and BuffRemaining(combustion_buff) > ExecuteTime(pyroblast) and Spell(pyroblast) or BuffPresent(hot_streak_buff) and Spell(pyroblast)
 {
  #fire_blast,if=buff.heating_up.react
  if BuffPresent(heating_up_buff) Spell(fire_blast)
  #phoenixs_flames
  Spell(phoenixs_flames)

  unless BuffRemaining(combustion_buff) > CastTime(scorch) and Spell(scorch)
  {
   #dragons_breath,if=!buff.hot_streak.react&action.fire_blast.charges<1&action.phoenixs_flames.charges<1
   if not BuffPresent(hot_streak_buff) and Charges(fire_blast) < 1 and Charges(phoenixs_flames) < 1 and target.Distance(less 8) Spell(dragons_breath)
  }
 }
}

AddFunction FireCombustionPhaseShortCdPostConditions
{
 FireActiveTalentsShortCdPostConditions() or { Talent(flame_patch_talent) and Enemies(tagged=1) > 2 or Enemies(tagged=1) > 4 } and BuffPresent(hot_streak_buff) and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or BuffPresent(kaelthas_ultimate_ability_buff) and BuffRemaining(combustion_buff) > ExecuteTime(pyroblast) and Spell(pyroblast) or BuffPresent(hot_streak_buff) and Spell(pyroblast) or BuffRemaining(combustion_buff) > CastTime(scorch) and Spell(scorch) or target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(scorch)
}

AddFunction FireCombustionPhaseCdActions
{
 unless BuffExpires(combustion_buff) and Spell(rune_of_power)
 {
  #call_action_list,name=active_talents
  FireActiveTalentsCdActions()

  unless FireActiveTalentsCdPostConditions()
  {
   #combustion
   Spell(combustion)
   #potion
   # Item(prolonged_power_potion)
   #blood_fury
   Spell(blood_fury_sp)
   #berserking
   Spell(berserking)
   #arcane_torrent
   Spell(arcane_torrent_mana)
   #use_items
   # FireUseItemActions()
  }
 }
}

AddFunction FireCombustionPhaseCdPostConditions
{
 BuffExpires(combustion_buff) and Spell(rune_of_power) or FireActiveTalentsCdPostConditions() or { Talent(flame_patch_talent) and Enemies(tagged=1) > 2 or Enemies(tagged=1) > 4 } and BuffPresent(hot_streak_buff) and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or BuffPresent(kaelthas_ultimate_ability_buff) and BuffRemaining(combustion_buff) > ExecuteTime(pyroblast) and Spell(pyroblast) or BuffPresent(hot_streak_buff) and Spell(pyroblast) or Spell(phoenixs_flames) or BuffRemaining(combustion_buff) > CastTime(scorch) and Spell(scorch) or not BuffPresent(hot_streak_buff) and Charges(fire_blast) < 1 and Charges(phoenixs_flames) < 1 and target.Distance(less 8) and Spell(dragons_breath) or target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(scorch)
}

### actions.precombat

AddFunction FirePrecombatMainActions
{
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
 Spell(pyroblast)
}

AddFunction FirePrecombatCdActions
{
 #flask
 #food
 #augmentation
 #snapshot_stats
 #mirror_image
 Spell(mirror_image)
 #potion
 # Item(prolonged_power_potion)
}

AddFunction FirePrecombatCdPostConditions
{
 Spell(pyroblast)
}

### actions.rop_phase

AddFunction FireRopPhaseMainActions
{
 #flamestrike,if=((talent.flame_patch.enabled&active_enemies>1)|active_enemies>3)&buff.hot_streak.react
 if { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and mouseover.Present() and not mouseover.IsFriend() Spell(flamestrike)
 #pyroblast,if=buff.hot_streak.react
 if BuffPresent(hot_streak_buff) Spell(pyroblast)
 #call_action_list,name=active_talents
 FireActiveTalentsMainActions()

 unless FireActiveTalentsMainPostConditions()
 {
  #pyroblast,if=buff.kaelthas_ultimate_ability.react&execute_time<buff.kaelthas_ultimate_ability.remains&buff.rune_of_power.remains>cast_time
  if BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) and TotemRemaining(rune_of_power) > CastTime(pyroblast) Spell(pyroblast)
  #scorch,if=target.health.pct<=30&equipped.132454
  if target.HealthPercent() <= 30 and HasEquippedItem(132454) Spell(scorch)
  #flamestrike,if=(talent.flame_patch.enabled&active_enemies>2)|active_enemies>5
  if { Talent(flame_patch_talent) and Enemies(tagged=1) > 2 or Enemies(tagged=1) > 5 } and mouseover.Present() and not mouseover.IsFriend() Spell(flamestrike)
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
 #rune_of_power
 Spell(rune_of_power)

 unless { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or BuffPresent(hot_streak_buff) and Spell(pyroblast)
 {
  #call_action_list,name=active_talents
  FireActiveTalentsShortCdActions()

  unless FireActiveTalentsShortCdPostConditions() or BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) and TotemRemaining(rune_of_power) > CastTime(pyroblast) and Spell(pyroblast)
  {
   #fire_blast,if=!prev_off_gcd.fire_blast&buff.heating_up.react&firestarter.active&charges_fractional>1.7
   if not PreviousOffGCDSpell(fire_blast) and BuffPresent(heating_up_buff) and Talent(firestarter_talent) and target.HealthPercent() >= 90 and Charges(fire_blast count=0) > 1.7 Spell(fire_blast)
   #phoenixs_flames,if=!prev_gcd.1.phoenixs_flames&charges_fractional>2.7&firestarter.active
   if not PreviousGCDSpell(phoenixs_flames) and Charges(phoenixs_flames count=0) > 2.7 and Talent(firestarter_talent) and target.HealthPercent() >= 90 Spell(phoenixs_flames)
   #fire_blast,if=!prev_off_gcd.fire_blast&!firestarter.active
   if not PreviousOffGCDSpell(fire_blast) and not { Talent(firestarter_talent) and target.HealthPercent() >= 90 } Spell(fire_blast)
   #phoenixs_flames,if=!prev_gcd.1.phoenixs_flames
   if not PreviousGCDSpell(phoenixs_flames) Spell(phoenixs_flames)

   unless target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(scorch)
   {
    #dragons_breath,if=active_enemies>2
    if Enemies(tagged=1) > 2 and target.Distance(less 8) Spell(dragons_breath)
   }
  }
 }
}

AddFunction FireRopPhaseShortCdPostConditions
{
 { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or BuffPresent(hot_streak_buff) and Spell(pyroblast) or FireActiveTalentsShortCdPostConditions() or BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) and TotemRemaining(rune_of_power) > CastTime(pyroblast) and Spell(pyroblast) or target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(scorch) or { Talent(flame_patch_talent) and Enemies(tagged=1) > 2 or Enemies(tagged=1) > 5 } and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or Spell(fireball)
}

AddFunction FireRopPhaseCdActions
{
 unless Spell(rune_of_power) or { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or BuffPresent(hot_streak_buff) and Spell(pyroblast)
 {
  #call_action_list,name=active_talents
  FireActiveTalentsCdActions()
 }
}

AddFunction FireRopPhaseCdPostConditions
{
 Spell(rune_of_power) or { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or BuffPresent(hot_streak_buff) and Spell(pyroblast) or FireActiveTalentsCdPostConditions() or BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) and TotemRemaining(rune_of_power) > CastTime(pyroblast) and Spell(pyroblast) or not PreviousGCDSpell(phoenixs_flames) and Charges(phoenixs_flames count=0) > 2.7 and Talent(firestarter_talent) and target.HealthPercent() >= 90 and Spell(phoenixs_flames) or not PreviousGCDSpell(phoenixs_flames) and Spell(phoenixs_flames) or target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(scorch) or Enemies(tagged=1) > 2 and target.Distance(less 8) and Spell(dragons_breath) or { Talent(flame_patch_talent) and Enemies(tagged=1) > 2 or Enemies(tagged=1) > 5 } and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or Spell(fireball)
}

### actions.standard_rotation

AddFunction FireStandardRotationMainActions
{
 #flamestrike,if=((talent.flame_patch.enabled&active_enemies>1)|active_enemies>3)&buff.hot_streak.react
 if { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and mouseover.Present() and not mouseover.IsFriend() Spell(flamestrike)
 #pyroblast,if=buff.hot_streak.react&buff.hot_streak.remains<action.fireball.execute_time
 if BuffPresent(hot_streak_buff) and BuffRemaining(hot_streak_buff) < ExecuteTime(fireball) Spell(pyroblast)
 #pyroblast,if=buff.hot_streak.react&firestarter.active&!talent.rune_of_power.enabled
 if BuffPresent(hot_streak_buff) and Talent(firestarter_talent) and target.HealthPercent() >= 90 and not Talent(rune_of_power_talent) Spell(pyroblast)
 #pyroblast,if=buff.hot_streak.react&(!prev_gcd.1.pyroblast|action.pyroblast.in_flight)
 if BuffPresent(hot_streak_buff) and { not PreviousGCDSpell(pyroblast) or InFlightToTarget(pyroblast) } Spell(pyroblast)
 #pyroblast,if=buff.hot_streak.react&target.health.pct<=30&equipped.132454
 if BuffPresent(hot_streak_buff) and target.HealthPercent() <= 30 and HasEquippedItem(132454) Spell(pyroblast)
 #pyroblast,if=buff.kaelthas_ultimate_ability.react&execute_time<buff.kaelthas_ultimate_ability.remains
 if BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) Spell(pyroblast)
 #call_action_list,name=active_talents
 FireActiveTalentsMainActions()

 unless FireActiveTalentsMainPostConditions()
 {
  #flamestrike,if=(talent.flame_patch.enabled&active_enemies>3)|active_enemies>5
  if { Talent(flame_patch_talent) and Enemies(tagged=1) > 3 or Enemies(tagged=1) > 5 } and mouseover.Present() and not mouseover.IsFriend() Spell(flamestrike)
  #scorch,if=target.health.pct<=30&equipped.132454
  if target.HealthPercent() <= 30 and HasEquippedItem(132454) Spell(scorch)
  #fireball
  Spell(fireball)
  #scorch
  Spell(scorch)
 }
}

AddFunction FireStandardRotationMainPostConditions
{
 FireActiveTalentsMainPostConditions()
}

AddFunction FireStandardRotationShortCdActions
{
 unless { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or BuffPresent(hot_streak_buff) and BuffRemaining(hot_streak_buff) < ExecuteTime(fireball) and Spell(pyroblast) or BuffPresent(hot_streak_buff) and Talent(firestarter_talent) and target.HealthPercent() >= 90 and not Talent(rune_of_power_talent) and Spell(pyroblast)
 {
  #phoenixs_flames,if=charges_fractional>2.7&active_enemies>2
  if Charges(phoenixs_flames count=0) > 2.7 and Enemies(tagged=1) > 2 Spell(phoenixs_flames)

  unless BuffPresent(hot_streak_buff) and { not PreviousGCDSpell(pyroblast) or InFlightToTarget(pyroblast) } and Spell(pyroblast) or BuffPresent(hot_streak_buff) and target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(pyroblast) or BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) and Spell(pyroblast)
  {
   #call_action_list,name=active_talents
   FireActiveTalentsShortCdActions()

   unless FireActiveTalentsShortCdPostConditions()
   {
    #fire_blast,if=!talent.kindling.enabled&buff.heating_up.react&(!talent.rune_of_power.enabled|charges_fractional>1.4|cooldown.combustion.remains<40)&(3-charges_fractional)*(12*spell_haste)<cooldown.combustion.remains+3|target.time_to_die<4
    if not Talent(kindling_talent) and BuffPresent(heating_up_buff) and { not Talent(rune_of_power_talent) or Charges(fire_blast count=0) > 1.4 or SpellCooldown(combustion) < 40 } and { 3 - Charges(fire_blast count=0) } * 12 * { 100 / { 100 + SpellHaste() } } < SpellCooldown(combustion) + 3 or target.TimeToDie() < 4 Spell(fire_blast)
    #fire_blast,if=talent.kindling.enabled&buff.heating_up.react&(!talent.rune_of_power.enabled|charges_fractional>1.5|cooldown.combustion.remains<40)&(3-charges_fractional)*(18*spell_haste)<cooldown.combustion.remains+3|target.time_to_die<4
    if Talent(kindling_talent) and BuffPresent(heating_up_buff) and { not Talent(rune_of_power_talent) or Charges(fire_blast count=0) > 1.5 or SpellCooldown(combustion) < 40 } and { 3 - Charges(fire_blast count=0) } * 18 * { 100 / { 100 + SpellHaste() } } < SpellCooldown(combustion) + 3 or target.TimeToDie() < 4 Spell(fire_blast)
    #phoenixs_flames,if=(buff.combustion.up|buff.rune_of_power.up|buff.incanters_flow.stack>3|talent.mirror_image.enabled)&artifact.phoenix_reborn.enabled&(4-charges_fractional)*13<cooldown.combustion.remains+5|target.time_to_die<10
    if { BuffPresent(combustion_buff) or BuffPresent(rune_of_power_buff) or BuffStacks(incanters_flow_buff) > 3 or Talent(mirror_image_talent) } and HasArtifactTrait(phoenix_reborn) and { 4 - Charges(phoenixs_flames count=0) } * 13 < SpellCooldown(combustion) + 5 or target.TimeToDie() < 10 Spell(phoenixs_flames)
    #phoenixs_flames,if=(buff.combustion.up|buff.rune_of_power.up)&(4-charges_fractional)*30<cooldown.combustion.remains+5
    if { BuffPresent(combustion_buff) or BuffPresent(rune_of_power_buff) } and { 4 - Charges(phoenixs_flames count=0) } * 30 < SpellCooldown(combustion) + 5 Spell(phoenixs_flames)
    #phoenixs_flames,if=charges_fractional>2.5&cooldown.combustion.remains>23
    if Charges(phoenixs_flames count=0) > 2.5 and SpellCooldown(combustion) > 23 Spell(phoenixs_flames)
   }
  }
 }
}

AddFunction FireStandardRotationShortCdPostConditions
{
 { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or BuffPresent(hot_streak_buff) and BuffRemaining(hot_streak_buff) < ExecuteTime(fireball) and Spell(pyroblast) or BuffPresent(hot_streak_buff) and Talent(firestarter_talent) and target.HealthPercent() >= 90 and not Talent(rune_of_power_talent) and Spell(pyroblast) or BuffPresent(hot_streak_buff) and { not PreviousGCDSpell(pyroblast) or InFlightToTarget(pyroblast) } and Spell(pyroblast) or BuffPresent(hot_streak_buff) and target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(pyroblast) or BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) and Spell(pyroblast) or FireActiveTalentsShortCdPostConditions() or { Talent(flame_patch_talent) and Enemies(tagged=1) > 3 or Enemies(tagged=1) > 5 } and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(scorch) or Spell(fireball) or Spell(scorch)
}

AddFunction FireStandardRotationCdActions
{
 unless { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or BuffPresent(hot_streak_buff) and BuffRemaining(hot_streak_buff) < ExecuteTime(fireball) and Spell(pyroblast) or BuffPresent(hot_streak_buff) and Talent(firestarter_talent) and target.HealthPercent() >= 90 and not Talent(rune_of_power_talent) and Spell(pyroblast) or Charges(phoenixs_flames count=0) > 2.7 and Enemies(tagged=1) > 2 and Spell(phoenixs_flames) or BuffPresent(hot_streak_buff) and { not PreviousGCDSpell(pyroblast) or InFlightToTarget(pyroblast) } and Spell(pyroblast) or BuffPresent(hot_streak_buff) and target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(pyroblast) or BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) and Spell(pyroblast)
 {
  #call_action_list,name=active_talents
  FireActiveTalentsCdActions()
 }
}

AddFunction FireStandardRotationCdPostConditions
{
 { Talent(flame_patch_talent) and Enemies(tagged=1) > 1 or Enemies(tagged=1) > 3 } and BuffPresent(hot_streak_buff) and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or BuffPresent(hot_streak_buff) and BuffRemaining(hot_streak_buff) < ExecuteTime(fireball) and Spell(pyroblast) or BuffPresent(hot_streak_buff) and Talent(firestarter_talent) and target.HealthPercent() >= 90 and not Talent(rune_of_power_talent) and Spell(pyroblast) or Charges(phoenixs_flames count=0) > 2.7 and Enemies(tagged=1) > 2 and Spell(phoenixs_flames) or BuffPresent(hot_streak_buff) and { not PreviousGCDSpell(pyroblast) or InFlightToTarget(pyroblast) } and Spell(pyroblast) or BuffPresent(hot_streak_buff) and target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(pyroblast) or BuffPresent(kaelthas_ultimate_ability_buff) and ExecuteTime(pyroblast) < BuffRemaining(kaelthas_ultimate_ability_buff) and Spell(pyroblast) or FireActiveTalentsCdPostConditions() or { { BuffPresent(combustion_buff) or BuffPresent(rune_of_power_buff) or BuffStacks(incanters_flow_buff) > 3 or Talent(mirror_image_talent) } and HasArtifactTrait(phoenix_reborn) and { 4 - Charges(phoenixs_flames count=0) } * 13 < SpellCooldown(combustion) + 5 or target.TimeToDie() < 10 } and Spell(phoenixs_flames) or { BuffPresent(combustion_buff) or BuffPresent(rune_of_power_buff) } and { 4 - Charges(phoenixs_flames count=0) } * 30 < SpellCooldown(combustion) + 5 and Spell(phoenixs_flames) or Charges(phoenixs_flames count=0) > 2.5 and SpellCooldown(combustion) > 23 and Spell(phoenixs_flames) or { Talent(flame_patch_talent) and Enemies(tagged=1) > 3 or Enemies(tagged=1) > 5 } and mouseover.Present() and not mouseover.IsFriend() and Spell(flamestrike) or target.HealthPercent() <= 30 and HasEquippedItem(132454) and Spell(scorch) or Spell(fireball) or Spell(scorch)
}
]]

	OvaleScripts:RegisterScript("MAGE", "fire", name, desc, code, "script")
end
