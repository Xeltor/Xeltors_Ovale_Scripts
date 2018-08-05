local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_demonology"
	local desc = "[Xel][8.0] Warlock: Demonology"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_warlock_spells)

Define(health_funnel 755)
Define(spell_lock_fh 19647)
	SpellInfo(spell_lock_fh cd=24)
Define(drain_life 234153)

AddIcon specialization=2 help=main
{
	# Interrupt
	if InCombat() InterruptActions()
	
	if InCombat() and target.InRange(shadow_bolt) and HasFullControl()
    {
		#life_tap
		# if ManaPercent() <= 30 Spell(life_tap)
		if pet.CreatureFamily(Voidwalker) or pet.CreatureFamily(Voidlord) or pet.CreatureFamily(Infernal) PetStuff()
		
		if Speed() == 0 or CanMove() > 0
		{
			# Cooldowns
			if Boss() DemonologyDefaultCdActions()
			
			# Short Cooldowns
			DemonologyDefaultShortCdActions()
			
			# Default rotation
			DemonologyDefaultMainActions()
		}
		if Speed() > 0 and SoulShards() < 5 and BuffStacks(demonic_core_buff) >= 1 Spell(demonbolt)
	}
}

AddFunction Boss
{
	IsBossFight() or target.Classification(worldboss) or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		# Felhunter Spell Lock
		if target.Distance() - pet.Distance() <= 40 and pet.CreatureFamily(Felhunter) Spell(spell_lock_fh)
	}
}

AddFunction PetStuff
{
	if pet.Health() < pet.HealthMissing() and pet.Present() and Speed() == 0 Spell(health_funnel)
	if HealthPercent() < 50 and target.Present() and not target.IsFriend() and Speed() == 0 Spell(drain_life)
}

### actions.default

AddFunction DemonologyDefaultMainActions
{
 #doom,if=!ticking&time_to_die>30&spell_targets.implosion<2
 if not target.DebuffPresent(doom_debuff) and target.TimeToDie() > 30 and Enemies(tagged=1) < 2 Spell(doom)
 #call_action_list,name=nether_portal,if=talent.nether_portal.enabled&spell_targets.implosion<=2
 if Talent(nether_portal_talent) and Enemies(tagged=1) <= 2 DemonologyNetherPortalMainActions()

 unless Talent(nether_portal_talent) and Enemies(tagged=1) <= 2 and DemonologyNetherPortalMainPostConditions()
 {
  #call_action_list,name=implosion,if=spell_targets.implosion>1
  if Enemies(tagged=1) > 1 DemonologyImplosionMainActions()

  unless Enemies(tagged=1) > 1 and DemonologyImplosionMainPostConditions()
  {
   #call_dreadstalkers,if=equipped.132369|(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
   if HasEquippedItem(132369) or SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 Spell(call_dreadstalkers)
   #doom,if=talent.doom.enabled&refreshable&time_to_die>(dot.doom.remains+30)
   if Talent(doom_talent) and target.Refreshable(doom_debuff) and target.TimeToDie() > target.DebuffRemaining(doom_debuff) + 30 Spell(doom)
   #hand_of_guldan,if=soul_shard>=5|(soul_shard>=3&cooldown.call_dreadstalkers.remains>4&(!talent.summon_vilefiend.enabled|cooldown.summon_vilefiend.remains>3))
   if SoulShards() >= 5 or SoulShards() >= 3 and SpellCooldown(call_dreadstalkers) > 4 and { not Talent(summon_vilefiend_talent) or SpellCooldown(summon_vilefiend) > 3 } Spell(hand_of_guldan)
   #soul_strike,if=soul_shard<5&buff.demonic_core.stack<=2
   if SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 Spell(soul_strike)
   #demonbolt,if=soul_shard<=3&buff.demonic_core.up&((cooldown.summon_demonic_tyrant.remains<10|cooldown.summon_demonic_tyrant.remains>22)|buff.demonic_core.stack>=3|buff.demonic_core.remains<5|time_to_die<25)
   if SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { SpellCooldown(summon_demonic_tyrant) < 10 or SpellCooldown(summon_demonic_tyrant) > 22 or BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) < 5 or target.TimeToDie() < 25 } Spell(demonbolt)
   #call_action_list,name=build_a_shard
   DemonologyBuildAShardMainActions()
  }
 }
}

AddFunction DemonologyDefaultMainPostConditions
{
 Talent(nether_portal_talent) and Enemies(tagged=1) <= 2 and DemonologyNetherPortalMainPostConditions() or Enemies(tagged=1) > 1 and DemonologyImplosionMainPostConditions() or DemonologyBuildAShardMainPostConditions()
}

AddFunction DemonologyDefaultShortCdActions
{
 unless not target.DebuffPresent(doom_debuff) and target.TimeToDie() > 30 and Enemies(tagged=1) < 2 and Spell(doom)
 {
  #demonic_strength
  if not pet.BuffPresent(felguard_felstorm_buff) Spell(demonic_strength)
  #call_action_list,name=nether_portal,if=talent.nether_portal.enabled&spell_targets.implosion<=2
  if Talent(nether_portal_talent) and Enemies(tagged=1) <= 2 DemonologyNetherPortalShortCdActions()

  unless Talent(nether_portal_talent) and Enemies(tagged=1) <= 2 and DemonologyNetherPortalShortCdPostConditions()
  {
   #call_action_list,name=implosion,if=spell_targets.implosion>1
   if Enemies(tagged=1) > 1 DemonologyImplosionShortCdActions()

   unless Enemies(tagged=1) > 1 and DemonologyImplosionShortCdPostConditions()
   {
    #summon_vilefiend,if=equipped.132369|cooldown.summon_demonic_tyrant.remains>40|cooldown.summon_demonic_tyrant.remains<12
    if HasEquippedItem(132369) or SpellCooldown(summon_demonic_tyrant) > 40 or SpellCooldown(summon_demonic_tyrant) < 12 Spell(summon_vilefiend)

    unless { HasEquippedItem(132369) or SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers)
    {
     #power_siphon,if=buff.wild_imps.stack>=2&buff.demonic_core.stack<=2&buff.demonic_power.down&spell_targets.implosion<2
     if Demons(wild_imp) + Demons(wild_imp_id) >= 2 and BuffStacks(demonic_core_buff) <= 2 and BuffExpires(demonic_power_buff) and Enemies(tagged=1) < 2 Spell(power_siphon)
     #summon_demonic_tyrant,if=equipped.132369|buff.dreadstalkers.remains>cast_time&(buff.wild_imps.stack>=3|prev_gcd.1.hand_of_guldan)&(soul_shard<3|buff.dreadstalkers.remains<gcd*2.7|buff.grimoire_felguard.remains<gcd*2.7)
     if HasEquippedItem(132369) or DemonDuration(dreadstalker) > CastTime(summon_demonic_tyrant) and { Demons(wild_imp) + Demons(wild_imp_id) >= 3 or PreviousGCDSpell(hand_of_guldan) } and { SoulShards() < 3 or DemonDuration(dreadstalker) < GCD() * 2.7 or DemonDuration(felguard) < GCD() * 2.7 } Spell(summon_demonic_tyrant)

     unless Talent(doom_talent) and target.Refreshable(doom_debuff) and target.TimeToDie() > target.DebuffRemaining(doom_debuff) + 30 and Spell(doom) or { SoulShards() >= 5 or SoulShards() >= 3 and SpellCooldown(call_dreadstalkers) > 4 and { not Talent(summon_vilefiend_talent) or SpellCooldown(summon_vilefiend) > 3 } } and Spell(hand_of_guldan) or SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { SpellCooldown(summon_demonic_tyrant) < 10 or SpellCooldown(summon_demonic_tyrant) > 22 or BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) < 5 or target.TimeToDie() < 25 } and Spell(demonbolt)
     {
      #call_action_list,name=build_a_shard
      DemonologyBuildAShardShortCdActions()
     }
    }
   }
  }
 }
}

AddFunction DemonologyDefaultShortCdPostConditions
{
 not target.DebuffPresent(doom_debuff) and target.TimeToDie() > 30 and Enemies(tagged=1) < 2 and Spell(doom) or Talent(nether_portal_talent) and Enemies(tagged=1) <= 2 and DemonologyNetherPortalShortCdPostConditions() or Enemies(tagged=1) > 1 and DemonologyImplosionShortCdPostConditions() or { HasEquippedItem(132369) or SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or Talent(doom_talent) and target.Refreshable(doom_debuff) and target.TimeToDie() > target.DebuffRemaining(doom_debuff) + 30 and Spell(doom) or { SoulShards() >= 5 or SoulShards() >= 3 and SpellCooldown(call_dreadstalkers) > 4 and { not Talent(summon_vilefiend_talent) or SpellCooldown(summon_vilefiend) > 3 } } and Spell(hand_of_guldan) or SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { SpellCooldown(summon_demonic_tyrant) < 10 or SpellCooldown(summon_demonic_tyrant) > 22 or BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) < 5 or target.TimeToDie() < 25 } and Spell(demonbolt) or DemonologyBuildAShardShortCdPostConditions()
}

AddFunction DemonologyDefaultCdActions
{
 #use_items,if=prev_gcd.1.summon_demonic_tyrant
 # if PreviousGCDSpell(summon_demonic_tyrant) DemonologyUseItemActions()
 #berserking,if=prev_gcd.1.summon_demonic_tyrant
 if PreviousGCDSpell(summon_demonic_tyrant) Spell(berserking)
 #blood_fury,if=prev_gcd.1.summon_demonic_tyrant
 if PreviousGCDSpell(summon_demonic_tyrant) Spell(blood_fury_sp)
 #fireblood,if=prev_gcd.1.summon_demonic_tyrant
 if PreviousGCDSpell(summon_demonic_tyrant) Spell(fireblood)

 unless not target.DebuffPresent(doom_debuff) and target.TimeToDie() > 30 and Enemies(tagged=1) < 2 and Spell(doom) or Spell(demonic_strength)
 {
  #call_action_list,name=nether_portal,if=talent.nether_portal.enabled&spell_targets.implosion<=2
  if Talent(nether_portal_talent) and Enemies(tagged=1) <= 2 DemonologyNetherPortalCdActions()

  unless Talent(nether_portal_talent) and Enemies(tagged=1) <= 2 and DemonologyNetherPortalCdPostConditions()
  {
   #call_action_list,name=implosion,if=spell_targets.implosion>1
   if Enemies(tagged=1) > 1 DemonologyImplosionCdActions()

   unless Enemies(tagged=1) > 1 and DemonologyImplosionCdPostConditions()
   {
    #grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
    if SpellCooldown(summon_demonic_tyrant) < 13 or not HasEquippedItem(132369) Spell(grimoire_felguard)

    unless { HasEquippedItem(132369) or SpellCooldown(summon_demonic_tyrant) > 40 or SpellCooldown(summon_demonic_tyrant) < 12 } and Spell(summon_vilefiend) or { HasEquippedItem(132369) or SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or Demons(wild_imp) + Demons(wild_imp_id) >= 2 and BuffStacks(demonic_core_buff) <= 2 and BuffExpires(demonic_power_buff) and Enemies(tagged=1) < 2 and Spell(power_siphon) or { HasEquippedItem(132369) or DemonDuration(dreadstalker) > CastTime(summon_demonic_tyrant) and { Demons(wild_imp) + Demons(wild_imp_id) >= 3 or PreviousGCDSpell(hand_of_guldan) } and { SoulShards() < 3 or DemonDuration(dreadstalker) < GCD() * 2.7 or DemonDuration(felguard) < GCD() * 2.7 } } and Spell(summon_demonic_tyrant)
    {
     #potion,if=pet.demonic_tyrant.active
     # if Demons(demonic_tyrant) and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)

     unless Talent(doom_talent) and target.Refreshable(doom_debuff) and target.TimeToDie() > target.DebuffRemaining(doom_debuff) + 30 and Spell(doom) or { SoulShards() >= 5 or SoulShards() >= 3 and SpellCooldown(call_dreadstalkers) > 4 and { not Talent(summon_vilefiend_talent) or SpellCooldown(summon_vilefiend) > 3 } } and Spell(hand_of_guldan) or SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { SpellCooldown(summon_demonic_tyrant) < 10 or SpellCooldown(summon_demonic_tyrant) > 22 or BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) < 5 or target.TimeToDie() < 25 } and Spell(demonbolt)
     {
      #call_action_list,name=build_a_shard
      DemonologyBuildAShardCdActions()
     }
    }
   }
  }
 }
}

AddFunction DemonologyDefaultCdPostConditions
{
 not target.DebuffPresent(doom_debuff) and target.TimeToDie() > 30 and Enemies(tagged=1) < 2 and Spell(doom) or Spell(demonic_strength) or Talent(nether_portal_talent) and Enemies(tagged=1) <= 2 and DemonologyNetherPortalCdPostConditions() or Enemies(tagged=1) > 1 and DemonologyImplosionCdPostConditions() or { HasEquippedItem(132369) or SpellCooldown(summon_demonic_tyrant) > 40 or SpellCooldown(summon_demonic_tyrant) < 12 } and Spell(summon_vilefiend) or { HasEquippedItem(132369) or SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or Demons(wild_imp) + Demons(wild_imp_id) >= 2 and BuffStacks(demonic_core_buff) <= 2 and BuffExpires(demonic_power_buff) and Enemies(tagged=1) < 2 and Spell(power_siphon) or { HasEquippedItem(132369) or DemonDuration(dreadstalker) > CastTime(summon_demonic_tyrant) and { Demons(wild_imp) + Demons(wild_imp_id) >= 3 or PreviousGCDSpell(hand_of_guldan) } and { SoulShards() < 3 or DemonDuration(dreadstalker) < GCD() * 2.7 or DemonDuration(felguard) < GCD() * 2.7 } } and Spell(summon_demonic_tyrant) or Talent(doom_talent) and target.Refreshable(doom_debuff) and target.TimeToDie() > target.DebuffRemaining(doom_debuff) + 30 and Spell(doom) or { SoulShards() >= 5 or SoulShards() >= 3 and SpellCooldown(call_dreadstalkers) > 4 and { not Talent(summon_vilefiend_talent) or SpellCooldown(summon_vilefiend) > 3 } } and Spell(hand_of_guldan) or SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { SpellCooldown(summon_demonic_tyrant) < 10 or SpellCooldown(summon_demonic_tyrant) > 22 or BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) < 5 or target.TimeToDie() < 25 } and Spell(demonbolt) or DemonologyBuildAShardCdPostConditions()
}

### actions.build_a_shard

AddFunction DemonologyBuildAShardMainActions
{
 #soul_strike
 Spell(soul_strike)
 #shadow_bolt
 Spell(shadow_bolt)
}

AddFunction DemonologyBuildAShardMainPostConditions
{
}

AddFunction DemonologyBuildAShardShortCdActions
{
}

AddFunction DemonologyBuildAShardShortCdPostConditions
{
 Spell(soul_strike) or Spell(shadow_bolt)
}

AddFunction DemonologyBuildAShardCdActions
{
}

AddFunction DemonologyBuildAShardCdPostConditions
{
 Spell(soul_strike) or Spell(shadow_bolt)
}

### actions.implosion

AddFunction DemonologyImplosionMainActions
{
 #implosion,if=buff.wild_imps.stack>=6&(soul_shard<3|prev_gcd.1.call_dreadstalkers|buff.wild_imps.stack>=9|prev_gcd.1.bilescourge_bombers)&!prev_gcd.1.hand_of_guldan&buff.demonic_power.down&cooldown.summon_demonic_tyrant.remains>4
 if Demons(wild_imp) + Demons(wild_imp_id) >= 6 and { SoulShards() < 3 or PreviousGCDSpell(call_dreadstalkers) or Demons(wild_imp) + Demons(wild_imp_id) >= 9 or PreviousGCDSpell(bilescourge_bombers) } and not PreviousGCDSpell(hand_of_guldan) and BuffExpires(demonic_power_buff) and SpellCooldown(summon_demonic_tyrant) > 4 Spell(implosion)
 #call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
 if SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 Spell(call_dreadstalkers)
 #hand_of_guldan,if=soul_shard>=5|(soul_shard>=3&buff.wild_imps.stack>=3&buff.wild_imps.stack<9&cooldown.call_dreadstalkers.remains>=gcd*2)
 if SoulShards() >= 5 or SoulShards() >= 3 and Demons(wild_imp) + Demons(wild_imp_id) >= 3 and Demons(wild_imp) + Demons(wild_imp_id) < 9 and SpellCooldown(call_dreadstalkers) >= GCD() * 2 Spell(hand_of_guldan)
 #demonbolt,if=prev_gcd.1.hand_of_guldan&soul_shard>=1&buff.wild_imps.stack<=3&soul_shard<4&buff.demonic_core.up
 if PreviousGCDSpell(hand_of_guldan) and SoulShards() >= 1 and Demons(wild_imp) + Demons(wild_imp_id) <= 3 and SoulShards() < 4 and BuffPresent(demonic_core_buff) Spell(demonbolt)
 #soul_strike,if=soul_shard<5&buff.demonic_core.stack<=2
 if SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 Spell(soul_strike)
 #demonbolt,if=soul_shard<=3&buff.demonic_core.up&(buff.demonic_core.stack>=3|buff.demonic_core.remains<5)
 if SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) < 5 } Spell(demonbolt)
 #call_action_list,name=build_a_shard
 DemonologyBuildAShardMainActions()
}

AddFunction DemonologyImplosionMainPostConditions
{
 DemonologyBuildAShardMainPostConditions()
}

AddFunction DemonologyImplosionShortCdActions
{
 unless Demons(wild_imp) + Demons(wild_imp_id) >= 6 and { SoulShards() < 3 or PreviousGCDSpell(call_dreadstalkers) or Demons(wild_imp) + Demons(wild_imp_id) >= 9 or PreviousGCDSpell(bilescourge_bombers) } and not PreviousGCDSpell(hand_of_guldan) and BuffExpires(demonic_power_buff) and SpellCooldown(summon_demonic_tyrant) > 4 and Spell(implosion) or { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers)
 {
  #summon_demonic_tyrant,if=soul_shard<3|buff.grimoire_felguard.remains<gcd*2.7|buff.dreadstalkers.remains<gcd*2.7
  if SoulShards() < 3 or DemonDuration(felguard) < GCD() * 2.7 or DemonDuration(dreadstalker) < GCD() * 2.7 Spell(summon_demonic_tyrant)

  unless { SoulShards() >= 5 or SoulShards() >= 3 and Demons(wild_imp) + Demons(wild_imp_id) >= 3 and Demons(wild_imp) + Demons(wild_imp_id) < 9 and SpellCooldown(call_dreadstalkers) >= GCD() * 2 } and Spell(hand_of_guldan) or PreviousGCDSpell(hand_of_guldan) and SoulShards() >= 1 and Demons(wild_imp) + Demons(wild_imp_id) <= 3 and SoulShards() < 4 and BuffPresent(demonic_core_buff) and Spell(demonbolt)
  {
   #summon_vilefiend,if=(cooldown.summon_demonic_tyrant.remains>40&spell_targets.implosion<=2)|cooldown.summon_demonic_tyrant.remains<12
   if SpellCooldown(summon_demonic_tyrant) > 40 and Enemies(tagged=1) <= 2 or SpellCooldown(summon_demonic_tyrant) < 12 Spell(summon_vilefiend)
   #bilescourge_bombers,if=cooldown.summon_demonic_tyrant.remains>9
   if SpellCooldown(summon_demonic_tyrant) > 9 Spell(bilescourge_bombers)

   unless SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) < 5 } and Spell(demonbolt)
   {
    #call_action_list,name=build_a_shard
    DemonologyBuildAShardShortCdActions()
   }
  }
 }
}

AddFunction DemonologyImplosionShortCdPostConditions
{
 Demons(wild_imp) + Demons(wild_imp_id) >= 6 and { SoulShards() < 3 or PreviousGCDSpell(call_dreadstalkers) or Demons(wild_imp) + Demons(wild_imp_id) >= 9 or PreviousGCDSpell(bilescourge_bombers) } and not PreviousGCDSpell(hand_of_guldan) and BuffExpires(demonic_power_buff) and SpellCooldown(summon_demonic_tyrant) > 4 and Spell(implosion) or { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or { SoulShards() >= 5 or SoulShards() >= 3 and Demons(wild_imp) + Demons(wild_imp_id) >= 3 and Demons(wild_imp) + Demons(wild_imp_id) < 9 and SpellCooldown(call_dreadstalkers) >= GCD() * 2 } and Spell(hand_of_guldan) or PreviousGCDSpell(hand_of_guldan) and SoulShards() >= 1 and Demons(wild_imp) + Demons(wild_imp_id) <= 3 and SoulShards() < 4 and BuffPresent(demonic_core_buff) and Spell(demonbolt) or SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) < 5 } and Spell(demonbolt) or DemonologyBuildAShardShortCdPostConditions()
}

AddFunction DemonologyImplosionCdActions
{
 unless Demons(wild_imp) + Demons(wild_imp_id) >= 6 and { SoulShards() < 3 or PreviousGCDSpell(call_dreadstalkers) or Demons(wild_imp) + Demons(wild_imp_id) >= 9 or PreviousGCDSpell(bilescourge_bombers) } and not PreviousGCDSpell(hand_of_guldan) and BuffExpires(demonic_power_buff) and SpellCooldown(summon_demonic_tyrant) > 4 and Spell(implosion)
 {
  #grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
  if SpellCooldown(summon_demonic_tyrant) < 13 or not HasEquippedItem(132369) Spell(grimoire_felguard)

  unless { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or { SoulShards() < 3 or DemonDuration(felguard) < GCD() * 2.7 or DemonDuration(dreadstalker) < GCD() * 2.7 } and Spell(summon_demonic_tyrant) or { SoulShards() >= 5 or SoulShards() >= 3 and Demons(wild_imp) + Demons(wild_imp_id) >= 3 and Demons(wild_imp) + Demons(wild_imp_id) < 9 and SpellCooldown(call_dreadstalkers) >= GCD() * 2 } and Spell(hand_of_guldan) or PreviousGCDSpell(hand_of_guldan) and SoulShards() >= 1 and Demons(wild_imp) + Demons(wild_imp_id) <= 3 and SoulShards() < 4 and BuffPresent(demonic_core_buff) and Spell(demonbolt) or { SpellCooldown(summon_demonic_tyrant) > 40 and Enemies(tagged=1) <= 2 or SpellCooldown(summon_demonic_tyrant) < 12 } and Spell(summon_vilefiend) or SpellCooldown(summon_demonic_tyrant) > 9 and Spell(bilescourge_bombers) or SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) < 5 } and Spell(demonbolt)
  {
   #call_action_list,name=build_a_shard
   DemonologyBuildAShardCdActions()
  }
 }
}

AddFunction DemonologyImplosionCdPostConditions
{
 Demons(wild_imp) + Demons(wild_imp_id) >= 6 and { SoulShards() < 3 or PreviousGCDSpell(call_dreadstalkers) or Demons(wild_imp) + Demons(wild_imp_id) >= 9 or PreviousGCDSpell(bilescourge_bombers) } and not PreviousGCDSpell(hand_of_guldan) and BuffExpires(demonic_power_buff) and SpellCooldown(summon_demonic_tyrant) > 4 and Spell(implosion) or { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or { SoulShards() < 3 or DemonDuration(felguard) < GCD() * 2.7 or DemonDuration(dreadstalker) < GCD() * 2.7 } and Spell(summon_demonic_tyrant) or { SoulShards() >= 5 or SoulShards() >= 3 and Demons(wild_imp) + Demons(wild_imp_id) >= 3 and Demons(wild_imp) + Demons(wild_imp_id) < 9 and SpellCooldown(call_dreadstalkers) >= GCD() * 2 } and Spell(hand_of_guldan) or PreviousGCDSpell(hand_of_guldan) and SoulShards() >= 1 and Demons(wild_imp) + Demons(wild_imp_id) <= 3 and SoulShards() < 4 and BuffPresent(demonic_core_buff) and Spell(demonbolt) or { SpellCooldown(summon_demonic_tyrant) > 40 and Enemies(tagged=1) <= 2 or SpellCooldown(summon_demonic_tyrant) < 12 } and Spell(summon_vilefiend) or SpellCooldown(summon_demonic_tyrant) > 9 and Spell(bilescourge_bombers) or SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) < 5 } and Spell(demonbolt) or DemonologyBuildAShardCdPostConditions()
}

### actions.nether_portal

AddFunction DemonologyNetherPortalMainActions
{
 #call_action_list,name=nether_portal_building,if=cooldown.nether_portal.remains<20
 if SpellCooldown(nether_portal) < 20 DemonologyNetherPortalBuildingMainActions()

 unless SpellCooldown(nether_portal) < 20 and DemonologyNetherPortalBuildingMainPostConditions()
 {
  #call_action_list,name=nether_portal_active,if=cooldown.nether_portal.remains>160
  if SpellCooldown(nether_portal) > 160 DemonologyNetherPortalActiveMainActions()
 }
}

AddFunction DemonologyNetherPortalMainPostConditions
{
 SpellCooldown(nether_portal) < 20 and DemonologyNetherPortalBuildingMainPostConditions() or SpellCooldown(nether_portal) > 160 and DemonologyNetherPortalActiveMainPostConditions()
}

AddFunction DemonologyNetherPortalShortCdActions
{
 #call_action_list,name=nether_portal_building,if=cooldown.nether_portal.remains<20
 if SpellCooldown(nether_portal) < 20 DemonologyNetherPortalBuildingShortCdActions()

 unless SpellCooldown(nether_portal) < 20 and DemonologyNetherPortalBuildingShortCdPostConditions()
 {
  #call_action_list,name=nether_portal_active,if=cooldown.nether_portal.remains>160
  if SpellCooldown(nether_portal) > 160 DemonologyNetherPortalActiveShortCdActions()
 }
}

AddFunction DemonologyNetherPortalShortCdPostConditions
{
 SpellCooldown(nether_portal) < 20 and DemonologyNetherPortalBuildingShortCdPostConditions() or SpellCooldown(nether_portal) > 160 and DemonologyNetherPortalActiveShortCdPostConditions()
}

AddFunction DemonologyNetherPortalCdActions
{
 #call_action_list,name=nether_portal_building,if=cooldown.nether_portal.remains<20
 if SpellCooldown(nether_portal) < 20 DemonologyNetherPortalBuildingCdActions()

 unless SpellCooldown(nether_portal) < 20 and DemonologyNetherPortalBuildingCdPostConditions()
 {
  #call_action_list,name=nether_portal_active,if=cooldown.nether_portal.remains>160
  if SpellCooldown(nether_portal) > 160 DemonologyNetherPortalActiveCdActions()
 }
}

AddFunction DemonologyNetherPortalCdPostConditions
{
 SpellCooldown(nether_portal) < 20 and DemonologyNetherPortalBuildingCdPostConditions() or SpellCooldown(nether_portal) > 160 and DemonologyNetherPortalActiveCdPostConditions()
}

### actions.nether_portal_active

AddFunction DemonologyNetherPortalActiveMainActions
{
 #call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
 if SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 Spell(call_dreadstalkers)
 #call_action_list,name=build_a_shard,if=soul_shard=1&(cooldown.call_dreadstalkers.remains<action.shadow_bolt.cast_time|(talent.bilescourge_bombers.enabled&cooldown.bilescourge_bombers.remains<action.shadow_bolt.cast_time))
 if SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } DemonologyBuildAShardMainActions()

 unless SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } and DemonologyBuildAShardMainPostConditions()
 {
  #hand_of_guldan,if=((cooldown.call_dreadstalkers.remains>action.demonbolt.cast_time)&(cooldown.call_dreadstalkers.remains>action.shadow_bolt.cast_time))&cooldown.nether_portal.remains>(160+action.hand_of_guldan.cast_time)
  if SpellCooldown(call_dreadstalkers) > CastTime(demonbolt) and SpellCooldown(call_dreadstalkers) > CastTime(shadow_bolt) and SpellCooldown(nether_portal) > 160 + CastTime(hand_of_guldan) Spell(hand_of_guldan)
  #demonbolt,if=buff.demonic_core.up
  if BuffPresent(demonic_core_buff) Spell(demonbolt)
  #call_action_list,name=build_a_shard
  DemonologyBuildAShardMainActions()
 }
}

AddFunction DemonologyNetherPortalActiveMainPostConditions
{
 SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } and DemonologyBuildAShardMainPostConditions() or DemonologyBuildAShardMainPostConditions()
}

AddFunction DemonologyNetherPortalActiveShortCdActions
{
 #summon_vilefiend,if=cooldown.summon_demonic_tyrant.remains>40|cooldown.summon_demonic_tyrant.remains<12
 if SpellCooldown(summon_demonic_tyrant) > 40 or SpellCooldown(summon_demonic_tyrant) < 12 Spell(summon_vilefiend)

 unless { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers)
 {
  #call_action_list,name=build_a_shard,if=soul_shard=1&(cooldown.call_dreadstalkers.remains<action.shadow_bolt.cast_time|(talent.bilescourge_bombers.enabled&cooldown.bilescourge_bombers.remains<action.shadow_bolt.cast_time))
  if SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } DemonologyBuildAShardShortCdActions()

  unless SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } and DemonologyBuildAShardShortCdPostConditions() or SpellCooldown(call_dreadstalkers) > CastTime(demonbolt) and SpellCooldown(call_dreadstalkers) > CastTime(shadow_bolt) and SpellCooldown(nether_portal) > 160 + CastTime(hand_of_guldan) and Spell(hand_of_guldan)
  {
   #summon_demonic_tyrant,if=buff.nether_portal.remains<10&soul_shard=0
   if BuffRemaining(nether_portal_buff) < 10 and SoulShards() == 0 Spell(summon_demonic_tyrant)
   #summon_demonic_tyrant,if=buff.nether_portal.remains<action.summon_demonic_tyrant.cast_time+5.5
   if BuffRemaining(nether_portal_buff) < CastTime(summon_demonic_tyrant) + 5.5 Spell(summon_demonic_tyrant)

   unless BuffPresent(demonic_core_buff) and Spell(demonbolt)
   {
    #call_action_list,name=build_a_shard
    DemonologyBuildAShardShortCdActions()
   }
  }
 }
}

AddFunction DemonologyNetherPortalActiveShortCdPostConditions
{
 { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } and DemonologyBuildAShardShortCdPostConditions() or SpellCooldown(call_dreadstalkers) > CastTime(demonbolt) and SpellCooldown(call_dreadstalkers) > CastTime(shadow_bolt) and SpellCooldown(nether_portal) > 160 + CastTime(hand_of_guldan) and Spell(hand_of_guldan) or BuffPresent(demonic_core_buff) and Spell(demonbolt) or DemonologyBuildAShardShortCdPostConditions()
}

AddFunction DemonologyNetherPortalActiveCdActions
{
 #grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
 if SpellCooldown(summon_demonic_tyrant) < 13 or not HasEquippedItem(132369) Spell(grimoire_felguard)

 unless { SpellCooldown(summon_demonic_tyrant) > 40 or SpellCooldown(summon_demonic_tyrant) < 12 } and Spell(summon_vilefiend) or { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers)
 {
  #call_action_list,name=build_a_shard,if=soul_shard=1&(cooldown.call_dreadstalkers.remains<action.shadow_bolt.cast_time|(talent.bilescourge_bombers.enabled&cooldown.bilescourge_bombers.remains<action.shadow_bolt.cast_time))
  if SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } DemonologyBuildAShardCdActions()

  unless SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } and DemonologyBuildAShardCdPostConditions() or SpellCooldown(call_dreadstalkers) > CastTime(demonbolt) and SpellCooldown(call_dreadstalkers) > CastTime(shadow_bolt) and SpellCooldown(nether_portal) > 160 + CastTime(hand_of_guldan) and Spell(hand_of_guldan) or BuffRemaining(nether_portal_buff) < 10 and SoulShards() == 0 and Spell(summon_demonic_tyrant) or BuffRemaining(nether_portal_buff) < CastTime(summon_demonic_tyrant) + 5.5 and Spell(summon_demonic_tyrant) or BuffPresent(demonic_core_buff) and Spell(demonbolt)
  {
   #call_action_list,name=build_a_shard
   DemonologyBuildAShardCdActions()
  }
 }
}

AddFunction DemonologyNetherPortalActiveCdPostConditions
{
 { SpellCooldown(summon_demonic_tyrant) > 40 or SpellCooldown(summon_demonic_tyrant) < 12 } and Spell(summon_vilefiend) or { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } and DemonologyBuildAShardCdPostConditions() or SpellCooldown(call_dreadstalkers) > CastTime(demonbolt) and SpellCooldown(call_dreadstalkers) > CastTime(shadow_bolt) and SpellCooldown(nether_portal) > 160 + CastTime(hand_of_guldan) and Spell(hand_of_guldan) or BuffRemaining(nether_portal_buff) < 10 and SoulShards() == 0 and Spell(summon_demonic_tyrant) or BuffRemaining(nether_portal_buff) < CastTime(summon_demonic_tyrant) + 5.5 and Spell(summon_demonic_tyrant) or BuffPresent(demonic_core_buff) and Spell(demonbolt) or DemonologyBuildAShardCdPostConditions()
}

### actions.nether_portal_building

AddFunction DemonologyNetherPortalBuildingMainActions
{
 #call_dreadstalkers
 Spell(call_dreadstalkers)
 #hand_of_guldan,if=cooldown.call_dreadstalkers.remains>18&soul_shard>=3
 if SpellCooldown(call_dreadstalkers) > 18 and SoulShards() >= 3 Spell(hand_of_guldan)
 #hand_of_guldan,if=soul_shard>=5
 if SoulShards() >= 5 Spell(hand_of_guldan)
 #call_action_list,name=build_a_shard
 DemonologyBuildAShardMainActions()
}

AddFunction DemonologyNetherPortalBuildingMainPostConditions
{
 DemonologyBuildAShardMainPostConditions()
}

AddFunction DemonologyNetherPortalBuildingShortCdActions
{
 unless Spell(call_dreadstalkers) or SpellCooldown(call_dreadstalkers) > 18 and SoulShards() >= 3 and Spell(hand_of_guldan)
 {
  #power_siphon,if=buff.wild_imps.stack>=2&buff.demonic_core.stack<=2&buff.demonic_power.down&soul_shard>=3
  if Demons(wild_imp) + Demons(wild_imp_id) >= 2 and BuffStacks(demonic_core_buff) <= 2 and BuffExpires(demonic_power_buff) and SoulShards() >= 3 Spell(power_siphon)

  unless SoulShards() >= 5 and Spell(hand_of_guldan)
  {
   #call_action_list,name=build_a_shard
   DemonologyBuildAShardShortCdActions()
  }
 }
}

AddFunction DemonologyNetherPortalBuildingShortCdPostConditions
{
 Spell(call_dreadstalkers) or SpellCooldown(call_dreadstalkers) > 18 and SoulShards() >= 3 and Spell(hand_of_guldan) or SoulShards() >= 5 and Spell(hand_of_guldan) or DemonologyBuildAShardShortCdPostConditions()
}

AddFunction DemonologyNetherPortalBuildingCdActions
{
 #nether_portal,if=soul_shard>=5&(!talent.power_siphon.enabled|buff.demonic_core.up)
 if SoulShards() >= 5 and { not Talent(power_siphon_talent) or BuffPresent(demonic_core_buff) } Spell(nether_portal)

 unless Spell(call_dreadstalkers) or SpellCooldown(call_dreadstalkers) > 18 and SoulShards() >= 3 and Spell(hand_of_guldan) or Demons(wild_imp) + Demons(wild_imp_id) >= 2 and BuffStacks(demonic_core_buff) <= 2 and BuffExpires(demonic_power_buff) and SoulShards() >= 3 and Spell(power_siphon) or SoulShards() >= 5 and Spell(hand_of_guldan)
 {
  #call_action_list,name=build_a_shard
  DemonologyBuildAShardCdActions()
 }
}

AddFunction DemonologyNetherPortalBuildingCdPostConditions
{
 Spell(call_dreadstalkers) or SpellCooldown(call_dreadstalkers) > 18 and SoulShards() >= 3 and Spell(hand_of_guldan) or Demons(wild_imp) + Demons(wild_imp_id) >= 2 and BuffStacks(demonic_core_buff) <= 2 and BuffExpires(demonic_power_buff) and SoulShards() >= 3 and Spell(power_siphon) or SoulShards() >= 5 and Spell(hand_of_guldan) or DemonologyBuildAShardCdPostConditions()
}

### actions.precombat

AddFunction DemonologyPrecombatMainActions
{
 #demonbolt
 Spell(demonbolt)
}

AddFunction DemonologyPrecombatMainPostConditions
{
}

AddFunction DemonologyPrecombatShortCdActions
{
 #flask
 #food
 #augmentation
 #summon_pet
 # if not pet.Present() Spell(summon_felguard)
}

AddFunction DemonologyPrecombatShortCdPostConditions
{
 Spell(demonbolt)
}
]]

	OvaleScripts:RegisterScript("WARLOCK", "demonology", name, desc, code, "script")
end
