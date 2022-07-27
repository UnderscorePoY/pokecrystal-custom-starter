
# Pokémon Crystal - Custom Starter ROM

This is a **non-PSR-official, modified** version of the disassembly of Pokémon Crystal. Modifications are made to offer starter customization for the player, as well as workarounds for RNG manipulations and spinners.

It builds the following ROM:

- Pokemon Crystal pokecrystal.gbc `sha1: 1e51e882c94ca722a40c070b7855aa316c94f95f` `crc32: 9BD75359`

To set up the repository, see [INSTALL.md](INSTALL.md).

If you only need to apply the changes to an existing vanilla ROM, see [**PATCHES.md**](PATCHES.md) (an additional patch produces an IT/Automash ROM : `sha1: 7615018f76d100cbba26884b8a9c4e0f39e014e6` `crc32: C8AC5819`).

## Main changes
### Menus
- The added Custom Starter menu is available before New Game, through the Option menu. No access to it is possible after a run is started.
### Items
- 5 Repels are given by Elm's Assistant when exiting the Lab the first time (additionally to the vanilla Potion).
- 5 Master Balls are given by Elm's Assistant when exiting the Lab the second time (replacing Poké Balls).
- Master Balls sell for 100$ each (same as Poké Ball).

### Forced encounters
(a dash `-` denotes no modifications to vanilla encounters)
Location | Morning/Day | Night
--- | --- | ---
Route 29 | L2 Sentret (75%) <br/> L3 Sentret (25%) | -
Route 30 | L4 Hoppip | L4 Poliwag
Route 31 | L5 Bellsprout | L4 Poliwag
Route 34 | L10 Abra | L10 Abra
Route 36 | L5 Growlithe | -
Dark Cave <br/> Violet side | L4 Geodude | L4 Geodude
Sprout Tower | - | L4 Gastly
Ilex Forest | L6 Paras | L7 Psyduck

### Spinners
- Randomly spinning trainers (or "spinners") have been adjusted to guarantee a dodge with an average reaction time (minimal spin time of 0.6/0.86 seconds for Bike/Walk dodges).
- Douglas (spinner in Mahogany Gym) faces away from the player's path.

## Visuals
![Image of Option menu](https://i.imgur.com/U9FqOvC.png)
![Image of Starter menu](https://i.imgur.com/0KuyUBi.png)

## See also

- **Gen 1-3 Pokémon Speedrunning:** [Discord][speedrun-discord]

- [**FAQ**](FAQ.md)
- [**Documentation**][docs]
- [**Wiki**][wiki] (includes [tutorials][tutorials])

Other disassembly projects:

- [**Pokémon Red/Blue - Custom Starter**][pokered-custom-starter]
- [**Pokémon Crystal**][pokecrystal]

[speedrun-discord]: https://discord.gg/NjQFEkc
[pokered-custom-starter]: https://github.com/Arcaseriam/pokered-custom-starter
[pokecrystal]: https://github.com/pret/pokecrystal
[docs]: https://pret.github.io/pokecrystal/
[wiki]: https://github.com/pret/pokecrystal/wiki
[tutorials]: https://github.com/pret/pokecrystal/wiki/Tutorials
