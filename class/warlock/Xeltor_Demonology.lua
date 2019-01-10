local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_demonology"
	local desc = "[Xel][8.1] Warlock: Demonology"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_warlock_spells)

Define(spell_lock_fh 19647)
	SpellInfo(spell_lock_fh cd=24)
Define(pet_auto_spin 89751)
	SpellInfo(pet_auto_spin duration=5)

AddIcon specialization=2 help=main
{
	# Interrupt
	if InCombat() InterruptActions()
	
	# Save ass
	SaveActions()
	
	if wet() and not mounted() Spell(unending_breath)
	
	# Rotation
	if InCombat() and target.InRange(shadow_bolt) and HasFullControl()
    {
		#life_tap
		# if ManaPercent() <= 30 Spell(life_tap)
		PetStuff()
		if HealthPercent() < 30 and target.Present() and not target.IsFriend() and not Boss() and Speed() == 0 Spell(drain_life)
		
		# Control stuff
		
		if Speed() == 0 or CanMove() > 0
		{
			# Cooldowns
			if Boss() DemonologyDefaultCdActions()
			
			# Short Cooldowns
			DemonologyDefaultShortCdActions()
			
			# Default rotation
			DemonologyDefaultMainActions()
		}
		if Speed() > 0 and SoulShards() < 4 and BuffStacks(demonic_core_buff) >= 1 Spell(demonbolt)
	}
	
	if not InCombat() and not mounted() OutOfCombatActions()
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		# Felhunter Spell Lock
		if target.Distance() - pet.Distance() <= 40 and pet.CreatureFamily(Felhunter) Spell(spell_lock_fh)
		if pet.CreatureFamily(Felguard) and not target.Classification(worldboss) Spell(pet_axe_toss)
	}
}

AddFunction PetStuff
{
	if pet.Health() < pet.HealthMissing() and pet.Present() and Speed() == 0 and SpellUsable(health_funnel) Texture(ability_deathwing_bloodcorruption_death)
}

AddFunction SaveActions
{
	if HealthPercent() < 30 and InCombat() Spell(unending_resolve)
	if HealthPercent() < 30 and ItemCharges(healthstone) > 0 and Item(healthstone usable=1) Texture(inv_stone_04)
}

AddFunction OutOfCombatActions
{
	if not ItemCharges(healthstone) > 0 and Speed() == 0 and SpellUsable(create_healthstone) and not PreviousGCDSpell(create_healthstone) Texture(inv_misc_gem_bloodstone_01)
}

AddFunction DemonologyUseItemActions
{
	if Item(Trinket0Slot usable=1) Texture(inv_jewelry_talisman_12)
	if Item(Trinket1Slot usable=1) Texture(inv_jewelry_talisman_12)
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
   if HasEquippedItem(wilfreds_sigil_of_superior_summoning_item) or SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 Spell(call_dreadstalkers)
   #power_siphon,if=buff.wild_imps.stack>=2&buff.demonic_core.stack<=2&buff.demonic_power.down&spell_targets.implosion<2
   if Demons(wild_imp) >= 2 and BuffStacks(demonic_core_buff) <= 2 and DebuffExpires(demonic_power) and Enemies(tagged=1) < 2 Spell(power_siphon)
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
  #demonic_strength,if=(buff.wild_imps.stack<6|buff.demonic_power.up)|spell_targets.implosion<2
  if { Demons(wild_imp) < 6 or DebuffPresent(demonic_power) or Enemies(tagged=1) < 2 } and not pet.BuffPresent(pet_auto_spin) Spell(demonic_strength)
  #call_action_list,name=nether_portal,if=talent.nether_portal.enabled&spell_targets.implosion<=2
  if Talent(nether_portal_talent) and Enemies(tagged=1) <= 2 DemonologyNetherPortalShortCdActions()

  unless Talent(nether_portal_talent) and Enemies(tagged=1) <= 2 and DemonologyNetherPortalShortCdPostConditions()
  {
   #call_action_list,name=implosion,if=spell_targets.implosion>1
   if Enemies(tagged=1) > 1 DemonologyImplosionShortCdActions()

   unless Enemies(tagged=1) > 1 and DemonologyImplosionShortCdPostConditions()
   {
    #summon_vilefiend,if=equipped.132369|cooldown.summon_demonic_tyrant.remains>40|cooldown.summon_demonic_tyrant.remains<12
    if { HasEquippedItem(wilfreds_sigil_of_superior_summoning_item) or SpellCooldown(summon_demonic_tyrant) > 40 or SpellCooldown(summon_demonic_tyrant) < 12 } and Boss() Spell(summon_vilefiend)

    unless { HasEquippedItem(wilfreds_sigil_of_superior_summoning_item) or SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers)
    {
     #summon_demonic_tyrant,if=equipped.132369|(buff.dreadstalkers.remains>cast_time&(buff.wild_imps.stack>=3+talent.inner_demons.enabled+talent.demonic_consumption.enabled*3|prev_gcd.1.hand_of_guldan&(!talent.demonic_consumption.enabled|buff.wild_imps.stack>=3+talent.inner_demons.enabled))&(soul_shard<3|buff.dreadstalkers.remains<gcd*2.7|buff.grimoire_felguard.remains<gcd*2.7))
     if HasEquippedItem(wilfreds_sigil_of_superior_summoning_item) or DemonDuration(dreadstalker) > CastTime(summon_demonic_tyrant) and { Demons(wild_imp) >= 3 + TalentPoints(inner_demons_talent) + TalentPoints(demonic_consumption_talent) * 3 or PreviousGCDSpell(hand_of_guldan) and { not Talent(demonic_consumption_talent) or Demons(wild_imp) >= 3 + TalentPoints(inner_demons_talent) } } and { SoulShards() < 3 or DemonDuration(dreadstalker) < GCD() * 2.7 or DebuffRemaining(grimoire_felguard) < GCD() * 2.7 } Spell(summon_demonic_tyrant)

     unless Demons(wild_imp) >= 2 and BuffStacks(demonic_core_buff) <= 2 and DebuffExpires(demonic_power) and Enemies(tagged=1) < 2 and Spell(power_siphon) or Talent(doom_talent) and target.Refreshable(doom_debuff) and target.TimeToDie() > target.DebuffRemaining(doom_debuff) + 30 and Spell(doom) or { SoulShards() >= 5 or SoulShards() >= 3 and SpellCooldown(call_dreadstalkers) > 4 and { not Talent(summon_vilefiend_talent) or SpellCooldown(summon_vilefiend) > 3 } } and Spell(hand_of_guldan) or SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { SpellCooldown(summon_demonic_tyrant) < 10 or SpellCooldown(summon_demonic_tyrant) > 22 or BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) < 5 or target.TimeToDie() < 25 } and Spell(demonbolt)
     {
      #bilescourge_bombers
      Spell(bilescourge_bombers)
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
 not target.DebuffPresent(doom_debuff) and target.TimeToDie() > 30 and Enemies(tagged=1) < 2 and Spell(doom) or Talent(nether_portal_talent) and Enemies(tagged=1) <= 2 and DemonologyNetherPortalShortCdPostConditions() or Enemies(tagged=1) > 1 and DemonologyImplosionShortCdPostConditions() or { HasEquippedItem(wilfreds_sigil_of_superior_summoning_item) or SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or Demons(wild_imp) >= 2 and BuffStacks(demonic_core_buff) <= 2 and DebuffExpires(demonic_power) and Enemies(tagged=1) < 2 and Spell(power_siphon) or Talent(doom_talent) and target.Refreshable(doom_debuff) and target.TimeToDie() > target.DebuffRemaining(doom_debuff) + 30 and Spell(doom) or { SoulShards() >= 5 or SoulShards() >= 3 and SpellCooldown(call_dreadstalkers) > 4 and { not Talent(summon_vilefiend_talent) or SpellCooldown(summon_vilefiend) > 3 } } and Spell(hand_of_guldan) or SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { SpellCooldown(summon_demonic_tyrant) < 10 or SpellCooldown(summon_demonic_tyrant) > 22 or BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) < 5 or target.TimeToDie() < 25 } and Spell(demonbolt) or DemonologyBuildAShardShortCdPostConditions()
}

AddFunction DemonologyDefaultCdActions
{
 #potion,if=pet.demonic_tyrant.active|target.time_to_die<30
 # if { DemonDuration(demonic_tyrant) > 0 or target.TimeToDie() < 30 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_intellect usable=1)
 #use_items,if=pet.demonic_tyrant.active|target.time_to_die<=15
 if DemonDuration(demonic_tyrant) > 0 or target.TimeToDie() <= 15 DemonologyUseItemActions()
 #berserking,if=pet.demonic_tyrant.active|target.time_to_die<=15
 if DemonDuration(demonic_tyrant) > 0 or target.TimeToDie() <= 15 Spell(berserking)
 #blood_fury,if=pet.demonic_tyrant.active|target.time_to_die<=15
 if DemonDuration(demonic_tyrant) > 0 or target.TimeToDie() <= 15 Spell(blood_fury_sp)
 #fireblood,if=pet.demonic_tyrant.active|target.time_to_die<=15
 if DemonDuration(demonic_tyrant) > 0 or target.TimeToDie() <= 15 Spell(fireblood)

 unless not target.DebuffPresent(doom_debuff) and target.TimeToDie() > 30 and Enemies(tagged=1) < 2 and Spell(doom) or { Demons(wild_imp) < 6 or DebuffPresent(demonic_power) or Enemies(tagged=1) < 2 } and Spell(demonic_strength)
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
    if SpellCooldown(summon_demonic_tyrant) < 13 or not HasEquippedItem(wilfreds_sigil_of_superior_summoning_item) Spell(grimoire_felguard)

    unless { HasEquippedItem(wilfreds_sigil_of_superior_summoning_item) or SpellCooldown(summon_demonic_tyrant) > 40 or SpellCooldown(summon_demonic_tyrant) < 12 } and Spell(summon_vilefiend) or { HasEquippedItem(wilfreds_sigil_of_superior_summoning_item) or SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or { HasEquippedItem(wilfreds_sigil_of_superior_summoning_item) or DemonDuration(dreadstalker) > CastTime(summon_demonic_tyrant) and { Demons(wild_imp) >= 3 + TalentPoints(inner_demons_talent) + TalentPoints(demonic_consumption_talent) * 3 or PreviousGCDSpell(hand_of_guldan) and { not Talent(demonic_consumption_talent) or Demons(wild_imp) >= 3 + TalentPoints(inner_demons_talent) } } and { SoulShards() < 3 or DemonDuration(dreadstalker) < GCD() * 2.7 or DebuffRemaining(grimoire_felguard) < GCD() * 2.7 } } and Spell(summon_demonic_tyrant) or Demons(wild_imp) >= 2 and BuffStacks(demonic_core_buff) <= 2 and DebuffExpires(demonic_power) and Enemies(tagged=1) < 2 and Spell(power_siphon) or Talent(doom_talent) and target.Refreshable(doom_debuff) and target.TimeToDie() > target.DebuffRemaining(doom_debuff) + 30 and Spell(doom) or { SoulShards() >= 5 or SoulShards() >= 3 and SpellCooldown(call_dreadstalkers) > 4 and { not Talent(summon_vilefiend_talent) or SpellCooldown(summon_vilefiend) > 3 } } and Spell(hand_of_guldan) or SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { SpellCooldown(summon_demonic_tyrant) < 10 or SpellCooldown(summon_demonic_tyrant) > 22 or BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) < 5 or target.TimeToDie() < 25 } and Spell(demonbolt) or Spell(bilescourge_bombers)
    {
     #call_action_list,name=build_a_shard
     DemonologyBuildAShardCdActions()
    }
   }
  }
 }
}

AddFunction DemonologyDefaultCdPostConditions
{
 not target.DebuffPresent(doom_debuff) and target.TimeToDie() > 30 and Enemies(tagged=1) < 2 and Spell(doom) or { Demons(wild_imp) < 6 or DebuffPresent(demonic_power) or Enemies(tagged=1) < 2 } and Spell(demonic_strength) or Talent(nether_portal_talent) and Enemies(tagged=1) <= 2 and DemonologyNetherPortalCdPostConditions() or Enemies(tagged=1) > 1 and DemonologyImplosionCdPostConditions() or { HasEquippedItem(wilfreds_sigil_of_superior_summoning_item) or SpellCooldown(summon_demonic_tyrant) > 40 or SpellCooldown(summon_demonic_tyrant) < 12 } and Spell(summon_vilefiend) or { HasEquippedItem(wilfreds_sigil_of_superior_summoning_item) or SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or { HasEquippedItem(wilfreds_sigil_of_superior_summoning_item) or DemonDuration(dreadstalker) > CastTime(summon_demonic_tyrant) and { Demons(wild_imp) >= 3 + TalentPoints(inner_demons_talent) + TalentPoints(demonic_consumption_talent) * 3 or PreviousGCDSpell(hand_of_guldan) and { not Talent(demonic_consumption_talent) or Demons(wild_imp) >= 3 + TalentPoints(inner_demons_talent) } } and { SoulShards() < 3 or DemonDuration(dreadstalker) < GCD() * 2.7 or DebuffRemaining(grimoire_felguard) < GCD() * 2.7 } } and Spell(summon_demonic_tyrant) or Demons(wild_imp) >= 2 and BuffStacks(demonic_core_buff) <= 2 and DebuffExpires(demonic_power) and Enemies(tagged=1) < 2 and Spell(power_siphon) or Talent(doom_talent) and target.Refreshable(doom_debuff) and target.TimeToDie() > target.DebuffRemaining(doom_debuff) + 30 and Spell(doom) or { SoulShards() >= 5 or SoulShards() >= 3 and SpellCooldown(call_dreadstalkers) > 4 and { not Talent(summon_vilefiend_talent) or SpellCooldown(summon_vilefiend) > 3 } } and Spell(hand_of_guldan) or SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { SpellCooldown(summon_demonic_tyrant) < 10 or SpellCooldown(summon_demonic_tyrant) > 22 or BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) < 5 or target.TimeToDie() < 25 } and Spell(demonbolt) or Spell(bilescourge_bombers) or DemonologyBuildAShardCdPostConditions()
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
 #implosion,if=(buff.wild_imps.stack>=6&(soul_shard<3|prev_gcd.1.call_dreadstalkers|buff.wild_imps.stack>=9|prev_gcd.1.bilescourge_bombers|(!prev_gcd.1.hand_of_guldan&!prev_gcd.2.hand_of_guldan))&!prev_gcd.1.hand_of_guldan&!prev_gcd.2.hand_of_guldan&buff.demonic_power.down)|(time_to_die<3&buff.wild_imps.stack>0)|(prev_gcd.2.call_dreadstalkers&buff.wild_imps.stack>2&!talent.demonic_calling.enabled)
 if Demons(wild_imp) >= 6 and { SoulShards() < 3 or PreviousGCDSpell(call_dreadstalkers) or Demons(wild_imp) >= 9 or PreviousGCDSpell(bilescourge_bombers) or not PreviousGCDSpell(hand_of_guldan) and not PreviousGCDSpell(hand_of_guldan) } and not PreviousGCDSpell(hand_of_guldan) and not PreviousGCDSpell(hand_of_guldan) and DebuffExpires(demonic_power) or target.TimeToDie() < 3 and Demons(wild_imp) > 0 or PreviousGCDSpell(call_dreadstalkers count=2) and Demons(wild_imp) > 2 and not Talent(demonic_calling_talent) Spell(implosion)
 #call_dreadstalkers,if=(cooldown.summon_demonic_tyrant.remains<9&buff.demonic_calling.remains)|(cooldown.summon_demonic_tyrant.remains<11&!buff.demonic_calling.remains)|cooldown.summon_demonic_tyrant.remains>14
 if SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 Spell(call_dreadstalkers)
 #hand_of_guldan,if=soul_shard>=5
 if SoulShards() >= 5 Spell(hand_of_guldan)
 #hand_of_guldan,if=soul_shard>=3&(((prev_gcd.2.hand_of_guldan|buff.wild_imps.stack>=3)&buff.wild_imps.stack<9)|cooldown.summon_demonic_tyrant.remains<=gcd*2|buff.demonic_power.remains>gcd*2)
 if SoulShards() >= 3 and { { PreviousGCDSpell(hand_of_guldan) or Demons(wild_imp) >= 3 } and Demons(wild_imp) < 9 or SpellCooldown(summon_demonic_tyrant) <= GCD() * 2 or DebuffRemaining(demonic_power) > GCD() * 2 } Spell(hand_of_guldan)
 #demonbolt,if=prev_gcd.1.hand_of_guldan&soul_shard>=1&(buff.wild_imps.stack<=3|prev_gcd.3.hand_of_guldan)&soul_shard<4&buff.demonic_core.up
 if PreviousGCDSpell(hand_of_guldan) and SoulShards() >= 1 and { Demons(wild_imp) <= 3 or PreviousGCDSpell(hand_of_guldan) } and SoulShards() < 4 and BuffPresent(demonic_core_buff) Spell(demonbolt)
 #soul_strike,if=soul_shard<5&buff.demonic_core.stack<=2
 if SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 Spell(soul_strike)
 #demonbolt,if=soul_shard<=3&buff.demonic_core.up&(buff.demonic_core.stack>=3|buff.demonic_core.remains<=gcd*5.7)
 if SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) <= GCD() * 5.7 } Spell(demonbolt)
 #doom,cycle_targets=1,max_cycle_targets=7,if=refreshable
 if DebuffCountOnAny(doom_debuff) < Enemies(tagged=1) and DebuffCountOnAny(doom_debuff) <= 7 and target.Refreshable(doom_debuff) Spell(doom)
 #call_action_list,name=build_a_shard
 DemonologyBuildAShardMainActions()
}

AddFunction DemonologyImplosionMainPostConditions
{
 DemonologyBuildAShardMainPostConditions()
}

AddFunction DemonologyImplosionShortCdActions
{
 unless { Demons(wild_imp) >= 6 and { SoulShards() < 3 or PreviousGCDSpell(call_dreadstalkers) or Demons(wild_imp) >= 9 or PreviousGCDSpell(bilescourge_bombers) or not PreviousGCDSpell(hand_of_guldan) and not PreviousGCDSpell(hand_of_guldan) } and not PreviousGCDSpell(hand_of_guldan) and not PreviousGCDSpell(hand_of_guldan) and DebuffExpires(demonic_power) or target.TimeToDie() < 3 and Demons(wild_imp) > 0 or PreviousGCDSpell(call_dreadstalkers count=2) and Demons(wild_imp) > 2 and not Talent(demonic_calling_talent) } and Spell(implosion) or { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers)
 {
  #summon_demonic_tyrant
  Spell(summon_demonic_tyrant)

  unless SoulShards() >= 5 and Spell(hand_of_guldan) or SoulShards() >= 3 and { { PreviousGCDSpell(hand_of_guldan) or Demons(wild_imp) >= 3 } and Demons(wild_imp) < 9 or SpellCooldown(summon_demonic_tyrant) <= GCD() * 2 or DebuffRemaining(demonic_power) > GCD() * 2 } and Spell(hand_of_guldan) or PreviousGCDSpell(hand_of_guldan) and SoulShards() >= 1 and { Demons(wild_imp) <= 3 or PreviousGCDSpell(hand_of_guldan) } and SoulShards() < 4 and BuffPresent(demonic_core_buff) and Spell(demonbolt)
  {
   #summon_vilefiend,if=(cooldown.summon_demonic_tyrant.remains>40&spell_targets.implosion<=2)|cooldown.summon_demonic_tyrant.remains<12
   if { SpellCooldown(summon_demonic_tyrant) > 40 and Enemies(tagged=1) <= 2 or SpellCooldown(summon_demonic_tyrant) < 12 } and Boss() Spell(summon_vilefiend)
   #bilescourge_bombers,if=cooldown.summon_demonic_tyrant.remains>9
   if SpellCooldown(summon_demonic_tyrant) > 9 Spell(bilescourge_bombers)

   unless SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) <= GCD() * 5.7 } and Spell(demonbolt) or DebuffCountOnAny(doom_debuff) < Enemies(tagged=1) and DebuffCountOnAny(doom_debuff) <= 7 and target.Refreshable(doom_debuff) and Spell(doom)
   {
    #call_action_list,name=build_a_shard
    DemonologyBuildAShardShortCdActions()
   }
  }
 }
}

AddFunction DemonologyImplosionShortCdPostConditions
{
 { Demons(wild_imp) >= 6 and { SoulShards() < 3 or PreviousGCDSpell(call_dreadstalkers) or Demons(wild_imp) >= 9 or PreviousGCDSpell(bilescourge_bombers) or not PreviousGCDSpell(hand_of_guldan) and not PreviousGCDSpell(hand_of_guldan) } and not PreviousGCDSpell(hand_of_guldan) and not PreviousGCDSpell(hand_of_guldan) and DebuffExpires(demonic_power) or target.TimeToDie() < 3 and Demons(wild_imp) > 0 or PreviousGCDSpell(call_dreadstalkers count=2) and Demons(wild_imp) > 2 and not Talent(demonic_calling_talent) } and Spell(implosion) or { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or SoulShards() >= 5 and Spell(hand_of_guldan) or SoulShards() >= 3 and { { PreviousGCDSpell(hand_of_guldan) or Demons(wild_imp) >= 3 } and Demons(wild_imp) < 9 or SpellCooldown(summon_demonic_tyrant) <= GCD() * 2 or DebuffRemaining(demonic_power) > GCD() * 2 } and Spell(hand_of_guldan) or PreviousGCDSpell(hand_of_guldan) and SoulShards() >= 1 and { Demons(wild_imp) <= 3 or PreviousGCDSpell(hand_of_guldan) } and SoulShards() < 4 and BuffPresent(demonic_core_buff) and Spell(demonbolt) or SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) <= GCD() * 5.7 } and Spell(demonbolt) or DebuffCountOnAny(doom_debuff) < Enemies(tagged=1) and DebuffCountOnAny(doom_debuff) <= 7 and target.Refreshable(doom_debuff) and Spell(doom) or DemonologyBuildAShardShortCdPostConditions()
}

AddFunction DemonologyImplosionCdActions
{
 unless { Demons(wild_imp) >= 6 and { SoulShards() < 3 or PreviousGCDSpell(call_dreadstalkers) or Demons(wild_imp) >= 9 or PreviousGCDSpell(bilescourge_bombers) or not PreviousGCDSpell(hand_of_guldan) and not PreviousGCDSpell(hand_of_guldan) } and not PreviousGCDSpell(hand_of_guldan) and not PreviousGCDSpell(hand_of_guldan) and DebuffExpires(demonic_power) or target.TimeToDie() < 3 and Demons(wild_imp) > 0 or PreviousGCDSpell(call_dreadstalkers count=2) and Demons(wild_imp) > 2 and not Talent(demonic_calling_talent) } and Spell(implosion)
 {
  #grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
  if SpellCooldown(summon_demonic_tyrant) < 13 or not HasEquippedItem(wilfreds_sigil_of_superior_summoning_item) Spell(grimoire_felguard)

  unless { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or Spell(summon_demonic_tyrant) or SoulShards() >= 5 and Spell(hand_of_guldan) or SoulShards() >= 3 and { { PreviousGCDSpell(hand_of_guldan) or Demons(wild_imp) >= 3 } and Demons(wild_imp) < 9 or SpellCooldown(summon_demonic_tyrant) <= GCD() * 2 or DebuffRemaining(demonic_power) > GCD() * 2 } and Spell(hand_of_guldan) or PreviousGCDSpell(hand_of_guldan) and SoulShards() >= 1 and { Demons(wild_imp) <= 3 or PreviousGCDSpell(hand_of_guldan) } and SoulShards() < 4 and BuffPresent(demonic_core_buff) and Spell(demonbolt) or { SpellCooldown(summon_demonic_tyrant) > 40 and Enemies(tagged=1) <= 2 or SpellCooldown(summon_demonic_tyrant) < 12 } and Spell(summon_vilefiend) or SpellCooldown(summon_demonic_tyrant) > 9 and Spell(bilescourge_bombers) or SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) <= GCD() * 5.7 } and Spell(demonbolt) or DebuffCountOnAny(doom_debuff) < Enemies(tagged=1) and DebuffCountOnAny(doom_debuff) <= 7 and target.Refreshable(doom_debuff) and Spell(doom)
  {
   #call_action_list,name=build_a_shard
   DemonologyBuildAShardCdActions()
  }
 }
}

AddFunction DemonologyImplosionCdPostConditions
{
 { Demons(wild_imp) >= 6 and { SoulShards() < 3 or PreviousGCDSpell(call_dreadstalkers) or Demons(wild_imp) >= 9 or PreviousGCDSpell(bilescourge_bombers) or not PreviousGCDSpell(hand_of_guldan) and not PreviousGCDSpell(hand_of_guldan) } and not PreviousGCDSpell(hand_of_guldan) and not PreviousGCDSpell(hand_of_guldan) and DebuffExpires(demonic_power) or target.TimeToDie() < 3 and Demons(wild_imp) > 0 or PreviousGCDSpell(call_dreadstalkers count=2) and Demons(wild_imp) > 2 and not Talent(demonic_calling_talent) } and Spell(implosion) or { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or Spell(summon_demonic_tyrant) or SoulShards() >= 5 and Spell(hand_of_guldan) or SoulShards() >= 3 and { { PreviousGCDSpell(hand_of_guldan) or Demons(wild_imp) >= 3 } and Demons(wild_imp) < 9 or SpellCooldown(summon_demonic_tyrant) <= GCD() * 2 or DebuffRemaining(demonic_power) > GCD() * 2 } and Spell(hand_of_guldan) or PreviousGCDSpell(hand_of_guldan) and SoulShards() >= 1 and { Demons(wild_imp) <= 3 or PreviousGCDSpell(hand_of_guldan) } and SoulShards() < 4 and BuffPresent(demonic_core_buff) and Spell(demonbolt) or { SpellCooldown(summon_demonic_tyrant) > 40 and Enemies(tagged=1) <= 2 or SpellCooldown(summon_demonic_tyrant) < 12 } and Spell(summon_vilefiend) or SpellCooldown(summon_demonic_tyrant) > 9 and Spell(bilescourge_bombers) or SoulShards() < 5 and BuffStacks(demonic_core_buff) <= 2 and Spell(soul_strike) or SoulShards() <= 3 and BuffPresent(demonic_core_buff) and { BuffStacks(demonic_core_buff) >= 3 or BuffRemaining(demonic_core_buff) <= GCD() * 5.7 } and Spell(demonbolt) or DebuffCountOnAny(doom_debuff) < Enemies(tagged=1) and DebuffCountOnAny(doom_debuff) <= 7 and target.Refreshable(doom_debuff) and Spell(doom) or DemonologyBuildAShardCdPostConditions()
}

### actions.nether_portal

AddFunction DemonologyNetherPortalMainActions
{
 #call_action_list,name=nether_portal_building,if=cooldown.nether_portal.remains<20
 if SpellCooldown(nether_portal) < 20 DemonologyNetherPortalBuildingMainActions()

 unless SpellCooldown(nether_portal) < 20 and DemonologyNetherPortalBuildingMainPostConditions()
 {
  #call_action_list,name=nether_portal_active,if=cooldown.nether_portal.remains>165
  if SpellCooldown(nether_portal) > 165 DemonologyNetherPortalActiveMainActions()
 }
}

AddFunction DemonologyNetherPortalMainPostConditions
{
 SpellCooldown(nether_portal) < 20 and DemonologyNetherPortalBuildingMainPostConditions() or SpellCooldown(nether_portal) > 165 and DemonologyNetherPortalActiveMainPostConditions()
}

AddFunction DemonologyNetherPortalShortCdActions
{
 #call_action_list,name=nether_portal_building,if=cooldown.nether_portal.remains<20
 if SpellCooldown(nether_portal) < 20 DemonologyNetherPortalBuildingShortCdActions()

 unless SpellCooldown(nether_portal) < 20 and DemonologyNetherPortalBuildingShortCdPostConditions()
 {
  #call_action_list,name=nether_portal_active,if=cooldown.nether_portal.remains>165
  if SpellCooldown(nether_portal) > 165 DemonologyNetherPortalActiveShortCdActions()
 }
}

AddFunction DemonologyNetherPortalShortCdPostConditions
{
 SpellCooldown(nether_portal) < 20 and DemonologyNetherPortalBuildingShortCdPostConditions() or SpellCooldown(nether_portal) > 165 and DemonologyNetherPortalActiveShortCdPostConditions()
}

AddFunction DemonologyNetherPortalCdActions
{
 #call_action_list,name=nether_portal_building,if=cooldown.nether_portal.remains<20
 if SpellCooldown(nether_portal) < 20 DemonologyNetherPortalBuildingCdActions()

 unless SpellCooldown(nether_portal) < 20 and DemonologyNetherPortalBuildingCdPostConditions()
 {
  #call_action_list,name=nether_portal_active,if=cooldown.nether_portal.remains>165
  if SpellCooldown(nether_portal) > 165 DemonologyNetherPortalActiveCdActions()
 }
}

AddFunction DemonologyNetherPortalCdPostConditions
{
 SpellCooldown(nether_portal) < 20 and DemonologyNetherPortalBuildingCdPostConditions() or SpellCooldown(nether_portal) > 165 and DemonologyNetherPortalActiveCdPostConditions()
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
  #hand_of_guldan,if=((cooldown.call_dreadstalkers.remains>action.demonbolt.cast_time)&(cooldown.call_dreadstalkers.remains>action.shadow_bolt.cast_time))&cooldown.nether_portal.remains>(165+action.hand_of_guldan.cast_time)
  if SpellCooldown(call_dreadstalkers) > CastTime(demonbolt) and SpellCooldown(call_dreadstalkers) > CastTime(shadow_bolt) and SpellCooldown(nether_portal) > 165 + CastTime(hand_of_guldan) Spell(hand_of_guldan)
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
 #bilescourge_bombers
 Spell(bilescourge_bombers)
 #summon_vilefiend,if=cooldown.summon_demonic_tyrant.remains>40|cooldown.summon_demonic_tyrant.remains<12
 if SpellCooldown(summon_demonic_tyrant) > 40 or SpellCooldown(summon_demonic_tyrant) < 12 Spell(summon_vilefiend)

 unless { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers)
 {
  #call_action_list,name=build_a_shard,if=soul_shard=1&(cooldown.call_dreadstalkers.remains<action.shadow_bolt.cast_time|(talent.bilescourge_bombers.enabled&cooldown.bilescourge_bombers.remains<action.shadow_bolt.cast_time))
  if SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } DemonologyBuildAShardShortCdActions()

  unless SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } and DemonologyBuildAShardShortCdPostConditions() or SpellCooldown(call_dreadstalkers) > CastTime(demonbolt) and SpellCooldown(call_dreadstalkers) > CastTime(shadow_bolt) and SpellCooldown(nether_portal) > 165 + CastTime(hand_of_guldan) and Spell(hand_of_guldan)
  {
   #summon_demonic_tyrant,if=buff.nether_portal.remains<5&soul_shard=0
   if BuffRemaining(nether_portal_buff) < 5 and SoulShards() == 0 Spell(summon_demonic_tyrant)
   #summon_demonic_tyrant,if=buff.nether_portal.remains<action.summon_demonic_tyrant.cast_time+0.5
   if BuffRemaining(nether_portal_buff) < CastTime(summon_demonic_tyrant) + 0.5 Spell(summon_demonic_tyrant)

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
 { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } and DemonologyBuildAShardShortCdPostConditions() or SpellCooldown(call_dreadstalkers) > CastTime(demonbolt) and SpellCooldown(call_dreadstalkers) > CastTime(shadow_bolt) and SpellCooldown(nether_portal) > 165 + CastTime(hand_of_guldan) and Spell(hand_of_guldan) or BuffPresent(demonic_core_buff) and Spell(demonbolt) or DemonologyBuildAShardShortCdPostConditions()
}

AddFunction DemonologyNetherPortalActiveCdActions
{
 unless Spell(bilescourge_bombers)
 {
  #grimoire_felguard,if=cooldown.summon_demonic_tyrant.remains<13|!equipped.132369
  if SpellCooldown(summon_demonic_tyrant) < 13 or not HasEquippedItem(wilfreds_sigil_of_superior_summoning_item) Spell(grimoire_felguard)

  unless { SpellCooldown(summon_demonic_tyrant) > 40 or SpellCooldown(summon_demonic_tyrant) < 12 } and Spell(summon_vilefiend) or { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers)
  {
   #call_action_list,name=build_a_shard,if=soul_shard=1&(cooldown.call_dreadstalkers.remains<action.shadow_bolt.cast_time|(talent.bilescourge_bombers.enabled&cooldown.bilescourge_bombers.remains<action.shadow_bolt.cast_time))
   if SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } DemonologyBuildAShardCdActions()

   unless SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } and DemonologyBuildAShardCdPostConditions() or SpellCooldown(call_dreadstalkers) > CastTime(demonbolt) and SpellCooldown(call_dreadstalkers) > CastTime(shadow_bolt) and SpellCooldown(nether_portal) > 165 + CastTime(hand_of_guldan) and Spell(hand_of_guldan) or BuffRemaining(nether_portal_buff) < 5 and SoulShards() == 0 and Spell(summon_demonic_tyrant) or BuffRemaining(nether_portal_buff) < CastTime(summon_demonic_tyrant) + 0.5 and Spell(summon_demonic_tyrant) or BuffPresent(demonic_core_buff) and Spell(demonbolt)
   {
    #call_action_list,name=build_a_shard
    DemonologyBuildAShardCdActions()
   }
  }
 }
}

AddFunction DemonologyNetherPortalActiveCdPostConditions
{
 Spell(bilescourge_bombers) or { SpellCooldown(summon_demonic_tyrant) > 40 or SpellCooldown(summon_demonic_tyrant) < 12 } and Spell(summon_vilefiend) or { SpellCooldown(summon_demonic_tyrant) < 9 and BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) < 11 and not BuffPresent(demonic_calling_buff) or SpellCooldown(summon_demonic_tyrant) > 14 } and Spell(call_dreadstalkers) or SoulShards() == 1 and { SpellCooldown(call_dreadstalkers) < CastTime(shadow_bolt) or Talent(bilescourge_bombers_talent) and SpellCooldown(bilescourge_bombers) < CastTime(shadow_bolt) } and DemonologyBuildAShardCdPostConditions() or SpellCooldown(call_dreadstalkers) > CastTime(demonbolt) and SpellCooldown(call_dreadstalkers) > CastTime(shadow_bolt) and SpellCooldown(nether_portal) > 165 + CastTime(hand_of_guldan) and Spell(hand_of_guldan) or BuffRemaining(nether_portal_buff) < 5 and SoulShards() == 0 and Spell(summon_demonic_tyrant) or BuffRemaining(nether_portal_buff) < CastTime(summon_demonic_tyrant) + 0.5 and Spell(summon_demonic_tyrant) or BuffPresent(demonic_core_buff) and Spell(demonbolt) or DemonologyBuildAShardCdPostConditions()
}

### actions.nether_portal_building

AddFunction DemonologyNetherPortalBuildingMainActions
{
 #call_dreadstalkers
 Spell(call_dreadstalkers)
 #hand_of_guldan,if=cooldown.call_dreadstalkers.remains>18&soul_shard>=3
 if SpellCooldown(call_dreadstalkers) > 18 and SoulShards() >= 3 Spell(hand_of_guldan)
 #power_siphon,if=buff.wild_imps.stack>=2&buff.demonic_core.stack<=2&buff.demonic_power.down&soul_shard>=3
 if Demons(wild_imp) >= 2 and BuffStacks(demonic_core_buff) <= 2 and DebuffExpires(demonic_power) and SoulShards() >= 3 Spell(power_siphon)
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
 unless Spell(call_dreadstalkers) or SpellCooldown(call_dreadstalkers) > 18 and SoulShards() >= 3 and Spell(hand_of_guldan) or Demons(wild_imp) >= 2 and BuffStacks(demonic_core_buff) <= 2 and DebuffExpires(demonic_power) and SoulShards() >= 3 and Spell(power_siphon) or SoulShards() >= 5 and Spell(hand_of_guldan)
 {
  #call_action_list,name=build_a_shard
  DemonologyBuildAShardShortCdActions()
 }
}

AddFunction DemonologyNetherPortalBuildingShortCdPostConditions
{
 Spell(call_dreadstalkers) or SpellCooldown(call_dreadstalkers) > 18 and SoulShards() >= 3 and Spell(hand_of_guldan) or Demons(wild_imp) >= 2 and BuffStacks(demonic_core_buff) <= 2 and DebuffExpires(demonic_power) and SoulShards() >= 3 and Spell(power_siphon) or SoulShards() >= 5 and Spell(hand_of_guldan) or DemonologyBuildAShardShortCdPostConditions()
}

AddFunction DemonologyNetherPortalBuildingCdActions
{
 #nether_portal,if=soul_shard>=5&(!talent.power_siphon.enabled|buff.demonic_core.up)
 if SoulShards() >= 5 and { not Talent(power_siphon_talent) or BuffPresent(demonic_core_buff) } Spell(nether_portal)

 unless Spell(call_dreadstalkers) or SpellCooldown(call_dreadstalkers) > 18 and SoulShards() >= 3 and Spell(hand_of_guldan) or Demons(wild_imp) >= 2 and BuffStacks(demonic_core_buff) <= 2 and DebuffExpires(demonic_power) and SoulShards() >= 3 and Spell(power_siphon) or SoulShards() >= 5 and Spell(hand_of_guldan)
 {
  #call_action_list,name=build_a_shard
  DemonologyBuildAShardCdActions()
 }
}

AddFunction DemonologyNetherPortalBuildingCdPostConditions
{
 Spell(call_dreadstalkers) or SpellCooldown(call_dreadstalkers) > 18 and SoulShards() >= 3 and Spell(hand_of_guldan) or Demons(wild_imp) >= 2 and BuffStacks(demonic_core_buff) <= 2 and DebuffExpires(demonic_power) and SoulShards() >= 3 and Spell(power_siphon) or SoulShards() >= 5 and Spell(hand_of_guldan) or DemonologyBuildAShardCdPostConditions()
}

### actions.precombat

AddFunction DemonologyPrecombatMainActions
{
 #inner_demons,if=talent.inner_demons.enabled
 if Talent(inner_demons_talent) Spell(inner_demons)
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
 if not pet.Present() Spell(summon_felguard)
}

AddFunction DemonologyPrecombatShortCdPostConditions
{
 Talent(inner_demons_talent) and Spell(inner_demons) or Spell(demonbolt)
}

AddFunction DemonologyPrecombatCdActions
{
 unless not pet.Present() and Spell(summon_felguard) or Talent(inner_demons_talent) and Spell(inner_demons)
 {
  #snapshot_stats
  #potion
  # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_intellect usable=1)
 }
}

AddFunction DemonologyPrecombatCdPostConditions
{
 not pet.Present() and Spell(summon_felguard) or Talent(inner_demons_talent) and Spell(inner_demons) or Spell(demonbolt)
}
]]

	OvaleScripts:RegisterScript("WARLOCK", "demonology", name, desc, code, "script")
end
