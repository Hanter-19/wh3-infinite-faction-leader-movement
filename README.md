# Infinite Faction Leader Movement
A simple modder utility for Total War: Warhammer 3 that does the following:
- Logs the following information to `hanter_log.txt` after the player faction leader moves:
    - Faction Leader name and command queue index (CQI)
    - Region Key moved to, including its CQI
    - Province Key moved to
    - Logical Coordinates
    - Display Coordinates
- Replenishes the faction leader's movement points after moving (effectively infinite campaign movement)
    - This can be disabled by setting `local infinite_movement = false;` at the top line of `hanter_iflm.lua`.

### Example log entry
```
[2023-06-02 8:31:47 PM][IFLM][hanter_iflm.lua] [Karl Franz | cqi=97] has moved to [wh3_main_combi_region_weismund | cqi=374][wh3_main_combi_province_middenland][539,691][360.06997680664,533.408203125]
```
