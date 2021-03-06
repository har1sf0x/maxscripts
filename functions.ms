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
nameBonesRollout --rollout for naming v2 human character (Pelvis,Spine0...-Neck-Head-nub,Clavicle-Shoulder-Elbow-nub-Hand-nub,Thigh-Knee-Ankle-Toes)
findReplaceText searchFor replaceWith &result --it modifies result by changing the searchFor text with the replaceWith text
findReplaceNameRollout --rollout for replacing with string in selection.name
name_RenameRF --var for containing name_RenameRF rolloutFloater
UI_NameBones --fn for setting name_RenameRF and adding nameBonesRollout and findReplaceNameRollout
createRigForearmRollBones sel count:2 --create and rig Forearm roll bones. sel must be #(forearm, hand)
runCreateRigForearmRollBones count:2 --an other way to createRigForearmRollBones by picking object on site
createRigShoulderRollBones bn count:1 --create and rig Shoulder roll bones.
createBoneEnd bn --it creates a boneEnd (nub)
copyWeightsOfSelectedVerticesFromBoneToBone skinMod fromBn toBN: --copy skin weights of selected vertices from one bone to another
cWOSVFBTB skinMod fromBn toBN: --alias of copyWeightsOfSelectedVerticesFromBoneToBone
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
	  	result
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

	nameBonesRollout = rollout nameBonesRollout "Name Bones of v2 Bone Structure"
	(
		editText edt_CharacterName "Character Name:"
		dropDownList ddl_BodyPart "Body Part:" items:#("Pelvis", "Spine-Neck-Head", "Leg", "Reversed Foot", "Arm", "Finger") --width:120
		group "Finger"
		(
			editText edt_FingerName "Finger Name:" enabled:false --across:2
			checkBox ckb_HasMetacarpus "Has Metacarpus?" enabled:false
		)
		dropDownList ddl_Side "Side:" items:#("rt", "lt") enabled:false width:50
		
		on ddl_BodyPart selected arg do
		(
			edt_FingerName.enabled = ckb_HasMetacarpus.enabled = (ddl_BodyPart.selected == "Finger")
			ddl_Side.enabled = (ddl_BodyPart.selected == "Leg" or ddl_BodyPart.selected == "Reversed Foot" or ddl_BodyPart.selected == "Arm" or ddl_BodyPart.selected == "Finger")
		)
		
		button btn_Rename "Rename Selection"

		on btn_Rename pressed do
		(
			setWaitCursor()
			if selection.count == 0 then
			(
				messageBox "Please select the bone chain that you want to rename." title:"Warning..."
				setArrowCursor()
				false
			) else
			(
				bonesAr = selection as array
				case ddl_BodyPart.selection of
				(
					1:
					(
						if bonesAr.count != 2 then
						(
							messageBox "The v2 Pelvis needs 2 bones. Action aborted." title:"Warning..."
							setArrowCursor()
							false
						) else
						(
							bonesAr[1].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+"Pelvis"+"_"+"_DEF_bn"
							bonesAr[2].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+"Pelvis"+"_"+"_nub"
							setArrowCursor()
							true
						)
					)
					2:
					(
						if bonesAr.count < 4 then
						(
							messageBox "The v2 Spine needs at least 4 bones. Action aborted." title:"Warning..."
							setArrowCursor()
							false
						) else
						(
							for i = 1 to bonesAr.count-3 do bonesAr[i].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+"Spine0"+(i as string)+"_DEF_bn"
							bonesAr[bonesAr.count-2].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+"Neck"+"_DEF_bn"
							bonesAr[bonesAr.count-1].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+"Head"+"_DEF_bn"
							bonesAr[bonesAr.count].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+"Head"+"_nub"
							setArrowCursor()
							true
						)
					)
					3:
					(
						if bonesAr.count != 5 then
						(
							messageBox "The v2 Leg needs 5 bones. Action aborted." title:"Warning..."
							setArrowCursor()
							false
						) else
						(
							boneNames = #("Thigh", "Knee", "Ankle", "Toes", "Toes")
							for i in #(1, 2, 3, 4) do bonesAr[i].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+ddl_Side.selected+"_"+boneNames[i]+"_DEF_bn"
							for i in #(5) do bonesAr[i].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+ddl_Side.selected+"_"+boneNames[i]+"_nub"
							setArrowCursor()
							true
						)
					)
					4:
					(
						if bonesAr.count != 6 then
						(
							messageBox "The v2 Reversed Foot needs 6 bones. Action aborted." title:"Warning..."
							setArrowCursor()
							false
						) else
						(
							boneNames = #("Foot0", "Foot0", "Ankle",  "Foot", "Toes", "Toes")
							indices = #(1,2)
							for i in indices do bonesAr[i].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+ddl_Side.selected+"_"+boneNames[i]+(i as string)+"_HLP_bn"
							indices = #(3,5)
							for i in indices do bonesAr[i].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+ddl_Side.selected+"_"+boneNames[i]+"_DEF_bn"
							indices = #(4,6)
							for i in indices do bonesAr[i].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+ddl_Side.selected+"_"+boneNames[i]+"_nub"
							setArrowCursor()
							true
						)
					)
					5:
					(
						if bonesAr.count != 6 then
						(
							messageBox "The v2 Arm needs 6 bones. Action aborted." title:"Warning..."
							setArrowCursor()
							false
						) else
						(
							boneNames = #("Clavicle", "Shoulder", "Elbow", "Arm", "Hand", "Hand")
							for i in #(1, 2, 3, 5) do bonesAr[i].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+ddl_Side.selected+"_"+boneNames[i]+"_DEF_bn"
							for i in #(4, 6) do bonesAr[i].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+ddl_Side.selected+"_"+boneNames[i]+"_nub"
							setArrowCursor()
							true
						)
					)
					6:
					(
						bonesCount = if ckb_HasMetacarpus.checked then 5 else 4
						if bonesAr.count != bonesCount then
						(
							messageBox ("The finger needs " + (bonesCount as string) + " bones. Action aborted.") title:"Warning..."
							setArrowCursor()
							false
						) else
						(
							startIndex = if ckb_HasMetacarpus.checked then 0 else 1
							for i = startIndex to bonesAr.count - 1 do bonesAr[i].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+ddl_Side.selected+"_"+edt_FingerName.text+"0"+(i as string)+"_DEF_bn"
							bonesAr[bonesAr.count].name = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+ddl_Side.selected+"_"+edt_FingerName.text+"_nub"
							setArrowCursor()
							true
						)
					)
				)
				--bnName = (if edt_CharacterName.text != "" then (edt_CharacterName.text + "::") else "")+"put_the_bodyPart_var_here"+"_"+ddl_Side.selected+"_DEF_bn"
			)
		)
	),

	fn findReplaceText searchFor replaceWith &result =
	(
		if classof searchFor != string and classof replaceWith != string and classof result != string then
		(
			format "error: findReplaceText % % %" searchFor replaceWith result
			false
		) else
		(
			index = findString result searchFor
			if index != undefined do
			(
				result = replace result index searchFor.count replaceWith
			)
			true
		)
	),

	findReplaceNameRollout = rollout findReplaceNameRollout "Find/Replace selection.name"
	(
		editText edt_SearchFor "Search for:"
		editText edt_ReplaceWith "Replace With:"
		button btn_Replace "Replace Selection"
		
		on btn_Replace pressed do
		(
			if edt_SearchFor.text != "" and edt_ReplaceWith.text != "" and selection.count != 0 do
			(
				setWaitCursor()
				for o in selection do
				(
					functions.findReplaceText edt_SearchFor.text edt_ReplaceWith.text &o.name
				)
				setArrowCursor()
			)
		)
	),
	name_RenameRF = undefined,

	fn UI_NameBones =
	(
		try(closeRolloutFloater name_RenameRF)catch()
		name_RenameRF = newRolloutFloater "Name/Rename v2 Bone Structure" 300 500
		addRollout nameBonesRollout name_RenameRF
		addRollout findReplaceNameRollout name_RenameRF
-- 		try(destroyDialog nameBonesRollout)catch()
-- 		createDialog nameBonesRollout width:500
	),

	fn createRigForearmRollBones sel count:2 =
	(
		if classof sel != array or sel.count != 2 or classof sel[1] != BoneGeometry or classof sel[2] != BoneGeometry then
		(
			messageBox "Please pass an array of type #(forearm, hand). Action aborted." title:"Warning..."
			false
		) else
		(
			setWaitCursor()
			bn = sel[1]
			hand = sel[2]
			rollBones = #()
			for i = 1 to count do
			(
				roll = copy bn
				roll.wirecolor = red --bn.wirecolor
				roll.name = (trimright bn.name "_DEF_bn") + "roll0" + (i as string) + "_DEF_bn"
				roll.parent = bn
				roll.length = (bn.length * 1.0/(count + 1))
				tm = bn.transform
				tm.position = bn.pos + (i * roll.length) * bn.transform.row1
				roll.transform = tm
				append rollBones roll
			)
			for i = 1 to (count - 1) do
			(
				contro = orientation_constraint()
				rollBones[i].transform.controller[2].controller = contro
				contro.appendTarget bn (100*(1.0 - (i*(1.0/count))))
				contro.appendTarget rollBones[count] (100*i*(1.0/count))
			)
			(
				contro = lookAt_constraint()
				rollBones[count].transform.controller[2].controller = contro
				contro.lookat_vector_length = 0.0
				contro.appendTarget bn 1.0
				contro.target_axis = 0
				contro.target_axisFlip = true
				contro.pickUpNode = hand
				contro.upnode_world = false
				contro.StoUP_axis = 1
				contro.upnode_axis = 1
			)
			setArrowCursor()
			true
		)
	),

	fn runCreateRigForearmRollBones count:2 =
	(
		fn pickBone o = (classof o == BoneGeometry)
		sel = pickObject message:"Please pick the forearm and the hand." filter:pickBone count:2
		if sel == array or sel.count != 2 then
		(
			messageBox "Please pick the forearm and the hand. Action aborted." title:"Warning..."
			false
		) else
		(
			createRigForearmRollBones sel count:count
			true
		)
	),

	fn createRigShoulderRollBones bn count:1 =
	(
		if classof bn != BoneGeometry or bn.parent == undefined then
		(
			messageBox "Please pass the shoulder bone. Action aborted." title:"Warning..."
			false
		) else
		(
			setWaitCursor()
			rollBones = #()
			for i = 1 to count do
			(
				roll = copy bn
				roll.wirecolor = red --bn.wirecolor
				roll.name = (trimright bn.name "_DEF_bn") + "roll0" + (i as string) + "_DEF_bn"
				roll.parent = bn
				roll.length = (bn.length * 1.0/(count + 1))
				tm = bn.transform
				tm.position = bn.pos + ((i-1) * roll.length) * bn.transform.row1
				roll.transform = tm
				append rollBones roll
			)
			for i = 2 to count do
			(
				contro = orientation_constraint()
				rollBones[i].transform.controller[2].controller = contro
				contro.appendTarget rollBones[1] (100*(1.0 - (i-1)*(1.0/count)))
				contro.appendTarget bn (100*(i-1)*(1.0/count))
			)
			(
				pt = point name:((trimright bn.name "bn") + "pt") size:(2*(amax #(bn.height,bn.width))) box:true axistipod:false cross:false centermarker:false wirecolor:green
				pt.transform = bn.transform
				pt.parent = bn.parent
				contro = float_script()
				rollBones[1].transform.controller[2].controller[1].controller = contro
				contro.addNode "pt" pt
				contro.addNode "bn" bn
				txt = "rot = (bn.transform * inverse pt.transform).rotation as eulerAngles\ndegToRad -rot.x"
				contro.script = txt
			)
			setArrowCursor()
			true
		)
	),

	fn createBoneEnd bn =
	(
		if classof bn != BoneGeometry then
		(
			format "WARNING: The createBoneEnd aborted. % was not a BoneGeometry. Please pass a bone next time..." bn.name
			false
		) else
		(
			result = (BoneSys.createBone (bn.pos + bn.length * bn.transform.row1) (bn.pos + (bn.length + (amin #(bn.height, bn.width))) * bn.transform.row1) bn.transform.row3)
			result.parent = bn
			result.name = (trimright bn.name "bn") + "nub"
			result.width = result.height = result.length
			if har1sf0x != undefined then har1sf0x.riggingTools.resetStretch result else displayTempPrompt "The end bone might be stretched..." 3000
			true
		)
	),

	fn copyWeightsOfSelectedVerticesFromBoneToBone skinMod fromBn toBN =
	(
		boneNames = #()
		if classof skinMod == skin do
		(
			for i = 1 to skinOps.GetNumberBones skinMod do
			(
				append boneNames (skinOps.GetBoneName skinMod i 0 )
			)
		)
		if boneNames.count != 0 and (fromIndex = findItem boneNames fromBn) != 0 and (toIndex = findItem boneNames toBn) != 0 then
		(
			for i = 1 to skinOps.GetNumberVertices skinMod where (skinOps.IsVertexSelected skinMod i) == 1 do
			(
				for bnIndex = 1 to skinOps.GetVertexWeightCount skinMod i where (skinOps.GetVertexWeightBoneID skinMod i bnIndex == fromIndex) do
				(
					weight = skinOps.GetVertexWeight skinMod i bnIndex
					if weight == undefined do weight = 0.0
					skinOps.SetVertexWeights skinMod i fromIndex 0.0
					skinOps.RemoveZeroWeights skinMod
					skinOps.SetVertexWeights skinMod i toIndex weight
				)
			)
			skinOps.RemoveZeroWeights skinMod
			print "Done"
		) else
		(
			print "Failed"
		)
	),

	fn cWOSVFBTB skinMod fromBn toBN =
	(
		copyWeightsOfSelectedVerticesFromBoneToBone skinMod fromBn toBN
	)
)--end struct functions