use Modern::Perl;
use autodie;
use Data::Dumper;

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

my %parents = ();
my $first = 1;
my $last_level = 0;
my $my_parent = "";
my $last_level_name = "";

while(<DATA>) {
  chomp;
  my $g = $_;
  my $starting_spaces = count_starting_spaces($g);
  my $level = current_level($starting_spaces);

  if($level==$last_level){
    if($first) {
      $parents{$level} = $g;
      $first = 0;
      $my_parent = "I don't have a parent so I must be the root node.";
    }
    else {
      $my_parent = $parents{$level};
    }
  }
  elsif($level > $last_level) {
    $parents{$level} = $last_level_name;
    $my_parent = $parents{$level};
  }
  elsif ($level < $last_level) {
    $parents{$level+1} = undef;
    $my_parent = $parents{$level};
  }

  my $clean_value = ltrim($g);
  say "$clean_value is level $level. It's parent is $my_parent";

  $last_level = $level;
  $last_level_name = $clean_value;

}


__DATA__
Music
  African popular music
    African heavy metal
    African hip hop
    Afrobeat
    Apala
    Benga
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
    K-pop
    Mandopop
    Onkyokei
    Taiwanese pop
      TPop
      C-pop
      All Kinds a pop