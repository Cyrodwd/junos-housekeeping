module app;

import popka;
import player;
import std.stdio : writeln;

enum uint screenWidth = 480;
enum uint screenHeight = 352;

Player juno;

void ready() {
    lockResolution(screenWidth, screenHeight);
	toggleIsPixelPerfect();
    juno.start();
}

bool update(float dt) {
    juno.update(dt);
    juno.render();
    return false;
}

void finish() {
    writeln("Thanks for playing! Made by Cyrodwd. Popka made by Kapendev.");
}

mixin runGame!(ready, update, finish, screenWidth, screenHeight, "Juno's HouseKeeping");
