#all the variables to be saved in the player save

extends Resource
class_name playerSave
@export var position: Vector3
@export var itemsPickedUp: Array
@export var itemsPickedUp2: Array
@export var itemEquiped: String
@export var playerSize: float
@export var paintPickedUp: Array
@export var paintEquiped: String
@export var gatchaInv: Array
@export var gatchaInitialized: bool = false
@export var currentLvl: int 
@export var barsOpen = false
@export var completionFlag = false
@export var itemTotal = 1 
@export var volume = 50.0
@export var sens = 25
@export var SPEED = 8.0
@export var moveData:Dictionary = {
	"forward":0.0,
	"backward": 0.0,
	"left" : 0.0,
	"right": 0.0
}

@export var collisionData:Dictionary= {
	
	"forward":0,
	"backward":0,
	"left":0,
	"right":0
}


@export var totalData: Dictionary ={
	"forward":0.0,
	"backward": 0.0,
	"left" : 0.0,
	"right": 0.0
	
}

@export var totalCollisions:Dictionary= {
	"forward":0,
	"backward":0,
	"left":0,
	"right":0
}


@export var sessionHistory: Array = []
