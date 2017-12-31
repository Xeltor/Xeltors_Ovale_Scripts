local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_elemental"
	local desc = "[Xel][7.3] Shaman: Elemental"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_shaman_spells)

Define(ghost_wolf_buff 2645)

# Elemental
AddIcon specialization=1 help=main
{
	if not InCombat() and not target.IsFriend() and not mounted() and target.Present()
	{
		if BuffRemaining(resonance_totem_buff) < 2 Spell(totem_mastery)
	}
	
	# Interrupt
	if InCombat() InterruptActions()
	
	if target.InRange(lightning_bolt_elemental) and HasFullControl() and InCombat()
    {
		# Cooldowns
		if Boss()
		{
			if Speed() == 0 or CanMove() > 0 ElementalDefaultCdActions()
		}
		
		# Short Cooldowns
		if Speed() == 0 or CanMove() > 0 ElementalDefaultShortCdActions()
		
		# Default rotation
		if Speed() == 0 or CanMove() > 0 ElementalDefaultMainActions()
		
		#flame_shock,moving=1,target_if=refreshable
		if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
		#earth_shock,moving=1
		if Speed() > 0 Spell(earth_shock)
		#flame_shock,moving=1,if=movement.distance>6
		if Speed() > 0 and target.Distance() > 6 Spell(flame_shock)
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
		if target.InRange(wind_shear) Spell(wind_shear)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_mana)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}

### actions.default

AddFunction ElementalDefaultMainActions
{
 #totem_mastery,if=buff.resonance_totem.remains<2
 if TotemRemaining(totem_mastery) < 2 and { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 Spell(totem_mastery)
 #storm_elemental
 Spell(storm_elemental)
 #run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
 if Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } ElementalAoeMainActions()

 unless Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalAoeMainPostConditions()
 {
  #run_action_list,name=single_asc,if=talent.ascendance.enabled
  if Talent(ascendance_talent) ElementalSingleAscMainActions()

  unless Talent(ascendance_talent) and ElementalSingleAscMainPostConditions()
  {
   #run_action_list,name=single_if,if=talent.icefury.enabled
   if Talent(icefury_talent) ElementalSingleIfMainActions()

   unless Talent(icefury_talent) and ElementalSingleIfMainPostConditions()
   {
    #run_action_list,name=single_lr,if=talent.lightning_rod.enabled
    if Talent(lightning_rod_talent) ElementalSingleLrMainActions()
   }
  }
 }
}

AddFunction ElementalDefaultMainPostConditions
{
 Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalAoeMainPostConditions() or Talent(ascendance_talent) and ElementalSingleAscMainPostConditions() or Talent(icefury_talent) and ElementalSingleIfMainPostConditions() or Talent(lightning_rod_talent) and ElementalSingleLrMainPostConditions()
}

AddFunction ElementalDefaultShortCdActions
{
 unless TotemRemaining(totem_mastery) < 2 and { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 and Spell(totem_mastery) or Spell(storm_elemental)
 {
  #run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
  if Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } ElementalAoeShortCdActions()

  unless Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalAoeShortCdPostConditions()
  {
   #run_action_list,name=single_asc,if=talent.ascendance.enabled
   if Talent(ascendance_talent) ElementalSingleAscShortCdActions()

   unless Talent(ascendance_talent) and ElementalSingleAscShortCdPostConditions()
   {
    #run_action_list,name=single_if,if=talent.icefury.enabled
    if Talent(icefury_talent) ElementalSingleIfShortCdActions()

    unless Talent(icefury_talent) and ElementalSingleIfShortCdPostConditions()
    {
     #run_action_list,name=single_lr,if=talent.lightning_rod.enabled
     if Talent(lightning_rod_talent) ElementalSingleLrShortCdActions()
    }
   }
  }
 }
}

AddFunction ElementalDefaultShortCdPostConditions
{
 TotemRemaining(totem_mastery) < 2 and { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 and Spell(totem_mastery) or Spell(storm_elemental) or Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalAoeShortCdPostConditions() or Talent(ascendance_talent) and ElementalSingleAscShortCdPostConditions() or Talent(icefury_talent) and ElementalSingleIfShortCdPostConditions() or Talent(lightning_rod_talent) and ElementalSingleLrShortCdPostConditions()
}

AddFunction ElementalDefaultCdActions
{
 #bloodlust,if=target.health.pct<25|time>0.500
 # if target.HealthPercent() < 25 or TimeInCombat() > 0.5 ElementalBloodlust()
 #potion,if=cooldown.fire_elemental.remains>280|target.time_to_die<=60
 # if { SpellCooldown(fire_elemental) > 280 or target.TimeToDie() <= 60 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
 #wind_shear
 # ElementalInterruptActions()

 unless TotemRemaining(totem_mastery) < 2 and { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 and Spell(totem_mastery)
 {
  #fire_elemental
  Spell(fire_elemental)

  unless Spell(storm_elemental)
  {
   #elemental_mastery
   Spell(elemental_mastery)
   #use_items
   # ElementalUseItemActions()
   #use_item,name=gnawed_thumb_ring,if=equipped.gnawed_thumb_ring&(talent.ascendance.enabled&!buff.ascendance.up|!talent.ascendance.enabled)
   # if HasEquippedItem(gnawed_thumb_ring) and { Talent(ascendance_talent) and not BuffPresent(ascendance_elemental_buff) or not Talent(ascendance_talent) } ElementalUseItemActions()
   #blood_fury,if=!talent.ascendance.enabled|buff.ascendance.up|cooldown.ascendance.remains>50
   if not Talent(ascendance_talent) or BuffPresent(ascendance_elemental_buff) or SpellCooldown(ascendance_elemental) > 50 Spell(blood_fury_apsp)
   #berserking,if=!talent.ascendance.enabled|buff.ascendance.up
   if not Talent(ascendance_talent) or BuffPresent(ascendance_elemental_buff) Spell(berserking)
   #run_action_list,name=aoe,if=active_enemies>2&(spell_targets.chain_lightning>2|spell_targets.lava_beam>2)
   if Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } ElementalAoeCdActions()

   unless Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalAoeCdPostConditions()
   {
    #run_action_list,name=single_asc,if=talent.ascendance.enabled
    if Talent(ascendance_talent) ElementalSingleAscCdActions()

    unless Talent(ascendance_talent) and ElementalSingleAscCdPostConditions()
    {
     #run_action_list,name=single_if,if=talent.icefury.enabled
     if Talent(icefury_talent) ElementalSingleIfCdActions()

     unless Talent(icefury_talent) and ElementalSingleIfCdPostConditions()
     {
      #run_action_list,name=single_lr,if=talent.lightning_rod.enabled
      if Talent(lightning_rod_talent) ElementalSingleLrCdActions()
     }
    }
   }
  }
 }
}

AddFunction ElementalDefaultCdPostConditions
{
 TotemRemaining(totem_mastery) < 2 and { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 and Spell(totem_mastery) or Spell(storm_elemental) or Enemies(tagged=1) > 2 and { Enemies(tagged=1) > 2 or Enemies(tagged=1) > 2 } and ElementalAoeCdPostConditions() or Talent(ascendance_talent) and ElementalSingleAscCdPostConditions() or Talent(icefury_talent) and ElementalSingleIfCdPostConditions() or Talent(lightning_rod_talent) and ElementalSingleLrCdPostConditions()
}

### actions.aoe

AddFunction ElementalAoeMainActions
{
 #stormkeeper
 Spell(stormkeeper)
 #flame_shock,if=spell_targets.chain_lightning<4&maelstrom>=20,target_if=refreshable
 if Enemies(tagged=1) < 4 and Maelstrom() >= 20 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
 #earthquake
 Spell(earthquake)
 #lava_burst,if=dot.flame_shock.remains>cast_time&buff.lava_surge.up&!talent.lightning_rod.enabled&spell_targets.chain_lightning<4
 if target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and BuffPresent(lava_surge_buff) and not Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 Spell(lava_burst)
 #elemental_blast,if=!talent.lightning_rod.enabled&spell_targets.chain_lightning<5|talent.lightning_rod.enabled&spell_targets.chain_lightning<4
 if not Talent(lightning_rod_talent) and Enemies(tagged=1) < 5 or Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 Spell(elemental_blast)
 #lava_beam
 Spell(lava_beam)
 #chain_lightning,target_if=debuff.lightning_rod.down
 if target.DebuffExpires(lightning_rod_debuff) Spell(chain_lightning)
 #chain_lightning
 Spell(chain_lightning)
 #lava_burst,moving=1
 if Speed() > 0 Spell(lava_burst)
 #flame_shock,moving=1,target_if=refreshable
 if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
}

AddFunction ElementalAoeMainPostConditions
{
}

AddFunction ElementalAoeShortCdActions
{
 unless Spell(stormkeeper)
 {
  #liquid_magma_totem
  Spell(liquid_magma_totem)
 }
}

AddFunction ElementalAoeShortCdPostConditions
{
 Spell(stormkeeper) or Enemies(tagged=1) < 4 and Maelstrom() >= 20 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Spell(earthquake) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and BuffPresent(lava_surge_buff) and not Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 and Spell(lava_burst) or { not Talent(lightning_rod_talent) and Enemies(tagged=1) < 5 or Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 } and Spell(elemental_blast) or Spell(lava_beam) or target.DebuffExpires(lightning_rod_debuff) and Spell(chain_lightning) or Spell(chain_lightning) or Speed() > 0 and Spell(lava_burst) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock)
}

AddFunction ElementalAoeCdActions
{
 unless Spell(stormkeeper)
 {
  #ascendance
  if BuffExpires(ascendance_elemental_buff) Spell(ascendance_elemental)
 }
}

AddFunction ElementalAoeCdPostConditions
{
 Spell(stormkeeper) or Spell(liquid_magma_totem) or Enemies(tagged=1) < 4 and Maelstrom() >= 20 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Spell(earthquake) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and BuffPresent(lava_surge_buff) and not Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 and Spell(lava_burst) or { not Talent(lightning_rod_talent) and Enemies(tagged=1) < 5 or Talent(lightning_rod_talent) and Enemies(tagged=1) < 4 } and Spell(elemental_blast) or Spell(lava_beam) or target.DebuffExpires(lightning_rod_debuff) and Spell(chain_lightning) or Spell(chain_lightning) or Speed() > 0 and Spell(lava_burst) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock)
}

### actions.precombat

AddFunction ElementalPrecombatMainActions
{
 #totem_mastery
 if { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 Spell(totem_mastery)
 #stormkeeper
 Spell(stormkeeper)
}

AddFunction ElementalPrecombatMainPostConditions
{
}

AddFunction ElementalPrecombatShortCdActions
{
}

AddFunction ElementalPrecombatShortCdPostConditions
{
 { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 and Spell(totem_mastery) or Spell(stormkeeper)
}

AddFunction ElementalPrecombatCdActions
{
 #flask
 #food
 #augmentation
 #snapshot_stats
 #potion
 # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
}

AddFunction ElementalPrecombatCdPostConditions
{
 { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 and Spell(totem_mastery) or Spell(stormkeeper)
}

### actions.single_asc

AddFunction ElementalSingleAscMainActions
{
 #flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
 if not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() Spell(flame_shock)
 #flame_shock,if=maelstrom>=20&remains<=buff.ascendance.duration&cooldown.ascendance.remains+buff.ascendance.duration<=duration
 if Maelstrom() >= 20 and target.DebuffRemaining(flame_shock_debuff) <= BaseDuration(ascendance_elemental_buff) and SpellCooldown(ascendance_elemental) + BaseDuration(ascendance_elemental_buff) <= BaseDuration(flame_shock_debuff) Spell(flame_shock)
 #earthquake,if=buff.echoes_of_the_great_sundering.up&!buff.ascendance.up
 if BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_elemental_buff) Spell(earthquake)
 #elemental_blast
 Spell(elemental_blast)
 #earth_shock,if=maelstrom>=117|!artifact.swelling_maelstrom.enabled&maelstrom>=92
 if Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 Spell(earth_shock)
 #stormkeeper,if=raid_event.adds.count<3|raid_event.adds.in>50
 if 0 < 3 or 600 > 50 Spell(stormkeeper)
 #lightning_bolt,if=buff.power_of_the_maelstrom.up&buff.stormkeeper.up&spell_targets.chain_lightning<3
 if BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt_elemental)
 #lava_burst,if=dot.flame_shock.remains>cast_time&(cooldown_react|buff.ascendance.up)
 if target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and { not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_elemental_buff) } Spell(lava_burst)
 #flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
 if Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
 #earth_shock,if=maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86|equipped.smoldering_heart&equipped.the_deceivers_blood_pact&maelstrom>70&talent.aftershock.enabled
 if Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 or HasEquippedItem(smoldering_heart) and HasEquippedItem(the_deceivers_blood_pact) and Maelstrom() > 70 and Talent(aftershock_talent) Spell(earth_shock)
 #totem_mastery,if=buff.resonance_totem.remains<10|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15)
 if { TotemRemaining(totem_mastery) < 10 or TotemRemaining(totem_mastery) < BaseDuration(ascendance_elemental_buff) + SpellCooldown(ascendance_elemental) and SpellCooldown(ascendance_elemental) < 15 } and { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 Spell(totem_mastery)
 #lava_beam,if=active_enemies>1&spell_targets.lava_beam>1
 if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 Spell(lava_beam)
 #lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
 if BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt_elemental)
 #chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
 if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 Spell(chain_lightning)
 #lightning_bolt
 Spell(lightning_bolt_elemental)
 #flame_shock,moving=1,target_if=refreshable
 if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
 #earth_shock,moving=1
 if Speed() > 0 Spell(earth_shock)
 #flame_shock,moving=1,if=movement.distance>6
 if Speed() > 0 and target.Distance() > 6 Spell(flame_shock)
}

AddFunction ElementalSingleAscMainPostConditions
{
}

AddFunction ElementalSingleAscShortCdActions
{
 unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or Maelstrom() >= 20 and target.DebuffRemaining(flame_shock_debuff) <= BaseDuration(ascendance_elemental_buff) and SpellCooldown(ascendance_elemental) + BaseDuration(ascendance_elemental_buff) <= BaseDuration(flame_shock_debuff) and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_elemental_buff) and Spell(earthquake) or Spell(elemental_blast) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper)
 {
  #liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
  if 0 < 3 or 600 > 50 Spell(liquid_magma_totem)
 }
}

AddFunction ElementalSingleAscShortCdPostConditions
{
 { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or Maelstrom() >= 20 and target.DebuffRemaining(flame_shock_debuff) <= BaseDuration(ascendance_elemental_buff) and SpellCooldown(ascendance_elemental) + BaseDuration(ascendance_elemental_buff) <= BaseDuration(flame_shock_debuff) and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_elemental_buff) and Spell(earthquake) or Spell(elemental_blast) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt_elemental) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and { not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_elemental_buff) } and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 or HasEquippedItem(smoldering_heart) and HasEquippedItem(the_deceivers_blood_pact) and Maelstrom() > 70 and Talent(aftershock_talent) } and Spell(earth_shock) or { TotemRemaining(totem_mastery) < 10 or TotemRemaining(totem_mastery) < BaseDuration(ascendance_elemental_buff) + SpellCooldown(ascendance_elemental) and SpellCooldown(ascendance_elemental) < 15 } and { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 and Spell(totem_mastery) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(lava_beam) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt_elemental) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or Spell(lightning_bolt_elemental) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

AddFunction ElementalSingleAscCdActions
{
 #ascendance,if=dot.flame_shock.remains>buff.ascendance.duration&(time>=60|buff.bloodlust.up)&cooldown.lava_burst.remains>0&!buff.stormkeeper.up
 if target.DebuffRemaining(flame_shock_debuff) > BaseDuration(ascendance_elemental_buff) and { TimeInCombat() >= 60 or BuffPresent(burst_haste_buff any=1) } and SpellCooldown(lava_burst) > 0 and not BuffPresent(stormkeeper_buff) and BuffExpires(ascendance_elemental_buff) Spell(ascendance_elemental)
}

AddFunction ElementalSingleAscCdPostConditions
{
 { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or Maelstrom() >= 20 and target.DebuffRemaining(flame_shock_debuff) <= BaseDuration(ascendance_elemental_buff) and SpellCooldown(ascendance_elemental) + BaseDuration(ascendance_elemental_buff) <= BaseDuration(flame_shock_debuff) and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_elemental_buff) and Spell(earthquake) or Spell(elemental_blast) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt_elemental) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and { not SpellCooldown(lava_burst) > 0 or BuffPresent(ascendance_elemental_buff) } and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 or HasEquippedItem(smoldering_heart) and HasEquippedItem(the_deceivers_blood_pact) and Maelstrom() > 70 and Talent(aftershock_talent) } and Spell(earth_shock) or { TotemRemaining(totem_mastery) < 10 or TotemRemaining(totem_mastery) < BaseDuration(ascendance_elemental_buff) + SpellCooldown(ascendance_elemental) and SpellCooldown(ascendance_elemental) < 15 } and { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 and Spell(totem_mastery) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(lava_beam) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt_elemental) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or Spell(lightning_bolt_elemental) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

### actions.single_if

AddFunction ElementalSingleIfMainActions
{
 #flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
 if not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() Spell(flame_shock)
 #earthquake,if=buff.echoes_of_the_great_sundering.up&!buff.ascendance.up
 if BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_elemental_buff) Spell(earthquake)
 #elemental_blast
 Spell(elemental_blast)
 #earth_shock,if=(maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=92)&buff.earthen_strength.up
 if { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and BuffPresent(earthen_strength_buff) Spell(earth_shock)
 #frost_shock,if=buff.icefury.up&maelstrom>=20&!buff.ascendance.up&buff.earthen_strength.up
 if BuffPresent(icefury_buff) and Maelstrom() >= 20 and not BuffPresent(ascendance_elemental_buff) and BuffPresent(earthen_strength_buff) Spell(frost_shock)
 #earth_shock,if=maelstrom>=117|!artifact.swelling_maelstrom.enabled&maelstrom>=92
 if Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 Spell(earth_shock)
 #stormkeeper,if=raid_event.adds.count<3|raid_event.adds.in>50
 if 0 < 3 or 600 > 50 Spell(stormkeeper)
 #icefury,if=(raid_event.movement.in<5|maelstrom<=101&artifact.swelling_maelstrom.enabled|!artifact.swelling_maelstrom.enabled&maelstrom<=76)&!buff.ascendance.up
 if { 600 < 5 or Maelstrom() <= 101 and HasArtifactTrait(swelling_maelstrom) or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() <= 76 } and not BuffPresent(ascendance_elemental_buff) Spell(icefury)
 #lightning_bolt,if=buff.power_of_the_maelstrom.up&buff.stormkeeper.up&spell_targets.chain_lightning<3
 if BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt_elemental)
 #lava_burst,if=dot.flame_shock.remains>cast_time&cooldown_react
 if target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 Spell(lava_burst)
 #frost_shock,if=buff.icefury.up&((maelstrom>=20&raid_event.movement.in>buff.icefury.remains)|buff.icefury.remains<(1.5*spell_haste*buff.icefury.stack+1))
 if BuffPresent(icefury_buff) and { Maelstrom() >= 20 and 600 > BuffRemaining(icefury_buff) or BuffRemaining(icefury_buff) < 1.5 * { 100 / { 100 + SpellHaste() } } * BuffStacks(icefury_buff) + 1 } Spell(frost_shock)
 #flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
 if Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
 #frost_shock,moving=1,if=buff.icefury.up
 if Speed() > 0 and BuffPresent(icefury_buff) Spell(frost_shock)
 #earth_shock,if=maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86|equipped.smoldering_heart&equipped.the_deceivers_blood_pact&maelstrom>70&talent.aftershock.enabled&buff.earthen_strength.up
 if Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 or HasEquippedItem(smoldering_heart) and HasEquippedItem(the_deceivers_blood_pact) and Maelstrom() > 70 and Talent(aftershock_talent) and BuffPresent(earthen_strength_buff) Spell(earth_shock)
 #totem_mastery,if=buff.resonance_totem.remains<10
 if TotemRemaining(totem_mastery) < 10 and { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 Spell(totem_mastery)
 #lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
 if BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt_elemental)
 #chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
 if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 Spell(chain_lightning)
 #lightning_bolt
 Spell(lightning_bolt_elemental)
 #flame_shock,moving=1,target_if=refreshable
 if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
 #earth_shock,moving=1
 if Speed() > 0 Spell(earth_shock)
 #flame_shock,moving=1,if=movement.distance>6
 if Speed() > 0 and target.Distance() > 6 Spell(flame_shock)
}

AddFunction ElementalSingleIfMainPostConditions
{
}

AddFunction ElementalSingleIfShortCdActions
{
 unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_elemental_buff) and Spell(earthquake) or Spell(elemental_blast) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and BuffPresent(earthen_strength_buff) and Spell(earth_shock) or BuffPresent(icefury_buff) and Maelstrom() >= 20 and not BuffPresent(ascendance_elemental_buff) and BuffPresent(earthen_strength_buff) and Spell(frost_shock) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or { 600 < 5 or Maelstrom() <= 101 and HasArtifactTrait(swelling_maelstrom) or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() <= 76 } and not BuffPresent(ascendance_elemental_buff) and Spell(icefury)
 {
  #liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
  if 0 < 3 or 600 > 50 Spell(liquid_magma_totem)
 }
}

AddFunction ElementalSingleIfShortCdPostConditions
{
 { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_elemental_buff) and Spell(earthquake) or Spell(elemental_blast) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and BuffPresent(earthen_strength_buff) and Spell(earth_shock) or BuffPresent(icefury_buff) and Maelstrom() >= 20 and not BuffPresent(ascendance_elemental_buff) and BuffPresent(earthen_strength_buff) and Spell(frost_shock) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or { 600 < 5 or Maelstrom() <= 101 and HasArtifactTrait(swelling_maelstrom) or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() <= 76 } and not BuffPresent(ascendance_elemental_buff) and Spell(icefury) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt_elemental) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or BuffPresent(icefury_buff) and { Maelstrom() >= 20 and 600 > BuffRemaining(icefury_buff) or BuffRemaining(icefury_buff) < 1.5 * { 100 / { 100 + SpellHaste() } } * BuffStacks(icefury_buff) + 1 } and Spell(frost_shock) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and BuffPresent(icefury_buff) and Spell(frost_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 or HasEquippedItem(smoldering_heart) and HasEquippedItem(the_deceivers_blood_pact) and Maelstrom() > 70 and Talent(aftershock_talent) and BuffPresent(earthen_strength_buff) } and Spell(earth_shock) or TotemRemaining(totem_mastery) < 10 and { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 and Spell(totem_mastery) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt_elemental) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or Spell(lightning_bolt_elemental) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

AddFunction ElementalSingleIfCdActions
{
}

AddFunction ElementalSingleIfCdPostConditions
{
 { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_elemental_buff) and Spell(earthquake) or Spell(elemental_blast) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and BuffPresent(earthen_strength_buff) and Spell(earth_shock) or BuffPresent(icefury_buff) and Maelstrom() >= 20 and not BuffPresent(ascendance_elemental_buff) and BuffPresent(earthen_strength_buff) and Spell(frost_shock) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or { 600 < 5 or Maelstrom() <= 101 and HasArtifactTrait(swelling_maelstrom) or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() <= 76 } and not BuffPresent(ascendance_elemental_buff) and Spell(icefury) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or BuffPresent(power_of_the_maelstrom_buff) and BuffPresent(stormkeeper_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt_elemental) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or BuffPresent(icefury_buff) and { Maelstrom() >= 20 and 600 > BuffRemaining(icefury_buff) or BuffRemaining(icefury_buff) < 1.5 * { 100 / { 100 + SpellHaste() } } * BuffStacks(icefury_buff) + 1 } and Spell(frost_shock) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and BuffPresent(icefury_buff) and Spell(frost_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 or HasEquippedItem(smoldering_heart) and HasEquippedItem(the_deceivers_blood_pact) and Maelstrom() > 70 and Talent(aftershock_talent) and BuffPresent(earthen_strength_buff) } and Spell(earth_shock) or TotemRemaining(totem_mastery) < 10 and { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 and Spell(totem_mastery) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt_elemental) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or Spell(lightning_bolt_elemental) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

### actions.single_lr

AddFunction ElementalSingleLrMainActions
{
 #flame_shock,if=!ticking|dot.flame_shock.remains<=gcd
 if not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() Spell(flame_shock)
 #earthquake,if=buff.echoes_of_the_great_sundering.up&!buff.ascendance.up
 if BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_elemental_buff) Spell(earthquake)
 #elemental_blast
 Spell(elemental_blast)
 #earth_shock,if=maelstrom>=117|!artifact.swelling_maelstrom.enabled&maelstrom>=92
 if Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 Spell(earth_shock)
 #stormkeeper,if=raid_event.adds.count<3|raid_event.adds.in>50
 if 0 < 3 or 600 > 50 Spell(stormkeeper)
 #lava_burst,if=dot.flame_shock.remains>cast_time&cooldown_react
 if target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 Spell(lava_burst)
 #flame_shock,if=maelstrom>=20&buff.elemental_focus.up,target_if=refreshable
 if Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
 #earth_shock,if=maelstrom>=111|!artifact.swelling_maelstrom.enabled&maelstrom>=86|equipped.smoldering_heart&equipped.the_deceivers_blood_pact&maelstrom>70&talent.aftershock.enabled
 if Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 or HasEquippedItem(smoldering_heart) and HasEquippedItem(the_deceivers_blood_pact) and Maelstrom() > 70 and Talent(aftershock_talent) Spell(earth_shock)
 #totem_mastery,if=buff.resonance_totem.remains<10|(buff.resonance_totem.remains<(buff.ascendance.duration+cooldown.ascendance.remains)&cooldown.ascendance.remains<15)
 if { TotemRemaining(totem_mastery) < 10 or TotemRemaining(totem_mastery) < BaseDuration(ascendance_elemental_buff) + SpellCooldown(ascendance_elemental) and SpellCooldown(ascendance_elemental) < 15 } and { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 Spell(totem_mastery)
 #lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3,target_if=debuff.lightning_rod.down
 if BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and target.DebuffExpires(lightning_rod_debuff) Spell(lightning_bolt_elemental)
 #lightning_bolt,if=buff.power_of_the_maelstrom.up&spell_targets.chain_lightning<3
 if BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 Spell(lightning_bolt_elemental)
 #chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1,target_if=debuff.lightning_rod.down
 if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and target.DebuffExpires(lightning_rod_debuff) Spell(chain_lightning)
 #chain_lightning,if=active_enemies>1&spell_targets.chain_lightning>1
 if Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 Spell(chain_lightning)
 #lightning_bolt,target_if=debuff.lightning_rod.down
 if target.DebuffExpires(lightning_rod_debuff) Spell(lightning_bolt_elemental)
 #lightning_bolt
 Spell(lightning_bolt_elemental)
 #flame_shock,moving=1,target_if=refreshable
 if Speed() > 0 and target.Refreshable(flame_shock_debuff) Spell(flame_shock)
 #earth_shock,moving=1
 if Speed() > 0 Spell(earth_shock)
 #flame_shock,moving=1,if=movement.distance>6
 if Speed() > 0 and target.Distance() > 6 Spell(flame_shock)
}

AddFunction ElementalSingleLrMainPostConditions
{
}

AddFunction ElementalSingleLrShortCdActions
{
 unless { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_elemental_buff) and Spell(earthquake) or Spell(elemental_blast) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper)
 {
  #liquid_magma_totem,if=raid_event.adds.count<3|raid_event.adds.in>50
  if 0 < 3 or 600 > 50 Spell(liquid_magma_totem)
 }
}

AddFunction ElementalSingleLrShortCdPostConditions
{
 { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_elemental_buff) and Spell(earthquake) or Spell(elemental_blast) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 or HasEquippedItem(smoldering_heart) and HasEquippedItem(the_deceivers_blood_pact) and Maelstrom() > 70 and Talent(aftershock_talent) } and Spell(earth_shock) or { TotemRemaining(totem_mastery) < 10 or TotemRemaining(totem_mastery) < BaseDuration(ascendance_elemental_buff) + SpellCooldown(ascendance_elemental) and SpellCooldown(ascendance_elemental) < 15 } and { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 and Spell(totem_mastery) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and target.DebuffExpires(lightning_rod_debuff) and Spell(lightning_bolt_elemental) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt_elemental) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and target.DebuffExpires(lightning_rod_debuff) and Spell(chain_lightning) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or target.DebuffExpires(lightning_rod_debuff) and Spell(lightning_bolt_elemental) or Spell(lightning_bolt_elemental) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}

AddFunction ElementalSingleLrCdActions
{
}

AddFunction ElementalSingleLrCdPostConditions
{
 { not target.DebuffPresent(flame_shock_debuff) or target.DebuffRemaining(flame_shock_debuff) <= GCD() } and Spell(flame_shock) or BuffPresent(echoes_of_the_great_sundering_buff) and not BuffPresent(ascendance_elemental_buff) and Spell(earthquake) or Spell(elemental_blast) or { Maelstrom() >= 117 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 92 } and Spell(earth_shock) or { 0 < 3 or 600 > 50 } and Spell(stormkeeper) or { 0 < 3 or 600 > 50 } and Spell(liquid_magma_totem) or target.DebuffRemaining(flame_shock_debuff) > CastTime(lava_burst) and not SpellCooldown(lava_burst) > 0 and Spell(lava_burst) or Maelstrom() >= 20 and BuffPresent(elemental_focus_buff) and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or { Maelstrom() >= 111 or not HasArtifactTrait(swelling_maelstrom) and Maelstrom() >= 86 or HasEquippedItem(smoldering_heart) and HasEquippedItem(the_deceivers_blood_pact) and Maelstrom() > 70 and Talent(aftershock_talent) } and Spell(earth_shock) or { TotemRemaining(totem_mastery) < 10 or TotemRemaining(totem_mastery) < BaseDuration(ascendance_elemental_buff) + SpellCooldown(ascendance_elemental) and SpellCooldown(ascendance_elemental) < 15 } and { not TotemPresent(totem_mastery) or InCombat() } and Speed() == 0 and Spell(totem_mastery) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and target.DebuffExpires(lightning_rod_debuff) and Spell(lightning_bolt_elemental) or BuffPresent(power_of_the_maelstrom_buff) and Enemies(tagged=1) < 3 and Spell(lightning_bolt_elemental) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and target.DebuffExpires(lightning_rod_debuff) and Spell(chain_lightning) or Enemies(tagged=1) > 1 and Enemies(tagged=1) > 1 and Spell(chain_lightning) or target.DebuffExpires(lightning_rod_debuff) and Spell(lightning_bolt_elemental) or Spell(lightning_bolt_elemental) or Speed() > 0 and target.Refreshable(flame_shock_debuff) and Spell(flame_shock) or Speed() > 0 and Spell(earth_shock) or Speed() > 0 and target.Distance() > 6 and Spell(flame_shock)
}
]]

	OvaleScripts:RegisterScript("SHAMAN", "elemental", name, desc, code, "script")
end
