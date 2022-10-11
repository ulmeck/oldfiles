#!/usr/bin/perl

use strict;
use XML::Simple;
use Data::Dumper qw(Dumper);
use utf8;
use Encode;
use POSIX;
use Switch '__';

#
# Pull XML into datastructure
#

my $xml = new XML::Simple;
my $CS_in = $xml->XMLin('-');
#print Dumper ($CS_in);


#
#Assign the 'easy' data to their proper vars
#


my $Speed = $CS_in->{'baseSpeed'} + $CS_in->{'speedMiscMod'};
my $HPMax = $CS_in->{'maxHealth'};
my $ProfBonus = $CS_in->{'proficiencyBonus'};


#
# Decode Ability Scores
#

my @abilityScores = split (/\x{22a0}|\x{e2}\x{8a}\x{a0}/, $CS_in->{'abilityScores'});
#print Dumper(@abilityScores);

foreach my $item(@abilityScores){
  $item = $item eq 'true' ? "Yes" : $item;
#  print $item;
}

my ($STR,$DEX,$CON,
		$INT,$WIS,$CHA,
		$Prof_STR, $Prof_DEX,
		$Prof_CON, $Prof_INT,
		$Prof_WIS, $Prof_CHA,
		$str_misc, $dex_misc, $con_misc,
		$int_misc, $wis_misc, $cha_misc, 
		$mod_savs) = @abilityScores;




#print Dumper(@abilityScores);

#
# Calculate Ability Scores
#


my $STRmod = floor(($STR - 10) / 2);
my $STSTR = $Prof_STR eq 'Yes' ? $STRmod + $ProfBonus : $STRmod;
$STSTR += $str_misc;
my $DEXmod = floor(($DEX - 10) / 2);
my $STDEX = $Prof_DEX eq 'Yes' ? $DEXmod + $ProfBonus : $DEXmod;
$STDEX += $dex_misc;
my $CONmod = floor(($CON - 10) / 2);
my $STCON = $Prof_CON eq 'Yes' ? $CONmod + $ProfBonus : $CONmod;
$STCON += $con_misc;
my $INTmod = floor(($INT - 10) / 2);
my $STINT = $Prof_INT eq 'Yes' ? $INTmod + $ProfBonus : $INTmod;
$STINT += $int_misc;
my $WISmod = floor(($WIS - 10) / 2);
my $STWIS = $Prof_WIS eq 'Yes' ? $WISmod + $ProfBonus : $WISmod;
$STWIS += $wis_misc;
my $CHAmod = floor(($CHA - 10) / 2);
my $STCHA = $Prof_CHA eq 'Yes' ? $CHAmod + $ProfBonus : $CHAmod;
$STCHA += $cha_misc;

# add

my $sav_misc;

switch ($mod_savs) {

	case 1	{$sav_misc = $STRmod}
	case 2	{$sav_misc = $DEXmod}
	case 3	{$sav_misc = $CONmod}
	case 4	{$sav_misc = $INTmod}
	case 5	{$sav_misc = $WISmod}
	case 6	{$sav_misc = $CHAmod}
	else		{$sav_misc = 0}
}	

$STSTR += $sav_misc;
$STDEX += $sav_misc;
$STCON += $sav_misc;
$STINT += $sav_misc;
$STWIS += $sav_misc;
$STCHA += $sav_misc;


#print "$CHA, $CHAmod, $ProfBonus, $STCHA, $cha_misc\n";

#
# Casting Ability
#

my $CastingModCode = $CS_in->{'castingStatCode'};
my $SpellcastingAbility;
my $CastingMod;
switch ($CastingModCode) {
	case 0	{$SpellcastingAbility = 'STR'; $CastingMod = $STRmod}
	case 1	{$SpellcastingAbility = 'DEX'; $CastingMod = $DEXmod}
	case 2	{$SpellcastingAbility = 'CON'; $CastingMod = $CONmod}
	case 3	{$SpellcastingAbility = 'INT'; $CastingMod = $INTmod}
	case 4	{$SpellcastingAbility = 'WIS'; $CastingMod = $WISmod}
	case 5	{$SpellcastingAbility = 'CHA'; $CastingMod = $CHAmod}
	else		{$SpellcastingAbility = 'UNK'; $CastingMod = 0}
}	

my $SpellSaveDC = $CastingMod + $ProfBonus + $CS_in->{'miscSpellDCBonus'} + 8;
my $SpellAtkBonus = $CastingMod + $CS_in->{'miscSpellAttackBonus'} + $ProfBonus;


#
# Decode Skills
#

my @Skills = split (/\x{22a0}|\x{e2}\x{8a}\x{a0}/, $CS_in->{'skillInfo'});
#print Dumper(@Skills);
#exit;

foreach my $item(@Skills){
  $item = $item eq 'true' ? "Yes" : $item; 
}

my (

$Prof_Athletics,
$Prof_Acrobatics,
$Prof_SleightofHand,
$Prof_Stealth,
$Prof_Arcana,
$Prof_History,
$Prof_Investigation,
$Prof_Nature,
$Prof_Religion,
$Prof_Animal,
$Prof_Insight,
$Prof_Medicine,
$Prof_Perception,
$Prof_Survival,
$Prof_Deception,
$Prof_Intimidation,
$Prof_Performance,
$Prof_Persuasion,
$unknown,
$Skill_Codes) =  @Skills;



foreach my $item(@Skills){
  $item = $item eq 'false' ? 0 : $item; 
}

#print Dumper(@Skills);
my (
$Skill1,
$Skill2,
$Skill3,
$Skill4,
$Skill5,
$Skill6,
$Skill7,
$Skill8,
$Skill9,
$Skill10,
$Skill11,
$Skill12,
$Skill13,
$Skill14,
$Skill15,
$Skill16,
$Skill17,
$Skill18,
$Skill19,
$Skill_misc_Athletics,
$Skill_misc_Acrobatics,
$Skill_misc_SleightofHand,
$Skill_misc_Stealth,
$Skill_misc_Arcana,
$Skill_misc_History,
$Skill_misc_Investigation,
$Skill_misc_Nature,
$Skill_misc_Religion,
$Skill_misc_Animal,
$Skill_misc_Insight,
$Skill_misc_Medicine,
$Skill_misc_Perception,
$Skill_misc_Survival,
$Skill_misc_Deception,
$Skill_misc_Intimidation,
$Skill_misc_Performance,
$Skill_misc_Persuasion,
$Skill_misc_Init,
$Skill_dbl_Athletics,
$Skill_dbl_Acrobatics,
$Skill_dbl_SleightofHand,
$Skill_dbl_Stealth,
$Skill_dbl_Arcana,
$Skill_dbl_History,
$Skill_dbl_Investigation,
$Skill_dbl_Nature,
$Skill_dbl_Religion,
$Skill_dbl_Animal,
$Skill_dbl_Insight,
$Skill_dbl_Medicine,
$Skill_dbl_Perception,
$Skill_dbl_Survival,
$Skill_dbl_Deception,
$Skill_dbl_Intimidation,
$Skill_dbl_Performance,
$Skill_dbl_Persuasion,
$Skill_dbl_Init,
$Skill_hlf_Athletics,
$Skill_hlf_Acrobatics,
$Skill_hlf_SleightofHand,
$Skill_hlf_Stealth,
$Skill_hlf_Arcana,
$Skill_hlf_History,
$Skill_hlf_Investigation,
$Skill_hlf_Nature,
$Skill_hlf_Religion,
$Skill_hlf_Animal,
$Skill_hlf_Insight,
$Skill_hlf_Medicine,
$Skill_hlf_Perception,
$Skill_hlf_Survival,
$Skill_hlf_Deception,
$Skill_hlf_Intimidation,
$Skill_hlf_Performance,
$Skill_hlf_Persuasion,
$Skill_hlf_Init,
$Skill77,
$Skill78,
$Skill79,
$Skill80,
$Skill81,
$Skill82,
$Skill83,
$Skill84,
$Skill85,
$Skill86,
$Skill87,
$Skill88,
$Skill89,
$Skill90,
$Skill91,
$Skill92,
$Skill93,
$Skill94,
$Skill95) = @Skills;


#print "$Skill_hlf_Init\n";





my $Athletics = $Prof_Athletics eq 'Yes' ? $STRmod + $ProfBonus : ($Skill_hlf_Athletics ? floor($ProfBonus/2) + $STRmod : $STRmod);
$Athletics += $Skill_dbl_Athletics ? $ProfBonus : 0;
my $Acrobatics = $Prof_Acrobatics eq 'Yes' ? $DEXmod + $ProfBonus : ($Skill_hlf_Acrobatics ? floor($ProfBonus/2) + $DEXmod : $DEXmod);
$Acrobatics += $Skill_dbl_Acrobatics ? $ProfBonus : 0;
my $SleightofHand = $Prof_SleightofHand eq 'Yes' ? $DEXmod + $ProfBonus : ($Skill_hlf_SleightofHand ? floor($ProfBonus/2) + $DEXmod : $DEXmod);
$SleightofHand += $Skill_dbl_SleightofHand ? $ProfBonus : 0;
my $Stealth = $Prof_Stealth eq 'Yes' ? $DEXmod + $ProfBonus : ($Skill_hlf_Stealth ? floor($ProfBonus/2) + $DEXmod : $DEXmod);
$Stealth += $Skill_dbl_Stealth ? $ProfBonus : 0;
my $Arcana = $Prof_Arcana eq 'Yes' ? $INTmod + $ProfBonus : ($Skill_hlf_Arcana ? floor($ProfBonus/2) + $INTmod : $INTmod);
$Arcana += $Skill_dbl_Arcana ? $ProfBonus : 0;
my $History = $Prof_History eq 'Yes' ? $INTmod + $ProfBonus : ($Skill_hlf_History ? floor($ProfBonus/2) + $INTmod : $INTmod);
$History += $Skill_dbl_History ? $ProfBonus : 0;
my $Investigation = $Prof_Investigation eq 'Yes' ? $INTmod + $ProfBonus : ($Skill_hlf_Investigation ? floor($ProfBonus/2) + $INTmod : $INTmod);
$Investigation += $Skill_dbl_Investigation ? $ProfBonus : 0;
my $Religion = $Prof_Religion eq 'Yes' ? $INTmod + $ProfBonus : ($Skill_hlf_Religion ? floor($ProfBonus/2) + $INTmod : $INTmod);
$Religion += $Skill_dbl_Religion ? $ProfBonus : 0;
my $Nature = $Prof_Nature eq 'Yes' ? $INTmod + $ProfBonus : ($Skill_hlf_Nature ? floor($ProfBonus/2) + $INTmod : $INTmod);
$Nature += $Skill_dbl_Nature ? $ProfBonus : 0;
my $Insight = $Prof_Insight eq 'Yes' ? $WISmod + $ProfBonus : ($Skill_hlf_Insight ? floor($ProfBonus/2) + $WISmod : $WISmod);
$Insight += $Skill_dbl_Insight ? $ProfBonus : 0;
my $Medicine = $Prof_Medicine eq 'Yes' ? $WISmod + $ProfBonus : ($Skill_hlf_Medicine ? floor($ProfBonus/2) + $WISmod : $WISmod);
$Medicine += $Skill_dbl_Medicine ? $ProfBonus : 0;
my $Animal = $Prof_Animal eq 'Yes' ? $WISmod + $ProfBonus : ($Skill_hlf_Animal ? floor($ProfBonus/2) + $WISmod : $WISmod);
$Animal += $Skill_dbl_Animal ? $ProfBonus : 0;
my $Perception = $Prof_Perception eq 'Yes' ? $WISmod + $ProfBonus : ($Skill_hlf_Perception ? floor($ProfBonus/2) + $WISmod : $WISmod);
$Perception += $Skill_dbl_Perception ? $ProfBonus : 0;
my $Survival = $Prof_Survival eq 'Yes' ? $WISmod + $ProfBonus : ($Skill_hlf_Survival ? floor($ProfBonus/2) + $WISmod : $WISmod);
$Survival += $Skill_dbl_Survival ? $ProfBonus : 0;
my $Deception = $Prof_Deception eq 'Yes' ? $CHAmod + $ProfBonus : ($Skill_hlf_Deception ? floor($ProfBonus/2) + $CHAmod : $CHAmod);
$Deception += $Skill_dbl_Deception ? $ProfBonus : 0;
my $Intimidation = $Prof_Intimidation eq 'Yes' ? $CHAmod + $ProfBonus : ($Skill_hlf_Intimidation ? floor($ProfBonus/2) + $CHAmod : $CHAmod);
$Intimidation += $Skill_dbl_Intimidation ? $ProfBonus : 0;
my $Performance = $Prof_Performance eq 'Yes' ? $CHAmod + $ProfBonus : ($Skill_hlf_Performance ? floor($ProfBonus/2) + $CHAmod : $CHAmod);
$Performance += $Skill_dbl_Performance ? $ProfBonus : 0;
my $Persuasion = $Prof_Persuasion eq 'Yes' ? $CHAmod + $ProfBonus : ($Skill_hlf_Persuasion ? floor($ProfBonus/2) + $CHAmod : $CHAmod);
$Persuasion += $Skill_dbl_Persuasion ? $ProfBonus : 0;

$Athletics += $Skill_misc_Athletics;
$Acrobatics += $Skill_misc_Acrobatics;
$SleightofHand += $Skill_misc_SleightofHand;
$Stealth += $Skill_misc_Stealth;
$Arcana += $Skill_misc_Arcana;
$History += $Skill_misc_History;
$Investigation += $Skill_misc_Investigation;
$Nature += $Skill_misc_Nature;
$Religion += $Skill_misc_Religion;
$Animal += $Skill_misc_Animal;
$Insight += $Skill_misc_Insight;
$Medicine += $Skill_misc_Medicine;
$Perception += $Skill_misc_Perception;
$Survival += $Skill_misc_Survival;
$Deception += $Skill_misc_Deception;
$Intimidation += $Skill_misc_Intimidation;
$Performance += $Skill_misc_Performance;
$Persuasion += $Skill_misc_Persuasion;



my $Passive = $Persuasion + 10;

my $HD;

my @HDList = split (/\x{22a0}|\x{e2}\x{8a}\x{a0}/, $CS_in->{'hitDiceList'});
#print Dumper(@HDList);
for (my $i=0; $i < $HDList[0]; $i++) {
  $HD .= "$HDList[(($i * 3) + 1)]d$HDList[(($i * 3) + 2)]\n";
}
chomp $HD;


#
# Decode Class Data
#


my @ClassData = split (/\x{229f}/, $CS_in->{'classData'});
#print Dumper(@ClassData);


my( $classes, $class_feature1, $class_feature2, $feats, $class_misc,
$class_unk1, $class_unk2, $race, $subrace, $background, $class_mods,
$class_mods2, $class_unk6, $init_mod, $class_unk8, $class_unk9, $class_unk10,
$class_unk11, $class_unk12) = split (/\x{229f}/, $CS_in->{'classData'});

my @classMods = split (/\x{22a0}/, $class_mods);
my @classMods2 = split (/\x{22a0}/, $class_mods2);

#print Dumper(@classMods);
#exit;

my ($mod_1, $mod_2, $r_tohit_mod, $mod_4, $mod_5, $mod6,
$mod_7, $mod_8, $mod_9) = @classMods;

my ($mod_1, $mod_2, $r_dam_mod, $mod_4, $mod_5, $mod6,
$mod_7, $mod_8, $mod_9) = @classMods2;



#
# Decode WeaponList
#

my @WeaponList = split (/\x{22a0}|\x{e2}\x{8a}\x{a0}/, $CS_in->{'weaponList'});
my $wCounter = $WeaponList[0];
my @Weapons;
my $pointer = 1;
my $wrows = 11;
#print Dumper (@WeaponList);



for (my $i=0; $i < $wCounter; $i++) {
#  print "$i:" . $WeaponList[0] . "\n";
  my $weaponlen = ($wrows + $pointer - 1) + ($WeaponList[($wrows + $pointer - 1)] * 2);
#  print $weaponlen . "\n";
  my $count = 0;  
  for (my $s=$pointer; $s <= $weaponlen; $s++) {
#    print "$s:".($wrows + ($WeaponList[($wrows + $pointer - 1)] * 2))."\n";
    $Weapons[$i][$count] = ($i, $WeaponList[$s]);
    $count++;
    }
  $pointer = $pointer + $count;
  
}


#
#Parse out first three weapon entries and assign to the first three slots
#

#print Dumper(@Weapons);
#exit;

my ($Wpn1_Name, $Wpn2_Name, $Wpn3_Name);
my ($Wpn1_AtkBonus, $Wpn2_AtkBonus, $Wpn3_AtkBonus);
my ($Wpn1_Damage, $Wpn2_Damage, $Wpn3_Damage);
my $wpn_mod = $STRmod;

# Weapon 1
#
#if ($wCounter < 0) {
#my $Wpn1_Name = $Weapons[0][0];
#print "$WpnName1\n";
#
#if ($Weapons[0][9] eq 'true') {
#switch ($Weapons[0][3]) {
#
#	case 0	{$wpn_mod = $STRmod}
#	case 1	{$wpn_mod = $DEXmod}
#	case 2	{$wpn_mod = $CONmod}
#	case 3	{$wpn_mod = $INTmod}
#	case 4	{$wpn_mod = $WISmod}
#	case 5	{$wpn_mod = $CHAmod}
#	else		{$wpn_mod = 0}
#}} else { $wpn_mod = 0 }	
#
#my $wpn_hit_bonus;
#
#switch (substr($Weapons[0][2], 0, 1)) {
#	case 2 	{$wpn_hit_bonus = $r_tohit_mod} 
#	else		{$wpn_hit_bonus = 0}
#}
#
#
#
#my $Wpn1_AtkBonus = $wpn_mod + $Weapons[0][4] + $Weapons[0][5] + $ProfBonus + $wpn_hit_bonus;
#my $WpnDamBonus = $wpn_mod + $Weapons[0][6] + $Weapons[0][7];
#my $dam_string = "";
#for (my $i=11; $i < ($Weapons[0][10] * 2) + 10; $i+=2) {
#  $dam_string .= $Weapons[0][$i] ."d" . $Weapons[0][$i+1] . "+";
#}  
#$dam_string .= "$WpnDamBonus\n";
#chomp $dam_string;
#my $Wpn1_Damage = $dam_string;
#}
#
##
## Weapon 2
##
#
#
#if ($wCounter < 1) {
#my $Wpn2_Name = $Weapons[1][0];
##print "$WpnName1\n";
#
#
#
#
#if ($Weapons[1][9] eq 'true') {
#switch ($Weapons[1][3]) {
#
#	case 0	{$wpn_mod = $STRmod}
#	case 1	{$wpn_mod = $DEXmod}
#	case 2	{$wpn_mod = $CONmod}
#	case 3	{$wpn_mod = $INTmod}
#	case 4	{$wpn_mod = $WISmod}
#	case 5	{$wpn_mod = $CHAmod}
#	else		{$wpn_mod = 0}
#}} else {$wpn_mod = 0 }
#
#my $wpn_hit_bonus;
#
#switch (substr($Weapons[1][2], 0, 1)) {
#	case 2 	{$wpn_hit_bonus = $r_tohit_mod} 
#	else		{$wpn_hit_bonus = 0}
#}
#
#	
#my $Wpn2_AtkBonus = $wpn_mod + $Weapons[1][4] + $Weapons[1][5] + $ProfBonus + $wpn_hit_bonus;
#my $WpnDamBonus = $wpn_mod + $Weapons[1][6] + $Weapons[1][7];
#my $dam_string = "";
#for (my $i=11; $i < ($Weapons[1][10] * 2) + 10; $i+=2) {
#  $dam_string .= $Weapons[1][$i] ."d" . $Weapons[1][$i+1] . "+";
#}  
#$dam_string .= "$WpnDamBonus\n";
#chomp $dam_string;
#my $Wpn2_Damage = $dam_string;
#}
#
##
##Weapon 3
##
#
#if ($wCounter < 2) {
#my $Wpn3_Name = $Weapons[2][0];
##print "$WpnName1\n";
#
#
#
#if ($Weapons[2][9] eq 'true') {
#switch ($Weapons[2][3]) {
#
#	case 0	{$wpn_mod = $STRmod}
#	case 1	{$wpn_mod = $DEXmod}
#	case 2	{$wpn_mod = $CONmod}
#	case 3	{$wpn_mod = $INTmod}
#	case 4	{$wpn_mod = $WISmod}
#	case 5	{$wpn_mod = $CHAmod}
#	else		{$wpn_mod = 0}
#}} else { $wpn_mod = 0}	
#	
#my $wpn_hit_bonus;
#
#switch (substr($Weapons[2][2], 0, 1)) {
#	case 2 	{$wpn_hit_bonus = $r_tohit_mod} 
#	else		{$wpn_hit_bonus = 0}
#}
#	
#my $Wpn3_AtkBonus = $wpn_mod + $Weapons[2][4] + $Weapons[2][5] + $ProfBonus + $wpn_hit_bonus;
#my $WpnDamBonus = $wpn_mod + $Weapons[2][6] + $Weapons[2][7];
#my $dam_string = "";
#for (my $i=11; $i < ($Weapons[2][10] * 2) + 10; $i+=2) {
#  $dam_string .= $Weapons[2][$i] ."d" . $Weapons[2][$i+1] . "+";
#}  
#$dam_string .= "$WpnDamBonus\n";
#chomp $dam_string;
#my $Wpn3_Damage = $dam_string;
#}
#
#
#Weapon text field... for later.
#

my $AttackSpellcasting eq "";

for (my $w=0; $w < $wCounter; $w++) {

	my $Wpn_Name = $Weapons[$w][0];
  
	
		switch ($Weapons[$w][3]) {

		case 0	{$wpn_mod = $STRmod}
		case 1	{$wpn_mod = $DEXmod}
		case 2	{$wpn_mod = $CONmod}
		case 3	{$wpn_mod = $INTmod}
		case 4	{$wpn_mod = $WISmod}
		case 5	{$wpn_mod = $CHAmod}
		else		{$wpn_mod = 0}
}	

	my $wpn_hit_bonus;
	my $wpn_dam_bonus;

	switch (substr($Weapons[$w][2], 0, 1)) {
	case 2 	{$wpn_hit_bonus = $r_tohit_mod} 
	else		{$wpn_hit_bonus = 0}
}


	my $Wpn_AtkBonus = $wpn_mod + $Weapons[$w][4] + $Weapons[$w][5] + $ProfBonus + $wpn_hit_bonus;
	my $WpnDamBonus =  $Weapons[$w][6] + $Weapons[$w][7];
	if ($Weapons[$w][9] eq 'true') { $WpnDamBonus += $wpn_mod }
	my $dam_string = "";
	for (my $i=11; $i < ($Weapons[$w][10] * 2) + 10; $i+=2) {
  	$dam_string .= $Weapons[$w][$i] ."d" . $Weapons[$w][$i+1] . "+";
	}  
	$dam_string .= "$WpnDamBonus\n";
	chomp $dam_string;
	my $Wpn_Damage = $dam_string;

	switch ($w) {
	
	case 0	{$Wpn1_Name = $Wpn_Name; $Wpn1_AtkBonus = $Wpn_AtkBonus; $Wpn1_Damage = $Wpn_Damage} 
	case 1	{$Wpn2_Name = $Wpn_Name; $Wpn2_AtkBonus = $Wpn_AtkBonus; $Wpn2_Damage = $Wpn_Damage} 
	case 2	{$Wpn3_Name = $Wpn_Name; $Wpn3_AtkBonus = $Wpn_AtkBonus; $Wpn3_Damage = $Wpn_Damage} 
  else		{$AttackSpellcasting .= sprintf "%-20s %2s %14s\n", $Wpn_Name, $Wpn_AtkBonus, $Wpn_Damage}
  }
}

#print $AttackSpellcasting;




#
# Calculate the AC
#

my $AC = $CS_in->{'armorBonus'} + $CS_in->{'miscArmorBonus'} + $CS_in->{'shieldBonus'};
$AC += $DEXmod > $CS_in->{'maxDex'} ? $CS_in->{'maxDex'} : $DEXmod;


if ($CS_in->{'unarmoredDefense'} eq '3') {
  $AC = 10 + $DEXmod + $CONmod + $CS_in->{'miscArmorBonus'} + $CS_in->{'shieldBonus'};
}

if ($CS_in->{'unarmoredDefense'} eq '5') {
  $AC = 10 + $DEXmod + $WISmod + $CS_in->{'miscArmorBonus'};
}

#print "$STR:$DEX:$CON:$INT:$WIS:$CHA\n";
#print "AC:$CS_in->{'armorBonus'} $CS_in->{'miscArmorBonus'} $DEXmod $AC\n";



my $init_misc = $CS_in->{'initMiscMod'} ;
$init_misc += $Skill_hlf_Init ? floor($ProfBonus / 2) : 0;
#print "$Skill_hlf_Init, $init_mod, $init_misc\n";

#
# Add mod to init, if indicated
#

switch ($init_mod) {

	case 1	{$init_misc += $STRmod > 0 ? $STRmod : 0 }
	case 2	{$init_misc += $DEXmod > 0 ? $DEXmod : 0 }
	case 3	{$init_misc += $CONmod > 0 ? $CONmod : 0 }
	case 4	{$init_misc += $INTmod > 0 ? $INTmod : 0 }
	case 5	{$init_misc += $WISmod > 0 ? $WISmod : 0 }
	case 6	{$init_misc += $CHAmod > 0 ? $CHAmod : 0 }				
	else		{$init_misc += 0}
}	
#print "$init_misc\n";

my $Initiative = $DEXmod + $init_misc;

#print "$DEXmod, $init_misc, $Initiative\n";


#
# Spells
#
my %spellhash;
my %spellslots;
my %spellarray;
my %spellfinal;
my @spellList= split (/\x{22a0}|\x{e2}\x{8a}\x{a0}/, $CS_in->{'spellList'});
#print Dumper(@spellList);

foreach my $item(@spellList){
  $item = $item eq 'true' ? "Yes" : $item;
 # print "$item\n\n";
}

my ($spellist_version,$sslots,$sp_unk1,
		$sp_unk2,$sp_unk3,$sp_unk4,
		$caster_level, $sp_unk6, $spells) = @spellList;

my @spell_slots = split (/\x{e2}\x{8a}\x{a1}/, $sslots);
my $counter = 0;
foreach my $slot(@spell_slots) { 
	$spellslots{$counter} = $slot;
	$counter++;
}

my @spells = split (/\x{e2}\x{8a}\x{a1}/, $spells);
#print Dumper(@spells);

foreach my $spell(@spells){

	my @spell = split (/\x{e2}\x{8a}\x{9f}/, $spell);
	$spellhash{$spell[0]}{$spell[1]} = $spell[0];
}
#	print Dumper (%spellhash) . "\n\n";
#foreach my $spell (sort keys %spellhash) { print "$spellhash{$spell} $spell\n"}
foreach my $level (sort keys %spellhash) { 
#  print scalar (keys %{$spellhash{$level}}) . "\n";
	foreach my $spell (keys %{$spellhash{$level}}) {
		$spellarray{$level}{$spell} = $level;
	}
}


for (my $x=0; $x <=9; $x++) {
  my @temp = sort keys %{$spellarray{$x}};
	for (my $y=1; $y <= scalar (keys %{$spellarray{$x}}); $y++) {
	#	print "s$x-$y = $temp[$y-1]\n";
	  my $newy = sprintf("%02d", $y);
		$spellfinal{"S$x-$newy"} = $temp[$y-1];
	}	
}

#print Dumper (%spellfinal);

#foreach my $slot (sort keys %spellslots) { print "$slot $spellslots{$slot}\n"}


#
#
# Class Names and Levels
#
#my $ClassLevel = "";
#my $ClassVerbose = "";
#
#my @classes_arr = split (/\x{22a0}/, $classes);
#print Dumper(@classes_arr);
#for (my $i=0; $i < scalar @classes_arr; $i++) {
#  my($class,$subclass,$level,$tmp2) = split(/\x{22a1}/, @classes_arr[$i]);
#  $ClassLevel .= "$class $level,";
#  $ClassVerbose .= "$class $subclass $level/n";
#}
#chop $ClassLevel;
#chomp $ClassVerbose;


my @NoteList = split (/\x{22a0}|\x{e2}\x{8a}\x{a0}/, $CS_in->{'noteList'});

#print Dumper(@NoteList);

my $Features_Traits;
my $Feat_Traits = @NoteList[0];
my $box = chr(183);
$Feat_Traits =~ s/\x{e2}\x{80}\x{a2}/$box/mg;


my $CharacterName = @NoteList[15];
my $CharacterName2 = $CharacterName;
my $Background = @NoteList[9];
my $PlayerName = "John Fulmer";
my $Race = $subrace eq "" ? "$race" : "$subrace";
my $Alignment = @NoteList[10];
my $ClassLevel = @NoteList[16];
my $XP = @NoteList[22];
my $ProfLang = "@NoteList[3]@NoteList[4]";

my $CP = @NoteList[17];
my $SP = @NoteList[18];
my $EP = @NoteList[19];
my $GP = @NoteList[20];
my $PP = @NoteList[21];
my $Equipment = @NoteList[5];
my $PersonalityTraits = @NoteList[11];
my $Ideals = @NoteList[12];
my $Bonds = @NoteList[13];
my $Flaws = @NoteList[14];
my $Passive = $Perception + 10;
my $Age;
my $Eyes;
my $Height;
my $Skin;
my $Weight;
my $Hair;
my $Allies;
my $FactionName;
my $Backstory;
my $Treasure;
my $Add_Feat_Traits;

if ($NoteList[6] =~ s/(\+Back\+.*?\-Back\-)//s) {
	#print $NoteList[6] . "\n\n";
	$Backstory = $1;
	$Backstory =~ s/\+Back\+(.*?)\-Back\-/$1/s;
	#print $Backstory . "\n\n";
}

if ($NoteList[6] =~ s/(\+Treas\+.*?\-Treas\-)//s) {
	#print $NoteList[6] . "\n\n";
	$Treasure = $1;
	$Treasure =~ s/\+Treas\+(.*?)\-Treas\-/$1/s;
	#print $Treasure . "\n\n";
}

if ($NoteList[6] =~ s/(\+Add\+.*?\-Add\-)//s) {
	$Add_Feat_Traits =$1;
	$Add_Feat_Traits =~ s/\+Add\+(.*?)\-Add\-/$1/s;
}

my $Notes = @NoteList[6];
my @test;

my $output;



$output = <<"END_FDF";
%FDF-1.2
%‚„œ”
1 0 obj 
<<
/FDF 
<<
/Fields [
<<
/V ()
/T (FactionName)
>> 
<<
/V ($Ideals)
/T (Ideals)
>> 
<<
/V ($CP)
/T (CP)
>> 
<<
/V ($HPMax)
/T (HPMax)
>> 
<<
/V ($spellfinal{"S3-13"})
/T (S3-13)
>> 
<<
/V /$Prof_Stealth
/T (Prof_Stealth)
>> 
<<
/V ($spellfinal{"S3-12"})
/T (S3-12)
>> 
<<
/V ($spellfinal{"S3-11"})
/T (S3-11)
>> 
<<
/V ($spellfinal{"S3-10"})
/T (S3-10)
>> 
<<
/V /$Prof_Perception
/T (Prof_Perception)
>> 
<<
/V ($ClassLevel)
/T (ClassLevel)
>> 
<<
/V ($Animal)
/T (Animal)
>> 
<<
/V ($spellfinal{"S3-09"})
/T (S3-09)
>> 
<<
/V ($spellfinal{"S3-08"})
/T (S3-08)
>> 
<<
/V ($SP)
/T (SP)
>> 
<<
/V ($spellfinal{"S3-07"})
/T (S3-07)
>> 
<<
/V ($Perception)
/T (Perception)
>> 
<<
/V ($spellfinal{"S3-06"})
/T (S3-06)
>> 
<<
/V ($spellfinal{"S3-05"})
/T (S3-05)
>> 
<<
/V ($Wpn2_AtkBonus)
/T (Wpn2_AtkBonus)
>> 
<<
/V ($Intimidation)
/T (Intimidation)
>> 
<<
/V ($spellfinal{"S3-04"})
/T (S3-04)
>> 
<<
/V ()
/T (Weight)
>> 
<<
/V ($spellfinal{"S3-03"})
/T (S3-03)
>> 
<<
/V ($spellfinal{"S3-02"})
/T (S3-02)
>> 
<<
/V ($spellfinal{"S3-01"})
/T (S3-01)
>> 
<<
/V /$Prof_Insight
/T (Prof_Insight)
>> 
<<
/V ($STR)
/T (STR)
>> 
<<
/V ($CharacterName)
/T (CharacterName)
>> 
<<
/V ($AC)
/T (AC)
>> 
<<
/V /$Prof_CON
/T (Prof_CON)
>> 
<<
/V ($Investigation)
/T (Investigation)
>> 
<<
/V /$Prof_SleightofHand
/T (Prof_SleightofHand)
>> 
<<
/V ($CHA)
/T (CHA)
>> 
<<
/V ($INT)
/T (INT)
>> 
<<
/V ($spellfinal{"S4-13"})
/T (S4-13)
>> 
<<
/V ($spellfinal{"S4-12"})
/T (S4-12)
>> 
<<
/V ($spellfinal{"S4-11"})
/T (S4-11)
>> 
<<
/V ($spellfinal{"S4-10"})
/T (S4-10)
>> 
<<
/V ($Speed)
/T (Speed)
>> 
<<
/V ($PlayerName)
/T (PlayerName)
>> 
<<
/V /$Prof_WIS
/T (Prof_WIS)
>> 
<<
/V /$Prof_Investigation
/T (Prof_Investigation)
>> 
<<
/V ($Wpn2_Damage)
/T (Wpn2_Damage)
>> 
<<
/V ($spellfinal{"S4-09"})
/T (S4-09)
>> 
<<
/V ($spellfinal{"S4-08"})
/T (S4-08)
>> 
<<
/V ($spellfinal{"S4-07"})
/T (S4-07)
>> 
<<
/V ($Acrobatics)
/T (Acrobatics)
>> 
<<
/V ($spellfinal{"S4-06"})
/T (S4-06)
>> 
<<
/V ($spellfinal{"S4-05"})
/T (S4-05)
>> 
<<
/V ($STSTR)
/T (STSTR)
>> 
<<
/V ($spellfinal{"S4-04"})
/T (S4-04)
>> 
<<
/V ($spellfinal{"S4-03"})
/T (S4-03)
>> 
<<
/V ($spellfinal{"S4-02"})
/T (S4-02)
>> 
<<
/V ($CHAmod)
/T (CHAmod)
>> 
<<
/V ($spellfinal{"S4-01"})
/T (S4-01)
>> 
<<
/V ($spellslots{1})
/T (S1-Slots)
>> 
<<
/V ()
/T (Eyes)
>> 
<<
/V ($Add_Feat_Traits)
/T (Add_Feat_Traits)
>> 
<<
/V ($PP)
/T (PP)
>> 
<<
/V ($STCHA)
/T (STCHA)
>> 
<<
/V ($STINT)
/T (STINT)
>> 
<<
/V ($SpellSaveDC)
/T (SpellSaveDC)
>> 
<<
/V ()
/T (HPCurrent)
>> 
<<
/V /$Prof_Religion
/T (Prof_Religion)
>> 
<<
/V ($AttackSpellcasting)
/T (AttacksSpellcasting)
>> 
<<
/V ($Bonds)
/T (Bonds)
>> 
<<
/V /$Prof_DEX
/T (Prof_DEX)
>> 
<<
/V ($spellfinal{"S5-09"})
/T (S5-09)
>> 
<<
/V ($spellfinal{"S5-07"})
/T (S5-07)
>> 
<<
/V ($spellfinal{"S5-06"})
/T (S5-06)
>> 
<<
/V ($spellfinal{"S5-05"})
/T (S5-05)
>> 
<<
/V ($spellfinal{"S5-04"})
/T (S5-04)
>> 
<<
/V ($spellfinal{"S5-03"})
/T (S5-03)
>> 
<<
/V ($spellfinal{"S5-02"})
/T (S5-02)
>> 
<<
/V ($spellfinal{"S5-01"})
/T (S5-01)
>> 
<<
/V ($WISmod)
/T (WISmod)
>> 
<<
/V ($Wpn3_AtkBonus)
/T (Wpn3_AtkBonus)
>> 
<<
/V ($ProfBonus)
/T (ProfBonus)
>> 
<<
/V ($spellfinal{"S6-09"})
/T (S6-09)
>> 
<<
/V ($spellfinal{"S6-08"})
/T (S6-08)
>> 
<<
/V ($spellfinal{"S6-07"})
/T (S6-07)
>> 
<<
/V ($spellfinal{"S6-06"})
/T (S6-06)
>> 
<<
/V /$Prof_Intimidation
/T (Prof_Intimidation)
>> 
<<
/V ($Nature)
/T (Nature)
>> 
<<
/V ($Alignment)
/T (Alignment)
>> 
<<
/V ($spellfinal{"S6-05"})
/T (S6-05)
>> 
<<
/V ($spellfinal{"S6-04"})
/T (S6-04)
>> 
<<
/V ($History)
/T (History)
>> 
<<
/V ($spellfinal{"S6-03"})
/T (S6-03)
>> 
<<
/V ($spellfinal{"S6-02"})
/T (S6-02)
>> 
<<
/V ($spellfinal{"S6-01"})
/T (S6-01)
>> 
<<
/V /$Prof_Arcana
/T (Prof_Arcana)
>> 
<<
/V ($Insight)
/T (Insight)
>> 
<<
/V ($DEX)
/T (DEX)
>> 
<<
/V ($Survival)
/T (Survival)
>> 
<<
/V /$Prof_Persuasion
/T (Prof_Persuasion)
>> 
<<
/V ($Medicine)
/T (Medicine)
>> 
<<
/V ()
/T (Height)
>> 
<<
/V ($CONmod)
/T (CONmod)
>> 
<<
/V ($Wpn1_Name)
/T (Wpn1_Name)
>> 
<<
/V /$Prof_Athletics
/T (Prof_Athletics)
>> 
<<
/V ($Stealth)
/T (Stealth)
>> 
<<
/V ($SpellAtkBonus)
/T (SpellAtkBonus)
>> 
<<
/V ($Initiative)
/T (Initiative)
>> 
<<
/V ($Feat_Traits)
/T (Feat_Traits)
>> 
<<
/V ($STDEX)
/T (STDEX)
>> 
<<
/V ($INTmod)
/T (INTmod)
>> 
<<
/V ($spellfinal{"S7-09"})
/T (S7-09)
>> 
<<
/V ($Wpn2_Name)
/T (Wpn2_Name)
>> 
<<
/V ($spellfinal{"S7-08"})
/T (S7-08)
>> 
<<
/V ($SpellcastingAbility)
/T (SpellcastingAbility)
>> 
<<
/V ($spellfinal{"S7-07"})
/T (S7-07)
>> 
<<
/V ($spellfinal{"S7-06"})
/T (S7-06)
>> 
<<
/V ($spellfinal{"S7-05"})
/T (S7-05)
>> 
<<
/V ($ProfLang)
/T (ProfLang)
>> 
<<
/V ($spellfinal{"S7-04"})
/T (S7-04)
>> 
<<
/V ($Race)
/T (Race)
>> 
<<
/V ($spellfinal{"S7-03"})
/T (S7-03)
>> 
<<
/V ($spellfinal{"S7-02"})
/T (S7-02)
>> 
<<
/V ($spellfinal{"S7-01"})
/T (S7-01)
>> 
<<
/V ($DEXmod)
/T (DEXmod)
>> 
<<
/V ($Wpn3_Name)
/T (Wpn3_Name)
>> 
<<
/V ($Backstory)
/T (Backstory)
>> 
<<
/V ($CharacterName2)
/T (CharacterName2)
>> 
<<
/V ($Arcana)
/T (Arcana)
>> 
<<
/V ($Equipment)
/T (Equipment)
>> 
<<
/V ($spellfinal{"S0-08"})
/T (S0-08)
>> 
<<
/V ($WIS)
/T (WIS)
>> 
<<
/V ($spellfinal{"S0-07"})
/T (S0-07)
>> 
<<
/V ($spellfinal{"S0-06"})
/T (S0-06)
>> 
<<
/V ($Wpn3_Damage)
/T (Wpn3_Damage)
>> 
<<
/V ($spellfinal{"S0-05"})
/T (S0-05)
>> 
<<
/V ($spellfinal{"S0-04"})
/T (S0-04)
>> 
<<
/V ($spellfinal{"S0-03"})
/T (S0-03)
>> 
<<
/V ($spellfinal{"S0-02"})
/T (S0-02)
>> 
<<
/V ($spellfinal{"S0-01"})
/T (S0-01)
>> 
<<
/V ()
/T (HPTemp)
>> 
<<
/V ($Passive)
/T (Passive)
>> 
<<
/V ($Athletics)
/T (Athletics)
>> 
<<
/V /$Prof_INT
/T (Prof_INT)
>> 
<<
/V /$Prof_CHA
/T (Prof_CHA)
>> 
<<
/V ()
/T (Skin)
>> 
<<
/V ($SleightofHand)
/T (SleightofHand)
>> 
<<
/V ($HD)
/T (HD)
>> 
<<
/V ($Flaws)
/T (Flaws)
>> 
<<
/V ($CON)
/T (CON)
>> 
<<
/V /$Prof_STR
/T (Prof_STR)
>> 
<<
/V ($Treasure)
/T (Treasure)
>> 
<<
/V /
/T (Check Box 13)
>> 
<<
/V /
/T (Check Box 14)
>> 
<<
/V /
/T (Check Box 15)
>> 
<<
/V ($spellslots{3})
/T (S3-Slots)
>> 
<<
/V /
/T (Check Box 16)
>> 
<<
/V /
/T (Check Box 17)
>> 
<<
/V ($spellfinal{"S1-12"})
/T (S1-12)
>> 
<<
/V ($Wpn1_AtkBonus)
/T (Wpn1_AtkBonus)
>> 
<<
/V ($spellfinal{"S1-11"})
/T (S1-11)
>> 
<<
/V ($spellfinal{"S8-07"})
/T (S8-07)
>> 
<<
/V ($GP)
/T (GP)
>> 
<<
/V ($spellfinal{"S1-10"})
/T (S1-10)
>> 
<<
/V ($spellfinal{"S8-06"})
/T (S8-06)
>> 
<<
/V ($spellfinal{"S8-05"})
/T (S8-05)
>> 
<<
/V ($STWIS)
/T (STWIS)
>> 
<<
/V ($spellfinal{"S8-04"})
/T (S8-04)
>> 
<<
/V ($spellfinal{"S8-03"})
/T (S8-03)
>> 
<<
/V ($spellfinal{"S8-02"})
/T (S8-02)
>> 
<<
/V ($spellfinal{"S8-01"})
/T (S8-01)
>> 
<<
/V ($Performance)
/T (Performance)
>> 
<<
/V ($PersonalityTraits)
/T (PersonalityTraits)
>> 
<<
/V ($XP)
/T (XP)
>> 
<<
/V /$Prof_History
/T (Prof_History)
>> 
<<
/V ($spellfinal{"S1-09"})
/T (S1-09)
>> 
<<
/V ($spellfinal{"S1-08"})
/T (S1-08)
>> 
<<
/V ($spellslots{8})
/T (S8-Slots)
>> 
<<
/V ($spellfinal{"S1-07"})
/T (S1-07)
>> 
<<
/V ($spellfinal{"S1-06"})
/T (S1-06)
>> 
<<
/V ($spellfinal{"S1-05"})
/T (S1-05)
>> 
<<
/V ($spellfinal{"S1-04"})
/T (S1-04)
>> 
<<
/V ($Wpn1_Damage)
/T (Wpn1_Damage)
>> 
<<
/V ($spellfinal{"S1-03"})
/T (S1-03)
>> 
<<
/V ($spellfinal{"S1-02"})
/T (S1-02)
>> 
<<
/V ($spellfinal{"S1-01"})
/T (S1-01)
>> 
<<
/V /
/T (Faction Symbol Image)
>> 
<<
/V ($Persuasion)
/T (Persuasion)
>> 
<<
/V ($spellslots{4})
/T (S4-Slots)
>> 
<<
/V ($STCON)
/T (STCON)
>> 
<<
/V ($spellslots{7})
/T (S7-Slots)
>> 
<<
/V /
/T (CHARACTER IMAGE)
>> 
<<
/V ()
/T (Age)
>> 
<<
/V ($Notes)
/T (Allies)
>> 
<<
/V ()
/T (HDTotal)
>> 
<<
/V ()
/T (Inspiration)
>> 
<<
/V /$Prof_Performance
/T (Prof_Performance)
>> 
<<
/V ($EP)
/T (EP)
>> 
<<
/V ($STRmod)
/T (STRmod)
>> 
<<
/V ($spellslots{9})
/T (S9-Slots)
>> 
<<
/V ($spellfinal{"S2-13"})
/T (S2-13)
>> 
<<
/V /$Prof_Survival
/T (Prof_Survival)
>> 
<<
/V ($spellfinal{"S2-12"})
/T (S2-12)
>> 
<<
/V ($spellfinal{"S2-11"})
/T (S2-11)
>> 
<<
/V ($spellfinal{"S9-07"})
/T (S9-07)
>> 
<<
/V ($spellfinal{"S9-06"})
/T (S9-06)
>> 
<<
/V ($spellfinal{"S2-10"})
/T (S2-10)
>> 
<<
/V ()
/T (Hair)
>> 
<<
/V ($spellfinal{"S9-05"})
/T (S9-05)
>> 
<<
/V ($spellfinal{"S9-04"})
/T (S9-04)
>> 
<<
/V ($Background)
/T (Background)
>> 
<<
/V ($spellfinal{"S9-03"})
/T (S9-03)
>> 
<<
/V ($spellslots{2})
/T (S2-Slots)
>> 
<<
/V /$Prof_Acrobatics
/T (Prof_Acrobatics)
>> 
<<
/V ($spellfinal{"S9-02"})
/T (S9-02)
>> 
<<
/V /$Prof_Animal
/T (Prof_Animal)
>> 
<<
/V ($spellfinal{"S9-01"})
/T (S9-01)
>> 
<<
/V /$Prof_Medicine
/T (Prof_Medicine)
>> 
<<
/V ($spellslots{5})
/T (S5-Slots)
>> 
<<
/V ()
/T (Spellcasting_Class)
>> 
<<
/V /$Prof_Nature
/T (Prof_Nature)
>>
<<
/V /$Prof_Deception
/T (Prof_Deception)
>>
<<
/V ($spellslots{6})
/T (S6-Slots)
>> 
<<
/V ($Religion)
/T (Religion)
>> 
<<
/V ($spellfinal{"S2-09"})
/T (S2-09)
>> 
<<
/V ($spellfinal{"S2-08"})
/T (S2-08)
>> 
<<
/V ($spellfinal{"S2-07"})
/T (S2-07)
>> 
<<
/V ($spellfinal{"S2-06"})
/T (S2-06)
>> 
<<
/V ($spellfinal{"S2-05"})
/T (S2-05)
>> 
<<
/V ($spellfinal{"S2-04"})
/T (S2-04)
>> 
<<
/V ($spellfinal{"S2-03"})
/T (S2-03)
>> 
<<
/V ($spellfinal{"S2-02"})
/T (S2-02)
>> 
<<
/V ($spellfinal{"S2-01"})
/T (S2-01)
>> 
<<
/V ($Deception)
/T (Deception)
>>]
>>
>>
endobj 
trailer

<<
/Root 1 0 R
>>
%%EOF
END_FDF



print encode('iso-8859-1', $output);
#my @test = split(/\<\</, $output);
#print Dumper(@test);





