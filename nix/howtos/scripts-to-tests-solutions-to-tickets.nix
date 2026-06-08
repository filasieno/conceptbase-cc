# HOW-TO: scripts-to-tests-solutions-to-tickets (independent groups by ticket range)
args:

let
  mkGroup = groupName: patterns: maxCbsFiles:
    import ./howto-tickets-group.nix (args // {
      inherit groupName maxCbsFiles;
      filePatterns = patterns;
    });
in
{
  "scripts-to-tests-tickets-misc" = mkGroup "misc" [
    "BigFlights.cbs.txt"
    "issue1.cbs.txt"
  ] 2;
  "scripts-to-tests-tickets-000-099" = import ./howto-tickets-assets.nix (args // {
    groupName = "000-099";
    patterns = [
      "ticket0*.cbs.txt"
      "Ticket0*.cbs.txt"
    ];
  });
  "scripts-to-tests-tickets-100-199" = import ./howto-tickets-assets.nix (args // {
    groupName = "100-199";
    patterns = [
      "ticket1*.cbs.txt"
      "Ticket1*.cbs.txt"
    ];
  });
  "scripts-to-tests-tickets-200-299" = mkGroup "200-299" [
    "ticket2*.cbs.txt"
    "Ticket2*.cbs.txt"
  ] 1;
  "scripts-to-tests-tickets-300-399" = mkGroup "300-399" [
    "ticket3*.cbs.txt"
    "Ticket3*.cbs.txt"
  ] 1;
  "scripts-to-tests-tickets-400-599" = mkGroup "400-599" [
    "ticket4*.cbs.txt"
    "ticket5*.cbs.txt"
    "Ticket4*.cbs.txt"
    "Ticket5*.cbs.txt"
  ] 2;
}
