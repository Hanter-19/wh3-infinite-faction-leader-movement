# v1.0.0
- Logs the following information to `hanter_log.txt` after the player faction leader moves:
    - Faction Leader name and command queue index (CQI)
    - Region Key moved to, including its CQI
    - Province Key moved to
    - Logical Coordinates
    - Display Coordinates
- Replenishes the faction leader's movement points after moving (effectively infinite campaign movement)
    - This can be disabled by setting `local infinite_movement = false;` at the top line of `hanter_iflm.lua`.