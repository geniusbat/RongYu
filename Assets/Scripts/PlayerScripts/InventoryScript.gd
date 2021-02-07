extends Node2D

var items : Node2D

onready var floorItem = preload("res://Objects/Items/FloorItemGeneric.tscn")

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
		get_child(cellId).get_node("Description").text=items.get_child(cellId).itemInfo.description
		get_child(cellId).get_node("Description").visible=true
#When the mouse exits the cell
func MouseExitedCell(cellId):
	#Hide dialogue
	get_child(cellId).get_node("Description").visible=false
#When the mouse clicks the cell
func MouseClickedCell(cellId):
	#Check correct id
	if HasCellItem(cellId):
		MouseExitedCell(cellId)
		var item = items.get_child(cellId)
		#Create floor item
		var ins = floorItem.instance()
		get_tree().get_root().add_child(ins)
		ins.global_position=get_node("../..").global_position
		ins.Create(item.itemInfo,false,(get_global_mouse_position()-get_node("../..").global_position).normalized())
		item.queue_free()
		#Release hold on cell
		get_child(cellId).get_node("TextureButton").texture_normal=null
		get_child(cellId).get_node("TextureButton").release_focus()
		#Move other items foward
		var i = cellId+1
		while (i<get_child_count()):
			get_child(i-1).get_node("TextureButton").texture_normal=get_child(i).get_node("TextureButton").texture_normal
			get_child(i).get_node("TextureButton").texture_normal=null
			i+=1

#Ask if cell id is correct and if it has an item
func HasCellItem(cellId) -> bool:
	var ret = false
	for el in items.get_children():
		if el.get_index()==cellId:
			ret = true
	return ret

#Adds item to the next empty cell, remember that this is unchecked, to add items properly use playerScript
func AddItem(item):
	var pos = GetEmptyCell()
	if pos != -1:
		var cell = get_child(pos)
		cell.get_node("TextureButton").texture_normal=item.itemInfo.sprite
#Get first empty cell, -1 if not possible
func GetEmptyCell()->int:
	for cell in get_children():
		if cell.get_node("TextureButton").texture_normal==null:
			return cell.get_index()
	return -1
