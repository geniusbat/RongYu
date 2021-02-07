extends Node2D

var items : Node2D

func _ready():
	items = get_node("../../Items")
	#Get correct number of cells. TODO
#	var cellAmmount = get_parent().get_parent().inventorySize
#	var i = get_child_count()
#	while (i<=cellAmmount):
#		load()
#		i+=1

#When the mouse enters the cell, show dialogue
func MouseEnteredCell(cellId):
	if HasCellItem(cellId):
		#Show dialogue
		get_child(cellId).get_node("Description").text=items.get_child(cellId).description
		get_child(cellId).get_node("Description").visible=true
#When the mouse exits the cell
func MouseExitedCell(cellId):
	#Hide dialogue
	get_child(cellId).get_node("Description").visible=false
#When the mouse clicks the cell
func MouseClickedCell(cellId):
	MouseExitedCell(cellId)
	var item = items.get_child(cellId)
	#TODO

#Ask if cell id is correct and if it has an item
func HasCellItem(cellId) -> bool:
	if cellId < items.get_child_count():
		return true
	else:
		return false

#Adds item to the next empty cell, remember that this is unchecked, to add items properly use playerScript
func AddItem(item):
	var pos = GetEmptyCell()
	var cell = get_child(pos)
	cell.get_node("TextureRect").texture_normal=item.itemInfo.sprite
#Get first empty cell, -1 if not possible
func GetEmptyCell()->int:
	for cell in get_children():
		if cell.get_node("TextureButton").texture_normal==null:
			return cell.get_index()
	return -1
