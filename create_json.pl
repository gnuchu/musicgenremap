use Modern::Perl;
use autodie;
use Data::Dumper;
use DBI;
use DBD::SQLite;

foreach my $genre (@genres) {
  create_json_data($genre);
}

sub create_json_data {
  add_id();
  add_name();
  does_node_have_children() ? create_json_data()
}

__DATA__
var json = 
{
  id: "A",
  name: "A",
  children: [{
    id: "B",
    name: "B",
    children: [{
      id: "C",
      name: "C",
      children: []
    },
    {
      id: "F",
      name: "F",
      children: [{
        id: "G",
        name: "G",
        children:[]
      },
      {
        id: "Z",
        name: "Z",
        children: []
      }]
    }]
  },
  {
    id: "D",
    name: "D",
    children: [{
      id: "E",
      name: "E",
      children: []
    }]
  }]
};