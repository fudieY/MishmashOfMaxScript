function GetLayerNames =
(
	layernames = #()
	for i = 1 to LayerManager.count  do
	(
		lay = (LayerManager.getLayer (i-1))
		append layernames lay.name
	)
	return layernames
	
)

function isLayernameAlready  str = (
	layernames = GetlayerNames () 	
	for ln in layernames do (
		if str == ln then return true 
	)
	return false 
)
function GetParentLayersToRootFromCurrentLayer lay = (
	lay.getparent()
	templayer = lay 
	result = #()
	countLimit = 1 
	while  undefined  !=  templayer   and  countLimit  < 100 do (
		append result  templayer 
		templayer = templayer.getparent()
		countLimit += 1 
	)
	return result 
)

function GetUsedLayerFromObjects  objlist = (
	result =#()
	for obj in objlist do (
		join result (GetParentLayersToRootFromCurrentLayer obj.layer )
	)
	
	return (makeUniqueArray result )
)


function GetNumbersOfLayerHierarchie  Layers = (
	result  =#()
	for lay in layers do (
		parentlayer = lay.getparent()
		if parentlayer == undefined then (
			append result 0
		)else (
			id = finditem layers  parentlayer 
			append result id 
		)
	)
	return result 
)
function convertNumberToStringOcount   num count  = (
	result = num as string 
	addOcount = count  - result.count  
	for i =  1 to addOcount do (
		result = "0" + result 
	)
	return result 
)

function replaceSuffixNumber str  num  addNumber:true  = (
	suffixCount = 0
	for i = 0 to str.count do (
		checkchar = str[str.count - i ]  
		if  checkchar as integer  != undefined then (
			suffixCount += 1 
		)else(
			exit 
		)
	)
	if suffixCount == 0  then (
		numstring =convertNumberToStringOcount  num  3 
		return (str +"-"+ numstring )
	)
	suffix  = substring str (str.count - suffixCount + 1 )   suffixCount

	result = ""
	if addNumber then (
		newnum =  (suffix as integer ) + num 
		result = substituteString str  suffix  (convertNumberToStringOcount newnum suffixCount)
	)else(
		result =  substituteString str  suffix  (convertNumberToStringOcount num suffixCount)
	)
	return result
)
 function CreateNewLayer lay=(
	
	newname = ""
	flg = true  
	i = 1
	 while flg  and  i < 99  do (
		newname = replaceSuffixNumber lay.name  i 
		 flg = isLayernameAlready newname 
		 i += 1
	)	
	return (LayerManager.newLayerFromName newname)
)

function GetMultiArrayObjectsByLayerArray  objList LayerList = (
	result = #()
	for i = 1 to LayerList.count do(
		append result #()
	)
	for obj in objlist do (
		findId = finditem LayerList obj.layer
		append result[findId] obj 
	)
	return result 
)

function  SepareteLayerKeepHierarchie = (
	selObjects = selection  as array 
	
	usedLayers = GetUsedLayerFromObjects  selobjects 
	hierarchieList = GetNumbersOfLayerHierarchie usedLayers
	newlayers = #()
	for lay in  usedlayers do (
		newlayer  = CreateNewLayer lay 
		append newlayers newlayer 
	)
	for i  =  1 to hierarchieList.count do (
		if  0 != hierarchieList[i] then (
			newlayers[i].setParent  newlayers[ hierarchieList[i] ]
		)
	)
	selmultList =GetMultiArrayObjectsByLayerArray   selObjects usedLayers
	for i = 1 to selmultList.count do (
		newlayers[i].addnodes  selmultList[i]
	)
)
 

	
	Rollout SepareteLayerRO "Separate Layer Keep Hierarchie"
	(
		button start_button "RunScript"
		on start_button pressed do
		(
			
			SepareteLayerKeepHierarchie()
			messageBox "Done!"
		)
	)
	CreateDialog SepareteLayerRO
	