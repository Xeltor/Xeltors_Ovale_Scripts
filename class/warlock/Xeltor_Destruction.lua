local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_destruction"
	local desc = "[Xel][7.3] Warlock: Destruction"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_warlock_spells)

AddIcon specialization=3 help=main
{
	if InCombat() and target.InRange(chaos_bolt) and HasFullControl()
    {
		# Cooldowns
		if Boss()
		{
			if Speed() == 0 or CanMove() > 0 DestructionDefaultCdActions()
		}
		
		# Short Cooldowns
		if Speed() == 0 or CanMove() > 0 DestructionDefaultShortCdActions()
		
		# Default rotation
		if Speed() == 0 or CanMove() > 0 DestructionDefaultMainActions()
	}
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

### actions.default

AddFunction DestructionDefaultMainActions
{
 #immolate,cycle_targets=1,if=active_enemies=2&talent.roaring_blaze.enabled&!cooldown.havoc.remains&dot.immolate.remains<=buff.active_havoc.duration
 if Enemies(tagged=1) == 2 and Talent(roaring_blaze_talent) and not SpellCooldown(havoc) > 0 and target.DebuffRemaining(immolate_debuff) <= BaseDuration(havoc_buff) Spell(immolate)
 #immolate,if=(active_enemies<5|!talent.fire_and_brimstone.enabled)&remains<=tick_time
 if { Enemies(tagged=1) < 5 or not Talent(fire_and_brimstone_talent) } and target.DebuffRemaining(immolate_debuff) <= target.TickTime(immolate_debuff) Spell(immolate)
 #immolate,cycle_targets=1,if=(active_enemies<5|!talent.fire_and_brimstone.enabled)&(!talent.cataclysm.enabled|cooldown.cataclysm.remains>=action.immolate.cast_time*active_enemies)&active_enemies>1&remains<=tick_time&(!talent.roaring_blaze.enabled|(!debuff.roaring_blaze.remains&action.conflagrate.charges<2+set_bonus.tier19_4pc))
 if { Enemies(tagged=1) < 5 or not Talent(fire_and_brimstone_talent) } and { not Talent(cataclysm_talent) or SpellCooldown(cataclysm) >= CastTime(immolate) * Enemies(tagged=1) } and Enemies(tagged=1) > 1 and target.DebuffRemaining(immolate_debuff) <= target.TickTime(immolate_debuff) and { not Talent(roaring_blaze_talent) or not target.DebuffPresent(roaring_blaze_debuff) and Charges(conflagrate) < 2 + ArmorSetBonus(T19 4) } Spell(immolate)
 #immolate,if=talent.roaring_blaze.enabled&remains<=duration&!debuff.roaring_blaze.remains&target.time_to_die>10&(action.conflagrate.charges=2+set_bonus.tier19_4pc|(action.conflagrate.charges>=1+set_bonus.tier19_4pc&action.conflagrate.recharge_time<cast_time+gcd)|target.time_to_die<24)
 if Talent(roaring_blaze_talent) and target.DebuffRemaining(immolate_debuff) <= BaseDuration(immolate_debuff) and not target.DebuffPresent(roaring_blaze_debuff) and target.TimeToDie() > 10 and { Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) or Charges(conflagrate) >= 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < CastTime(immolate) + GCD() or target.TimeToDie() < 24 } Spell(immolate)
 #shadowburn,if=soul_shard<4&buff.conflagration_of_chaos.remains<=action.chaos_bolt.cast_time
 if SoulShards() < 4 and BuffRemaining(conflagration_of_chaos_buff) <= CastTime(chaos_bolt) Spell(shadowburn)
 #shadowburn,if=(charges=1+set_bonus.tier19_4pc&recharge_time<action.chaos_bolt.cast_time|charges=2+set_bonus.tier19_4pc)&soul_shard<5
 if { Charges(shadowburn) == 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(shadowburn) < CastTime(chaos_bolt) or Charges(shadowburn) == 2 + ArmorSetBonus(T19 4) } and SoulShards() < 5 Spell(shadowburn)
 #conflagrate,if=talent.roaring_blaze.enabled&(charges=2+set_bonus.tier19_4pc|(charges>=1+set_bonus.tier19_4pc&recharge_time<gcd)|target.time_to_die<24)
 if Talent(roaring_blaze_talent) and { Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) or Charges(conflagrate) >= 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < GCD() or target.TimeToDie() < 24 } Spell(conflagrate)
 #conflagrate,if=talent.roaring_blaze.enabled&debuff.roaring_blaze.stack>0&dot.immolate.remains>dot.immolate.duration*0.3&(active_enemies=1|soul_shard<3)&soul_shard<5
 if Talent(roaring_blaze_talent) and target.DebuffStacks(roaring_blaze_debuff) > 0 and target.DebuffRemaining(immolate_debuff) > target.DebuffDuration(immolate_debuff) * 0.3 and { Enemies(tagged=1) == 1 or SoulShards() < 3 } and SoulShards() < 5 Spell(conflagrate)
 #conflagrate,if=!talent.roaring_blaze.enabled&buff.backdraft.stack<3&(charges=1+set_bonus.tier19_4pc&recharge_time<action.chaos_bolt.cast_time|charges=2+set_bonus.tier19_4pc)&soul_shard<5
 if not Talent(roaring_blaze_talent) and BuffStacks(backdraft_buff) < 3 and { Charges(conflagrate) == 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < CastTime(chaos_bolt) or Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) } and SoulShards() < 5 Spell(conflagrate)
 #life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<=gcd
 if Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() Spell(life_tap)
 #chaos_bolt,if=active_enemies<4&buff.active_havoc.remains>cast_time
 if Enemies(tagged=1) < 4 and BuffRemaining(havoc_buff) > CastTime(chaos_bolt) Spell(chaos_bolt)
 #channel_demonfire,if=dot.immolate.remains>cast_time&(active_enemies=1|buff.active_havoc.remains<action.chaos_bolt.cast_time)
 if target.DebuffRemaining(immolate_debuff) > CastTime(channel_demonfire) and { Enemies(tagged=1) == 1 or BuffRemaining(havoc_buff) < CastTime(chaos_bolt) } Spell(channel_demonfire)
 #rain_of_fire,if=active_enemies>=3
 if Enemies(tagged=1) >= 3 Spell(rain_of_fire)
 #rain_of_fire,if=active_enemies>=6&talent.wreak_havoc.enabled
 if Enemies(tagged=1) >= 6 and Talent(wreak_havoc_talent) Spell(rain_of_fire)
 #life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<duration*0.3
 if Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 Spell(life_tap)
 #chaos_bolt,if=active_enemies<3&(cooldown.havoc.remains>12&cooldown.havoc.remains|active_enemies=1|soul_shard>=5-spell_targets.infernal_awakening*1.5|target.time_to_die<=10)
 if Enemies(tagged=1) < 3 and { SpellCooldown(havoc) > 12 and SpellCooldown(havoc) > 0 or Enemies(tagged=1) == 1 or SoulShards() >= 5 - Enemies(tagged=1) * 1.5 or target.TimeToDie() <= 10 } Spell(chaos_bolt)
 #shadowburn
 Spell(shadowburn)
 #conflagrate,if=!talent.roaring_blaze.enabled&buff.backdraft.stack<3
 if not Talent(roaring_blaze_talent) and BuffStacks(backdraft_buff) < 3 Spell(conflagrate)
 #immolate,cycle_targets=1,if=(active_enemies<5|!talent.fire_and_brimstone.enabled)&(!talent.cataclysm.enabled|cooldown.cataclysm.remains>=action.immolate.cast_time*active_enemies)&!talent.roaring_blaze.enabled&remains<=duration*0.3
 if { Enemies(tagged=1) < 5 or not Talent(fire_and_brimstone_talent) } and { not Talent(cataclysm_talent) or SpellCooldown(cataclysm) >= CastTime(immolate) * Enemies(tagged=1) } and not Talent(roaring_blaze_talent) and target.DebuffRemaining(immolate_debuff) <= BaseDuration(immolate_debuff) * 0.3 Spell(immolate)
 #incinerate
 Spell(incinerate)
 #life_tap
 Spell(life_tap)
}

AddFunction DestructionDefaultMainPostConditions
{
}

AddFunction DestructionDefaultShortCdActions
{
 unless Enemies(tagged=1) == 2 and Talent(roaring_blaze_talent) and not SpellCooldown(havoc) > 0 and target.DebuffRemaining(immolate_debuff) <= BaseDuration(havoc_buff) and Spell(immolate)
 {
  #havoc,target=2,if=active_enemies>1&(active_enemies<4|talent.wreak_havoc.enabled&active_enemies<6)&!debuff.havoc.remains
  if Enemies(tagged=1) > 1 and { Enemies(tagged=1) < 4 or Talent(wreak_havoc_talent) and Enemies(tagged=1) < 6 } and not target.DebuffPresent(havoc_debuff) and Enemies(tagged=1) > 1 Spell(havoc text=other)
  #dimensional_rift,if=charges=3
  if Charges(dimensional_rift) == 3 Spell(dimensional_rift)
  #cataclysm,if=spell_targets.cataclysm>=3
  if Enemies(tagged=1) >= 3 Spell(cataclysm)

  unless { Enemies(tagged=1) < 5 or not Talent(fire_and_brimstone_talent) } and target.DebuffRemaining(immolate_debuff) <= target.TickTime(immolate_debuff) and Spell(immolate) or { Enemies(tagged=1) < 5 or not Talent(fire_and_brimstone_talent) } and { not Talent(cataclysm_talent) or SpellCooldown(cataclysm) >= CastTime(immolate) * Enemies(tagged=1) } and Enemies(tagged=1) > 1 and target.DebuffRemaining(immolate_debuff) <= target.TickTime(immolate_debuff) and { not Talent(roaring_blaze_talent) or not target.DebuffPresent(roaring_blaze_debuff) and Charges(conflagrate) < 2 + ArmorSetBonus(T19 4) } and Spell(immolate) or Talent(roaring_blaze_talent) and target.DebuffRemaining(immolate_debuff) <= BaseDuration(immolate_debuff) and not target.DebuffPresent(roaring_blaze_debuff) and target.TimeToDie() > 10 and { Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) or Charges(conflagrate) >= 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < CastTime(immolate) + GCD() or target.TimeToDie() < 24 } and Spell(immolate) or SoulShards() < 4 and BuffRemaining(conflagration_of_chaos_buff) <= CastTime(chaos_bolt) and Spell(shadowburn) or { Charges(shadowburn) == 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(shadowburn) < CastTime(chaos_bolt) or Charges(shadowburn) == 2 + ArmorSetBonus(T19 4) } and SoulShards() < 5 and Spell(shadowburn) or Talent(roaring_blaze_talent) and { Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) or Charges(conflagrate) >= 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < GCD() or target.TimeToDie() < 24 } and Spell(conflagrate) or Talent(roaring_blaze_talent) and target.DebuffStacks(roaring_blaze_debuff) > 0 and target.DebuffRemaining(immolate_debuff) > target.DebuffDuration(immolate_debuff) * 0.3 and { Enemies(tagged=1) == 1 or SoulShards() < 3 } and SoulShards() < 5 and Spell(conflagrate) or not Talent(roaring_blaze_talent) and BuffStacks(backdraft_buff) < 3 and { Charges(conflagrate) == 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < CastTime(chaos_bolt) or Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) } and SoulShards() < 5 and Spell(conflagrate) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap)
  {
   #dimensional_rift,if=equipped.144369&!buff.lessons_of_spacetime.remains&((!talent.grimoire_of_supremacy.enabled&!cooldown.summon_doomguard.remains)|(talent.grimoire_of_service.enabled&!cooldown.service_pet.remains)|(talent.soul_harvest.enabled&!cooldown.soul_harvest.remains))
   if HasEquippedItem(144369) and not BuffPresent(lessons_of_spacetime_buff) and { not Talent(grimoire_of_supremacy_talent) and not SpellCooldown(summon_doomguard) > 0 or Talent(grimoire_of_service_talent) and not SpellCooldown(service_pet) > 0 or Talent(soul_harvest_talent) and not SpellCooldown(soul_harvest) > 0 } Spell(dimensional_rift)
   #service_pet
   Spell(service_imp)

   unless Enemies(tagged=1) < 4 and BuffRemaining(havoc_buff) > CastTime(chaos_bolt) and Spell(chaos_bolt) or target.DebuffRemaining(immolate_debuff) > CastTime(channel_demonfire) and { Enemies(tagged=1) == 1 or BuffRemaining(havoc_buff) < CastTime(chaos_bolt) } and Spell(channel_demonfire) or Enemies(tagged=1) >= 3 and Spell(rain_of_fire) or Enemies(tagged=1) >= 6 and Talent(wreak_havoc_talent) and Spell(rain_of_fire)
   {
    #dimensional_rift,if=target.time_to_die<=32|!equipped.144369|charges>1|(!equipped.144369&(!talent.grimoire_of_service.enabled|recharge_time<cooldown.service_pet.remains)&(!talent.soul_harvest.enabled|recharge_time<cooldown.soul_harvest.remains)&(!talent.grimoire_of_supremacy.enabled|recharge_time<cooldown.summon_doomguard.remains))
    if target.TimeToDie() <= 32 or not HasEquippedItem(144369) or Charges(dimensional_rift) > 1 or not HasEquippedItem(144369) and { not Talent(grimoire_of_service_talent) or SpellChargeCooldown(dimensional_rift) < SpellCooldown(service_pet) } and { not Talent(soul_harvest_talent) or SpellChargeCooldown(dimensional_rift) < SpellCooldown(soul_harvest) } and { not Talent(grimoire_of_supremacy_talent) or SpellChargeCooldown(dimensional_rift) < SpellCooldown(summon_doomguard) } Spell(dimensional_rift)

    unless Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 and Spell(life_tap)
    {
     #cataclysm
     Spell(cataclysm)
    }
   }
  }
 }
}

AddFunction DestructionDefaultShortCdPostConditions
{
 Enemies(tagged=1) == 2 and Talent(roaring_blaze_talent) and not SpellCooldown(havoc) > 0 and target.DebuffRemaining(immolate_debuff) <= BaseDuration(havoc_buff) and Spell(immolate) or { Enemies(tagged=1) < 5 or not Talent(fire_and_brimstone_talent) } and target.DebuffRemaining(immolate_debuff) <= target.TickTime(immolate_debuff) and Spell(immolate) or { Enemies(tagged=1) < 5 or not Talent(fire_and_brimstone_talent) } and { not Talent(cataclysm_talent) or SpellCooldown(cataclysm) >= CastTime(immolate) * Enemies(tagged=1) } and Enemies(tagged=1) > 1 and target.DebuffRemaining(immolate_debuff) <= target.TickTime(immolate_debuff) and { not Talent(roaring_blaze_talent) or not target.DebuffPresent(roaring_blaze_debuff) and Charges(conflagrate) < 2 + ArmorSetBonus(T19 4) } and Spell(immolate) or Talent(roaring_blaze_talent) and target.DebuffRemaining(immolate_debuff) <= BaseDuration(immolate_debuff) and not target.DebuffPresent(roaring_blaze_debuff) and target.TimeToDie() > 10 and { Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) or Charges(conflagrate) >= 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < CastTime(immolate) + GCD() or target.TimeToDie() < 24 } and Spell(immolate) or SoulShards() < 4 and BuffRemaining(conflagration_of_chaos_buff) <= CastTime(chaos_bolt) and Spell(shadowburn) or { Charges(shadowburn) == 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(shadowburn) < CastTime(chaos_bolt) or Charges(shadowburn) == 2 + ArmorSetBonus(T19 4) } and SoulShards() < 5 and Spell(shadowburn) or Talent(roaring_blaze_talent) and { Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) or Charges(conflagrate) >= 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < GCD() or target.TimeToDie() < 24 } and Spell(conflagrate) or Talent(roaring_blaze_talent) and target.DebuffStacks(roaring_blaze_debuff) > 0 and target.DebuffRemaining(immolate_debuff) > target.DebuffDuration(immolate_debuff) * 0.3 and { Enemies(tagged=1) == 1 or SoulShards() < 3 } and SoulShards() < 5 and Spell(conflagrate) or not Talent(roaring_blaze_talent) and BuffStacks(backdraft_buff) < 3 and { Charges(conflagrate) == 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < CastTime(chaos_bolt) or Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) } and SoulShards() < 5 and Spell(conflagrate) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap) or Enemies(tagged=1) < 4 and BuffRemaining(havoc_buff) > CastTime(chaos_bolt) and Spell(chaos_bolt) or target.DebuffRemaining(immolate_debuff) > CastTime(channel_demonfire) and { Enemies(tagged=1) == 1 or BuffRemaining(havoc_buff) < CastTime(chaos_bolt) } and Spell(channel_demonfire) or Enemies(tagged=1) >= 3 and Spell(rain_of_fire) or Enemies(tagged=1) >= 6 and Talent(wreak_havoc_talent) and Spell(rain_of_fire) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 and Spell(life_tap) or Enemies(tagged=1) < 3 and { SpellCooldown(havoc) > 12 and SpellCooldown(havoc) > 0 or Enemies(tagged=1) == 1 or SoulShards() >= 5 - Enemies(tagged=1) * 1.5 or target.TimeToDie() <= 10 } and Spell(chaos_bolt) or Spell(shadowburn) or not Talent(roaring_blaze_talent) and BuffStacks(backdraft_buff) < 3 and Spell(conflagrate) or { Enemies(tagged=1) < 5 or not Talent(fire_and_brimstone_talent) } and { not Talent(cataclysm_talent) or SpellCooldown(cataclysm) >= CastTime(immolate) * Enemies(tagged=1) } and not Talent(roaring_blaze_talent) and target.DebuffRemaining(immolate_debuff) <= BaseDuration(immolate_debuff) * 0.3 and Spell(immolate) or Spell(incinerate) or Spell(life_tap)
}

AddFunction DestructionDefaultCdActions
{
 unless Enemies(tagged=1) == 2 and Talent(roaring_blaze_talent) and not SpellCooldown(havoc) > 0 and target.DebuffRemaining(immolate_debuff) <= BaseDuration(havoc_buff) and Spell(immolate) or Enemies(tagged=1) > 1 and { Enemies(tagged=1) < 4 or Talent(wreak_havoc_talent) and Enemies(tagged=1) < 6 } and not target.DebuffPresent(havoc_debuff) and Enemies(tagged=1) > 1 and Spell(havoc text=other) or Charges(dimensional_rift) == 3 and Spell(dimensional_rift) or { Enemies(tagged=1) < 5 or not Talent(fire_and_brimstone_talent) } and target.DebuffRemaining(immolate_debuff) <= target.TickTime(immolate_debuff) and Spell(immolate) or { Enemies(tagged=1) < 5 or not Talent(fire_and_brimstone_talent) } and { not Talent(cataclysm_talent) or SpellCooldown(cataclysm) >= CastTime(immolate) * Enemies(tagged=1) } and Enemies(tagged=1) > 1 and target.DebuffRemaining(immolate_debuff) <= target.TickTime(immolate_debuff) and { not Talent(roaring_blaze_talent) or not target.DebuffPresent(roaring_blaze_debuff) and Charges(conflagrate) < 2 + ArmorSetBonus(T19 4) } and Spell(immolate) or Talent(roaring_blaze_talent) and target.DebuffRemaining(immolate_debuff) <= BaseDuration(immolate_debuff) and not target.DebuffPresent(roaring_blaze_debuff) and target.TimeToDie() > 10 and { Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) or Charges(conflagrate) >= 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < CastTime(immolate) + GCD() or target.TimeToDie() < 24 } and Spell(immolate)
 {
  #berserking
  Spell(berserking)
  #blood_fury
  Spell(blood_fury_sp)
  #use_items
  # DestructionUseItemActions()
  #potion,name=deadly_grace,if=(buff.soul_harvest.remains|trinket.proc.any.react|target.time_to_die<=45)
  # if { BuffPresent(soul_harvest_buff) or BuffPresent(trinket_proc_any_buff) or target.TimeToDie() <= 45 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(deadly_grace_potion usable=1)

  unless SoulShards() < 4 and BuffRemaining(conflagration_of_chaos_buff) <= CastTime(chaos_bolt) and Spell(shadowburn) or { Charges(shadowburn) == 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(shadowburn) < CastTime(chaos_bolt) or Charges(shadowburn) == 2 + ArmorSetBonus(T19 4) } and SoulShards() < 5 and Spell(shadowburn) or Talent(roaring_blaze_talent) and { Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) or Charges(conflagrate) >= 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < GCD() or target.TimeToDie() < 24 } and Spell(conflagrate) or Talent(roaring_blaze_talent) and target.DebuffStacks(roaring_blaze_debuff) > 0 and target.DebuffRemaining(immolate_debuff) > target.DebuffDuration(immolate_debuff) * 0.3 and { Enemies(tagged=1) == 1 or SoulShards() < 3 } and SoulShards() < 5 and Spell(conflagrate) or not Talent(roaring_blaze_talent) and BuffStacks(backdraft_buff) < 3 and { Charges(conflagrate) == 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < CastTime(chaos_bolt) or Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) } and SoulShards() < 5 and Spell(conflagrate) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap) or HasEquippedItem(144369) and not BuffPresent(lessons_of_spacetime_buff) and { not Talent(grimoire_of_supremacy_talent) and not SpellCooldown(summon_doomguard) > 0 or Talent(grimoire_of_service_talent) and not SpellCooldown(service_pet) > 0 or Talent(soul_harvest_talent) and not SpellCooldown(soul_harvest) > 0 } and Spell(dimensional_rift) or Spell(service_imp)
  {
   #summon_infernal,if=artifact.lord_of_flames.rank>0&!buff.lord_of_flames.remains
   if ArtifactTraitRank(lord_of_flames) > 0 and not BuffPresent(lord_of_flames_buff) Spell(summon_infernal)
   #summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening<=2&(target.time_to_die>180|target.health.pct<=20|target.time_to_die<30)
   if not Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) <= 2 and { target.TimeToDie() > 180 or target.HealthPercent() <= 20 or target.TimeToDie() < 30 } Spell(summon_doomguard)
   #summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening>2
   if not Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) > 2 Spell(summon_infernal)
   #summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal=1&artifact.lord_of_flames.rank>0&buff.lord_of_flames.remains&!pet.doomguard.active
   if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) == 1 and ArtifactTraitRank(lord_of_flames) > 0 and BuffPresent(lord_of_flames_buff) and not pet.Present() Spell(summon_doomguard)
   #summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal=1&equipped.132379&!cooldown.sindorei_spite_icd.remains
   if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) == 1 and HasEquippedItem(132379) and not SpellCooldown(sindorei_spite_icd) > 0 Spell(summon_doomguard)
   #summon_infernal,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>1&equipped.132379&!cooldown.sindorei_spite_icd.remains
   if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) > 1 and HasEquippedItem(132379) and not SpellCooldown(sindorei_spite_icd) > 0 Spell(summon_infernal)
   #soul_harvest,if=!buff.soul_harvest.remains
   if not BuffPresent(soul_harvest_buff) Spell(soul_harvest)
  }
 }
}

AddFunction DestructionDefaultCdPostConditions
{
 Enemies(tagged=1) == 2 and Talent(roaring_blaze_talent) and not SpellCooldown(havoc) > 0 and target.DebuffRemaining(immolate_debuff) <= BaseDuration(havoc_buff) and Spell(immolate) or Enemies(tagged=1) > 1 and { Enemies(tagged=1) < 4 or Talent(wreak_havoc_talent) and Enemies(tagged=1) < 6 } and not target.DebuffPresent(havoc_debuff) and Enemies(tagged=1) > 1 and Spell(havoc text=other) or Charges(dimensional_rift) == 3 and Spell(dimensional_rift) or { Enemies(tagged=1) < 5 or not Talent(fire_and_brimstone_talent) } and target.DebuffRemaining(immolate_debuff) <= target.TickTime(immolate_debuff) and Spell(immolate) or { Enemies(tagged=1) < 5 or not Talent(fire_and_brimstone_talent) } and { not Talent(cataclysm_talent) or SpellCooldown(cataclysm) >= CastTime(immolate) * Enemies(tagged=1) } and Enemies(tagged=1) > 1 and target.DebuffRemaining(immolate_debuff) <= target.TickTime(immolate_debuff) and { not Talent(roaring_blaze_talent) or not target.DebuffPresent(roaring_blaze_debuff) and Charges(conflagrate) < 2 + ArmorSetBonus(T19 4) } and Spell(immolate) or Talent(roaring_blaze_talent) and target.DebuffRemaining(immolate_debuff) <= BaseDuration(immolate_debuff) and not target.DebuffPresent(roaring_blaze_debuff) and target.TimeToDie() > 10 and { Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) or Charges(conflagrate) >= 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < CastTime(immolate) + GCD() or target.TimeToDie() < 24 } and Spell(immolate) or SoulShards() < 4 and BuffRemaining(conflagration_of_chaos_buff) <= CastTime(chaos_bolt) and Spell(shadowburn) or { Charges(shadowburn) == 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(shadowburn) < CastTime(chaos_bolt) or Charges(shadowburn) == 2 + ArmorSetBonus(T19 4) } and SoulShards() < 5 and Spell(shadowburn) or Talent(roaring_blaze_talent) and { Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) or Charges(conflagrate) >= 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < GCD() or target.TimeToDie() < 24 } and Spell(conflagrate) or Talent(roaring_blaze_talent) and target.DebuffStacks(roaring_blaze_debuff) > 0 and target.DebuffRemaining(immolate_debuff) > target.DebuffDuration(immolate_debuff) * 0.3 and { Enemies(tagged=1) == 1 or SoulShards() < 3 } and SoulShards() < 5 and Spell(conflagrate) or not Talent(roaring_blaze_talent) and BuffStacks(backdraft_buff) < 3 and { Charges(conflagrate) == 1 + ArmorSetBonus(T19 4) and SpellChargeCooldown(conflagrate) < CastTime(chaos_bolt) or Charges(conflagrate) == 2 + ArmorSetBonus(T19 4) } and SoulShards() < 5 and Spell(conflagrate) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) <= GCD() and Spell(life_tap) or HasEquippedItem(144369) and not BuffPresent(lessons_of_spacetime_buff) and { not Talent(grimoire_of_supremacy_talent) and not SpellCooldown(summon_doomguard) > 0 or Talent(grimoire_of_service_talent) and not SpellCooldown(service_pet) > 0 or Talent(soul_harvest_talent) and not SpellCooldown(soul_harvest) > 0 } and Spell(dimensional_rift) or Spell(service_imp) or Enemies(tagged=1) < 4 and BuffRemaining(havoc_buff) > CastTime(chaos_bolt) and Spell(chaos_bolt) or target.DebuffRemaining(immolate_debuff) > CastTime(channel_demonfire) and { Enemies(tagged=1) == 1 or BuffRemaining(havoc_buff) < CastTime(chaos_bolt) } and Spell(channel_demonfire) or Enemies(tagged=1) >= 3 and Spell(rain_of_fire) or Enemies(tagged=1) >= 6 and Talent(wreak_havoc_talent) and Spell(rain_of_fire) or { target.TimeToDie() <= 32 or not HasEquippedItem(144369) or Charges(dimensional_rift) > 1 or not HasEquippedItem(144369) and { not Talent(grimoire_of_service_talent) or SpellChargeCooldown(dimensional_rift) < SpellCooldown(service_pet) } and { not Talent(soul_harvest_talent) or SpellChargeCooldown(dimensional_rift) < SpellCooldown(soul_harvest) } and { not Talent(grimoire_of_supremacy_talent) or SpellChargeCooldown(dimensional_rift) < SpellCooldown(summon_doomguard) } } and Spell(dimensional_rift) or Talent(empowered_life_tap_talent) and BuffRemaining(empowered_life_tap_buff) < BaseDuration(empowered_life_tap_buff) * 0.3 and Spell(life_tap) or Enemies(tagged=1) < 3 and { SpellCooldown(havoc) > 12 and SpellCooldown(havoc) > 0 or Enemies(tagged=1) == 1 or SoulShards() >= 5 - Enemies(tagged=1) * 1.5 or target.TimeToDie() <= 10 } and Spell(chaos_bolt) or Spell(shadowburn) or not Talent(roaring_blaze_talent) and BuffStacks(backdraft_buff) < 3 and Spell(conflagrate) or { Enemies(tagged=1) < 5 or not Talent(fire_and_brimstone_talent) } and { not Talent(cataclysm_talent) or SpellCooldown(cataclysm) >= CastTime(immolate) * Enemies(tagged=1) } and not Talent(roaring_blaze_talent) and target.DebuffRemaining(immolate_debuff) <= BaseDuration(immolate_debuff) * 0.3 and Spell(immolate) or Spell(incinerate) or Spell(life_tap)
}

### actions.precombat

AddFunction DestructionPrecombatMainActions
{
 #snapshot_stats
 #grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
 if Talent(grimoire_of_sacrifice_talent) and pet.Present() Spell(grimoire_of_sacrifice)
 #life_tap,if=talent.empowered_life_tap.enabled&!buff.empowered_life_tap.remains
 if Talent(empowered_life_tap_talent) and not BuffPresent(empowered_life_tap_buff) Spell(life_tap)
 #chaos_bolt
 Spell(chaos_bolt)
}

AddFunction DestructionPrecombatMainPostConditions
{
}

AddFunction DestructionPrecombatShortCdActions
{
 #flask
 #food
 #augmentation
 #summon_pet,if=!talent.grimoire_of_supremacy.enabled&(!talent.grimoire_of_sacrifice.enabled|buff.demonic_power.down)
 if not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() Spell(summon_imp)
}

AddFunction DestructionPrecombatShortCdPostConditions
{
 Talent(empowered_life_tap_talent) and not BuffPresent(empowered_life_tap_buff) and Spell(life_tap) or Spell(chaos_bolt)
}

AddFunction DestructionPrecombatCdActions
{
 unless not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() and Spell(summon_imp)
 {
  #summon_infernal,if=talent.grimoire_of_supremacy.enabled&artifact.lord_of_flames.rank>0
  if Talent(grimoire_of_supremacy_talent) and ArtifactTraitRank(lord_of_flames) > 0 Spell(summon_infernal)
  #summon_infernal,if=talent.grimoire_of_supremacy.enabled&active_enemies>1
  if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) > 1 Spell(summon_infernal)
  #summon_doomguard,if=talent.grimoire_of_supremacy.enabled&active_enemies=1&artifact.lord_of_flames.rank=0
  if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) == 1 and ArtifactTraitRank(lord_of_flames) == 0 Spell(summon_doomguard)

  unless Talent(empowered_life_tap_talent) and not BuffPresent(empowered_life_tap_buff) and Spell(life_tap)
  {
   #potion
   # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
  }
 }
}

AddFunction DestructionPrecombatCdPostConditions
{
 not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() and Spell(summon_imp) or Talent(empowered_life_tap_talent) and not BuffPresent(empowered_life_tap_buff) and Spell(life_tap) or Spell(chaos_bolt)
}
]]

	OvaleScripts:RegisterScript("WARLOCK", "destruction", name, desc, code, "script")
end
