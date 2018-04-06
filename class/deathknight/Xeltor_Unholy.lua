local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_unholy_functions"
	local desc = "[Xel][7.3] Death Knight: Unholy Functions"
	local code = [[
### actions.default

AddFunction UnholyDefaultMainActions
{
 #outbreak,target_if=(dot.virulent_plague.tick_time_remains+tick_time<=dot.virulent_plague.remains)&dot.virulent_plague.remains<=gcd
 if target.TickTimeRemaining(virulent_plague_debuff) + target.TickTime(virulent_plague_debuff) <= target.DebuffRemaining(virulent_plague_debuff) and target.DebuffRemaining(virulent_plague_debuff) <= GCD() or not target.DebuffPresent(virulent_plague_debuff) Spell(outbreak)
 #call_action_list,name=cooldowns
 UnholyCooldownsMainActions()

 unless UnholyCooldownsMainPostConditions()
 {
  #run_action_list,name=valkyr,if=pet.valkyr_battlemaiden.active&talent.dark_arbiter.enabled
  if pet.Present() and Talent(dark_arbiter_talent) UnholyValkyrMainActions()

  unless pet.Present() and Talent(dark_arbiter_talent) and UnholyValkyrMainPostConditions()
  {
   #call_action_list,name=generic
   UnholyGenericMainActions()
  }
 }
}

AddFunction UnholyDefaultMainPostConditions
{
 UnholyCooldownsMainPostConditions() or pet.Present() and Talent(dark_arbiter_talent) and UnholyValkyrMainPostConditions() or UnholyGenericMainPostConditions()
}

AddFunction UnholyDefaultShortCdActions
{
 #auto_attack
 # UnholyGetInMeleeRange()
 #blighted_rune_weapon,if=debuff.festering_wound.stack<=4
 if target.DebuffStacks(festering_wound_debuff) <= 4 Spell(blighted_rune_weapon)

 unless target.TickTimeRemaining(virulent_plague_debuff) + target.TickTime(virulent_plague_debuff) <= target.DebuffRemaining(virulent_plague_debuff) and target.DebuffRemaining(virulent_plague_debuff) <= GCD() and Spell(outbreak)
 {
  #call_action_list,name=cooldowns
  UnholyCooldownsShortCdActions()

  unless UnholyCooldownsShortCdPostConditions()
  {
   #run_action_list,name=valkyr,if=pet.valkyr_battlemaiden.active&talent.dark_arbiter.enabled
   if pet.Present() and Talent(dark_arbiter_talent) UnholyValkyrShortCdActions()

   unless pet.Present() and Talent(dark_arbiter_talent) and UnholyValkyrShortCdPostConditions()
   {
    #call_action_list,name=generic
    UnholyGenericShortCdActions()
   }
  }
 }
}

AddFunction UnholyDefaultShortCdPostConditions
{
 target.TickTimeRemaining(virulent_plague_debuff) + target.TickTime(virulent_plague_debuff) <= target.DebuffRemaining(virulent_plague_debuff) and target.DebuffRemaining(virulent_plague_debuff) <= GCD() and Spell(outbreak) or UnholyCooldownsShortCdPostConditions() or pet.Present() and Talent(dark_arbiter_talent) and UnholyValkyrShortCdPostConditions() or UnholyGenericShortCdPostConditions()
}

AddFunction UnholyDefaultCdActions
{
 #mind_freeze
 # UnholyInterruptActions()
 #arcane_torrent,if=runic_power.deficit>20&(pet.valkyr_battlemaiden.active|!talent.dark_arbiter.enabled)
 if RunicPowerDeficit() > 20 and { pet.Present() or not Talent(dark_arbiter_talent) } Spell(arcane_torrent_runicpower)
 #blood_fury,if=pet.valkyr_battlemaiden.active|!talent.dark_arbiter.enabled
 if pet.Present() or not Talent(dark_arbiter_talent) Spell(blood_fury_ap)
 #berserking,if=pet.valkyr_battlemaiden.active|!talent.dark_arbiter.enabled
 if pet.Present() or not Talent(dark_arbiter_talent) Spell(berserking)
 #use_items
 # UnholyUseItemActions()
 #use_item,name=feloiled_infernal_machine,if=pet.valkyr_battlemaiden.active|!talent.dark_arbiter.enabled
 # if pet.Present() or not Talent(dark_arbiter_talent) UnholyUseItemActions()
 #use_item,name=ring_of_collapsing_futures,if=(buff.temptation.stack=0&target.time_to_die>60)|target.time_to_die<60
 # if BuffStacks(temptation_buff) == 0 and target.TimeToDie() > 60 or target.TimeToDie() < 60 UnholyUseItemActions()
 #potion,if=buff.unholy_strength.react
 # if BuffPresent(unholy_strength_buff) and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)

 unless target.DebuffStacks(festering_wound_debuff) <= 4 and Spell(blighted_rune_weapon) or target.TickTimeRemaining(virulent_plague_debuff) + target.TickTime(virulent_plague_debuff) <= target.DebuffRemaining(virulent_plague_debuff) and target.DebuffRemaining(virulent_plague_debuff) <= GCD() and Spell(outbreak)
 {
  #call_action_list,name=cooldowns
  UnholyCooldownsCdActions()

  unless UnholyCooldownsCdPostConditions()
  {
   #run_action_list,name=valkyr,if=pet.valkyr_battlemaiden.active&talent.dark_arbiter.enabled
   if pet.Present() and Talent(dark_arbiter_talent) UnholyValkyrCdActions()

   unless pet.Present() and Talent(dark_arbiter_talent) and UnholyValkyrCdPostConditions()
   {
    #call_action_list,name=generic
    UnholyGenericCdActions()
   }
  }
 }
}

AddFunction UnholyDefaultCdPostConditions
{
 target.DebuffStacks(festering_wound_debuff) <= 4 and Spell(blighted_rune_weapon) or target.TickTimeRemaining(virulent_plague_debuff) + target.TickTime(virulent_plague_debuff) <= target.DebuffRemaining(virulent_plague_debuff) and target.DebuffRemaining(virulent_plague_debuff) <= GCD() and Spell(outbreak) or UnholyCooldownsCdPostConditions() or pet.Present() and Talent(dark_arbiter_talent) and UnholyValkyrCdPostConditions() or UnholyGenericCdPostConditions()
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

### actions.cold_heart

AddFunction UnholyColdHeartMainActions
{
 #chains_of_ice,if=buff.unholy_strength.remains<gcd&buff.unholy_strength.react&buff.cold_heart.stack>16
 if BuffRemaining(unholy_strength_buff) < GCD() and BuffPresent(unholy_strength_buff) and BuffStacks(cold_heart_buff) > 16 Spell(chains_of_ice)
 #chains_of_ice,if=buff.master_of_ghouls.remains<gcd&buff.master_of_ghouls.up&buff.cold_heart.stack>17
 if BuffRemaining(master_of_ghouls_buff) < GCD() and BuffPresent(master_of_ghouls_buff) and BuffStacks(cold_heart_buff) > 17 Spell(chains_of_ice)
 #chains_of_ice,if=buff.cold_heart.stack=20&buff.unholy_strength.react
 if BuffStacks(cold_heart_buff) == 20 and BuffPresent(unholy_strength_buff) Spell(chains_of_ice)
}

AddFunction UnholyColdHeartMainPostConditions
{
}

AddFunction UnholyColdHeartShortCdActions
{
}

AddFunction UnholyColdHeartShortCdPostConditions
{
 BuffRemaining(unholy_strength_buff) < GCD() and BuffPresent(unholy_strength_buff) and BuffStacks(cold_heart_buff) > 16 and Spell(chains_of_ice) or BuffRemaining(master_of_ghouls_buff) < GCD() and BuffPresent(master_of_ghouls_buff) and BuffStacks(cold_heart_buff) > 17 and Spell(chains_of_ice) or BuffStacks(cold_heart_buff) == 20 and BuffPresent(unholy_strength_buff) and Spell(chains_of_ice)
}

AddFunction UnholyColdHeartCdActions
{
}

AddFunction UnholyColdHeartCdPostConditions
{
 BuffRemaining(unholy_strength_buff) < GCD() and BuffPresent(unholy_strength_buff) and BuffStacks(cold_heart_buff) > 16 and Spell(chains_of_ice) or BuffRemaining(master_of_ghouls_buff) < GCD() and BuffPresent(master_of_ghouls_buff) and BuffStacks(cold_heart_buff) > 17 and Spell(chains_of_ice) or BuffStacks(cold_heart_buff) == 20 and BuffPresent(unholy_strength_buff) and Spell(chains_of_ice)
}

### actions.cooldowns

AddFunction UnholyCooldownsMainActions
{
 #call_action_list,name=cold_heart,if=equipped.cold_heart&buff.cold_heart.stack>10&!debuff.soul_reaper.up
 if HasEquippedItem(cold_heart) and BuffStacks(cold_heart_buff) > 10 and not target.DebuffPresent(soul_reaper_unholy_debuff) UnholyColdHeartMainActions()

 unless HasEquippedItem(cold_heart) and BuffStacks(cold_heart_buff) > 10 and not target.DebuffPresent(soul_reaper_unholy_debuff) and UnholyColdHeartMainPostConditions()
 {
  #call_action_list,name=dt,if=cooldown.dark_transformation.ready
  if SpellCooldown(dark_transformation) == 0 UnholyDtMainActions()
 }
}

AddFunction UnholyCooldownsMainPostConditions
{
 HasEquippedItem(cold_heart) and BuffStacks(cold_heart_buff) > 10 and not target.DebuffPresent(soul_reaper_unholy_debuff) and UnholyColdHeartMainPostConditions() or SpellCooldown(dark_transformation) == 0 and UnholyDtMainPostConditions()
}

AddFunction UnholyCooldownsShortCdActions
{
 #call_action_list,name=cold_heart,if=equipped.cold_heart&buff.cold_heart.stack>10&!debuff.soul_reaper.up
 if HasEquippedItem(cold_heart) and BuffStacks(cold_heart_buff) > 10 and not target.DebuffPresent(soul_reaper_unholy_debuff) UnholyColdHeartShortCdActions()

 unless HasEquippedItem(cold_heart) and BuffStacks(cold_heart_buff) > 10 and not target.DebuffPresent(soul_reaper_unholy_debuff) and UnholyColdHeartShortCdPostConditions()
 {
  #apocalypse,if=debuff.festering_wound.stack>=6
  if target.DebuffStacks(festering_wound_debuff) >= 6 Spell(apocalypse)
  #soul_reaper,if=(debuff.festering_wound.stack>=6&cooldown.apocalypse.remains<=gcd)|(debuff.festering_wound.stack>=3&rune>=3&cooldown.apocalypse.remains>20)
  if target.DebuffStacks(festering_wound_debuff) >= 6 and SpellCooldown(apocalypse) <= GCD() or target.DebuffStacks(festering_wound_debuff) >= 3 and Rune() >= 3 and SpellCooldown(apocalypse) > 20 Spell(soul_reaper_unholy)
  #call_action_list,name=dt,if=cooldown.dark_transformation.ready
  if SpellCooldown(dark_transformation) == 0 UnholyDtShortCdActions()
 }
}

AddFunction UnholyCooldownsShortCdPostConditions
{
 HasEquippedItem(cold_heart) and BuffStacks(cold_heart_buff) > 10 and not target.DebuffPresent(soul_reaper_unholy_debuff) and UnholyColdHeartShortCdPostConditions() or SpellCooldown(dark_transformation) == 0 and UnholyDtShortCdPostConditions()
}

AddFunction UnholyCooldownsCdActions
{
 #call_action_list,name=cold_heart,if=equipped.cold_heart&buff.cold_heart.stack>10&!debuff.soul_reaper.up
 if HasEquippedItem(cold_heart) and BuffStacks(cold_heart_buff) > 10 and not target.DebuffPresent(soul_reaper_unholy_debuff) UnholyColdHeartCdActions()

 unless HasEquippedItem(cold_heart) and BuffStacks(cold_heart_buff) > 10 and not target.DebuffPresent(soul_reaper_unholy_debuff) and UnholyColdHeartCdPostConditions()
 {
  #army_of_the_dead
  Spell(army_of_the_dead)

  unless target.DebuffStacks(festering_wound_debuff) >= 6 and Spell(apocalypse)
  {
   #dark_arbiter,if=(!equipped.137075|cooldown.dark_transformation.remains<2)&runic_power.deficit<30
   if { not HasEquippedItem(137075) or SpellCooldown(dark_transformation) < 2 } and RunicPowerDeficit() < 30 Spell(dark_arbiter)
   #summon_gargoyle,if=(!equipped.137075|cooldown.dark_transformation.remains<10)&rune.time_to_4>=gcd
   if { not HasEquippedItem(137075) or SpellCooldown(dark_transformation) < 10 } and TimeToRunes(4) >= GCD() Spell(summon_gargoyle)

   unless { target.DebuffStacks(festering_wound_debuff) >= 6 and SpellCooldown(apocalypse) <= GCD() or target.DebuffStacks(festering_wound_debuff) >= 3 and Rune() >= 3 and SpellCooldown(apocalypse) > 20 } and Spell(soul_reaper_unholy)
   {
    #call_action_list,name=dt,if=cooldown.dark_transformation.ready
    if SpellCooldown(dark_transformation) == 0 UnholyDtCdActions()
   }
  }
 }
}

AddFunction UnholyCooldownsCdPostConditions
{
 HasEquippedItem(cold_heart) and BuffStacks(cold_heart_buff) > 10 and not target.DebuffPresent(soul_reaper_unholy_debuff) and UnholyColdHeartCdPostConditions() or target.DebuffStacks(festering_wound_debuff) >= 6 and Spell(apocalypse) or { target.DebuffStacks(festering_wound_debuff) >= 6 and SpellCooldown(apocalypse) <= GCD() or target.DebuffStacks(festering_wound_debuff) >= 3 and Rune() >= 3 and SpellCooldown(apocalypse) > 20 } and Spell(soul_reaper_unholy) or SpellCooldown(dark_transformation) == 0 and UnholyDtCdPostConditions()
}

### actions.dt

AddFunction UnholyDtMainActions
{
}

AddFunction UnholyDtMainPostConditions
{
}

AddFunction UnholyDtShortCdActions
{
 #dark_transformation,if=equipped.137075&talent.dark_arbiter.enabled&(talent.shadow_infusion.enabled|cooldown.dark_arbiter.remains>52)&cooldown.dark_arbiter.remains>30&!equipped.140806
 if HasEquippedItem(137075) and Talent(dark_arbiter_talent) and { Talent(shadow_infusion_talent) or SpellCooldown(dark_arbiter) > 52 } and SpellCooldown(dark_arbiter) > 30 and not HasEquippedItem(140806) Spell(dark_transformation)
 #dark_transformation,if=equipped.137075&(talent.shadow_infusion.enabled|cooldown.dark_arbiter.remains>(52*1.333))&equipped.140806&cooldown.dark_arbiter.remains>(30*1.333)
 if HasEquippedItem(137075) and { Talent(shadow_infusion_talent) or SpellCooldown(dark_arbiter) > 52 * 1.333 } and HasEquippedItem(140806) and SpellCooldown(dark_arbiter) > 30 * 1.333 Spell(dark_transformation)
 #dark_transformation,if=equipped.137075&target.time_to_die<cooldown.dark_arbiter.remains-8
 if HasEquippedItem(137075) and target.TimeToDie() < SpellCooldown(dark_arbiter) - 8 Spell(dark_transformation)
 #dark_transformation,if=equipped.137075&(talent.shadow_infusion.enabled|cooldown.summon_gargoyle.remains>55)&cooldown.summon_gargoyle.remains>35
 if HasEquippedItem(137075) and { Talent(shadow_infusion_talent) or SpellCooldown(summon_gargoyle) > 55 } and SpellCooldown(summon_gargoyle) > 35 Spell(dark_transformation)
 #dark_transformation,if=equipped.137075&target.time_to_die<cooldown.summon_gargoyle.remains-8
 if HasEquippedItem(137075) and target.TimeToDie() < SpellCooldown(summon_gargoyle) - 8 Spell(dark_transformation)
 #dark_transformation,if=!equipped.137075&rune.time_to_4>=gcd
 if not HasEquippedItem(137075) and TimeToRunes(4) >= GCD() Spell(dark_transformation)
}

AddFunction UnholyDtShortCdPostConditions
{
}

AddFunction UnholyDtCdActions
{
}

AddFunction UnholyDtCdPostConditions
{
 HasEquippedItem(137075) and Talent(dark_arbiter_talent) and { Talent(shadow_infusion_talent) or SpellCooldown(dark_arbiter) > 52 } and SpellCooldown(dark_arbiter) > 30 and not HasEquippedItem(140806) and Spell(dark_transformation) or HasEquippedItem(137075) and { Talent(shadow_infusion_talent) or SpellCooldown(dark_arbiter) > 52 * 1.333 } and HasEquippedItem(140806) and SpellCooldown(dark_arbiter) > 30 * 1.333 and Spell(dark_transformation) or HasEquippedItem(137075) and target.TimeToDie() < SpellCooldown(dark_arbiter) - 8 and Spell(dark_transformation) or HasEquippedItem(137075) and { Talent(shadow_infusion_talent) or SpellCooldown(summon_gargoyle) > 55 } and SpellCooldown(summon_gargoyle) > 35 and Spell(dark_transformation) or HasEquippedItem(137075) and target.TimeToDie() < SpellCooldown(summon_gargoyle) - 8 and Spell(dark_transformation) or not HasEquippedItem(137075) and TimeToRunes(4) >= GCD() and Spell(dark_transformation)
}

### actions.generic

AddFunction UnholyGenericMainActions
{
 #scourge_strike,if=debuff.soul_reaper.up&debuff.festering_wound.up
 if target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffPresent(festering_wound_debuff) Spell(scourge_strike)
 #clawing_shadows,if=debuff.soul_reaper.up&debuff.festering_wound.up
 if target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffPresent(festering_wound_debuff) Spell(clawing_shadows)
 #death_coil,if=runic_power.deficit<22&(talent.shadow_infusion.enabled|(!talent.dark_arbiter.enabled|cooldown.dark_arbiter.remains>5))
 if RunicPowerDeficit() < 22 and { Talent(shadow_infusion_talent) or not Talent(dark_arbiter_talent) or SpellCooldown(dark_arbiter) > 5 } Spell(death_coil)
 #death_coil,if=!buff.necrosis.up&buff.sudden_doom.react&((!talent.dark_arbiter.enabled&rune<=3)|cooldown.dark_arbiter.remains>5)
 if not BuffPresent(necrosis_buff) and BuffPresent(sudden_doom_buff) and { not Talent(dark_arbiter_talent) and Rune() < 4 or SpellCooldown(dark_arbiter) > 5 } Spell(death_coil)
 #festering_strike,if=debuff.festering_wound.stack<6&cooldown.apocalypse.remains<=6
 if target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) <= 6 Spell(festering_strike)
 #call_action_list,name=aoe,if=active_enemies>=2
 if Enemies(tagged=1) >= 2 UnholyAoeMainActions()

 unless Enemies(tagged=1) >= 2 and UnholyAoeMainPostConditions()
 {
  #festering_strike,if=(buff.blighted_rune_weapon.stack*2+debuff.festering_wound.stack)<=2|((buff.blighted_rune_weapon.stack*2+debuff.festering_wound.stack)<=4&talent.castigator.enabled)&(cooldown.army_of_the_dead.remains>5|rune.time_to_4<=gcd)
  if BuffStacks(blighted_rune_weapon_buff) * 2 + target.DebuffStacks(festering_wound_debuff) <= 2 or BuffStacks(blighted_rune_weapon_buff) * 2 + target.DebuffStacks(festering_wound_debuff) <= 4 and Talent(castigator_talent) and { SpellCooldown(army_of_the_dead) > 5 or TimeToRunes(4) <= GCD() } Spell(festering_strike)
  #death_coil,if=!buff.necrosis.up&talent.necrosis.enabled&rune.time_to_4>=gcd
  if not BuffPresent(necrosis_buff) and Talent(necrosis_talent) and TimeToRunes(4) >= GCD() Spell(death_coil)
  #scourge_strike,if=(buff.necrosis.up|buff.unholy_strength.react|rune>=2)&debuff.festering_wound.stack>=1&(debuff.festering_wound.stack>=3|!(talent.castigator.enabled|equipped.132448))&(cooldown.army_of_the_dead.remains>5|rune.time_to_4<=gcd)
  if { BuffPresent(necrosis_buff) or BuffPresent(unholy_strength_buff) or Rune() >= 2 } and target.DebuffStacks(festering_wound_debuff) >= 1 and { target.DebuffStacks(festering_wound_debuff) >= 3 or not { Talent(castigator_talent) or HasEquippedItem(132448) } } and { SpellCooldown(army_of_the_dead) > 5 or TimeToRunes(4) <= GCD() } Spell(scourge_strike)
  #clawing_shadows,if=(buff.necrosis.up|buff.unholy_strength.react|rune>=2)&debuff.festering_wound.stack>=1&(debuff.festering_wound.stack>=3|!equipped.132448)&(cooldown.army_of_the_dead.remains>5|rune.time_to_4<=gcd)
  if { BuffPresent(necrosis_buff) or BuffPresent(unholy_strength_buff) or Rune() >= 2 } and target.DebuffStacks(festering_wound_debuff) >= 1 and { target.DebuffStacks(festering_wound_debuff) >= 3 or not HasEquippedItem(132448) } and { SpellCooldown(army_of_the_dead) > 5 or TimeToRunes(4) <= GCD() } Spell(clawing_shadows)
  #death_coil,if=(talent.dark_arbiter.enabled&cooldown.dark_arbiter.remains>10)|!talent.dark_arbiter.enabled
  if Talent(dark_arbiter_talent) and SpellCooldown(dark_arbiter) > 10 or not Talent(dark_arbiter_talent) Spell(death_coil)
 }
}

AddFunction UnholyGenericMainPostConditions
{
 Enemies(tagged=1) >= 2 and UnholyAoeMainPostConditions()
}

AddFunction UnholyGenericShortCdActions
{
 unless target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffPresent(festering_wound_debuff) and Spell(scourge_strike) or target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffPresent(festering_wound_debuff) and Spell(clawing_shadows) or RunicPowerDeficit() < 22 and { Talent(shadow_infusion_talent) or not Talent(dark_arbiter_talent) or SpellCooldown(dark_arbiter) > 5 } and Spell(death_coil) or not BuffPresent(necrosis_buff) and BuffPresent(sudden_doom_buff) and { not Talent(dark_arbiter_talent) and Rune() < 4 or SpellCooldown(dark_arbiter) > 5 } and Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) <= 6 and Spell(festering_strike)
 {
  #defile
  Spell(defile)
  #call_action_list,name=aoe,if=active_enemies>=2
  if Enemies(tagged=1) >= 2 UnholyAoeShortCdActions()
 }
}

AddFunction UnholyGenericShortCdPostConditions
{
 target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffPresent(festering_wound_debuff) and Spell(scourge_strike) or target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffPresent(festering_wound_debuff) and Spell(clawing_shadows) or RunicPowerDeficit() < 22 and { Talent(shadow_infusion_talent) or not Talent(dark_arbiter_talent) or SpellCooldown(dark_arbiter) > 5 } and Spell(death_coil) or not BuffPresent(necrosis_buff) and BuffPresent(sudden_doom_buff) and { not Talent(dark_arbiter_talent) and Rune() < 4 or SpellCooldown(dark_arbiter) > 5 } and Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) <= 6 and Spell(festering_strike) or Enemies(tagged=1) >= 2 and UnholyAoeShortCdPostConditions() or { BuffStacks(blighted_rune_weapon_buff) * 2 + target.DebuffStacks(festering_wound_debuff) <= 2 or BuffStacks(blighted_rune_weapon_buff) * 2 + target.DebuffStacks(festering_wound_debuff) <= 4 and Talent(castigator_talent) and { SpellCooldown(army_of_the_dead) > 5 or TimeToRunes(4) <= GCD() } } and Spell(festering_strike) or not BuffPresent(necrosis_buff) and Talent(necrosis_talent) and TimeToRunes(4) >= GCD() and Spell(death_coil) or { BuffPresent(necrosis_buff) or BuffPresent(unholy_strength_buff) or Rune() >= 2 } and target.DebuffStacks(festering_wound_debuff) >= 1 and { target.DebuffStacks(festering_wound_debuff) >= 3 or not { Talent(castigator_talent) or HasEquippedItem(132448) } } and { SpellCooldown(army_of_the_dead) > 5 or TimeToRunes(4) <= GCD() } and Spell(scourge_strike) or { BuffPresent(necrosis_buff) or BuffPresent(unholy_strength_buff) or Rune() >= 2 } and target.DebuffStacks(festering_wound_debuff) >= 1 and { target.DebuffStacks(festering_wound_debuff) >= 3 or not HasEquippedItem(132448) } and { SpellCooldown(army_of_the_dead) > 5 or TimeToRunes(4) <= GCD() } and Spell(clawing_shadows) or { Talent(dark_arbiter_talent) and SpellCooldown(dark_arbiter) > 10 or not Talent(dark_arbiter_talent) } and Spell(death_coil)
}

AddFunction UnholyGenericCdActions
{
 unless target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffPresent(festering_wound_debuff) and Spell(scourge_strike) or target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffPresent(festering_wound_debuff) and Spell(clawing_shadows) or RunicPowerDeficit() < 22 and { Talent(shadow_infusion_talent) or not Talent(dark_arbiter_talent) or SpellCooldown(dark_arbiter) > 5 } and Spell(death_coil) or not BuffPresent(necrosis_buff) and BuffPresent(sudden_doom_buff) and { not Talent(dark_arbiter_talent) and Rune() < 4 or SpellCooldown(dark_arbiter) > 5 } and Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) <= 6 and Spell(festering_strike) or Spell(defile)
 {
  #call_action_list,name=aoe,if=active_enemies>=2
  if Enemies(tagged=1) >= 2 UnholyAoeCdActions()
 }
}

AddFunction UnholyGenericCdPostConditions
{
 target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffPresent(festering_wound_debuff) and Spell(scourge_strike) or target.DebuffPresent(soul_reaper_unholy_debuff) and target.DebuffPresent(festering_wound_debuff) and Spell(clawing_shadows) or RunicPowerDeficit() < 22 and { Talent(shadow_infusion_talent) or not Talent(dark_arbiter_talent) or SpellCooldown(dark_arbiter) > 5 } and Spell(death_coil) or not BuffPresent(necrosis_buff) and BuffPresent(sudden_doom_buff) and { not Talent(dark_arbiter_talent) and Rune() < 4 or SpellCooldown(dark_arbiter) > 5 } and Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) <= 6 and Spell(festering_strike) or Spell(defile) or Enemies(tagged=1) >= 2 and UnholyAoeCdPostConditions() or { BuffStacks(blighted_rune_weapon_buff) * 2 + target.DebuffStacks(festering_wound_debuff) <= 2 or BuffStacks(blighted_rune_weapon_buff) * 2 + target.DebuffStacks(festering_wound_debuff) <= 4 and Talent(castigator_talent) and { SpellCooldown(army_of_the_dead) > 5 or TimeToRunes(4) <= GCD() } } and Spell(festering_strike) or not BuffPresent(necrosis_buff) and Talent(necrosis_talent) and TimeToRunes(4) >= GCD() and Spell(death_coil) or { BuffPresent(necrosis_buff) or BuffPresent(unholy_strength_buff) or Rune() >= 2 } and target.DebuffStacks(festering_wound_debuff) >= 1 and { target.DebuffStacks(festering_wound_debuff) >= 3 or not { Talent(castigator_talent) or HasEquippedItem(132448) } } and { SpellCooldown(army_of_the_dead) > 5 or TimeToRunes(4) <= GCD() } and Spell(scourge_strike) or { BuffPresent(necrosis_buff) or BuffPresent(unholy_strength_buff) or Rune() >= 2 } and target.DebuffStacks(festering_wound_debuff) >= 1 and { target.DebuffStacks(festering_wound_debuff) >= 3 or not HasEquippedItem(132448) } and { SpellCooldown(army_of_the_dead) > 5 or TimeToRunes(4) <= GCD() } and Spell(clawing_shadows) or { Talent(dark_arbiter_talent) and SpellCooldown(dark_arbiter) > 10 or not Talent(dark_arbiter_talent) } and Spell(death_coil)
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
 #blighted_rune_weapon
 Spell(blighted_rune_weapon)
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
 if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)

 unless Spell(raise_dead)
 {
  #army_of_the_dead
  Spell(army_of_the_dead)
 }
}

AddFunction UnholyPrecombatCdPostConditions
{
 Spell(raise_dead) or Spell(blighted_rune_weapon)
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
 unless Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) < 3 and Spell(festering_strike)
 {
  #call_action_list,name=aoe,if=active_enemies>=2
  if Enemies(tagged=1) >= 2 UnholyAoeShortCdActions()
 }
}

AddFunction UnholyValkyrShortCdPostConditions
{
 Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) < 3 and Spell(festering_strike) or Enemies(tagged=1) >= 2 and UnholyAoeShortCdPostConditions() or target.DebuffStacks(festering_wound_debuff) <= 4 and Spell(festering_strike) or target.DebuffPresent(festering_wound_debuff) and Spell(scourge_strike) or target.DebuffPresent(festering_wound_debuff) and Spell(clawing_shadows)
}

AddFunction UnholyValkyrCdActions
{
 unless Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) < 3 and Spell(festering_strike)
 {
  #call_action_list,name=aoe,if=active_enemies>=2
  if Enemies(tagged=1) >= 2 UnholyAoeCdActions()
 }
}

AddFunction UnholyValkyrCdPostConditions
{
 Spell(death_coil) or target.DebuffStacks(festering_wound_debuff) < 6 and SpellCooldown(apocalypse) < 3 and Spell(festering_strike) or Enemies(tagged=1) >= 2 and UnholyAoeCdPostConditions() or target.DebuffStacks(festering_wound_debuff) <= 4 and Spell(festering_strike) or target.DebuffPresent(festering_wound_debuff) and Spell(scourge_strike) or target.DebuffPresent(festering_wound_debuff) and Spell(clawing_shadows)
}
]]

	OvaleScripts:RegisterScript("DEATHKNIGHT", nill, name, desc, code, "include")
end
