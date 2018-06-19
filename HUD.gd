extends CanvasLayer

signal start_game

func _ready():
    $TweetButton.hide()  # tweet button starts hidden by default

func show_message(text):
    $MessageLabel.text = text
    $MessageLabel.show()
    $MessageTimer.start()

func show_game_over():
    show_message("Game Over")
    yield($MessageTimer, "timeout")
    $StartButton.show()
    $MessageLabel.text = "Dodge the\nCreeps!"
    $MessageLabel.show()
    $TweetButton.show()

func update_score(score):
    $ScoreLabel.text = str(score)
    $ScoreLabel/TickSound.play()

func _on_MessageTimer_timeout():
    $MessageLabel.hide()

func _on_StartButton_pressed():
    $StartButton.hide()
    emit_signal("start_game")
    $StartButton/StartSound.play()

func _on_TweetButton_pressed():
    var score = get_parent().score
    # opens a web browser, asking for confirmation to make a tweet from the user's account
    OS.shell_open("https://twitter.com/intent/tweet?text=I scored " + str(score) +  "points!"  # tweet body
    + "+https%3A%2F%2Ftwitter.com"  # url link to project homepage
    + "&hashtags=DodgeTheCreeps,gamedev"  # comma seperated hashtags to include at the end of the tweet
    + "&related=potus,menacingmecha")  # comma seperated related accounts to display after making the tweet
