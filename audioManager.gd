extends Node2D
func _ready() -> void:
	$lvl1BackgroundMusic.finished.connect(playlvl1Music)
	$carAmbience.finished.connect(playCarAmbience)
	
	$lvl2Music.finished.connect(playlvl2Music)
	$natrue.finished.connect(playnature)
	
	$mainMenu.finished.connect(playMainMenu)
	
func buttonClick():
	$buttonClick.play()

func newUser():
	$newUser.play()
	
func playlvl1Music():
	$lvl1BackgroundMusic.play()

func stoplvl1Music():
	$lvl1BackgroundMusic.stop()

func playEquipSound():
	$equipSound.play()

func doorOpen():
	$doorOpen.play()

func playCarAmbience():
	$carAmbience.play()

func stopCarAmbience():
	$carAmbience.stop()

func playBoing():
	$Boing.play()
	
func lockDoor():
	$lockdoor.play()
	
func playlvl2Music():
	$lvl2Music.play()
	
func stoplvl2Music():
	$lvl2Music.stop()
	
func playnature():
	$natrue.play()
func stopnature():
	$natrue.stop()

func playMainMenu():
	$mainMenu.play()
	
func stopMainMenu():
	$mainMenu.stop()
	
func hooray():
	$yatta.play()
