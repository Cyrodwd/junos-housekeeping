module player;

import popka;

// -------------------------------------------
// Definition of structs and others types.
// -------------------------------------------

/// Player (Juno) directions (frameRows)
enum PlayerDirection : ubyte
{
    Down = 0,
    Left = 1,
    Right = 2,
    Up = 3,
}

/// Player (Juno) base struct
public struct Player
{
    private:
    TextureId texture; /// Entire spritesheet texture
    Sprite sprite; /// Spritesheet/Atlas manager
    SpriteAnimation[string] animations; /// Player animations
    PlayerDirection actualDirection; /// Player actual direction

    float speed; /// Player movement speed
    float stamina; /// Player stamina (Time to run)

    Vec2 velocity; /// Player movement velocity (not speed) (for normalize Vec2)
    Vec2 position; /// Player position on screen

    bool isSprinting; /// Variable to verify if player is sprinting (running)
    bool isStressed; /// Variable to verify if player is stressed (player will move faster)
    bool isMoving; /// Variable to verify if player is moving
    bool canSprint; /// Variable to allow player to sprint

    // -----------------------------
    // Immutable values
    // -----------------------------
    immutable float walkSpeed = 200.0f; /// Player speed when walking
    immutable float sprintSpeed = 300.0f; /// Player speed when sprinting (running)
    
    immutable float maxStamina = 100.0f; /// Player maximum allowed stamina
    immutable float staminaMultiplier = 0.3f; /// Player stamina multiplier (drain & recover)

    immutable ubyte frameSpeed = 6; /// Speed between animations frames

    public:

    void start()
    {
        texture = loadTexture("JUNO.png");

        sprite = Sprite(32, 64, 0, 0); // The size of each frame will not be the same (the spritesheet of Juno, i.e. the player) will be changed afterwards.

        velocity = Vec2.zero;
        position = Vec2.zero;

        isSprinting = false;
        isStressed = false;
        canSprint = true;

        speed = 200.0f;
        stamina = 100.0f;

        actualDirection = PlayerDirection.Down;

        animations = [
            "idle" : SpriteAnimation(actualDirection, 0, frameSpeed),
            "walk" : SpriteAnimation(actualDirection, 4, frameSpeed),
        ];
    }

    void update(float dt)
    {
        sprite.update(dt);

        updateAnimations();

        handleInput();
        handleAnimations();
        handleMovement(dt);

        handleStamina();
    }

    void render()
    {
        renderStamina();
        debug drawDebugText(format("Can Sprint: {}", canSprint ? "TRUE" : "FALSE"), Vec2(0, 50));
        debug drawDebugText(format("Is Sprinting: {}", isSprinting ? "TRUE" : "FALSE"), Vec2(0, 100));
        drawSprite(texture, sprite, position);
    }

    // ---------------------------------
    // Private player methods
    // ---------------------------------
    private:

    void handleAnimations()
    {
        sprite.play(animations[ isMoving ? "walk" : "idle" ]); // Ok?
    }

    void move(float value, PlayerDirection direction)
    {
        if (direction == PlayerDirection.Up || direction == PlayerDirection.Down)
        {
            velocity.y = value;
        }
        
        if (direction == PlayerDirection.Left || direction == PlayerDirection.Right)
        {
            velocity.x = value;
        }

        actualDirection = direction;
        if (!isMoving) isMoving = true;
    }

    void handleInput()
    {
        velocity = Vec2.zero;
        if (isDown(Keyboard.w))
        {
            move(-1.0f, PlayerDirection.Up);
        }

        if (isDown(Keyboard.s))
        {
            move(1.0f, PlayerDirection.Down);
        }

        if (isDown(Keyboard.a))
        {
            move(-1.0f, PlayerDirection.Left);
        }

        if (isDown(Keyboard.d))
        {
            move(1.0f, PlayerDirection.Right);
        }

        // BUG - If the player presses ‘shift’ while recovering stamina, stamina recovering will stop until the user stops pressing ‘shift’.
        isSprinting = ( canSprint && isDown(Keyboard.shift));
    }

    void handleMovement( float dt )
    {
        if (velocity != Vec2.zero)
        {
            velocity = velocity.normalize();
        }
        else
        {
            isMoving = false;
        }

        {
            velocity = velocity.normalize();
            position += velocity * Vec2(speed) * Vec2(dt);
        }


        // ---------------------------
        // Running movement
        // ---------------------------
        speed = ( isMoving && isSprinting ) ? sprintSpeed : walkSpeed;

        if ( (isMoving && isSprinting) && stamina >= 0.0f )
        {
            stamina -= staminaMultiplier;
        }

        if ( !isSprinting && stamina <= maxStamina )
        {
            stamina += staminaMultiplier;
        }
    }

    void updateAnimations()
    {
        if (sprite.frame() != actualDirection) {
            animations["idle"] = SpriteAnimation(actualDirection, 0, 6);
            animations["walk"] = SpriteAnimation(actualDirection, 4, 6);
        }
    }

    void handleStamina()
    {
        if (stamina > maxStamina)
        {
            stamina = maxStamina;
            if (!canSprint) canSprint = true;
        }
        else if (stamina < 0.0f)
        {
            stamina = 0.0f;
            if (canSprint) canSprint = false;
        }
    }
    
    /// IMPORTANT: This representation of stamina is only a basic implementation, it will look different as the game changes.
    void renderStamina()
    {
        Rect staminaBaseLine = Rect(Vec2(0), Vec2(maxStamina, 15.0f));
        Rect staminaLine = Rect(Vec2(0), Vec2(stamina, 15.0f));
        drawRect(staminaBaseLine, black);
        drawRect(staminaLine, green);
    }
}
