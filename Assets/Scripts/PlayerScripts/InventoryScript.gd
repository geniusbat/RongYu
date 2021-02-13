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

#Use items
func _unhandled_input(event):
	if event.is_action_pressed("useItem_1"):
		if items.get_child_count()>0:
			if items.get_child(0).has_method("ItemUse"):
				items.get_child(0).ItemUse()
	elif event.is_action_pressed("useItem_2"):
		if items.get_child_count()>1:
			if items.get_child(1).has_method("ItemUse"):
				items.get_child(1).ItemUse()
	elif event.is_action_pressed("useItem_3"):
		if items.get_child_count()>=2:
			if items.get_child(2).has_method("ItemUse"):
				items.get_child(2).ItemUse()

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
#Delete item at selected id. 
func DeleteItem(cellId):
	items.get_child(cellId).queue_free()
	var i = cellId+1
	while (i<get_child_count()):
		get_child(i-1).get_node("TextureButton").texture_normal=get_child(i).get_node("TextureButton").texture_normal
		get_child(i).get_node("TextureButton").texture_normal=null
		#Check item list not empty at i-1
		if get_parent().get_parent().get_node("Items").get_child_count()>1:
			if i!=0 and get_parent().get_parent().get_node("Items").get_child(i-1)!=null:
				if get_parent().get_parent().get_node("Items").get_child(i-1).has_method("ItemIndexChanged"):
					get_parent().get_parent().get_node("Items").get_child(i-1).call_deferred("ItemIndexChanged",get_child(i-1))
		i+=1
#When the mouse clicks the cell
func MouseClickedCell(cellId):
	#Check correct id
	if HasCellItem(cellId):
		MouseExitedCell(cellId)
		var item = items.get_child(cellId)
		if item.has_method("ItemWasDeleted"):
			item.ItemWasDeleted()
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
			#Check item list not empty at i-1
			if get_parent().get_parent().get_node("Items").get_child_count()>1:
				if i!=0 and get_parent().get_parent().get_node("Items").get_child(i-1)!=null:
					if get_parent().get_parent().get_node("Items").get_child(i-1).has_method("ItemIndexChanged"):
						get_parent().get_parent().get_node("Items").get_child(i-1).call_deferred("ItemIndexChanged",get_child(i-1))
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
		if item.has_method("ItemWasAdded"):
			item.ItemWasAdded()
#Get first empty cell, -1 if not possible
func GetEmptyCell()->int:
	for cell in get_children():
		if cell.get_node("TextureButton").texture_normal==null:
			return cell.get_index()
	return -1
