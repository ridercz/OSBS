osbs_selected_extruder = 0;
function osbs_extruder(extruder_number) = osbs_selected_extruder == undef || osbs_selected_extruder == 0 ? true : osbs_selected_extruder == extruder_number;