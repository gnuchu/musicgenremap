use Modern::Perl;
use autodie;
use Data::Dumper;
use DBI;
use DBD::SQLite;

`rm -rf music.sqlite3`;
my $dbh = DBI->connect("dbi:SQLite:dbname=music.sqlite3","","",{RaiseError =>1}) || die "Couldnt connect to DB.";
$dbh->do("CREATE TABLE genres (id integer primary key autoincrement, name varchar(200))");
$dbh->do("CREATE TABLE genrehassubgenre(parent_id integer, child_id integer)");
$dbh->do("CREATE INDEX genrehassubgenre_idx on genrehassubgenre(parent_id, child_id)");

open(my $nodefile, ">", "nodes.json") || die "Couldn't create output file.";

sub count_starting_spaces {
  my $str = shift;
  $str =~ /^(\s*)/;
  my $count = length( $1 );
  return $count;
}

sub current_level {
  my $indent = shift;
  return ($indent==0) ? 0 : ($indent/2);
}

sub ltrim { my $s = shift; $s =~ s/^\s+//;       return $s };

sub insert_genre_record {
  my $g = shift;
  my $statement = qq|insert into genres(name) values ("| . $g . qq|");|;
  $dbh->do($statement);
  return $dbh->last_insert_id("","","genres","")
}

sub insert_relation_record {
  my $child = shift;
  my $parent = shift;
  my $statement = qq|insert into genrehassubgenre (parent_id, child_id) select a.id, b.id from genres a, genres b where a.name='$parent' and b.name='$child'|;
  $dbh->do($statement);
}

sub add_id {
  my $id = shift;
  my $line = qq|{\n\tid: "$id",\n|;
  return $line;

}

sub add_name {
  my $name = shift;
  my $line = qq|\tname: "$name",\n|;
  return $line;

}

sub add_child { 
  my $line = qq|\tchildren: []\n},\n|;
  return $line;
}

sub create_id {
  my $first = shift;
  my $second = shift;

  my $id = $first . $second;
  $id =~ s/\s/_/g;
  return $id;
}

my %parents = ();
my $first = 1;
my $last_level = 0;
my $my_parent = "";
my $last_level_name = "";
my $json; #not json just a scalar.

while(<DATA>) {
  chomp;
  my $g = $_;
  my $starting_spaces = count_starting_spaces($g);
  my $level = current_level($starting_spaces);
  my $clean_value = ltrim($g);
  insert_genre_record($clean_value);

  if($level==$last_level){
    if($first) {
      $parents{$level} = $g;
      $first = 0;
      $my_parent = "null";
    }
    else {
      $my_parent = $parents{$level};
      insert_relation_record($clean_value, $my_parent);
    }
  }
  elsif($level > $last_level) {
    $parents{$level} = $last_level_name;
    $my_parent = $parents{$level};
    insert_relation_record($clean_value, $my_parent);
  }
  elsif ($level < $last_level) {
    $parents{$level+1} = undef;
    $my_parent = $parents{$level};
    insert_relation_record($clean_value, $my_parent);
  }

  $json .= add_id(create_id($clean_value, $my_parent));
  $json .= add_name($clean_value);
  $json .= add_child();

  $last_level = $level;
  $last_level_name = $clean_value;

}

print $nodefile $json;
close($nodefile);


__DATA__
Music
  African popular music
    African heavy metal
    African hip hop
    Afrobeat
    Apala
    Benga
    Bongo Flava
    Bikutsi
    Cape Jazz
    Chimurenga
    Coupé-Décalé
    Fuji music
    Genge
    Highlife
    Hiplife
    Igbo highlife
    Igbo rap
    Isicathamiya
    Jit
    Jùjú
    Kapuka aka Boomba
    Kadodi
    Kadongo Kamu
    Kizomba
    Kuduro
    Kwaito
    Kwela
    Makossa
    Maloya
    Marrabenta
    Mbalax
    Museve aka Sungura
    Mbaqanga
    Mbube
    Morna
    Palm-wine
    Rumba
    Raï
    Sakara
    Sega
    Seggae
    Semba
    Soukous aka Congo, Lingala or African rumba
    Taarab
    Zouglou Cote D''Ivoire
  Asian music
    Fann at-Tanbura
    Fijiri
    Khaliji
    Liwa
    Sawt
  East Asian
    Anison
    Cantopop
    C-pop
    Enka
    Hong Kong English pop
    J-pop
    Kay&#333;kyoku
    K-pop
    Mandopop
    Onkyokei
    Taiwanese pop
  South and southeast Asian
    Baila
    Baul
    Bhangra
    Dangdut
    Filmi
    Indian pop
    Lavani
    Luk Thung
    Luk Krung
    Manila Sound
    Original Pilipino Music
    V-pop
    Morlam
    Pinoy pop
    Pop sunda
    Thai pop
    Ragini
    Keroncong
    Campursari / pop jawa
    Gamelan
  Avant-garde
    Experimental music
    Noise
    Lo-fi
    Musique concrète
    Electroacoustic
  Blues
    African blues
    Blues rock
    Blues shouter
    British blues
    Canadian blues
    Chicago blues
    Classic female blues
    Contemporary R&B
    Country blues
    Delta blues
    Detroit blues
    Electric blues
    Gospel blues
    Hill country blues
    Hokum blues
    Jazz blues
    Jump blues
    Kansas City blues
    Louisiana blues
    Memphis blues
    Piano blues
    Piedmont blues
    Punk blues
    Rhythm and blues
    Soul blues
    St. Louis blues
    Swamp blues
    Texas blues
    West Coast blues
  Caribbean and Caribbean-influenced
    Baithak Gana
    Calypso
    Chutney
    Chutney soca
    Compas
    Punta
    Punta Rock
    Rasin
    Reggae
      Dancehall
      Dub
      Lovers rock
      Ragga
      Ragga jungle
      Reggae fusion
      Reggaeton
    Rocksteady
    Ska
      2 Tone
      Ska punk
    Soca
    Twoubadou
    Zouk
  Comedy music
    Comedy rock
    Novelty music
    Parody music
  Country music
    Alternative country
      Cowpunk
    Blues country
    Hokum
    Outlaw country
    Progressive country
    Zydeco
    Country rap
    Red Dirt
    Rockabilly
      Hellbilly music
      Psychobilly/Punkabilly
    Country rock
    Texas country
    Americana
    Australian country music
    Bakersfield sound
    Bluegrass
      Progressive bluegrass
      Reactionary bluegrass
    Cajun
      Cajun fiddle tunes
    Christian country music
    Classic country
    Close harmony
    Dansband music
    Franco-country
    Gulf and western
    Honky Tonk
    Instrumental country
    Lubbock sound
    Nashville sound
    Neotraditional country
    Country pop
    Sertanejo
    Traditional country music
    Truck-driving country
    Western swing
  Easy listening
    Background music
    Beautiful music
    Elevator music
    Furniture music
    Lounge music
    Middle of the road
    New-age music
  Electronic music
    Ambient
      Ambient dub
      Ambient house
      Ambient techno
      Dark ambient
      Drone music
      Illbient
      Isolationism
      Lowercase
    Asian Underground
    Breakbeat
      Acid breaks
      Baltimore Club
      Big beat
      Breakbeat hardcore
      Broken beat
      Florida breaks
      Nu skool breaks
      4-beat
    Chiptune
      Bitpop
      Game Boy music
      Nintendocore
      Video game music
      Yorkshire Bleeps and Bass
    Disco
      Cosmic disco
      Disco polo
      Europop
      Euro disco
      Space disco
      Italo disco
      Nu-disco
    Downtempo
      Acid jazz
      Balearic Beat
      Chill out
      Dub music
      Dubtronica
      Ethnic electronica
      Moombahton
      New-age music
      Nu jazz
      Trip hop
    Drum and bass
      Darkcore
      Darkstep
      Drumfunk
      Drumstep
      Hardstep
      Intelligent drum and bass
      Jump-Up
      Liquid funk
      Neurofunk
      Oldschool jungle
        Darkside jungle
        Ragga-jungle
      Raggacore
      Sambass
      Techstep
    Electro
      Crunk
      Electro backbeat
      Electro-grime
      Electropop
    Electroacoustic
      Acousmatic music
      Computer music
      Electroacoustic improvisation
      Field recording
      Live electronics
      Live coding
      Musique concrète
      Soundscape composition
      Tape music
    Electronica
      Berlin school
      Chillwave
      Electronic art music
      Electronic dance music
      Folktronica
      Freestyle music
      IDM
      Glitch
      Laptronica
      Skweee
      Sound art
      Synthcore
    Electronic rock
      Alternative dance
        Baggy
        Madchester
      Dance-punk
      Dance-rock
      Dark Wave
      Electroclash
      Electronicore
      Electropunk
      Ethereal wave
      Indietronica
      New rave
      Space rock
      Synthpop
      Synthpunk
    Eurodance
      Bubblegum dance
      Italo dance
      Turbofolk
    Hardcore/Hard dance
      Bouncy house
      Bouncy techno
      Breakcore
      Darkcore
      Digital hardcore
      Doomcore
      Dubstyle
      Gabber
      Happy hardcore
      Hardstyle
      Jumpstyle
      Makina
      Speedcore
      Terrorcore
      UK hardcore
    Hi-NRG
      Eurobeat
      Hard NRG
      New Beat
    House
      Acid house
      Chicago house
      Deep house
      Diva house
      Dutch house
      Electro house
      French house
      Freestyle house
      Funky house
      Ghetto house
      Hardbag
      Hip house
      Italo house
      Latin house
      Minimal house/Microhouse
      Progressive house
      Rave music
      Swing house
      Tech house
      Tribal house
      UK hard house
      US garage
      Vocal house
    Industrial
      Aggrotech
      Coldwave
      Cybergrind
      Dark electro
      Death industrial
      Electronic body music
        Futurepop
      Electro-industrial
      Industrial metal
        Neue Deutsche Härte
      Industrial rock
      Noise
        Japanoise
        Power noise
        Power electronics
      Witch House/Drag
    Post-disco
      Boogie
      Dance-pop
    Progressive
      Progressive breaks
      Progressive drum & bass
      Progressive House/Trance
        Disco house
        Dream house
        Space house
      Progressive techno
    Techno
      Acid techno
      Detroit techno
      Free tekno
      Ghettotech
      Minimal
      Nortec
      Schranz / Hardtechno
      Tecno brega
      Techno-DNB
      Technopop
      Toytown Techno
    Trance
      Acid trance
      Classic trance
      Dream trance
      Goa trance / Psychedelic trance
        Dark psytrance
        Full on
        Psyprog
        Psybreaks
        Suomisaundi
      Hard trance
      Tech trance
      Uplifting trance
        Orchestral Uplifting
      Vocal trance
    UK garage
      2-step
      Bassline
      Breakstep
      Dubstep
      Trap
      Funky
      Grime
      Speed garage
  Folk music
    Contemporary folk
    Celtic music
    Indie folk
    Neofolk
    Progressive folk
    Anti-folk
    Freak folk
    Filk music
    American folk revival
    British folk revival
    Industrial folk
    Techno-folk
    Psychedelic folk
    Sung poetry
    Cowboy/Western music
  Hip hop music
    Alternative hip hop
    Avant-garde hip hop
    Bongo Flava
    Chap hop
    Christian hip hop
    Conscious hip hop
    Country-rap
    Crunkcore
    Cumbia rap
    Drill
    East Coast hip hop
      Baltimore club
      Brick City club
      Hardcore hip hop
      Mafioso rap
      New Jersey hip hop
    Electro music
    Freestyle music
    Freestyle rap
    G-Funk
    Gangsta rap
    Ghetto house
    Ghettotech
    Golden age hip hop
    Grime
    Hardcore hip hop
    Hip hop soul
    Hip house
    Hiplife
    Hip pop
    Hyphy
    Igbo rap
    Industrial hip hop
    Instrumental hip hop
    Jazz rap
    Kwaito
    Lyrical hip hop
    Low Bap
    Midwest hip hop
      Chicago hip hop
        Ghetto house
      Detroit hip hop
        Ghettotech
      St. Louis hip hop
      Twin Cities hip hop
      Horrorcore
    Merenrap
    Motswako
    Nerdcore
    New jack swing
    New school hip hop
    Old school hip hop
    Political hip hop
    Ragga
    Reggaeton
    Rap opera
    Rap rock
      Rapcore
      Rap metal
    Reggae Español/Spanish Reggae
    Southern hip hop
      Atlanta hip hop
        Snap music
      Bounce music
      Crunk
      Houston hip hop
        Chopped and screwed
      Miami bass
    Songo-salsa
    Trap
    Trip hop (or Bristol sound)
    Turntablism
    Underground hip hop
    Urban Pasifika
    West Coast hip hop
      Chicano rap
      Gangsta rap
      G-funk
      Hyphy
      Jerkin''
  Jazz
    Acid jazz
    Afro-Cuban jazz
    Asian American jazz
    Avant-garde jazz
    Bebop
    Boogie-woogie
    Bossa nova
    British dance band
    Cape jazz
    Chamber jazz
    Continental Jazz
    Cool jazz
    Crossover jazz
    Dixieland
    Ethno jazz
    European free jazz
    Free funk
    Free improvisation
    Free jazz
    Gypsy jazz
    Hard bop
    Jazz blues
    Jazz-funk
    Jazz fusion
    Jazz rap
    Jazz rock
    Kansas City blues
    Kansas City jazz
    Latin jazz
    Livetronica
    M-Base
    Mainstream jazz
    Modal jazz
    Neo-bop jazz
    Neo-swing
    Novelty ragtime
    Nu jazz
    Orchestral jazz
    Post-bop
    Punk jazz
    Ragtime
    Shibuya-kei
    Ska jazz
    Smooth jazz
    Soul jazz
    Stride jazz
    Straight-ahead jazz
    Swing
    Third stream
    Trad jazz
    Vocal jazz
    West Coast jazz
  Latin
    Bachata
    Banda
    Bolero
    Cumbia
    Huayno
    Chicha
    Criolla
    Flamenco
    Mambo
    Mariachi
    Merengue
    Méringue
    Norteña
    Ranchera
    Salsa
    Son
    Tejano
    Timba
  Brazil
    Axé
    Bossa Nova
    Brazilian rock
    Brega
    Choro
    Forró
    Frevo
    Funk Carioca
    Lambada
    Maracatu
    Música popular brasileira
    Música sertaneja
    Pagode
    Samba
    Samba rock
    Tecnobrega
    Tropicalia
    Zouk-Lambada
  Pop music
    Adult contemporary
    Arab pop
    Baroque pop
    Bubblegum pop
    Chalga
    Chanson
    Christian pop
    Classical crossover
    Country pop
    C-pop
      Mandopop
    Dance-pop
    Disco polo
    Electropop
    Europop
      Austropop
      Eurobeat
      French pop
      Italo dance
      Italo disco
      Laïkó
      Latin pop
      Nederpop
      Russian pop
      Folk pop
    Iranian pop
    J-pop
    Jangle pop
    K-pop
    Latin ballad
    Levenslied
    Louisiana swamp pop
    Mexican pop
    New Romanticism
    Pop rap
    Pop rock
    Popera
    Psychedelic pop
    Schlager
    Soft rock
    Sophisti-pop
    Space age pop
    Sunshine pop
    Surf pop
    Synthpop
    Technopop
    Teen pop
    Traditional pop music
    Turkish pop
    Vispop
    Wonky pop
    Worldbeat
  R&B and soul
    Contemporary R&B
    Funk
      Deep funk
      Go-go
      P-Funk
    Disco
      Post-disco
      Boogie
    New jack swing
    Rhythm and blues
    Soul
      Blue-eyed soul
      Hip hop soul
      Northern soul
      Neo soul
      Southern soul
  Rock
    Alternative rock
      Britpop
        Post-Britpop
      Dream pop
      Grunge
        Post-grunge
      Indie pop
        Dunedin Sound
        Twee Pop
      Indie rock
      Industrial rock
      Noise pop
      Nu metal
      Post-punk revival
      Post-rock
        Post-metal
      Sadcore
      Shoegaze
      Slowcore
    Art rock
    Beat music
    Chinese rock
    Christian rock
    Electronicore
    Dark cabaret
    Experimental rock
    Electronic rock
    Folk rock
    Garage rock
    Glam rock
    Hard rock
    Heavy metal
      Alternative metal
        Nu metal
      Black metal
        Viking metal
      Christian metal
      Death metal
        Melodic death metal
        Technical death metal
        Goregrind
      Doom metal
      Drone metal
      Folk metal
        Celtic metal
        Medieval metal
      Funk metal
      Glam metal
      Gothic metal
      Industrial metal
      Metalcore
      Deathcore
      Mathcore
      Power metal
        Progressive metal
      Djent
      Rap metal
      Sludge metal
      Speed metal
      Stoner rock
      Symphonic metal
      Thrash metal
        Crossover thrash
        Groove metal
    Jazz rock
    Math rock
    New wave
      World fusion
    Paisley Underground
    Desert rock
    Pop rock
    Power pop
    Progressive rock
      Canterbury scene
      Krautrock
      New prog
      Rock in Opposition
      Space rock
    Psychedelic rock
      Acid rock
      Freakbeat
      Neo-psychedelia
      Raga rock
    Punk rock
      Anarcho punk
        Crust punk
          D-beat
      Art punk
      Christian punk
      Deathrock
      Digital hardcore
      Folk punk
        Celtic punk
        Cowpunk
        Gypsy punk
      Garage punk
      Grindcore
        Crustgrind
        Noisegrind
      Hardcore punk
        Post-hardcore
          Emo
            Screamo
        Thrashcore
        Crossover thrash
        Powerviolence
        Street punk
      Horror punk
      Pop punk
      Psychobilly
      Riot grrrl
      Ska punk
      Skate punk
    Post-punk
      Gothic rock
      No wave
      Noise rock
    Rap rock
      Rapcore
    Rock and roll
    Southern rock
    Sufi rock
    Surf rock
    Visual kei
      Nagoya kei
    Worldbeat