module app;

import popka;
import player;
import std.stdio : writeln;

enum uint screenWidth = 480;
enum uint screenHeight = 352;

// --------------------------
// Example map
// --------------------------
TileMap map;
TextureId mapAtlas;

Player juno;

Rect wall;

void ready() {
    lockResolution(screenWidth, screenHeight);
	toggleIsPixelPerfect();
    mapAtlas = loadTexture("rooms/beta_walls.png");
    map = TileMap();
    map.parse(loadTempText("rooms/juno_room_beta.csv").get(), 32, 32);
    
    juno.ready();
}

bool update(float dt) {
    drawTileMap(mapAtlas, map, Vec2(0), Camera());

    juno.update(dt);
    juno.render();
    return false;
}

void finish() {
    map.free();
    writeln("Thanks for playing! Made by Cyrodwd. Popka made by Kapendev.");
}

mixin runGame!(ready, update, finish, screenWidth, screenHeight, "Juno's HouseKeeping");
