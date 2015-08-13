rollout f_Main "Export" width:291 height:159
(
	editText ePathName "FilePath:" pos:[1,24] width:253 height:20
	button bExport "&Export" pos:[196,85] width:66 height:30
	button bAll "Select &All" pos:[11,83] width:69 height:27
	button bPathName "..." pos:[260,24] width:26 height:19
	label l_state "Ready." pos:[0,131] width:221 height:28
	button bReTV "&Rebuild TVFaces" pos:[89,84] width:98 height:29
	on f_Main open  do
(
	
	)
	on f_Main close  do
(
	
	)
	on f_Main okToClose  do
(
	
	)
	on f_Main resized size do
(
	
	)
	on f_Main moved pos do
(
	
	)
	on ePathName entered text do
(
	
	)
	on bExport pressed  do
	(

	  l_state.caption = "Now exporting..."

	  convertTo $ TriMeshGeometry
	
	  myDMOD = DMODFile 0

	  ff = ePathName.text

	  result = myDMOD.Export ff

	  if result == 1 then

	  (

	    l_state.caption = "Finished."

	  )

	  else 

	  (

	    l_state.caption = "Error."

	  )

	)
	on bAll pressed  do
	(

	select $*

	l_state.caption = "You have selected all objects."

	)
	on bPathName pressed  do
	(

	    temp = getSaveFileName filename:"Untitled" types:"MODEL(*.DMod)|*.DMod|All|*.*|"

	    if temp != undefined then ePathName.text = temp

	)
	on bReTV pressed  do
	(

	objs = $
	

	if objs != undefined then
	(

	   for o in objs do
	  (
	

	     buildTVFaces o true

	  )

	)

	)
)