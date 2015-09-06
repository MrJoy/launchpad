#!/bin/bash

# Things that are identical:
dwdiff --line-numbers --no-common Orbit_Colors_And_Reset.2.txt Orbit_Retrieve.1.txt
dwdiff --line-numbers --no-common Orbit_Colors_And_Reset.1.txt Orbit_Colors_And_Reset.3.txt
dwdiff --line-numbers --no-common Orbit_Preset.txt Orbit_Preset.1.txt
dwdiff --line-numbers --no-common Orbit_Preset.txt Orbit_Preset.2.txt
dwdiff --line-numbers --no-common Orbit_Preset.txt Orbit_Retrieve.2.txt

# Difference should indicate color positions:
dwdiff --line-numbers --no-common Orbit_Preset.txt Orbit_Colors_And_Reset.1.txt

