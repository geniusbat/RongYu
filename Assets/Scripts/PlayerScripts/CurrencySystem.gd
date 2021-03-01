extends HBoxContainer

onready var coinHolder = preload("res://Objects/Player/CoinHolder.tscn")

func _ready():
	pass

#Call this when trying to add coins
func AddCoins(amount):
	#There is no coin holder
	if get_child_count()==0:
		var ins = coinHolder.instance()
		add_child(ins)
		ins.value=amount
	else:
		var currentAmount = get_child(get_child_count()-1).value
		#Check if the last coin holder  already  has 100
		if currentAmount==100:
			var ins = coinHolder.instance()
			add_child(ins)
			ins.value=amount
		#Check if the sum will be over 100, if so, create new coin holder
		elif currentAmount+amount > 100:
			get_child(get_child_count()-1).value=100
			var ins = coinHolder.instance()
			add_child(ins)
			ins.value=amount-currentAmount
		else:
			get_child(get_child_count()-1).value=currentAmount+amount

#Call this when trying to deplete coins, as if you were to buy or use them
func DepleteCoin(amount) -> bool:
	var array = []
	if get_child_count()>=amount:
		var i = 0
		while i < amount:
			if get_child(i).value==100:
				array.append(get_child(i))
				i+=1
			else:
				return false
		for el in array:
			el.queue_free()
		return true
	else:
		return false
