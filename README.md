# Psychedelia II
This is a tribute to [Psychedelia][psychedelia] by Jeff Minter. It's adapted from
the version included as a sub-game in [Batalyx][batalyx].

It turns Psychedelia into a game of sorts. Filling the screen with as few moves as possible
maximizes your points. There are infinite levels - so you never lose and you never die.

### Play Online

[<img src="https://img.shields.io/badge/Latest%20Release-Play%20Online-purple.svg">](https://mwenge.github.io/psyII/bin)


## Build Requirements
* [64tass][64tass], tested with v1.54, r1900
* [VICE][vice]

On Ubuntu you can do:
```sh
sudo apt install 64tass vice
```

## Build Instructions
To compile and run it do:

```sh
$ make
```
The compiled game is written to the `bin` folder. 

To just compile the game and get a binary (`psyII.prg`) do:

```sh
$ make psyII.prg
```
[64tass]: http://tass64.sourceforge.net/
[vice]: http://vice-emu.sourceforge.net/
[Psychedelia]: https://github.com/mwenge/psychedelia
[Batalyx]: https://github.com/mwenge/batalyx
