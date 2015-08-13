--The base script
--Included exporting struct
--For exporting 3D max model to DMod( Doublesoftware 3D model )
--Created by Liu Dw.
--Copyright DoubleSoftware (c)
--19:58 2009/1/13
-- Filename		: exportbase.ms
-- Made by		: Liu Dw.
-- System  		: Tested on MAX 9 in Windows Vista
-- Target API		: Direct 3D 9
-- Version      	: 1.00

struct D3DMATRIX
(
	_11,_12,_13,_14,
	_21,_22,_23,_24,
	_31,_32,_33,_34,
	_41,_42,_43,_44
)
struct D3DVECTOR
( x,y,z )
struct D3DFACE
( _1, _2, _3 )
struct D3DTEXTUREVEC
( tu, tv, tw )
struct BONE_WEIGHT
( strName, Weight )
struct OBJECT_WEIGHT
( nBoneCount, vertexSet )
struct D3DCOLOR
( r, g, b, a )
struct DMODMATERIAL
(
	Diffuse,
	Ambient,
	Specular,
	Emissive
,
	Power,

	DiffuseMap,
	SpecularMap,
	BumpMap,
	
DisplacementMap


)
fn FindObject name =
(
	for o in objects do
	(
		if o.name == name then return o
	)
	
	undefined
)

struct DMODOBJECT
(
	strName,
	m_object,
	m_VertCount,
	vertex,--local vert
	Normalvert,
	TVertCount,
	TextureVert,
	FaceCount,
	Face,
	TextureFace,
	Matrix,
	MaterialID,
	MaterialCount,
	fn DGetVerts =
	(
		--考虑Pivot，返回 Local Vertex.
		-- 注意 : 如果in coordsys local getvert o i，就可以很容易地求得 local vertex,
		--        但是, MAX中的 pivot不是 local坐标系的原点，只是旋转的中心轴.
		--        所以，如果直接求取 local vertex，就会得到没有考虑 pivot的错误 local vertex.(需要offset运算.)
		--        在这个函数中，求得 world vertex，使用 inverse tm相乘的方法.

		vertex = #()
		Normalvert = #()
		Normaltemp = D3DVECTOR 0.0f 0.0f 0.0f
		m_VertCount = m_object.numverts
		if m_VertCount == 0 then return 0
		TM = m_object.transform
		InvTM = inverse TM
		
		for k = 1 to m_VertCount do
		(
			local verttemp = D3DVECTOR 0.0f 0.0f 0.0f
			--Get Vector
			local vl -- vertex local
			local vw -- vertex world
			vw = in coordsys world getvert m_object k
			vl = vw * InvTM
		     --max pos to d3d pos
			verttemp.x = vl.x
			verttemp.y = vl.z
			verttemp.z = vl.y
			append vertex verttemp

		)
		for k = 1 to m_VertCount do
		(
			local verttemp = D3DVECTOR 0.0f 0.0f 0.0f
			-----------------------
			--Get Normal
			local v = getnormal m_object k
		        --max pos to d3d pos
			verttemp.x = v.x
			verttemp.y = v.z
			verttemp.z = v.y
			append Normalvert verttemp
		)
		m_VertCount
	),

	fn DGetFaces =
	(
		Face = #()
		TextureFace = #()
		FaceCount = m_object.numfaces
		if FaceCount == 0 then return 0
		for k = 1 to FaceCount do
		
		(
			FaceTemp = D3DFACE 0 0 0
			FaceTemp1 = D3DFACE 0 0 0
			pt = getFace m_object k
			if m_object.numtverts != 0  then
			(
				pv = getTVFace m_object k
			)
			else
			(
				pv = getface m_object k
			)
			--max face index fo d3d face index

		
			FaceTemp._1 =  (pt.x-1)

			FaceTemp._2 = (pt.z-1)

			FaceTemp._3 = (pt.y-1)
			append Face FaceTemp
			FaceTemp1._1 = (pv.x-1)

			FaceTemp1._2 = (pv.z-1)
			FaceTemp1._3 = (pv.y-1)
	
			append TextureFace FaceTemp1
	
		)
		return FaceCount
	),

	fn DGetTextureVert =
	(
		TextureVert = #()
		TVertCount = GetNumTVerts m_object
		if TVertCount == 0 then return 0
		for i = 1 to TVertCount do
		(
			local TVTemp = D3DTEXTUREVEC 0 0 0
			TVTemp.tu = (getTVert m_object i).x
			TVTemp.tv = (1.0 - (getTVert m_object i).y)
			TVTemp.tw = (getTVert m_object i).z
			append TextureVert TVTemp
		)
		return TVertCount
	),
	fn DGetTransform =
	(
		Matrix = D3DMATRIX 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
		--max transform to d3d trans
	
		-- [D3D matrix]               [MAX matrix]
		-- _11 _12 _13 0              _11 _13 _12 0
		-- _21 _22 _23 0       <->    _31 _33 _32 0
		-- _31 _32 _33 0              _21 _23 _22 0
		-- _41 _42 _43 1              _41 _43 _42 1
		Matrix._11 = m_object.transform.row1.x

		Matrix._12 = m_object.transform.row1.z
		Matrix._13 = m_object.transform.row1.y
		Matrix._14 = 0.0


		Matrix._21 = m_object.transform.row3.x
		Matrix._22 = m_object.transform.row3.z
		Matrix._23 = m_object.transform.row3.y
		Matrix._24 = 0.0

		Matrix._31 = m_object.transform.row2.x

		Matrix._32 = m_object.transform.row2.z
		Matrix._33 = m_object.transform.row2.y
		Matrix._34 = 0.0


		Matrix._41 = m_object.transform.row4.x
		Matrix._42 = m_object.transform.row4.z
		Matrix._43 = m_object.transform.row4.y
		Matrix._44 = 1.0
	
	),
	fn SetObject object1 =
	(
		if classof object1 != Editable_mesh then return 0
		m_object = object1
		strName = object1.name
		DGetVerts()
		DGetFaces()
		DGetTextureVert()
		DGetTransform()
		return 1
		
	)
)
struct Model
(
	m_Object,
	m_CountObject,
	m_Material,
	m_CountMaterial,
	m_Bone,

	-- 气泡排列函数
	fn mysort arr fnCompare = 
	(
		for i = 1 to arr.count do
			for j = i to arr.count do
			(
				if (fnCompare arr[i] arr[j]) > 0 then
				(
					t = arr[i]
					arr[i] = arr[j]
					arr[j] = t
				)
			)
	),
	-- 避免重复的累加
	fn SafeAppend sets item =
	(
		for i = 1 to sets.count do
		(
			if sets[i] == item then
			(
				return i
			)
		)
		
		append sets item
		return sets.count
	),
	fn GetStandardMaterial Material =
	(
		tempMaterial = DMODMATERIAL 0 0 0 0 0 "" "" "" ""
		tempMaterial.Diffuse	= D3DCOLOR 0.5f 0.5f 0.5f 1.0f
		tempMaterial.Ambient	= D3DCOLOR 0.5f 0.5f 0.5f 1.0f
		tempMaterial.Specular	= D3DCOLOR 0.0f 0.0f 0.0f 0.0f
		tempMaterial.Emissive	= D3DCOLOR 0.0f 0.0f 0.0f 0.0f
		tempMaterial.Power	= 0.0f

		--Diffuse

		if Material.Diffuse != undefined then
		(

			tempMaterial.Diffuse.r = ( Material.Diffuse.r/255.0  )


			tempMaterial.Diffuse.g = ( Material.Diffuse.g/255.0 )


			tempMaterial.Diffuse.b = ( Material.Diffuse.b/255.0 )


			tempMaterial.Diffuse.a = ( Material.Diffuse.a/255.0 )

		)

		--Ambient

		if Material.Ambient != undefined then
		(

			tempMaterial.Ambient.r = ( Material.Ambient.r/255.0 )


			tempMaterial.Ambient.g = ( Material.Ambient.g/255.0 )


			tempMaterial.Ambient.b = ( Material.Ambient.b/255.0 )


			tempMaterial.Ambient.a = ( Material.Ambient.a/255.0 )

		)

		--Specular

		if Material.Specular != undefined then
		(

			tempMaterial.Specular.r = ( Material.Specular.r/255.0 )


			tempMaterial.Specular.g = ( Material.Specular.g/255.0 )


			tempMaterial.Specular.b = ( Material.Specular.b/255.0 )


			tempMaterial.Specular.a = ( Material.Specular.a/255.0 )

		)


		--Emissive

		if Material.selfIllumColor != undefined then
		(

			tempMaterial.Emissive.r = ( Material.selfIllumColor.r/255.0 )


			tempMaterial.Emissive.g = ( Material.selfIllumColor.g/255.0 )


			tempMaterial.Emissive.b = ( Material.selfIllumColor.b/255.0 )


			tempMaterial.Emissive.a = ( Material.selfIllumColor.a/255.0 )
		)


		--Power
	
		if Material.SpecularLevel != undefined then
		(

			tempMaterial.Power = Material.SpecularLevel

		)

				

		-- Diffuse Map


		if Material.DiffuseMap != undefined then


		(


			tempMaterial.DiffuseMap = (filenameFromPath Material.DiffuseMap.filename)

		)


		-- Specular Map


		if Material.SpecularMap != undefined then

		(


			tempMaterial.SpecularMap = (filenameFromPath Material.SpecularMap.filename)


		)


		-- Bump Map


		if Material.BumpMap != undefined then


		(


			tempMaterial.BumpMap = (filenameFromPath Material.BumpMap.filename)


		)


		-- Displacement Map


		if Material.DisplacementMap != undefined then

		(


			tempMaterial.DisplacementMap = (filenameFromPath Material.DisplacementMap.filename)


		)

		local ID = SafeAppend m_Material tempMaterial
		return ID
	),
	fn GetMaterial object i =
	(
		if object.Material != undefined then

		(
			Material= object.Material
			if classOf Material == StandardMaterial then

			(
				m_Object[i].MaterialID = #()

				local MaterialID = ( GetStandardMaterial Material )
				Append m_Object[i].MaterialID MaterialID
				m_Object[i].MaterialCount = 1

			)
			else if classOf Material == MultiMaterial then
			(
				m_Object[i].MaterialID = #()
				m_Object[i].MaterialCount = Material.count
				for j = 1 to Material.numsubs do
				(
					if Material != undefined then
	
					(
			     			--if Material == StandardMaterial then
						--(
							local MaterialID = ( GetStandardMaterial Material[j] )
							Append m_Object[i].MaterialID MaterialID
						--)
					)
				)
			)
			else
			(
				MessageBox "Unkonow material!"
				return 0
			)

		)	
		else
		( 
			return 0
		)
		return 1
	),
	fn GetObject =
	(
		m_Object = #()
		m_Materil = #()
		objs = $
		if objs == undefine then return 0
		for o in objs do
		(
			local tempObj = DMODOBJECT  "" 0 0 #() #() 0 #() 0 #() #() 0 #() 0
			result = ( tempObj.SetObject o )
			if result == 0 then continue
			Append m_Object tempObj 
			GetMaterial o m_Object.count
		)

		m_CountMaterial = m_Material.count
		m_CountObject = m_Object.count
		msg = stringstream ""
		format "Count of objects:%\nCount of material:%" m_CountObject m_CountMaterial to:msg
		messagebox msg
		return 1
	)


)
struct DMODFile
(
	mymodel,
	fn WriteMaterial hFile i =
	(
		tempMaterial = mymodel.m_Material[i]


		--Diffuse

		WriteFloat hFile tempMaterial.Diffuse.r

		WriteFloat hFile tempMaterial.Diffuse.g

		WriteFloat hFile tempMaterial.Diffuse.b

		WriteFloat hFile tempMaterial.Diffuse.a

		--Ambient

		WriteFloat hFile tempMaterial.Ambient.r


		WriteFloat hFile tempMaterial.Ambient.g

		WriteFloat hFile tempMaterial.Ambient.b


		WriteFloat hFile tempMaterial.Ambient.a

		

		--Specular

		WriteFloat hFile tempMaterial.Specular.r

		WriteFloat hFile tempMaterial.Specular.g

		WriteFloat hFile tempMaterial.Specular.b

		WriteFloat hFile tempMaterial.Specular.a

		


		--Emissive
		WriteFloat hFile tempMaterial.Emissive.r

		WriteFloat hFile tempMaterial.Emissive.g

		WriteFloat hFile tempMaterial.Emissive.b

		WriteFloat hFile tempMaterial.Emissive.a


		--Power
	

		WriteFloat hFile tempMaterial.Power


				

		-- Diffuse Map


		WriteString hFile tempMaterial.DiffuseMap



		-- Specular Map


		WriteString hFile tempMaterial.SpecularMap



		-- Bump Map


		WriteString hFile tempMaterial.BumpMap



		-- Displacement Map


		WriteString hFile tempMaterial.DisplacementMap


	),
		--写入顶点、法向量和Texture vertex信息
	fn WriteVector hFile i =
	(
		objec = mymodel.m_Object[i]
		counta = objec.m_VertCount
		if counta == 0 then return 0
		WriteByte hFile 0x02 --Vector and normal
		WriteLong hFile counta
		aaa = stringstream ""

		for ii = 1 to counta do
		(
			WriteFloat hFile objec.vertex[ii].x
			WriteFloat hFile objec.vertex[ii].y
			WriteFloat hFile objec.vertex[ii].z
		)
		for ii = 1 to counta do
		(
			WriteFloat hFile objec.Normalvert[ii].x
			WriteFloat hFile objec.Normalvert[ii].y
			WriteFloat hFile objec.Normalvert[ii].z
		)
		counta = objec.TVertCount
		if counta == 0 then return 0
		WriteByte hFile 0x0a --Texture vertex
		WriteLong hFile counta
		for ii = 1 to counta do
		(
			WriteFloat hFile objec.TextureVert[ii].tu
			WriteFloat hFile objec.TextureVert[ii].tv
			WriteFloat hFile objec.TextureVert[ii].tw
		)
	),

	--写入面信息
	fn WriteFace hFile i =
	(
		local object = mymodel.m_Object[i]
		local count = object.FaceCount
		if count == 0 then return 0
		WriteByte hFile 0x03 --Faces
		WriteLong hFile count
		for ii = 1 to count do

		(
			WriteLong hFile object.Face[ii]._1
			WriteLong hFile object.Face[ii]._2
			WriteLong hFile object.Face[ii]._3
			WriteLong hFile object.TextureFace[ii]._1
			WriteLong hFile object.TextureFace[ii]._2
			WriteLong hFile object.TextureFace[ii]._3
	
		)
	),
	fn WriteMatrix hFile i =
	(
		local object = mymodel.m_Object[i]
		WriteByte hFile 0x04 --Transform

		WriteFloat hFile object.Matrix._11
		WriteFloat hFile object.Matrix._12
		WriteFloat hFile object.Matrix._13
		WriteFloat hFile object.Matrix._14

		WriteFloat hFile object.Matrix._21
		WriteFloat hFile object.Matrix._22
		WriteFloat hFile object.Matrix._23
		WriteFloat hFile object.Matrix._24

		WriteFloat hFile object.Matrix._31
		WriteFloat hFile object.Matrix._32
		WriteFloat hFile object.Matrix._33
		WriteFloat hFile object.Matrix._34

		WriteFloat hFile object.Matrix._41
		WriteFloat hFile object.Matrix._42
		WriteFloat hFile object.Matrix._43
		WriteFloat hFile object.Matrix._44
		
	),
	fn WriteMaterialID hFile i =
	(
		local object = mymodel.m_Object[i]
		local count = object.MaterialCount
		if count == 0 then return 0
		WriteByte hFile 0x05 --Material ID(s)
		WriteLong hFile object.MaterialCount
		for ii = 1 to count do
		(
			WriteLong hFile object.MaterialID[ii]
		)
	),
	fn WriteFrame hFile i =
	(
		WriteByte hFile 0x01 --Frame
		WriteString hFile mymodel.m_Object[i].strName
		
		WriteVector hFile i
		WriteFace hFile i
		WriteMatrix hFile i
		WriteMaterialID hFile i
		
	),


	fn Export FilePath =
	(
		ConvertToMesh objects
		mymodel = Model #() 0 #() 0 #()
		result = mymodel.GetObject()
		if result == 0 then
		(
			return 0
		)
		if mymodel.m_CountObject == 0 then
		(
			return 0
		)
		hFile = fopen FilePath "wb"
		WriteString hFile "DMod"

		CountMaterial = mymodel.m_CountMaterial
		CountObject = mymodel.m_CountObject
		WriteLong hFile CountMaterial
		if CountMaterial != 0 then
		(
			for i = 1 to CountMaterial do
			(
				WriteMaterial hFile i
			)
		)
		WriteLong hFile CountObject
		for i = 1 to CountObject do
		(
			WriteFrame hFile i
		)
		fclose hFile
		1
	)


)