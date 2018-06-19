extends Area2D

signal hit

export (int) var SPEED  # how fast the player will move (pixels/sec)
export (float) var IDLE_ANIMATION_SPEED
export (float) var WALK_ANIMATION_SPEED
var screensize  # size of the game window TODO: Make this a const?
var gameActive = false

func _ready():
    screensize = get_viewport_rect().size
    hide()

func _process(delta):
    if gameActive:
        var direction = GetInputDirection()  # get which way the player is aiming
        MovePlayer(direction, delta)

func Start(pos):
    position = pos
    show()
    $CollisionShape2D.disabled = false
    gameActive = true

# returns a Vector2 of the players inputted direction
func GetInputDirection():
    var direction = Vector2()
    if Input.is_action_pressed("ui_right"):
        direction.x += 1
    elif Input.is_action_pressed("ui_left"):  # prioritise moving right
        direction.x -= 1
    if Input.is_action_pressed("ui_up"):
        direction.y -= 1
    elif Input.is_action_pressed("ui_down"):  # prioritise moving up
        direction.y += 1
    return direction

# moves the player based on the input direction and speed, clamping to screen edges and updating appropriate animations
func MovePlayer(direction, delta):
    if direction.length() > 0:  # player is moving
        var velocity = direction.normalized() * SPEED
        $AnimatedSprite.frames.set_animation_speed($AnimatedSprite.animation, WALK_ANIMATION_SPEED)
        if velocity.x != 0:  # horizontal animation
            $AnimatedSprite.animation = "right"
            $AnimatedSprite.flip_h = velocity.x < 0  # flip if moving left
        elif velocity.y < 0:  # up animation (prioritising horizontal animation)
            $AnimatedSprite.animation = "up"
        elif velocity.y > 0:  # down animation (prioritising up animation)
            $AnimatedSprite.animation = "down"
        if $WalkSound/Timer.is_stopped():  # start playing walk sound on timer if it's not already playing
            $WalkSound/Timer.start()
        position += velocity * delta
        position.x = clamp(position.x, 0, screensize.x)  # TODO: add half of the player's size to the clamp
        position.y = clamp(position.y, 0, screensize.y)
    else:  # player isn't moving
        $WalkSound/Timer.stop()
        $AnimatedSprite.frames.set_animation_speed($AnimatedSprite.animation, IDLE_ANIMATION_SPEED)

func _on_Player_body_entered(body):
    hide()  # player dissapears after being hit
    emit_signal("hit")  # ends game
    $CollisionShape2D.disabled = true
    gameActive = false
    $WalkSound/Timer.stop()

func _on_WalkSound_Timer_timeout():
    $WalkSound.play()
