#!/usr/bin/perl

use strict;
use XML::Simple;
use Data::Dumper;
use utf8;
use POSIX;

#
# Pull XML into datastructure
#

my $xml = new XML::Simple;
my $CS_in = $xml->XMLin('-');


#
#Assign the 'easy' data to their proper vars
#


my $Speed = $CS_in->{'baseSpeed'} + $CS_in->{'speedMiscMod'};
my $HPMax = $CS_in->{'maxhealth'};
my $ProfBonus = $CS_in->{'proficiencyBonus'};

#
# Decode Ability Scores
#

my @abilityScores = split (/\x{22a0}|\x{e2}\x{8a}\x{a0}/, $CS_in->{'abilityScores'});
#print Dumper(@abilityScores);
my ($STR,$DEX,$CON,
		$INT,$WIS,$CHA,
		$str_button, $dex_button,
		$con_button, $int_button,
		$wis_button, $cha_button,
		$str_misc, $dex_misc, $con_misc,
		$int_misc, $wis_misc, $cha_misc, 
		$mod_savs) = split (/\x{22a0}|\x{e2}\x{8a}\x{a0}/, $CS_in->{'abilityScores'});

#print Dumper(@abilityScores);

#
# Calculate Ability Scores
#

my $STRmod = floor(($STR - 10) / 2);
my $STSTR = $str_button eq 'true' ? $STRmod + $ProfBonus : $STRmod;
$STSTR += $str_misc;
my $DEXmod = floor(($DEX - 10) / 2);
my $STDEX = $dex_button eq 'true' ? $DEXmod + $ProfBonus : $DEXmod;
$STDEX += $dex_misc;
my $CONmod = floor(($CON - 10) / 2);
my $STCON = $con_button eq 'true' ? $CONmod + $ProfBonus : $CONmod;
$STCON += $con_misc;
my $INTmod = floor(($INT - 10) / 2);
my $STINT = $int_button eq 'true' ? $INTmod + $ProfBonus : $INTmod;
$STINT += $int_misc;
my $WISmod = floor(($WIS - 10) / 2);
my $STWIS = $wis_button eq 'true' ? $WISmod + $ProfBonus : $WISmod;
$STWIS += $wis_misc;
my $CHAmod = floor(($CHA - 10) / 2);
my $STCHA = $cha_button eq 'true' ? $CHAmod + $ProfBonus : $CHAmod;
$STCHA += $cha_misc;


#print "$STR, $STRmod, $ProfBonus, $STSTR\n";


#
# Decode Skills
#

#my @abilityScores = split (/\x{22a0}|\x{e2}\x{8a}\x{a0}/, $CS_in->{'skillInfo'});
#print Dumper(@abilityScores);

my (

$Ath_button,
$Acro_button,
$SlightofHand_button,
$Stealth_button,
$Arcana_button,
$History_button,
$Invest_button,
$Nature_button,
$Religion_button,
$Animal_button,
$Insight_button,
$Medicine_button,
$Perc_button,
$Survival_button,
$Deception_button,
$Intim_button,
$Perf_button,
$Persu_button,
$unknown,
$Skill_Codes) =  split (/\x{22a0}|\x{e2}\x{8a}\x{a0}/, $CS_in->{'skillInfo'});

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
$Skill20,
$Skill21,
$Skill22,
$Skill23,
$Skill24,
$Skill25,
$Skill26,
$Skill27,
$Skill28,
$Skill29,
$Skill30,
$Skill31,
$Skill32,
$Skill33,
$Skill34,
$Skill35,
$Skill36,
$Skill_CON_Init,
$Skill38,
$Skill39,
$Skill40,
$Skill41,
$Skill42,
$Skill43,
$Skill44,
$Skill45,
$Skill46,
$Skill47,
$Skill48,
$Skill49,
$Skill50,
$Skill51,
$Skill52,
$Skill53,
$Skill54,
$Skill55,
$Skill56,
$Skill57,
$Skill58,
$Skill59,
$Skill60,
$Skill61,
$Skill62,
$Skill63,
$Skill64,
$Skill65,
$Skill66,
$Skill67,
$Skill68,
$Skill69,
$Skill70,
$Skill71,
$Skill72,
$Skill73,
$Skill74,
$Skill75 ) = split (/\x{22a0}|\x{e2}\x{8a}\x{a0}/,$Skill_Codes);

#print Dumper(@Skill_Codes);



my $Initiative = $DEXmod + $CS_in->{'initMiscMod'};


my $ClassLevel;
my $Background;
my $PlayerName;
my $XP;
my $Race;
my $Alignment;



my $Athletics;

my $Acrobatics = $Acro_button eq 'true' ? $DEXmod + $ProfBonus : $DEXmod;
my $SleightofHand = $SlightofHand_button eq 'true' ? $DEXmod + $ProfBonus : $DEXmod;
my $Stealth = $Stealth_button eq 'true' ? $DEXmod + $ProfBonus : $DEXmod;

my $Arcana = $Arcana_button eq 'true' ? $INTmod + $ProfBonus : $INTmod;
my $History = $History_button eq 'true' ? $INTmod + $ProfBonus : $INTmod;
my $Investigation = $Invest_button eq 'true' ? $INTmod + $ProfBonus : $INTmod;
my $Religion = $Religion_button eq 'true' ? $INTmod + $ProfBonus : $INTmod;
my $Nature = $Nature_button eq 'true' ? $INTmod + $ProfBonus : $INTmod;

my $Insight = $Insight_button eq 'true' ? $WISmod + $ProfBonus : $WISmod;
my $Medicine = $Medicine_button eq 'true' ? $WISmod + $ProfBonus : $WISmod;
my $Animal = $Animal_button eq 'true' ? $WISmod + $ProfBonus : $WISmod;
my $Perception = $Perc_button eq 'true' ? $WISmod + $ProfBonus : $WISmod;
my $Survival = $Survival_button eq 'true' ? $WISmod + $ProfBonus : $WISmod;

my $Deception = $Deception_button eq 'true' ? $CHAmod + $ProfBonus : $CHAmod;
my $Intimidation = $Intim_button eq 'true' ? $CHAmod + $ProfBonus : $CHAmod;
my $Performance = $Perf_button eq 'true' ? $CHAmod + $ProfBonus : $CHAmod;
my $Persuasion = $Persu_button eq 'true' ? $CHAmod + $ProfBonus : $CHAmod;

my $PP = $Persuasion + 10;

my $HD;

my @HDList = split (/\x{22a0}|\x{e2}\x{8a}\x{a0}/, $CS_in->{'hitDiceList'});
#print Dumper(@HDList);
for (my $i=0; $i < $HDList[0]; $i++) {
  $HD .= "$HDList[(($i * 3) + 1)]d$HDList[(($i * 3) + 2)]\n";
}
chomp $HD;

#
# Decode WeaponList
#

my @WeaponList = split (/\x{22a0}|\x{e2}\x{8a}\x{a0}/, $CS_in->{'weaponList'});
my $wCounter = $WeaponList[0];
my @Weapons;
my $pointer = 1;
my $wrows = 11;


for (my $i=0; $i < $WeaponList[0]; $i++) {
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
my $wpn_mod = $STRmod;

# Weapon 1

my $WpnName1 = $Weapons[0][0];
#print "$WpnName1\n";

if (substr($Weapons[0][2], 0, 1) eq '1') {
  $wpn_mod = $STRmod;
} elsif (substr($Weapons[0][2], 0, 1) eq '1') { 
  $wpn_mod = $DEXmod;
}
	
my $Wpn1AtkBonus = $wpn_mod + $Weapons[0][4] + $Weapons[0][5] + $ProfBonus;
my $WpnDamBonus = $wpn_mod + $Weapons[0][6] + $Weapons[0][7];
my $dam_string = "";
for (my $i=11; $i < ($Weapons[0][10] * 2) + 10; $i+=2) {
  $dam_string .= $Weapons[0][$i] ."d" . $Weapons[0][$i+1] . "+";
}  
$dam_string .= "$WpnDamBonus\n";
my $Wpn1Damage = $dam_string;

#
# Weapon 2
#

my $WpnName2 = $Weapons[1][0];
#print "$WpnName1\n";

if (substr($Weapons[1][2], 0, 1) == 1) {
  $wpn_mod = $STRmod;
} elsif (substr($Weapons[1][2], 0, 1) == 1) { 
  $wpn_mod = $DEXmod;
}
	
my $Wpn2AtkBonus = $wpn_mod + $Weapons[1][4] + $Weapons[1][5] + $ProfBonus;
my $WpnDamBonus = $wpn_mod + $Weapons[1][6] + $Weapons[1][7];
my $dam_string = "";
for (my $i=11; $i < ($Weapons[1][10] * 2) + 10; $i+=2) {
  $dam_string .= $Weapons[1][$i] ."d" . $Weapons[1][$i+1] . "+";
}  
$dam_string .= "$WpnDamBonus\n";
my $Wpn2Damage = $dam_string;

#
#Weapon 3
#

my $WpnName3 = $Weapons[2][0];
#print "$WpnName1\n";

if (substr($Weapons[2][2], 0, 1) == 1) {
  $wpn_mod = $STRmod;
} elsif (substr($Weapons[2][2], 0, 1) == 1) { 
  $wpn_mod = $DEXmod;
}
	
my $Wpn3AtkBonus = $wpn_mod + $Weapons[2][4] + $Weapons[2][5] + $ProfBonus;
my $WpnDamBonus = $wpn_mod + $Weapons[2][6] + $Weapons[2][7];
my $dam_string = "";
for (my $i=11; $i < ($Weapons[2][10] * 2) + 10; $i+=2) {
  $dam_string .= $Weapons[2][$i] ."d" . $Weapons[2][$i+1] . "+";
}  
$dam_string .= "$WpnDamBonus\n";
my $Wpn3Damage = $dam_string;

#
#Weapon text field... for later.
#

my $WpnName;

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

print "$STR:$DEX:$CON:$INT:$WIS:$CHA\n";
print "AC:$CS_in->{'armorBonus'} $CS_in->{'miscArmorBonus'} $DEXmod $AC\n";







my $ProfLang;
my $CP;
my $SP;
my $EP;
my $GP;
my $PP;
my $Equipment;
my $PersonalityTraits;
my $Ideals;
my $Bonds;
my $Flaws;
my $Feat_Traits;
my $Age;
my $Eyes;
my $Height;
my $Skin;
my $Weight;
my $Hair;
my $Allies					;
my $FactionName;
my $Backstory;
my $Features_Traits2;
my $Treasure;

my @test;



#print Dumper($CS_in);

#@test = split(/\x{22a0}/, $CS_in->{'noteList'});

#print "$test[0]\n\n";
#foreach (@test) {
#print "$_\n\n";
#}


