struct functions
(
	fn info =
	(
	txt = "
created by har1sf0x, 01/Aug/2018
contains usefull functions for various purposes
info --prints info about the struct
insertItemsToIndex originalAr insAr toIndex --helper fn for .net ListBox (toIndex is 0-based)
exportSelectedNodesToObj suffix:'' --it exports all selected nodes to different .obj files addind suffix
nameBonesRollout --rollout for UI_NameBones
UI_NameBones --UI for renaming bones of human character (Pelvis,Spine0...-Neck-Head-nub,Clavicle-Shoulder-Elbow-nub,Thigh-Knee-Ankle-Toes)
createRigForearmRollBones sel count:2 --create and rig Forearm roll bones. sel must be #(forearm, hand)
runCreateRigForearmRollBones count:2 --an other way to createRigForearmRollBones by picking object on site
"
	print txt
	),

	fn insertItemsToIndex originalAr insAr toIndex =
	(
		setWaitCursor()
	  	result = #()
	  	case toIndex of
	  	(
	  		0:
	  		(
	  			for item in insAr do append result item
	  			for i = 1 to insAr.count where (index = finditem originalAr insAr[i]) != 0 do deleteItem originalAr index
	  			for item in originalAr do append result item
	  		)
	  		(-1):
	  		(
	  			for i = 1 to insAr.count where (index = finditem originalAr insAr[i]) != 0 do deleteItem originalAr index
	  			for item in originalAr do append result item
	  			for item in insAr do append result item
	  		)
	  		default:
	  		(
	  			local secondAr = #()
	  			for i = 1 to (toIndex ) do append result originalAr[i]
	  			for i = (toIndex + 1) to originalAr.count do append secondAr originalAr[i]
	  			for i = 1 to insAr.count where (index = finditem result insAr[i]) != 0 do deleteItem result index
	  			for i = 1 to insAr.count where (index = finditem secondAr insAr[i]) != 0 do deleteItem secondAr index
				for item in insAr do append result item
	  			join result secondAr
	  		)
	  	)
	  	setArrowCursor()
	  	return result
	),

	fn exportSelectedNodesToObj suffix:"" =
	(
		fn exportNode nd fp suffix:"_highPoly"=
		(
			fileName = fp + @"\" + nd.name + suffix + ".obj"
			select nd
			exportFile fileName #noPrompt selectedOnly:true using:OBJExp
		)
		filePath = getSavePath caption:"Select Folder for Exporting .obj" initialDir:(getDir #export)
		setWaitCursor()
		disableSceneRedraw()
		ar = selection as array
		for o in ar do exportNode o filePath suffix:suffix
		select ar
		enableSceneRedraw()
		setArrowCursor()
		messageBox "Operation Completed" title:"Success"
	),

	nameBonesRollout = rollout nameBonesRollout "Name Bones"
	(
		editText edt_CharacterName "Character Name:"
		dropDownList ddl_BodyPart "Body Part:" items:#("Pelvis", "Spine-Neck-Head", "Clavicle-Arm", "Leg", "Finger") width:120
		editText edt_FingerName "Finger Name:" enabled:false across:2
		checkBox ckb_HasMetacarpus "Has Metacarpus?" enabled:false
		dropDownList ddl_Side "Side:" items:#("rt", "lt") enabled:false width:50
		
		on ddl_BodyPart selected arg do
		(
			edt_FingerName.enabled = ckb_HasMetacarpus.enabled = (ddl_BodyPart.selected == "Finger")
			ddl_Side.enabled = (ddl_BodyPart.selected == "Clavicle-Arm" or ddl_BodyPart.selected == "Leg" or ddl_BodyPart.selected == "Finger")
		)
		
		button btn_Rename "Rename..."

		on btn_Rename pressed do
		(
			setWaitCursor()
			if selection.count == 0 do
			(
				messageBox "Please select the bone chain that you want to rename." title:"Warning..."
				setArrowCursor()
				return false
			)
			bonesAr = selection as array
			case ddl_BodyPart.selection of
			(
				1: bonesAr[1].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+"Pelvis"+"_"+"_bn"
				2:
				(
					if bonesAr.count < 4 do
					(
						messageBox "The spine needs at least 4 bones. Action aborted." title:"Warning..."
						setArrowCursor()
						return false
					)
					for i = 1 to bonesAr.count-3 do bonesAr[i].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+"Spine0"+(i as string)+"_bn"
					bonesAr[bonesAr.count-2].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+"Neck"+"_bn"
					bonesAr[bonesAr.count-1].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+"Head"+"_bn"
					bonesAr[bonesAr.count].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+"Head"+"_nub"
				)
				3:
				(
					if bonesAr.count != 4 do
					(
						messageBox "The Arm needs 4 bones. Action aborted." title:"Warning..."
						setArrowCursor()
						return false
					)
					boneNames = #("Clavicle", "Shoulder", "Elbow", "Arm")
					for i = 1 to 3 do bonesAr[i].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+boneNames[i]+"_"+ddl_Side.selected+"_bn"
					bonesAr[4].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+boneNames[4]+"_"+ddl_Side.selected+"_nub"
				)
				4:
				(
					if bonesAr.count != 5 do
					(
						messageBox "The Leg needs 5 bones. Action aborted." title:"Warning..."
						setArrowCursor()
						return false
					)
					boneNames = #("Thigh", "Knee", "Ankle", "Toes", "Leg")
					for i = 1 to 4 do bonesAr[i].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+boneNames[i]+"_"+ddl_Side.selected+"_bn"
					bonesAr[5].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+boneNames[5]+"_"+ddl_Side.selected+"_nub"
				)
				5:
				(
					testVar = if ckb_HasMetacarpus.checked then 5 else 4
					if bonesAr.count != testVar do
					(
						messageBox ("The finger needs " + (testVar as string) + " bones. Action aborted.") title:"Warning..."
						setArrowCursor()
						return false
					)
					startIndex = if ckb_HasMetacarpus.checked then 0 else 1
					for i = startIndex to bonesAr.count - 1 do bonesAr[i].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+edt_FingerName.text+"0"+(i as string)+"_"+ddl_Side.selected+"_bn"
					bonesAr[bonesAr.count].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+edt_FingerName.text+"_"+ddl_Side.selected+"_nub"
				)
			)
-- 			bnName = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+"put_the_bodyPart_var_here"+"_"+ddl_Side.selected+"_bn"
			setArrowCursor()
			return true
		)
	),

	fn UI_NameBones =
	(
		try(destroyDialog nameBonesRollout)catch()
		createDialog nameBonesRollout width:500
	),

	fn createRigForearmRollBones sel count:2 =
	(
		if classof sel != array or sel.count != 2 or classof sel[1] != BoneGeometry or classof sel[2] != BoneGeometry do
		(
			messageBox "Please pass an array of type #(forearm, hand). Action aborted." title:"Warning..."
			return false
		)
		setWaitCursor()
		bn = sel[1]
		hand = sel[2]
		rollBones = #()
		for i = 1 to count do
		(
			roll = copy bn
			roll.name = (trimright bn.name "bn") + "roll0" + (i as string) + "_bn"
			roll.parent = bn
			roll.length = (bn.length * 1/(count + 1))
			tm = bn.transform
			tm.position = bn.pos + (i * roll.length) * bn.transform.row1
			roll.transform = tm
			append rollBones roll
		)


		setArrowCursor()
		return true
	),

	fn runCreateRigForearmRollBones count:2 =
	(
		fn pickBone o = (classof o == BoneGeometry)
		sel = pickObject message:"Please pick the forearm and the hand." filter:pickBone count:2
		if sel == array or sel.count != 2 do
		(
			messageBox "Please pick the forearm and the hand. Action aborted." title:"Warning..."
			return false
		)
		createRigForearmRollBones sel count:count
		return true
	)
)
