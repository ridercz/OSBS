#!/bin/sh

# -- Configuration
OSBS_VERSION=1.0.0
OSBS_SCAD="/usr/local/bin/OpenSCAD"
OSBS_TARGET_FOLDER="./stl"
OSBS_TARGET_FORMAT=stl

# -- Print banner
echo " _____ _____ _____ _____"
echo "|     |   __| __  |   __| OSBS - OpenSCAD Build System version %OSBS_VERSION%"
echo "|  |  |__   | __ -|__   | (c) Michal Altair Valasek, 2018 | MIT license"
echo "|_____|_____|_____|_____| www.rider.cz | github.com/ridercz/OSBS"
echo

# -- Create output folder
if [ ! -d "$OSBS_TARGET_FOLDER" ]; then
  echo "Creating output folder $OSBS_TARGET_FOLDER..."
  mkdir -p $OSBS_TARGET_FOLDER
else
  echo "Deleting files in output $OSBS_TARGET_FOLDER..."
  rm $OSBS_TARGET_FOLDER/*.$OSBS_TARGET_FORMAT
fi

# -- Process all *.scad files
for I in *.scad; do
  I_BASENAME=$(basename -- "$I")
  FILE_BASE=${I_BASENAME%.*}

  # -- Get number of extruders specified in file
  OSBS_EC=$(grep -o "\/\* OSBS\:build\:\dE \*\/" $I | grep -o "\d")
  if [ ! -n "$OSBS_EC" ]; then grep -q "OSBS\:build" $I && OSBS_EC=1; fi
  if [ ! -n "$OSBS_EC" ]; then OSBS_EC=0; fi

  if [ "$OSBS_EC" = '0' ]; then
    # -- No build instructions present in file
    echo "Ignoring $I, no build instructions present"
  else
    if [ ! -f "$I.vars" ]; then
      # -- Build instructions present, but no something.scad.vars file found
      echo "Building $I for $OSBS_EC extruder(s):"

      # -- Build all-in-one model
      echo "  $FILE_BASE.$OSBS_TARGET_FORMAT"
      $OSBS_SCAD -D "osbs_selected_extruder=0" -o "$OSBS_TARGET_FOLDER/$FILE_BASE.$OSBS_TARGET_FORMAT" "$I"

      # -- Build models for all extruders
      if [ "$OSBS_EC" -gt "1" ]; then
        for E in $(seq 1 $OSBS_EC); do
          echo "  $I-$E.$OSBS_TARGET_FORMAT"
          $OSBS_SCAD -D "osbs_selected_extruder=$E" -o "$OSBS_TARGET_FOLDER/$FILE_BASE-E$E.$OSBS_TARGET_FORMAT" "$I";
        done
      fi
    else
      # -- Build instructions present and we have something.scad.vars file
      echo "Building $I for $OSBS_EC extruder(s) with additional variables:"

      # -- Parse the .vars file; %%V is set name, %%W is code to be added
      cat "$I.vars" | grep -v "^#" | while read -r a; do
        V="$(cut -d':' -f1 <<< $a)"
        W="$(cut -d':' -f2 <<< $a)"
        echo "  Set $V"

        # -- Copy file to working copy ~something.scad and append variable line
        cp "$I" "$FILE_BASE-$V.scad"
        echo "" >> "$FILE_BASE-$V.scad"
        echo $W >> "$FILE_BASE-$V.scad"

        # -- Build all-in-one model
        echo "    $FILE_BASE-$V.$OSBS_TARGET_FORMAT"
        $OSBS_SCAD -D "osbs_selected_extruder=0" -o "$OSBS_TARGET_FOLDER/$FILE_BASE-$V.$OSBS_TARGET_FORMAT" "$FILE_BASE-$V.scad"

        # -- Build models for all extruders
        if [ "$OSBS_EC" -gt "1" ]; then
          for E in $(seq 1 $OSBS_EC); do
            echo "    $FILE_BASE-$V-$E.$OSBS_TARGET_FORMAT"
            $OSBS_SCAD -D "osbs_selected_extruder=$E" -o "$OSBS_TARGET_FOLDER/$FILE_BASE-$V-E$E.$OSBS_TARGET_FORMAT" "$FILE_BASE-$V.scad"
          done
        fi

        # -- Delete working copy of .scad file
        rm "$FILE_BASE-$V.scad"
      done
    fi
  fi
done
