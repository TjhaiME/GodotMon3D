extends Control

#simplify the interaction code

#as we dont want to be able to highlight every node

#we have various types that we want to interact with in various ways

#scroll -> control stick moves scroll bar up and down (left and right could add speed)
#when get to bottom or top it moves to next interactable node

#button -> interactable node, click to click
#left and right could move between different things

var interactableNodes = []#a list of dics of node info in the ui to interact with
var currentIndex = 0


func highlight_node():
	pass

#func hand
