local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_unholy_functions"
	local desc = "[Xel][7.3.5] Death Knight: Unholy Functions"
	local code = [[
AddFunction pooling_for_gargoyle
{
 SpellCooldown(summon_gargoyle) < 5 and { SpellCooldown(dark_transformation) < 5 or not HasEquippedItem(137075) } and Talent(summon_gargoyle_talent)
}

### actions.default

AddFunction UnholyDefaultMainActions
{
 #variable,name=pooling_for_gargoyle,value=(cooldown.summon_gargoyle.remains<5&(cooldown.dark_transformation.remains<5|!equipped.137075))&talent.summon_gargoyle.enabled
 #arcane_torrent,if=runic_power.deficit>65&(pet.gargoyle.active|!talent.summon_gargoyle.enabled)&rune.deficit>=5
 if RunicPowerDeficit() > 65 and { pet.Present() or not Talent(summon_gargoyle_talent) } and 6 - Rune() >= 5 Spell(arcane_torrent_runicpower)
 #blood_fury,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
 if pet.Present() or not Talent(summon_gargoyle_talent) Spell(blood_fury_ap)
 #berserking,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
 if pet.Present() or not Talent(summon_gargoyle_talent) Spell(berserking)
 #potion,if=cooldown.army_of_the_dead.ready|pet.gargoyle.active|buff.unholy_frenzy.up
 # if { SpellCooldown(army_of_the_dead) == 0 or pet.Present() or BuffPresent(unholy_frenzy_buff) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
 #outbreak,target_if=(dot.virulent_plague.tick_time_remains+tick_time<=dot.virulent_plague.remains)&dot.virulent_plague.remains<=gcd
 if target.TickTimeRemaining(virulent_plague_debuff) + target.TickTime(virulent_plague_debuff) <= target.DebuffRemaining(virulent_plague_debuff) and target.DebuffRemaining(virulent_plague_debuff) <= GCD() Spell(outbreak)
 #call_action_list,name=cooldowns
 UnholyCooldownsMainActions()

 unless UnholyCooldownsMainPostConditions()
 {
  #call_action_list,name=aoe,if=active_enemies>=2
  if Enemies(tagged=1) >= 2 UnholyAoeMainActions()

  unless Enemies(tagged=1) >= 2 and UnholyAoeMainPostConditions()
  {
   #call_action_list,name=generic
   UnholyGenericMainActions()
  }
 }
}

AddFunction UnholyDefaultMainPostConditions
{
 UnholyCooldownsMainPostConditions() or Enemies(tagged=1) >= 2 and UnholyAoeMainPostConditions() or UnholyGenericMainPostConditions()
}

AddFunction UnholyDefaultShortCdActions
{
 #auto_attack
 # UnholyGetInMeleeRange()

 unless RunicPowerDeficit() > 65 and { pet.Present() or not Talent(summon_gargoyle_talent) } and 6 - Rune() >= 5 and Spell(arcane_torrent_runicpower) or { pet.Present() or not Talent(summon_gargoyle_talent) } and Spell(blood_fury_ap) or { pet.Present() or not Talent(summon_gargoyle_talent) } and Spell(berserking) or { SpellCooldown(army_of_the_dead) == 0 or pet.Present() or BuffPresent(unholy_frenzy_buff) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(prolonged_power_potion usable=1) or target.TickTimeRemaining(virulent_plague_debuff) + target.TickTime(virulent_plague_debuff) <= target.DebuffRemaining(virulent_plague_debuff) and target.DebuffRemaining(virulent_plague_debuff) <= GCD() and Spell(outbreak)
 {
  #call_action_list,name=cooldowns
  UnholyCooldownsShortCdActions()

  unless UnholyCooldownsShortCdPostConditions()
  {
   #call_action_list,name=aoe,if=active_enemies>=2
   if Enemies(tagged=1) >= 2 UnholyAoeShortCdActions()

   unless Enemies(tagged=1) >= 2 and UnholyAoeShortCdPostConditions()
   {
    #call_action_list,name=generic
    UnholyGenericShortCdActions()
   }
  }
 }
}

AddFunction UnholyDefaultShortCdPostConditions
{
 RunicPowerDeficit() > 65 and { pet.Present() or not Talent(summon_gargoyle_talent) } and 6 - Rune() >= 5 and Spell(arcane_torrent_runicpower) or { pet.Present() or not Talent(summon_gargoyle_talent) } and Spell(blood_fury_ap) or { pet.Present() or not Talent(summon_gargoyle_talent) } and Spell(berserking) or { SpellCooldown(army_of_the_dead) == 0 or pet.Present() or BuffPresent(unholy_frenzy_buff) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(prolonged_power_potion usable=1) or target.TickTimeRemaining(virulent_plague_debuff) + target.TickTime(virulent_plague_debuff) <= target.DebuffRemaining(virulent_plague_debuff) and target.DebuffRemaining(virulent_plague_debuff) <= GCD() and Spell(outbreak) or UnholyCooldownsShortCdPostConditions() or Enemies(tagged=1) >= 2 and UnholyAoeShortCdPostConditions() or UnholyGenericShortCdPostConditions()
}

AddFunction UnholyDefaultCdActions
{
 #mind_freeze
 # UnholyInterruptActions()

 unless RunicPowerDeficit() > 65 and { pet.Present() or not Talent(summon_gargoyle_talent) } and 6 - Rune() >= 5 and Spell(arcane_torrent_runicpower) or { pet.Present() or not Talent(summon_gargoyle_talent) } and Spell(blood_fury_ap) or { pet.Present() or not Talent(summon_gargoyle_talent) } and Spell(berserking)
 {
  #use_items
  # UnholyUseItemActions()
  #use_item,name=feloiled_infernal_machine,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
  # if pet.Present() or not Talent(summon_gargoyle_talent) UnholyUseItemActions()
  #use_item,name=ring_of_collapsing_futures,if=(buff.temptation.stack=0&target.time_to_die>60)|target.time_to_die<60
  # if BuffStacks(temptation_buff) == 0 and target.TimeToDie() > 60 or target.TimeToDie() < 60 UnholyUseItemActions()

  unless { SpellCooldown(army_of_the_dead) == 0 or pet.Present() or BuffPresent(unholy_frenzy_buff) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(prolonged_power_potion usable=1) or target.TickTimeRemaining(virulent_plague_debuff) + target.TickTime(virulent_plague_debuff) <= target.DebuffRemaining(virulent_plague_debuff) and target.DebuffRemaining(virulent_plague_debuff) <= GCD() and Spell(outbreak)
  {
   #call_action_list,name=cooldowns
   UnholyCooldownsCdActions()

   unless UnholyCooldownsCdPostConditions()
   {
    #call_action_list,name=aoe,if=active_enemies>=2
    if Enemies(tagged=1) >= 2 UnholyAoeCdActions()

    unless Enemies(tagged=1) >= 2 and UnholyAoeCdPostConditions()
    {
     #call_action_list,name=generic
     UnholyGenericCdActions()
    }
   }
  }
 }
}

AddFunction UnholyDefaultCdPostConditions
{
 RunicPowerDeficit() > 65 and { pet.Present() or not Talent(summon_gargoyle_talent) } and 6 - Rune() >= 5 and Spell(arcane_torrent_runicpower) or { pet.Present() or not Talent(summon_gargoyle_talent) } and Spell(blood_fury_ap) or { pet.Present() or not Talent(summon_gargoyle_talent) } and Spell(berserking) or { SpellCooldown(army_of_the_dead) == 0 or pet.Present() or BuffPresent(unholy_frenzy_buff) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(prolonged_power_potion usable=1) or target.TickTimeRemaining(virulent_plague_debuff) + target.TickTime(virulent_plague_debuff) <= target.DebuffRemaining(virulent_plague_debuff) and target.DebuffRemaining(virulent_plague_debuff) <= GCD() and Spell(outbreak) or UnholyCooldownsCdPostConditions() or Enemies(tagged=1) >= 2 and UnholyAoeCdPostConditions() or UnholyGenericCdPostConditions()
}

### actions.aoe

AddFunction UnholyAoeMainActions
{
 #death_and_decay,if=cooldown.apocalypse.remains
 if SpellCooldown(apocalypse) > 0 Spell(death_and_decay)
 #defile
 Spell(defile)
 #epidemic,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
 if BuffPresent(death_and_decay_buff) and Rune() < 2 and not pooling_for_gargoyle() Spell(epidemic)
 #death_coil,if=death_and_decay.ticking&rune<2&!talent.epidemic.enabled&!variable.pooling_for_gargoyle
 if BuffPresent(death_and_decay_buff) and Rune() < 2 and not Talent(epidemic_talent) and not pooling_for_gargoyle() Spell(death_coil)
 #scourge_strike,if=death_and_decay.ticking&cooldown.apocalypse.remains
 if BuffPresent(death_and_decay_buff) and SpellCooldown(apocalypse) > 0 Spell(scourge_strike)
 #clawing_shadows,if=death_and_decay.ticking&cooldown.apocalypse.remains
 if BuffPresent(death_and_decay_buff) and SpellCooldown(apocalypse) > 0 Spell(clawing_shadows)
 #epidemic,if=!variable.pooling_for_gargoyle
 if not pooling_for_gargoyle() Spell(epidemic)
 #festering_strike,if=talent.bursting_sores.enabled&spell_targets.bursting_sores>=2&debuff.festering_wound.stack<=1
 if Talent(bursting_sores_talent) and Enemies() >= 2 and target.DebuffStacks(festering_wound_debuff) <= 1 Spell(festering_strike)
 #death_coil,if=buff.sudden_doom.react&rune.deficit>=4
 if BuffPresent(sudden_doom_buff) and 6 - Rune() >= 4 Spell(death_coil)
}

AddFunction UnholyAoeMainPostConditions
{
}

AddFunction UnholyAoeShortCdActions
{
}

AddFunction UnholyAoeShortCdPostConditions
{
 SpellCooldown(apocalypse) > 0 and Spell(death_and_decay) or Spell(defile) or BuffPresent(death_and_decay_buff) and Rune() < 2 and not pooling_for_gargoyle() and Spell(epidemic) or BuffPresent(death_and_decay_buff) and Rune() < 2 and not Talent(epidemic_talent) and not pooling_for_gargoyle() and Spell(death_coil) or BuffPresent(death_and_decay_buff) and SpellCooldown(apocalypse) > 0 and Spell(scourge_strike) or BuffPresent(death_and_decay_buff) and SpellCooldown(apocalypse) > 0 and Spell(clawing_shadows) or not pooling_for_gargoyle() and Spell(epidemic) or Talent(bursting_sores_talent) and Enemies() >= 2 and target.DebuffStacks(festering_wound_debuff) <= 1 and Spell(festering_strike) or BuffPresent(sudden_doom_buff) and 6 - Rune() >= 4 and Spell(death_coil)
}

AddFunction UnholyAoeCdActions
{
}

AddFunction UnholyAoeCdPostConditions
{
 SpellCooldown(apocalypse) > 0 and Spell(death_and_decay) or Spell(defile) or BuffPresent(death_and_decay_buff) and Rune() < 2 and not pooling_for_gargoyle() and Spell(epidemic) or BuffPresent(death_and_decay_buff) and Rune() < 2 and not Talent(epidemic_talent) and not pooling_for_gargoyle() and Spell(death_coil) or BuffPresent(death_and_decay_buff) and SpellCooldown(apocalypse) > 0 and Spell(scourge_strike) or BuffPresent(death_and_decay_buff) and SpellCooldown(apocalypse) > 0 and Spell(clawing_shadows) or not pooling_for_gargoyle() and Spell(epidemic) or Talent(bursting_sores_talent) and Enemies() >= 2 and target.DebuffStacks(festering_wound_debuff) <= 1 and Spell(festering_strike) or BuffPresent(sudden_doom_buff) and 6 - Rune() >= 4 and Spell(death_coil)
}

### actions.cold_heart

AddFunction UnholyColdHeartMainActions
{
 #chains_of_ice,if=buff.unholy_strength.remains<gcd&buff.unholy_strength.react&buff.cold_heart_item.stack>16
 if BuffRemaining(unholy_strength_buff) < GCD() and BuffPresent(unholy_strength_buff) and BuffStacks(cold_heart_item_buff) > 16 Spell(chains_of_ice)
 #chains_of_ice,if=buff.master_of_ghouls.remains<gcd&buff.master_of_ghouls.up&buff.cold_heart_item.stack>17
 if BuffRemaining(master_of_ghouls_buff) < GCD() and BuffPresent(master_of_ghouls_buff) and BuffStacks(cold_heart_item_buff) > 17 Spell(chains_of_ice)
 #chains_of_ice,if=buff.cold_heart_item.stack=20&buff.unholy_strength.react
 if BuffStacks(cold_heart_item_buff) == 20 and BuffPresent(unholy_strength_buff) Spell(chains_of_ice)
}

AddFunction UnholyColdHeartMainPostConditions
{
}

AddFunction UnholyColdHeartShortCdActions
{
}

AddFunction UnholyColdHeartShortCdPostConditions
{
 BuffRemaining(unholy_strength_buff) < GCD() and BuffPresent(unholy_strength_buff) and BuffStacks(cold_heart_item_buff) > 16 and Spell(chains_of_ice) or BuffRemaining(master_of_ghouls_buff) < GCD() and BuffPresent(master_of_ghouls_buff) and BuffStacks(cold_heart_item_buff) > 17 and Spell(chains_of_ice) or BuffStacks(cold_heart_item_buff) == 20 and BuffPresent(unholy_strength_buff) and Spell(chains_of_ice)
}

AddFunction UnholyColdHeartCdActions
{
}

AddFunction UnholyColdHeartCdPostConditions
{
 BuffRemaining(unholy_strength_buff) < GCD() and BuffPresent(unholy_strength_buff) and BuffStacks(cold_heart_item_buff) > 16 and Spell(chains_of_ice) or BuffRemaining(master_of_ghouls_buff) < GCD() and BuffPresent(master_of_ghouls_buff) and BuffStacks(cold_heart_item_buff) > 17 and Spell(chains_of_ice) or BuffStacks(cold_heart_item_buff) == 20 and BuffPresent(unholy_strength_buff) and Spell(chains_of_ice)
}

### actions.cooldowns

AddFunction UnholyCooldownsMainActions
{
 #call_action_list,name=cold_heart,if=equipped.cold_heart&buff.cold_heart_item.stack>10
 if HasEquippedItem(cold_heart) and BuffStacks(cold_heart_item_buff) > 10 UnholyColdHeartMainActions()

 unless HasEquippedItem(cold_heart) and BuffStacks(cold_heart_item_buff) > 10 and UnholyColdHeartMainPostConditions()
 {
  #army_of_the_dead
  Spell(army_of_the_dead)
  #apocalypse,if=debuff.festering_wound.stack>=4
  if target.DebuffStacks(festering_wound_debuff) >= 4 Spell(apocalypse)
  #dark_transformation,if=(equipped.137075&cooldown.summon_gargoyle.remains>40)|(!equipped.137075|!talent.summon_gargoyle.enabled)
  if HasEquippedItem(137075) and SpellCooldown(summon_gargoyle) > 40 or not HasEquippedItem(137075) or not Talent(summon_gargoyle_talent) Spell(dark_transformation)
  #summon_gargoyle,if=runic_power.deficit<14
  if RunicPowerDeficit() < 14 Spell(summon_gargoyle)
  #unholy_frenzy,if=debuff.festering_wound.stack<4
  if target.DebuffStacks(festering_wound_debuff) < 4 Spell(unholy_frenzy)
  #unholy_frenzy,if=active_enemies>=2&((cooldown.death_and_decay.remains<=gcd&!talent.defile.enabled)|(cooldown.defile.remains<=gcd&talent.defile.enabled))
  if Enemies(tagged=1) >= 2 and { SpellCooldown(death_and_decay) <= GCD() and not Talent(defile_talent) or SpellCooldown(defile) <= GCD() and Talent(defile_talent) } Spell(unholy_frenzy)
  #soul_reaper,target_if=(target.time_to_die<8|rune<=2)&!buff.unholy_frenzy.up
  if { target.TimeToDie() < 8 or Rune() < 3 } and not BuffPresent(unholy_frenzy_buff) Spell(soul_reaper_unholy)
  #unholy_blight
  Spell(unholy_blight)
 }
}

AddFunction UnholyCooldownsMainPostConditions
{
 HasEquippedItem(cold_heart) and BuffStacks(cold_heart_item_buff) > 10 and UnholyColdHeartMainPostConditions()
}

AddFunction UnholyCooldownsShortCdActions
{
 #call_action_list,name=cold_heart,if=equipped.cold_heart&buff.cold_heart_item.stack>10
 if HasEquippedItem(cold_heart) and BuffStacks(cold_heart_item_buff) > 10 UnholyColdHeartShortCdActions()
}

AddFunction UnholyCooldownsShortCdPostConditions
{
 HasEquippedItem(cold_heart) and BuffStacks(cold_heart_item_buff) > 10 and UnholyColdHeartShortCdPostConditions() or Spell(army_of_the_dead) or target.DebuffStacks(festering_wound_debuff) >= 4 and Spell(apocalypse) or { HasEquippedItem(137075) and SpellCooldown(summon_gargoyle) > 40 or not HasEquippedItem(137075) or not Talent(summon_gargoyle_talent) } and Spell(dark_transformation) or RunicPowerDeficit() < 14 and Spell(summon_gargoyle) or target.DebuffStacks(festering_wound_debuff) < 4 and Spell(unholy_frenzy) or Enemies(tagged=1) >= 2 and { SpellCooldown(death_and_decay) <= GCD() and not Talent(defile_talent) or SpellCooldown(defile) <= GCD() and Talent(defile_talent) } and Spell(unholy_frenzy) or { target.TimeToDie() < 8 or Rune() < 3 } and not BuffPresent(unholy_frenzy_buff) and Spell(soul_reaper_unholy) or Spell(unholy_blight)
}

AddFunction UnholyCooldownsCdActions
{
 #call_action_list,name=cold_heart,if=equipped.cold_heart&buff.cold_heart_item.stack>10
 if HasEquippedItem(cold_heart) and BuffStacks(cold_heart_item_buff) > 10 UnholyColdHeartCdActions()
}

AddFunction UnholyCooldownsCdPostConditions
{
 HasEquippedItem(cold_heart) and BuffStacks(cold_heart_item_buff) > 10 and UnholyColdHeartCdPostConditions() or Spell(army_of_the_dead) or target.DebuffStacks(festering_wound_debuff) >= 4 and Spell(apocalypse) or { HasEquippedItem(137075) and SpellCooldown(summon_gargoyle) > 40 or not HasEquippedItem(137075) or not Talent(summon_gargoyle_talent) } and Spell(dark_transformation) or RunicPowerDeficit() < 14 and Spell(summon_gargoyle) or target.DebuffStacks(festering_wound_debuff) < 4 and Spell(unholy_frenzy) or Enemies(tagged=1) >= 2 and { SpellCooldown(death_and_decay) <= GCD() and not Talent(defile_talent) or SpellCooldown(defile) <= GCD() and Talent(defile_talent) } and Spell(unholy_frenzy) or { target.TimeToDie() < 8 or Rune() < 3 } and not BuffPresent(unholy_frenzy_buff) and Spell(soul_reaper_unholy) or Spell(unholy_blight)
}

### actions.generic

AddFunction UnholyGenericMainActions
{
 #death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
 if BuffPresent(sudden_doom_buff) and not pooling_for_gargoyle() or pet.Present() Spell(death_coil)
 #death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
 if RunicPowerDeficit() < 14 and { SpellCooldown(apocalypse) > 5 or target.DebuffStacks(festering_wound_debuff) > 4 } and not pooling_for_gargoyle() Spell(death_coil)
 #death_and_decay,if=talent.pestilence.enabled&cooldown.apocalypse.remains
 if Talent(pestilence_talent) and SpellCooldown(apocalypse) > 0 Spell(death_and_decay)
 #defile,if=cooldown.apocalypse.remains
 if SpellCooldown(apocalypse) > 0 Spell(defile)
 #scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
 if { target.DebuffPresent(festering_wound_debuff) and SpellCooldown(apocalypse) > 5 or target.DebuffStacks(festering_wound_debuff) > 4 } and SpellCooldown(army_of_the_dead) > 5 Spell(scourge_strike)
 #clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
 if { target.DebuffPresent(festering_wound_debuff) and SpellCooldown(apocalypse) > 5 or target.DebuffStacks(festering_wound_debuff) > 4 } and SpellCooldown(army_of_the_dead) > 5 Spell(clawing_shadows)
 #death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
 if RunicPowerDeficit() < 20 and not pooling_for_gargoyle() Spell(death_coil)
 #festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
 if { { target.DebuffStacks(festering_wound_debuff) < 4 and not BuffPresent(unholy_frenzy_buff) or target.DebuffStacks(festering_wound_debuff) < 3 } and SpellCooldown(apocalypse) < 3 or target.DebuffStacks(festering_wound_debuff) < 1 } and SpellCooldown(army_of_the_dead) > 5 Spell(festering_strike)
 #death_coil,if=!variable.pooling_for_gargoyle
 if not pooling_for_gargoyle() Spell(death_coil)
}

AddFunction UnholyGenericMainPostConditions
{
}

AddFunction UnholyGenericShortCdActions
{
}

AddFunction UnholyGenericShortCdPostConditions
{
 { BuffPresent(sudden_doom_buff) and not pooling_for_gargoyle() or pet.Present() } and Spell(death_coil) or RunicPowerDeficit() < 14 and { SpellCooldown(apocalypse) > 5 or target.DebuffStacks(festering_wound_debuff) > 4 } and not pooling_for_gargoyle() and Spell(death_coil) or Talent(pestilence_talent) and SpellCooldown(apocalypse) > 0 and Spell(death_and_decay) or SpellCooldown(apocalypse) > 0 and Spell(defile) or { target.DebuffPresent(festering_wound_debuff) and SpellCooldown(apocalypse) > 5 or target.DebuffStacks(festering_wound_debuff) > 4 } and SpellCooldown(army_of_the_dead) > 5 and Spell(scourge_strike) or { target.DebuffPresent(festering_wound_debuff) and SpellCooldown(apocalypse) > 5 or target.DebuffStacks(festering_wound_debuff) > 4 } and SpellCooldown(army_of_the_dead) > 5 and Spell(clawing_shadows) or RunicPowerDeficit() < 20 and not pooling_for_gargoyle() and Spell(death_coil) or { { target.DebuffStacks(festering_wound_debuff) < 4 and not BuffPresent(unholy_frenzy_buff) or target.DebuffStacks(festering_wound_debuff) < 3 } and SpellCooldown(apocalypse) < 3 or target.DebuffStacks(festering_wound_debuff) < 1 } and SpellCooldown(army_of_the_dead) > 5 and Spell(festering_strike) or not pooling_for_gargoyle() and Spell(death_coil)
}

AddFunction UnholyGenericCdActions
{
}

AddFunction UnholyGenericCdPostConditions
{
 { BuffPresent(sudden_doom_buff) and not pooling_for_gargoyle() or pet.Present() } and Spell(death_coil) or RunicPowerDeficit() < 14 and { SpellCooldown(apocalypse) > 5 or target.DebuffStacks(festering_wound_debuff) > 4 } and not pooling_for_gargoyle() and Spell(death_coil) or Talent(pestilence_talent) and SpellCooldown(apocalypse) > 0 and Spell(death_and_decay) or SpellCooldown(apocalypse) > 0 and Spell(defile) or { target.DebuffPresent(festering_wound_debuff) and SpellCooldown(apocalypse) > 5 or target.DebuffStacks(festering_wound_debuff) > 4 } and SpellCooldown(army_of_the_dead) > 5 and Spell(scourge_strike) or { target.DebuffPresent(festering_wound_debuff) and SpellCooldown(apocalypse) > 5 or target.DebuffStacks(festering_wound_debuff) > 4 } and SpellCooldown(army_of_the_dead) > 5 and Spell(clawing_shadows) or RunicPowerDeficit() < 20 and not pooling_for_gargoyle() and Spell(death_coil) or { { target.DebuffStacks(festering_wound_debuff) < 4 and not BuffPresent(unholy_frenzy_buff) or target.DebuffStacks(festering_wound_debuff) < 3 } and SpellCooldown(apocalypse) < 3 or target.DebuffStacks(festering_wound_debuff) < 1 } and SpellCooldown(army_of_the_dead) > 5 and Spell(festering_strike) or not pooling_for_gargoyle() and Spell(death_coil)
}

### actions.precombat

AddFunction UnholyPrecombatMainActions
{
 #flask
 #food
 #augmentation
 #snapshot_stats
 #potion
 # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
 #raise_dead
 Spell(raise_dead)
 #army_of_the_dead
 Spell(army_of_the_dead)
}

AddFunction UnholyPrecombatMainPostConditions
{
}

AddFunction UnholyPrecombatShortCdActions
{
}

AddFunction UnholyPrecombatShortCdPostConditions
{
 # CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(prolonged_power_potion usable=1) or Spell(raise_dead) or Spell(army_of_the_dead)
}

AddFunction UnholyPrecombatCdActions
{
}

AddFunction UnholyPrecombatCdPostConditions
{
 # CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) and Item(prolonged_power_potion usable=1) or Spell(raise_dead) or Spell(army_of_the_dead)
}
]]

	OvaleScripts:RegisterScript("DEATHKNIGHT", nill, name, desc, code, "include")
end
