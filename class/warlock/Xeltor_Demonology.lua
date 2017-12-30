local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_demonology"
	local desc = "[Xel][7.3] Warlock: Demonology"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_warlock_spells)

Define(health_funnel 755)
Define(spell_lock_fh 19647)
	SpellInfo(spell_lock_fh cd=24)
Define(legion_strike 30213)
Define(drain_life 234153)

AddIcon specialization=2 help=main
{
	# Interrupt
	if InCombat() InterruptActions()
	
	if InCombat() and target.InRange(shadow_bolt) and HasFullControl()
    {
		#life_tap
		if ManaPercent() <= 30 Spell(life_tap)
		if pet.CreatureFamily(Voidwalker) or pet.CreatureFamily(Voidlord) PetStuff()
		
		# Cooldowns
		if Boss() and Speed() == 0 or CanMove() > 0 DemonologyDefaultCdActions()
		
		# Short Cooldowns
		if Speed() == 0 or CanMove() > 0 DemonologyDefaultShortCdActions()
		
		# Default rotation
		# Pet skill fixes.
		if pet.CreatureFamily(Felguard) and pet.BuffRemains(demonic_empowerment) >= 6 and target.Distance() - pet.Distance() <= 8 Spell(felguard_felstorm)
		if Speed() == 0 or CanMove() > 0 DemonologyDefaultMainActions()
		
		# AoE on the move :D
		if Pet.Present() and not { Speed() == 0 or CanMove() > 0 } Spell(demonwrath)
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
		if pet.CreatureFamily(Felhunter) and target.Distance() - pet.Distance() <= 40 Spell(spell_lock_fh)
	}
}

AddFunction pet_count
{
	pet.Present() + Demons(wild_imp) + Demons(dreadstalker) + Demons(darkglare) + Demons(doomguard) + Demons(infernal) + { SpellCooldown(service_felguard) > 65 }
}

AddFunction threemins
{
    NotDeDemons(doomguard) > 0 or NotDeDemons(infernal) > 0
}

AddFunction no_de2
{
    threemins() and 0 > 0 or threemins() and NotDeDemons(wild_imp) > 0 or threemins() and NotDeDemons(dreadstalker) > 0 and NotDeDemons(dreadstalker) > 0 and NotDeDemons(wild_imp) > 0 or NotDeDemons(dreadstalker) > 0 and NotDeDemons(wild_imp) > 0 or PreviousGCDSpell(hand_of_guldan) and no_de1()
}

AddFunction no_de1
{
    NotDeDemons(dreadstalker) > 0 or NotDeDemons(darkglare) > 0 or NotDeDemons(doomguard) > 0 or NotDeDemons(infernal) > 0
}

AddFunction PetStuff
{
	if pet.Health() < pet.HealthMissing() and pet.Present() and pet.Exists() and Speed() == 0 Spell(health_funnel)
	if HealthPercent() < 50 and target.Present() and not target.IsFriend() and Speed() == 0 Spell(drain_life)
}

### actions.default

AddFunction DemonologyDefaultMainActions
{
    #implosion,if=wild_imp_remaining_duration<=action.shadow_bolt.execute_time&(buff.demonic_synergy.remains|talent.soul_conduit.enabled|(!talent.soul_conduit.enabled&spell_targets.implosion>1)|wild_imp_count<=4)
    if DemonDuration(wild_imp) <= ExecuteTime(shadow_bolt) and { BuffPresent(demonic_synergy_buff) or Talent(soul_conduit_talent) or not Talent(soul_conduit_talent) and Enemies(tagged=1) > 1 or Demons(wild_imp) <= 4 } and Demons(wild_imp) >= 1 Spell(implosion)
    #variable,name=threemins,value=doomguard_no_de>0|infernal_no_de>0
    #variable,name=no_de1,value=dreadstalker_no_de>0|darkglare_no_de>0|doomguard_no_de>0|infernal_no_de>0|service_no_de>0
    #variable,name=no_de2,value=(variable.threemins&service_no_de>0)|(variable.threemins&wild_imp_no_de>0)|(variable.threemins&dreadstalker_no_de>0)|(service_no_de>0&dreadstalker_no_de>0)|(service_no_de>0&wild_imp_no_de>0)|(dreadstalker_no_de>0&wild_imp_no_de>0)|(prev_gcd.1.hand_of_guldan&variable.no_de1)
    #implosion,if=prev_gcd.1.hand_of_guldan&((wild_imp_remaining_duration<=3&buff.demonic_synergy.remains)|(wild_imp_remaining_duration<=4&spell_targets.implosion>2))
    if PreviousGCDSpell(hand_of_guldan) and { DemonDuration(wild_imp) <= 3 and BuffPresent(demonic_synergy_buff) or DemonDuration(wild_imp) <= 4 and Enemies(tagged=1) > 2 } Spell(implosion)
    #shadowflame,if=(debuff.shadowflame.stack>0&remains<action.shadow_bolt.cast_time+travel_time)&spell_targets.demonwrath<5
    if target.DebuffStacks(shadowflame_debuff) > 0 and target.DebuffRemaining(shadowflame_debuff) < CastTime(shadow_bolt) + TravelTime(shadowflame) and Enemies(tagged=1) < 5 Spell(shadowflame)
    #call_dreadstalkers,if=((!talent.summon_darkglare.enabled|talent.power_trip.enabled)&(spell_targets.implosion<3|!talent.implosion.enabled))&!(soul_shard=5&buff.demonic_calling.remains)
    if { not Talent(summon_darkglare_talent) or Talent(power_trip_talent) } and { Enemies(tagged=1) < 3 or not Talent(implosion_talent) } and not { SoulShards() == 5 and BuffPresent(demonic_calling_buff) } Spell(call_dreadstalkers)
    #doom,cycle_targets=1,if=(!talent.hand_of_doom.enabled&target.time_to_die>duration&(!ticking|remains<duration*0.3))&!(variable.no_de1|prev_gcd.1.hand_of_guldan)
    if not Talent(hand_of_doom_talent) and target.TimeToDie() > BaseDuration(doom_debuff) and { not target.DebuffPresent(doom_debuff) or target.DebuffRemaining(doom_debuff) < BaseDuration(doom_debuff) * 0.3 } and not { no_de1() or PreviousGCDSpell(hand_of_guldan) } Spell(doom)
    #shadowflame,if=(charges=2&soul_shard<5)&spell_targets.demonwrath<5&!variable.no_de1
    if Charges(shadowflame) == 2 and SoulShards() < 5 and Enemies(tagged=1) < 5 and not no_de1() Spell(shadowflame)
    #shadow_bolt,if=buff.shadowy_inspiration.remains&soul_shard<5&!prev_gcd.1.doom&!variable.no_de2
    if BuffPresent(shadowy_inspiration_buff) and SoulShards() < 5 and not PreviousGCDSpell(doom) and not no_de2() Spell(shadow_bolt)
    #summon_darkglare,if=prev_gcd.1.hand_of_guldan|prev_gcd.1.call_dreadstalkers|talent.power_trip.enabled
    if { PreviousGCDSpell(hand_of_guldan) or PreviousGCDSpell(call_dreadstalkers) or Talent(power_trip_talent) } and DebuffCountOnAny(doom) >= 1 Spell(summon_darkglare)
    #summon_darkglare,if=cooldown.call_dreadstalkers.remains>5&soul_shard<3
    if SpellCooldown(call_dreadstalkers) > 5 and SoulShards() < 3 and DebuffCountOnAny(doom) >= 1 Spell(summon_darkglare)
    #summon_darkglare,if=cooldown.call_dreadstalkers.remains<=action.summon_darkglare.cast_time&(soul_shard>=3|soul_shard>=1&buff.demonic_calling.react)
    if SpellCooldown(call_dreadstalkers) <= CastTime(summon_darkglare) and { SoulShards() >= 3 or SoulShards() >= 1 and BuffPresent(demonic_calling_buff) } and DebuffCountOnAny(doom) >= 1 Spell(summon_darkglare)
    #call_dreadstalkers,if=talent.summon_darkglare.enabled&(spell_targets.implosion<3|!talent.implosion.enabled)&(cooldown.summon_darkglare.remains>2|prev_gcd.1.summon_darkglare|cooldown.summon_darkglare.remains<=action.call_dreadstalkers.cast_time&soul_shard>=3|cooldown.summon_darkglare.remains<=action.call_dreadstalkers.cast_time&soul_shard>=1&buff.demonic_calling.react)
    if Talent(summon_darkglare_talent) and { Enemies(tagged=1) < 3 or not Talent(implosion_talent) } and { SpellCooldown(summon_darkglare) > 2 or PreviousGCDSpell(summon_darkglare) or SpellCooldown(summon_darkglare) <= CastTime(call_dreadstalkers) and SoulShards() >= 3 or SpellCooldown(summon_darkglare) <= CastTime(call_dreadstalkers) and SoulShards() >= 1 and BuffPresent(demonic_calling_buff) } Spell(call_dreadstalkers)
    #hand_of_guldan,if=soul_shard>=4&(((!(variable.no_de1|prev_gcd.1.hand_of_guldan)&(pet_count>=13&!talent.shadowy_inspiration.enabled|pet_count>=6&talent.shadowy_inspiration.enabled))|!variable.no_de2|soul_shard=5)&talent.power_trip.enabled)
    if SoulShards() >= 4 and { not { no_de1() or PreviousGCDSpell(hand_of_guldan) } and { pet_count() >= 10 and not Talent(shadowy_inspiration_talent) or pet_count() >= 6 and Talent(shadowy_inspiration_talent) } or not no_de2() or SoulShards() == 5 } and Talent(power_trip_talent) Spell(hand_of_guldan)
    #hand_of_guldan,if=(soul_shard>=3&prev_gcd.1.call_dreadstalkers&!artifact.thalkiels_ascendance.rank)|soul_shard>=5|(soul_shard>=4&cooldown.summon_darkglare.remains>2)
    if SoulShards() >= 3 and PreviousGCDSpell(call_dreadstalkers) and not ArtifactTraitRank(thalkiels_ascendance) or SoulShards() >= 5 or SoulShards() >= 4 and SpellCooldown(summon_darkglare) > 2 Spell(hand_of_guldan)
    #demonic_empowerment,if=(((talent.power_trip.enabled&(!talent.implosion.enabled|spell_targets.demonwrath<=1))|!talent.implosion.enabled|(talent.implosion.enabled&!talent.soul_conduit.enabled&spell_targets.demonwrath<=3))&(wild_imp_no_de>3|prev_gcd.1.hand_of_guldan))|(prev_gcd.1.hand_of_guldan&wild_imp_no_de=0&wild_imp_remaining_duration<=0)|(prev_gcd.1.implosion&wild_imp_no_de>0)
    if { { Talent(power_trip_talent) and { not Talent(implosion_talent) or Enemies(tagged=1) <= 1 } or not Talent(implosion_talent) or Talent(implosion_talent) and not Talent(soul_conduit_talent) and Enemies(tagged=1) <= 3 } and { NotDeDemons(wild_imp) > 3 or PreviousGCDSpell(hand_of_guldan) } or PreviousGCDSpell(hand_of_guldan) and NotDeDemons(wild_imp) == 0 and DemonDuration(wild_imp) <= 0 or PreviousGCDSpell(implosion) and NotDeDemons(wild_imp) > 0 } and not PreviousGCDSpell(demonic_empowerment) Spell(demonic_empowerment)
    #demonic_empowerment,if=variable.no_de1|prev_gcd.1.hand_of_guldan
    if { no_de1() or PreviousGCDSpell(hand_of_guldan) } and not PreviousGCDSpell(demonic_empowerment) Spell(demonic_empowerment)
    #shadowflame,if=charges=2&spell_targets.demonwrath<5
    if Charges(shadowflame) == 2 and Enemies(tagged=1) < 5 Spell(shadowflame)
    #life_tap,if=mana.pct<=15|(mana.pct<=65&((cooldown.call_dreadstalkers.remains<=0.75&soul_shard>=2)|((cooldown.call_dreadstalkers.remains<gcd*2)&(cooldown.summon_doomguard.remains<=0.75|cooldown.service_pet.remains<=0.75)&soul_shard>=3)))
    if ManaPercent() <= 15 or ManaPercent() <= 65 and { SpellCooldown(call_dreadstalkers) <= 0.75 and SoulShards() >= 2 or SpellCooldown(call_dreadstalkers) < GCD() * 2 and { SpellCooldown(summon_doomguard) <= 0.75 or SpellCooldown(service_pet) <= 0.75 } and SoulShards() >= 3 } Spell(life_tap)
    #demonwrath,chain=1,interrupt=1,if=spell_targets.demonwrath>=3
    if Enemies(tagged=1) >= 3 Spell(demonwrath)
    #demonwrath,moving=1,chain=1,interrupt=1
    if Speed() > 0 Spell(demonwrath)
    #demonbolt
    Spell(demonbolt)
    #shadow_bolt,if=buff.shadowy_inspiration.remains
    if BuffPresent(shadowy_inspiration_buff) Spell(shadow_bolt)
    #demonic_empowerment,if=artifact.thalkiels_ascendance.rank&talent.power_trip.enabled&!talent.demonbolt.enabled&talent.shadowy_inspiration.enabled
    if ArtifactTraitRank(thalkiels_ascendance) and Talent(power_trip_talent) and not Talent(demonbolt_talent) and Talent(shadowy_inspiration_talent) and not pet.BuffPresent(demonic_empowerment) Spell(demonic_empowerment)
    #shadow_bolt
    Spell(shadow_bolt)
    #life_tap
    Spell(life_tap)
}

AddFunction DemonologyDefaultMainPostConditions
{
}

AddFunction DemonologyDefaultShortCdActions
{
    unless DemonDuration(wild_imp) <= ExecuteTime(shadow_bolt) and { BuffPresent(demonic_synergy_buff) or Talent(soul_conduit_talent) or not Talent(soul_conduit_talent) and Enemies(tagged=1) > 1 or Demons(wild_imp) <= 4 } and Spell(implosion) or PreviousGCDSpell(hand_of_guldan) and { DemonDuration(wild_imp) <= 3 and BuffPresent(demonic_synergy_buff) or DemonDuration(wild_imp) <= 4 and Enemies(tagged=1) > 2 } and Spell(implosion) or target.DebuffStacks(shadowflame_debuff) > 0 and target.DebuffRemaining(shadowflame_debuff) < CastTime(shadow_bolt) + TravelTime(shadowflame) and Enemies(tagged=1) < 5 and Spell(shadowflame) or { not Talent(summon_darkglare_talent) or Talent(power_trip_talent) } and { Enemies(tagged=1) < 3 or not Talent(implosion_talent) } and not { SoulShards() == 5 and BuffPresent(demonic_calling_buff) } and Spell(call_dreadstalkers) or not Talent(hand_of_doom_talent) and target.TimeToDie() > BaseDuration(doom_debuff) and { not target.DebuffPresent(doom_debuff) or target.DebuffRemaining(doom_debuff) < BaseDuration(doom_debuff) * 0.3 } and not { no_de1() or PreviousGCDSpell(hand_of_guldan) } and Spell(doom) or Charges(shadowflame) == 2 and SoulShards() < 5 and Enemies(tagged=1) < 5 and not no_de1() and Spell(shadowflame)
    {
        #service_pet
        Spell(service_felguard)

        unless BuffPresent(shadowy_inspiration_buff) and SoulShards() < 5 and not PreviousGCDSpell(doom) and not no_de2() and Spell(shadow_bolt) or { PreviousGCDSpell(hand_of_guldan) or PreviousGCDSpell(call_dreadstalkers) or Talent(power_trip_talent) } and Spell(summon_darkglare) or SpellCooldown(call_dreadstalkers) > 5 and SoulShards() < 3 and Spell(summon_darkglare) or SpellCooldown(call_dreadstalkers) <= CastTime(summon_darkglare) and { SoulShards() >= 3 or SoulShards() >= 1 and BuffPresent(demonic_calling_buff) } and Spell(summon_darkglare) or Talent(summon_darkglare_talent) and { Enemies(tagged=1) < 3 or not Talent(implosion_talent) } and { SpellCooldown(summon_darkglare) > 2 or PreviousGCDSpell(summon_darkglare) or SpellCooldown(summon_darkglare) <= CastTime(call_dreadstalkers) and SoulShards() >= 3 or SpellCooldown(summon_darkglare) <= CastTime(call_dreadstalkers) and SoulShards() >= 1 and BuffPresent(demonic_calling_buff) } and Spell(call_dreadstalkers) or SoulShards() >= 4 and { not { no_de1() or PreviousGCDSpell(hand_of_guldan) } and { pet_count() >= 13 and not Talent(shadowy_inspiration_talent) or pet_count() >= 6 and Talent(shadowy_inspiration_talent) } or not no_de2() or SoulShards() == 5 } and Talent(power_trip_talent) and Spell(hand_of_guldan) or { SoulShards() >= 3 and PreviousGCDSpell(call_dreadstalkers) and not ArtifactTraitRank(thalkiels_ascendance) or SoulShards() >= 5 or SoulShards() >= 4 and SpellCooldown(summon_darkglare) > 2 } and Spell(hand_of_guldan) or { { Talent(power_trip_talent) and { not Talent(implosion_talent) or Enemies(tagged=1) <= 1 } or not Talent(implosion_talent) or Talent(implosion_talent) and not Talent(soul_conduit_talent) and Enemies(tagged=1) <= 3 } and { NotDeDemons(wild_imp) > 3 or PreviousGCDSpell(hand_of_guldan) } or PreviousGCDSpell(hand_of_guldan) and NotDeDemons(wild_imp) == 0 and DemonDuration(wild_imp) <= 0 or PreviousGCDSpell(implosion) and NotDeDemons(wild_imp) > 0 } and Spell(demonic_empowerment) or { no_de1() or PreviousGCDSpell(hand_of_guldan) } and Spell(demonic_empowerment) or Charges(shadowflame) == 2 and Enemies(tagged=1) < 5 and Spell(shadowflame)
        {
            #thalkiels_consumption,if=(dreadstalker_remaining_duration>execute_time|talent.implosion.enabled&spell_targets.implosion>=3)&wild_imp_count>3&wild_imp_remaining_duration>execute_time
            if { DemonDuration(dreadstalker) > ExecuteTime(thalkiels_consumption) or Talent(implosion_talent) and Enemies(tagged=1) >= 3 } and Demons(wild_imp) > 3 and DemonDuration(wild_imp) > ExecuteTime(thalkiels_consumption) Spell(thalkiels_consumption)
        }
    }
}

AddFunction DemonologyDefaultShortCdPostConditions
{
    DemonDuration(wild_imp) <= ExecuteTime(shadow_bolt) and { BuffPresent(demonic_synergy_buff) or Talent(soul_conduit_talent) or not Talent(soul_conduit_talent) and Enemies(tagged=1) > 1 or Demons(wild_imp) <= 4 } and Spell(implosion) or PreviousGCDSpell(hand_of_guldan) and { DemonDuration(wild_imp) <= 3 and BuffPresent(demonic_synergy_buff) or DemonDuration(wild_imp) <= 4 and Enemies(tagged=1) > 2 } and Spell(implosion) or target.DebuffStacks(shadowflame_debuff) > 0 and target.DebuffRemaining(shadowflame_debuff) < CastTime(shadow_bolt) + TravelTime(shadowflame) and Enemies(tagged=1) < 5 and Spell(shadowflame) or { not Talent(summon_darkglare_talent) or Talent(power_trip_talent) } and { Enemies(tagged=1) < 3 or not Talent(implosion_talent) } and not { SoulShards() == 5 and BuffPresent(demonic_calling_buff) } and Spell(call_dreadstalkers) or not Talent(hand_of_doom_talent) and target.TimeToDie() > BaseDuration(doom_debuff) and { not target.DebuffPresent(doom_debuff) or target.DebuffRemaining(doom_debuff) < BaseDuration(doom_debuff) * 0.3 } and not { no_de1() or PreviousGCDSpell(hand_of_guldan) } and Spell(doom) or Charges(shadowflame) == 2 and SoulShards() < 5 and Enemies(tagged=1) < 5 and not no_de1() and Spell(shadowflame) or BuffPresent(shadowy_inspiration_buff) and SoulShards() < 5 and not PreviousGCDSpell(doom) and not no_de2() and Spell(shadow_bolt) or { PreviousGCDSpell(hand_of_guldan) or PreviousGCDSpell(call_dreadstalkers) or Talent(power_trip_talent) } and Spell(summon_darkglare) or SpellCooldown(call_dreadstalkers) > 5 and SoulShards() < 3 and Spell(summon_darkglare) or SpellCooldown(call_dreadstalkers) <= CastTime(summon_darkglare) and { SoulShards() >= 3 or SoulShards() >= 1 and BuffPresent(demonic_calling_buff) } and Spell(summon_darkglare) or Talent(summon_darkglare_talent) and { Enemies(tagged=1) < 3 or not Talent(implosion_talent) } and { SpellCooldown(summon_darkglare) > 2 or PreviousGCDSpell(summon_darkglare) or SpellCooldown(summon_darkglare) <= CastTime(call_dreadstalkers) and SoulShards() >= 3 or SpellCooldown(summon_darkglare) <= CastTime(call_dreadstalkers) and SoulShards() >= 1 and BuffPresent(demonic_calling_buff) } and Spell(call_dreadstalkers) or SoulShards() >= 4 and { not { no_de1() or PreviousGCDSpell(hand_of_guldan) } and { pet_count() >= 13 and not Talent(shadowy_inspiration_talent) or pet_count() >= 6 and Talent(shadowy_inspiration_talent) } or not no_de2() or SoulShards() == 5 } and Talent(power_trip_talent) and Spell(hand_of_guldan) or { SoulShards() >= 3 and PreviousGCDSpell(call_dreadstalkers) and not ArtifactTraitRank(thalkiels_ascendance) or SoulShards() >= 5 or SoulShards() >= 4 and SpellCooldown(summon_darkglare) > 2 } and Spell(hand_of_guldan) or { { Talent(power_trip_talent) and { not Talent(implosion_talent) or Enemies(tagged=1) <= 1 } or not Talent(implosion_talent) or Talent(implosion_talent) and not Talent(soul_conduit_talent) and Enemies(tagged=1) <= 3 } and { NotDeDemons(wild_imp) > 3 or PreviousGCDSpell(hand_of_guldan) } or PreviousGCDSpell(hand_of_guldan) and NotDeDemons(wild_imp) == 0 and DemonDuration(wild_imp) <= 0 or PreviousGCDSpell(implosion) and NotDeDemons(wild_imp) > 0 } and Spell(demonic_empowerment) or { no_de1() or PreviousGCDSpell(hand_of_guldan) } and Spell(demonic_empowerment) or Charges(shadowflame) == 2 and Enemies(tagged=1) < 5 and Spell(shadowflame) or { ManaPercent() <= 15 or ManaPercent() <= 65 and { SpellCooldown(call_dreadstalkers) <= 0.75 and SoulShards() >= 2 or SpellCooldown(call_dreadstalkers) < GCD() * 2 and { SpellCooldown(summon_doomguard) <= 0.75 or SpellCooldown(service_pet) <= 0.75 } and SoulShards() >= 3 } } and Spell(life_tap) or Enemies(tagged=1) >= 3 and Spell(demonwrath) or Speed() > 0 and Spell(demonwrath) or Spell(demonbolt) or BuffPresent(shadowy_inspiration_buff) and Spell(shadow_bolt) or ArtifactTraitRank(thalkiels_ascendance) and Talent(power_trip_talent) and not Talent(demonbolt_talent) and Talent(shadowy_inspiration_talent) and Spell(demonic_empowerment) or Spell(shadow_bolt) or Spell(life_tap)
}

AddFunction DemonologyDefaultCdActions
{
    unless DemonDuration(wild_imp) <= ExecuteTime(shadow_bolt) and { BuffPresent(demonic_synergy_buff) or Talent(soul_conduit_talent) or not Talent(soul_conduit_talent) and Enemies(tagged=1) > 1 or Demons(wild_imp) <= 4 } and Spell(implosion) or PreviousGCDSpell(hand_of_guldan) and { DemonDuration(wild_imp) <= 3 and BuffPresent(demonic_synergy_buff) or DemonDuration(wild_imp) <= 4 and Enemies(tagged=1) > 2 } and Spell(implosion) or target.DebuffStacks(shadowflame_debuff) > 0 and target.DebuffRemaining(shadowflame_debuff) < CastTime(shadow_bolt) + TravelTime(shadowflame) and Enemies(tagged=1) < 5 and Spell(shadowflame)
    {
        #summon_infernal,if=(!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening>2)&equipped.132369
        if not Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) > 2 and HasEquippedItem(132369) Spell(summon_infernal)
        #summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening<=2&equipped.132369
        if not Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) <= 2 and HasEquippedItem(132369) Spell(summon_doomguard)

        unless { not Talent(summon_darkglare_talent) or Talent(power_trip_talent) } and { Enemies(tagged=1) < 3 or not Talent(implosion_talent) } and not { SoulShards() == 5 and BuffPresent(demonic_calling_buff) } and Spell(call_dreadstalkers) or not Talent(hand_of_doom_talent) and target.TimeToDie() > BaseDuration(doom_debuff) and { not target.DebuffPresent(doom_debuff) or target.DebuffRemaining(doom_debuff) < BaseDuration(doom_debuff) * 0.3 } and not { no_de1() or PreviousGCDSpell(hand_of_guldan) } and Spell(doom) or Charges(shadowflame) == 2 and SoulShards() < 5 and Enemies(tagged=1) < 5 and not no_de1() and Spell(shadowflame) or Spell(service_felguard)
        {
            #summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening<=2&(target.time_to_die>180|target.health.pct<=20|target.time_to_die<30)
            if not Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) <= 2 and { target.TimeToDie() > 180 or target.HealthPercent() <= 20 or target.TimeToDie() < 30 } Spell(summon_doomguard)
            #summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.infernal_awakening>2
            if not Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) > 2 Spell(summon_infernal)
            #summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal=1&equipped.132379&!cooldown.sindorei_spite_icd.remains
            # if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) == 1 and HasEquippedItem(132379) and not SpellCooldown(sindorei_spite_icd) > 0 Spell(summon_doomguard)
            #summon_infernal,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>1&equipped.132379&!cooldown.sindorei_spite_icd.remains
            # if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) > 1 and HasEquippedItem(132379) and not SpellCooldown(sindorei_spite_icd) > 0 Spell(summon_infernal)

            unless BuffPresent(shadowy_inspiration_buff) and SoulShards() < 5 and not PreviousGCDSpell(doom) and not no_de2() and Spell(shadow_bolt) or { PreviousGCDSpell(hand_of_guldan) or PreviousGCDSpell(call_dreadstalkers) or Talent(power_trip_talent) } and Spell(summon_darkglare) or SpellCooldown(call_dreadstalkers) > 5 and SoulShards() < 3 and Spell(summon_darkglare) or SpellCooldown(call_dreadstalkers) <= CastTime(summon_darkglare) and { SoulShards() >= 3 or SoulShards() >= 1 and BuffPresent(demonic_calling_buff) } and Spell(summon_darkglare) or Talent(summon_darkglare_talent) and { Enemies(tagged=1) < 3 or not Talent(implosion_talent) } and { SpellCooldown(summon_darkglare) > 2 or PreviousGCDSpell(summon_darkglare) or SpellCooldown(summon_darkglare) <= CastTime(call_dreadstalkers) and SoulShards() >= 3 or SpellCooldown(summon_darkglare) <= CastTime(call_dreadstalkers) and SoulShards() >= 1 and BuffPresent(demonic_calling_buff) } and Spell(call_dreadstalkers) or SoulShards() >= 4 and { not { no_de1() or PreviousGCDSpell(hand_of_guldan) } and { pet_count() >= 13 and not Talent(shadowy_inspiration_talent) or pet_count() >= 6 and Talent(shadowy_inspiration_talent) } or not no_de2() or SoulShards() == 5 } and Talent(power_trip_talent) and Spell(hand_of_guldan) or { SoulShards() >= 3 and PreviousGCDSpell(call_dreadstalkers) and not ArtifactTraitRank(thalkiels_ascendance) or SoulShards() >= 5 or SoulShards() >= 4 and SpellCooldown(summon_darkglare) > 2 } and Spell(hand_of_guldan) or { { Talent(power_trip_talent) and { not Talent(implosion_talent) or Enemies(tagged=1) <= 1 } or not Talent(implosion_talent) or Talent(implosion_talent) and not Talent(soul_conduit_talent) and Enemies(tagged=1) <= 3 } and { NotDeDemons(wild_imp) > 3 or PreviousGCDSpell(hand_of_guldan) } or PreviousGCDSpell(hand_of_guldan) and NotDeDemons(wild_imp) == 0 and DemonDuration(wild_imp) <= 0 or PreviousGCDSpell(implosion) and NotDeDemons(wild_imp) > 0 } and Spell(demonic_empowerment) or { no_de1() or PreviousGCDSpell(hand_of_guldan) } and Spell(demonic_empowerment)
            {
                #use_items
                # DemonologyUseItemActions()
                #berserking
                Spell(berserking)
                #blood_fury
                Spell(blood_fury_sp)
                #soul_harvest,if=!buff.soul_harvest.remains
                if not BuffPresent(soul_harvest_buff) Spell(soul_harvest)
                #potion,name=prolonged_power,if=buff.soul_harvest.remains|target.time_to_die<=70|trinket.proc.any.react
                # if { BuffPresent(soul_harvest_buff) or target.TimeToDie() <= 70 or BuffPresent(trinket_proc_any_buff) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
            }
        }
    }
}

AddFunction DemonologyDefaultCdPostConditions
{
    DemonDuration(wild_imp) <= ExecuteTime(shadow_bolt) and { BuffPresent(demonic_synergy_buff) or Talent(soul_conduit_talent) or not Talent(soul_conduit_talent) and Enemies(tagged=1) > 1 or Demons(wild_imp) <= 4 } and Spell(implosion) or PreviousGCDSpell(hand_of_guldan) and { DemonDuration(wild_imp) <= 3 and BuffPresent(demonic_synergy_buff) or DemonDuration(wild_imp) <= 4 and Enemies(tagged=1) > 2 } and Spell(implosion) or target.DebuffStacks(shadowflame_debuff) > 0 and target.DebuffRemaining(shadowflame_debuff) < CastTime(shadow_bolt) + TravelTime(shadowflame) and Enemies(tagged=1) < 5 and Spell(shadowflame) or { not Talent(summon_darkglare_talent) or Talent(power_trip_talent) } and { Enemies(tagged=1) < 3 or not Talent(implosion_talent) } and not { SoulShards() == 5 and BuffPresent(demonic_calling_buff) } and Spell(call_dreadstalkers) or not Talent(hand_of_doom_talent) and target.TimeToDie() > BaseDuration(doom_debuff) and { not target.DebuffPresent(doom_debuff) or target.DebuffRemaining(doom_debuff) < BaseDuration(doom_debuff) * 0.3 } and not { no_de1() or PreviousGCDSpell(hand_of_guldan) } and Spell(doom) or Charges(shadowflame) == 2 and SoulShards() < 5 and Enemies(tagged=1) < 5 and not no_de1() and Spell(shadowflame) or Spell(service_felguard) or BuffPresent(shadowy_inspiration_buff) and SoulShards() < 5 and not PreviousGCDSpell(doom) and not no_de2() and Spell(shadow_bolt) or { PreviousGCDSpell(hand_of_guldan) or PreviousGCDSpell(call_dreadstalkers) or Talent(power_trip_talent) } and Spell(summon_darkglare) or SpellCooldown(call_dreadstalkers) > 5 and SoulShards() < 3 and Spell(summon_darkglare) or SpellCooldown(call_dreadstalkers) <= CastTime(summon_darkglare) and { SoulShards() >= 3 or SoulShards() >= 1 and BuffPresent(demonic_calling_buff) } and Spell(summon_darkglare) or Talent(summon_darkglare_talent) and { Enemies(tagged=1) < 3 or not Talent(implosion_talent) } and { SpellCooldown(summon_darkglare) > 2 or PreviousGCDSpell(summon_darkglare) or SpellCooldown(summon_darkglare) <= CastTime(call_dreadstalkers) and SoulShards() >= 3 or SpellCooldown(summon_darkglare) <= CastTime(call_dreadstalkers) and SoulShards() >= 1 and BuffPresent(demonic_calling_buff) } and Spell(call_dreadstalkers) or SoulShards() >= 4 and { not { no_de1() or PreviousGCDSpell(hand_of_guldan) } and { pet_count() >= 13 and not Talent(shadowy_inspiration_talent) or pet_count() >= 6 and Talent(shadowy_inspiration_talent) } or not no_de2() or SoulShards() == 5 } and Talent(power_trip_talent) and Spell(hand_of_guldan) or { SoulShards() >= 3 and PreviousGCDSpell(call_dreadstalkers) and not ArtifactTraitRank(thalkiels_ascendance) or SoulShards() >= 5 or SoulShards() >= 4 and SpellCooldown(summon_darkglare) > 2 } and Spell(hand_of_guldan) or { { Talent(power_trip_talent) and { not Talent(implosion_talent) or Enemies(tagged=1) <= 1 } or not Talent(implosion_talent) or Talent(implosion_talent) and not Talent(soul_conduit_talent) and Enemies(tagged=1) <= 3 } and { NotDeDemons(wild_imp) > 3 or PreviousGCDSpell(hand_of_guldan) } or PreviousGCDSpell(hand_of_guldan) and NotDeDemons(wild_imp) == 0 and DemonDuration(wild_imp) <= 0 or PreviousGCDSpell(implosion) and NotDeDemons(wild_imp) > 0 } and Spell(demonic_empowerment) or { no_de1() or PreviousGCDSpell(hand_of_guldan) } and Spell(demonic_empowerment) or Charges(shadowflame) == 2 and Enemies(tagged=1) < 5 and Spell(shadowflame) or { DemonDuration(dreadstalker) > ExecuteTime(thalkiels_consumption) or Talent(implosion_talent) and Enemies(tagged=1) >= 3 } and Demons(wild_imp) > 3 and DemonDuration(wild_imp) > ExecuteTime(thalkiels_consumption) and Spell(thalkiels_consumption) or { ManaPercent() <= 15 or ManaPercent() <= 65 and { SpellCooldown(call_dreadstalkers) <= 0.75 and SoulShards() >= 2 or SpellCooldown(call_dreadstalkers) < GCD() * 2 and { SpellCooldown(summon_doomguard) <= 0.75 or SpellCooldown(service_pet) <= 0.75 } and SoulShards() >= 3 } } and Spell(life_tap) or Enemies(tagged=1) >= 3 and Spell(demonwrath) or Speed() > 0 and Spell(demonwrath) or Spell(demonbolt) or BuffPresent(shadowy_inspiration_buff) and Spell(shadow_bolt) or ArtifactTraitRank(thalkiels_ascendance) and Talent(power_trip_talent) and not Talent(demonbolt_talent) and Talent(shadowy_inspiration_talent) and Spell(demonic_empowerment) or Spell(shadow_bolt) or Spell(life_tap)
}

### actions.precombat

AddFunction DemonologyPrecombatMainActions
{
    #demonic_empowerment
    Spell(demonic_empowerment)
    #demonbolt
    Spell(demonbolt)
    #shadow_bolt
    Spell(shadow_bolt)
}

AddFunction DemonologyPrecombatMainPostConditions
{
}

AddFunction DemonologyPrecombatShortCdActions
{
    #flask
    #food
    #augmentation
    #summon_pet,if=!talent.grimoire_of_supremacy.enabled&(!talent.grimoire_of_sacrifice.enabled|buff.demonic_power.down)
    # if not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() Spell(summon_felguard)
}

AddFunction DemonologyPrecombatShortCdPostConditions
{
    Spell(demonic_empowerment) or Spell(demonbolt) or Spell(shadow_bolt)
}

AddFunction DemonologyPrecombatCdActions
{
    unless not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() and Spell(summon_felguard)
    {
        #summon_infernal,if=talent.grimoire_of_supremacy.enabled&artifact.lord_of_flames.rank>0
        # if Talent(grimoire_of_supremacy_talent) and ArtifactTraitRank(lord_of_flames) > 0 Spell(summon_infernal)
        #summon_infernal,if=talent.grimoire_of_supremacy.enabled&active_enemies>1
        # if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) > 1 Spell(summon_infernal)
        #summon_doomguard,if=talent.grimoire_of_supremacy.enabled&active_enemies=1&artifact.lord_of_flames.rank=0
        # if Talent(grimoire_of_supremacy_talent) and Enemies(tagged=1) == 1 and ArtifactTraitRank(lord_of_flames) == 0 Spell(summon_doomguard)
        #snapshot_stats
        #potion
        # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
    }
}

AddFunction DemonologyPrecombatCdPostConditions
{
    not Talent(grimoire_of_supremacy_talent) and { not Talent(grimoire_of_sacrifice_talent) or BuffExpires(demonic_power_buff) } and not pet.Present() and Spell(summon_felguard) or Spell(demonic_empowerment) or Spell(demonbolt) or Spell(shadow_bolt)
}
]]

	OvaleScripts:RegisterScript("WARLOCK", "demonology", name, desc, code, "script")
end
