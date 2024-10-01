import popka;
import std.stdio : writeln;

enum uint screenWidth = 460;
enum uint screenHeight = 344;

struct Task {
    string description;
    bool completed;
}

struct Kitty {
    TextureId texture;
    Vec2 position;
    float speed;
    bool running;

    void initialize() {
        texture = loadTexture("test.png");
        position = Vec2(0);
        speed = 200.0f;
        running = false;
    }

    void update( float dt ) {
        Vec2 direction = Vec2.zero;

        handleSpeed();

        // Popka made this sh*t easier
        if (isDown('A')) {
            direction.x -= 1;
        }
        if (isDown('D')) {
            direction.x += 1;
        }
        if (isDown('W')) {
            direction.y -= 1;
        }
        if (isDown('S')) {
            direction.y += 1;
        }

        // 'running' is defined directly using the key checker lol
        running = isDown(Keyboard.shift);

        if (direction.length > 0) direction = direction.normalize();

        position += direction * Vec2(speed) * Vec2(dt);
    }

    void draw()
    {
        drawTexture(texture, position);
    }

    void handleSpeed()
    {
        speed = running ? 300.0f : 200.0f;
    }
}

Kitty kitty;

void ready() {
    lockResolution(screenWidth, screenHeight);
	toggleIsPixelPerfect();
    kitty.initialize();
}

bool update(float dt) {
    kitty.update(dt);

    kitty.draw();

    drawDebugText("Hello world!", Vec2(8));
    return false;
}

void finish() {
    writeln("Thanks for playing! Made by Cyrodwd. Popka made by Kapendev.");
}

mixin runGame!(ready, update, finish, screenWidth, screenHeight, "Juno's HouseKeeping");
