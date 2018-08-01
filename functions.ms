struct functions
(
	fn insertItemsToIndex originalAr insAr toIndex =
	(
	  	result = #()
	  	case toIndex of
	  	(
	  		(-1):
	  		(
	  			for item in insAr do append result item
	  			for i = 1 to insAr.count where (index = finditem originalAr insAr[i]) != 0 do deleteItem originalAr index
	  			for item in originalAr do append result item
	  		)
	  		0:
	  		(
	  			for i = 1 to insAr.count where (index = finditem originalAr insAr[i]) != 0 do deleteItem originalAr index
	  			for item in originalAr do append result item
	  			for item in insAr do append result item
	  		)
	  		default:
	  		(
	  			local secondAr = #()
	  			for i = 1 to (toIndex + 1) do append result originalAr[i]
	  			for i = (toIndex + 2) to originalAr.count do append secondAr originalAr[i]
	  			for i = 1 to insAr.count where (index = finditem result insAr[i]) != 0 do deleteItem result index
	  			for i = 1 to insAr.count where (index = finditem secondAr insAr[i]) != 0 do deleteItem secondAr index
	  			join result secondAr
	  		)
	  	)
	  	return result
	),

	fn exportSelectedNodesToObj =
	(
		fn exportNode nd fp suffix:"_highPoly"=
		(
			fileName = fp + @"\" + nd.name + suffix + ".obj"
			select nd
			exportFile fileName #noPrompt selectedOnly:true using:OBJExp
		)
		filePath = getSavePath caption:"Select Folder for Exporting .obj" initialDir:(getDir #export)
		disableSceneRedraw()
		ar = selection as array
		for o in ar do exportNode o filePath
		select ar
		enableSceneRedraw()
		messageBox "Operation Completed" title:"Success"
	)
)
