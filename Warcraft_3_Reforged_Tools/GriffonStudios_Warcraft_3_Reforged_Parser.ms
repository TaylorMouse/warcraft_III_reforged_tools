/*
    .DESCRIPTION
    | Gather data from the scene for Warcraft III Reforged
    | Written by Taylor Mouse
    
    .DATE
    | (c)2015 - 2022
    
    .RELEASENOTES
    | 0.5 - Rewrite the Tangents calculation after hours of of reading :/
    | 0.4 - Rewrite of the textures in the scene
    | 0.3 - Split parser methods to their own file
    | 0.2 - Revisit
    | 0.1 - INIT
    
*/

struct Warcraft_3_Ref_Parser
(
    function GetTextureId mat layerIndex texs=
    (
        local textureId = -1
        local toFind = case layerIndex of
        (
            1: getfileNameFile mat.diffuse_map.fileName
            2: getfileNameFile mat.normal_map.fileName
            3: getfileNameFile mat.orm_map.fileName
            4: getfileNameFile mat.emissive_map.fileName
            5: ""
            6: getfileNameFile mat.reflection_map.fileName
        )
        
        if DEBUG_MODE then format "Looking for: %\n" toFind
        for t=1 to texs.count do 
            if ( toFind == getfileNameFile texs[t].path ) then (
                textureId = t - 1
                exit
            )

        if textureId == -1 then (
            format "[ERROR] Texture '%' not found in the TEXS list!!\n" toFind
            textureId = 0
        )
        
        textureId
    ),
    function RoundToFrame val=
    (
        local a = val * 30 / 1000
        local b = val * 30 / 1000.0
        
        if ( b - a ) > 0.5 then return a + 1 else return a
       
    ),
    function GetLODId theMesh=
    (
        local LODId = 0
        if ( findstring theMesh.Name "_LOD1" ) != undefined then LODId = 1
        if ( findstring theMesh.Name "_LOD2" ) != undefined then LODId = 2
        if ( findstring theMesh.Name "_LOD3" ) != undefined then LODId = 3
        return LODId
    ),
    function CalculateTangents theMesh=
    (
        local tan1 = #()
        local tan2 = #()
        local tangent = #()
        for i=1 to theMesh.numFaces do
        (

            local f = getTvFace theMesh i

            local w1 = getTVert theMesh f[1]
            local w2 = getTVert theMesh f[2]
            local w3 = getTVert theMesh f[3]

            local n1 = getnormal theMesh f[1]
            local n2 = getnormal theMesh f[2]
            local n3 = getnormal theMesh f[3]
            
            local t1 = cross n1 w1
            local t2 = cross n2 w2
            local t3 = cross n3 w3

            tangent[f[1]] = [t1.x, t1.y, t1.z, 1]
            tangent[f[2]] = [t2.x, t2.y, t2.z, 1]
            tangent[f[3]] = [t3.x, t3.y, t3.z, 1]

        )
        return tangent
    ),
    function GetWeights theMesh mdx=
    (
        struct weights1000 ( matrices = #(), vertex_weight_list )
        struct vertex_weight ( vertex, boneIndices = #(), vertexWeights = #() )
        
        local weights = weights1000()
        
        select theMesh
        max modify mode
        local skinMod = modPanel.getCurrentObject()

        local vertex_weight_list = #()
        for v=1 to skinOps.getnumbervertices skinMod do
        (
            local vw = vertex_weight vertex:v
            local vertexweightcount = skinops.getvertexweightcount skinMod v

            if vertexweightcount > 4 then vertexweightcount = 4
            
            for w=1 to vertexweightcount do
            (
                local weight = skinOps.getvertexweight skinMod v w
                local boneId = skinOps.getvertexweightboneid skinMod v w
                local boneName = skinOps.getBonename skinMod boneId 0
                
                for obj in mdx.allobjects do
                (
                    if ( obj.objRef.name == boneName ) then 
                    (
                        local weightByte = ( weight * 255 ) as integer
                        append vw.boneIndices obj.id
                        append vw.vertexWeights  weightByte
                        exit
                    )
                )
            )
            
            -- make sure each boneIndices / VertexWeight pair has 4 items
            for x=4 to vw.boneIndices.count by -1 do (
                append vw.boneIndices 0
                append vw.vertexWeights 0
            )
            
            if( 255 - vw.vertexWeights[1] - vw.vertexWeights[2] - vw.vertexWeights[3] - vw.vertexWeights[4] != 0 ) then
                    vw.vertexWeights[1] = 255 - vw.vertexWeights[2] - vw.vertexWeights[3] - vw.vertexWeights[4]
            
            
            append vertex_weight_list vw
            
        )
        
        for i=1 to mdx.allObjects.Count do if ( mdx.allObjects[i].objectType == #wc3Bone ) then  append weights.matrices ( i - 1)
        
        -- > annoyingly necessary to apply the correct weights to the correct vertices
        local tvVertices = #()
        for i=1 to theMesh.numFaces do
        (
            local f = getFace theMesh i
            local u = getTvFace theMesh i
            tvVertices[u.x] = f.x as integer
            tvVertices[u.y] = f.y as integer
            tvVertices[u.z] = f.z as integer
        )
        --> necessary as well as some models have isolated vertices...
        for i=1 to tvVertices.count do if (tvVertices[i] == undefined ) then tvVertices[i] = i as integer

        -- since vertices are matched by the tvFaces
        local tv_vertex_weight_list = #()
        for tv in tvVertices do
            append tv_vertex_weight_list vertex_weight_list[tv]
            
        weights.vertex_weight_list = tv_vertex_weight_list
        
        deselect theMesh
        return weights
    ),
    function GetAllAnimatedKeyFrames=
    (
        local uniqueKeys = #()
        for obj in objects do
        (
                for i=1 to obj.numSubs do 
                (
                    if obj[i].Keys != undefined then
                    (
                        
                        for j=1 to obj[i].numsubs do
                        (
                            if obj[i][j].Keys != undefined then
                            (
                                for k in obj[i][j].keys do
                                (
                                    local strTime = k.time as string
                                    local iTime = substring strTime 1 (strTime.count - 1 ) as integer
                                    
                                    appendifunique uniqueKeys iTime
                                    
                                )
                            )
                        )
                    )
                    
                )
        )

        local sortedKeys = sort uniqueKeys   
        return sortedKeys
        
    ),
    function GetMODLBoundingBoxBetweenFrames startFrame endFrame=
    (
        if DEBUG_MODE then Format "Calculating MODL Boundingbox between frame % and %\n" startFrame endFrame
        local allKeys = _parser.GetAllAnimatedKeyFrames()

        maxPoint = [0,0,0]
        minPoint = [0,0,0]

        for t in allKeys do
        (
            if ( t >= startFrame and t <= endFrame ) then 
            (
                at time t 
                for obj in objects do
                (
                    if ( classof obj == Editable_Mesh and obj.visibility == true ) then
                    (
                        local bbMax = obj.max
                        
                        for i=1 to 3 do
                            if( maxPoint[i] < bbMax[i] ) then maxPoint[i] = bbMax[i]
                        
                        local bbMin = obj.min
                        
                        for i=1 to 3 do
                            if( minPoint[i] > bbMin[i] ) then minPoint[i] = bbMin[i]
                        
                    )
                )
            )
        )
        local bbox = #()
        append bbox minPoint
        append bbox maxPoint

        return bbox
    ),
    function GetFlags flags obj=
    (
        if ( getUserProp obj "BILLBOARD" == true ) then flags += 0x8
        if ( getUserProp obj "BILLBOARD-LOCK-X" == true ) then flags += 0x10
        if ( getUserProp obj "BILLBOARD-LOCK-Y" == true ) then flags += 0x20
        if ( getUserProp obj "BILLBOARD-LOCK-Z" == true ) then flags += 0x40
        
        return flags
    ),
    function GetKGTR obj =
    (

        struct anim1000   ( Size = 16, nbrKeys, Type = "KGTR", LineType=1, glbsId = -1, AnimBlock = #() )  
        struct KeyValuePair ( Key, Val )

        local cntrl = obj.pos.controller
        
        local classOfController = classof cntrl
        local lineType = 1
        if ( classOfController == Position_XYZ )     then lineType = 0x1
        if ( classOfController == linear_position )  then lineType = 0x1
        if ( classOfController == TCB_position )     then lineType = 0x2
        if ( classOfController == bezier_position )  then lineType = 0x3
        
        
        local pvt = at time 0f in coordsys parent obj.pos
        local kgtr = anim1000 LineType:lineType
            
        kgtr.nbrKeys = numkeys cntrl
        kgtr.size += kgtr.nbrKeys * 16 --> framenbr, position
        
        for k in cntrl.keys do
        (
            local t = k.time as integer / TicksPerFrame
            
            local val = at time k.time in coordsys parent obj.pos
            val = val - pvt
            
            append kgtr.AnimBlock ( KeyValuePair Key:t Val:val )
        )
        return kgtr
    ),
    function GetKGRT obj =
    (
        struct anim1000   ( Size = 16, nbrKeys, Type = "KGRT", LineType=1, glbsId = -1, AnimBlock = #() )  
        struct KeyValuePair ( Key, Val )

        local ctrl = obj.rotation.controller
        local classOfController = classof cntrl
        local lineType = 1
        if ( classOfController == Euler_XYZ )        then lineType = 0x1
        if ( classOfController == linear_Rotation )  then lineType = 0x1
        if ( classOfController == TCB_Rotation )     then lineType = 0x2
        if ( classOfController == bezier_Rotation )  then lineType = 0x3
        
        local kgrt =  anim1000 LineType:lineType
        
        local rot = inverse obj.rotation
        local parentRot = quat 0 0 0 1
        
        if obj.parent != undefined then parentRot = inverse obj.parent.rotation
        
        kgrt.nbrKeys = numkeys ctrl
        kgrt.size += kgrt.nbrKeys * 20
         
        for key in ctrl.keys do
        (
            local t = key.time
            
            local val = undefined
            at time t
                val = obj.rotation * rot

            if ( obj.parent != undefined ) then
                at time t 
                    val = val / ( obj.parent.rotation * parentRot )
            
            append kgrt.AnimBlock ( KeyValuePair key:t val:val )
        )
        return kgrt
    ),
    function GetKGSC obj =
    (
        struct anim1000   ( Size = 16, nbrKeys, Type = "KGSC", LineType=1, glbsId = -1, AnimBlock = #() )  
        struct KeyValuePair ( Key, Val )

        local classOfController = classof obj.scale.controller
        local lineType = 1
        if ( classOfController == ScaleXYZ )      then lineType = 0x1
        if ( classOfController == linear_Scale )  then lineType = 0x1
        if ( classOfController == TCB_Scale )     then lineType = 0x2
        if ( classOfController == bezier_Scale )  then lineType = 0x1

        local kgsc =  anim1000 LineType:lineType
        
        kgsc.nbrKeys = numkeys obj.scale.controller
        kgsc.size += kgsc.nbrKeys * 16
           
        for k=1 to kgsc.nbrKeys do
        (
            local kv = KeyValuePair()
            kv.key =  ( getKeyTime obj.scale.controller k ) as integer / TicksPerFrame

            at time kv.key 
                kv.val = obj.scale

            append kgsc.AnimBlock kv
        )
        return kgsc
    ),
    function GetObjects mdx=
    (
        struct object1000 
            ( TotalSize = 0, ObjectType,  HeaderSize = 96, Id, parentId = -1, Name,  Flags, objRef, KGTR, KGRT, KGSC, geosetId = -1, geosetAnimationId = -1 )
     
        local allobjects = #() 
        local id = 0

        -- BONE
        for obj in objects do 
            if (classof obj == boneGeometry ) then
            (   
                local o = object1000 Id:id Name:obj.name ObjectType:#wc3BONE Flags:0x100 objRef:obj TotalSize:96

                o.flags = _parser.GetFlags o.flags obj
                
                id +=1
                append allObjects o
            )

        -- HELPERS
        for obj in objects do
            if (classof obj == Dummy or classof obj == SplineShape ) then
            (
                local o = object1000 Id:id Name:obj.name ObjectType:#wc3HELP Flags:0x00 objRef:obj TotalSize:96
                id +=1
                append allObjects o
            )
        
        -- ATCH
        for obj in objects do
            if (classof obj == WC3RefAttachment ) then 
            (
                local o = object1000 Id:id Name:obj.name ObjectType:#wc3ATCH Flags:0x800 objRef:obj TotalSize:364
                id +=1
                append allObjects o
            )
        
        -- EVTS
        for obj in objects do
            if (classof obj == WC3RefEvent ) then
            (
                if ( obj.keyList.count > 0 ) then 
                (
                    local o = object1000 Id:id Name:obj.name ObjectType:#wc3EVTS Flags:0x400 objRef:obj
                    id +=1
                    append allObjects o
                )
            )
            
        -- CLID
        for obj in objects do
            if ( getUserProp obj "COLLISION-OBJECT" != undefined and getUserProp obj "COLLISION-OBJECT" == true ) then
            (
                if ( classof obj == box or classof obj == sphere or classof obj == plane or classof obj == cylinder ) then
                (
                    local o = object1000 Id:id Name:obj.name ObjectType:#wc3CLID Flags:0x2000 objRef:obj
                    id +=1
                    append allObjects o
                )
            )

        -- CORN ?
        -- RIBB ?
        -- CAMS ?
        -- LITE ?
            
        /* build the hierarchy of objects */
        for x=1 to allobjects.count do
        (
            if ( allobjects[x].objRef.parent != undefined ) then
            (
                for i=1 to allObjects.count do
                (
                    if allObjects[i].name == allObjects[x].objRef.parent.name then
                    (
                        allObjects[x].ParentId = allObjects[i].Id
                        exit
                    )
                )
                
            )
        )
        
        /* get the animations of these objects */
        for obj in allObjects do
        (
            local theGlbs = undefined
            local glbsId = -1
            local type = undefined
            if ( obj.objectType == #wc3Bone ) then type = "Bone"
            if ( obj.objectType == #wc3HELP ) then type = "Dummy"
            
 
            obj.KGTR = _parser.GetKGTR obj.objRef --> translation
            obj.KGRT = _parser.GetKGRT obj.objRef --> rotation
            obj.KGSC = _parser.GetKGSC obj.objRef --> scale
            
            if obj.KGTR.nbrKeys > 0 then 
            (
                obj.TotalSize += obj.KGTR.Size
                obj.KGTR.glbsId = glbsId
            )
            if obj.KGRT.nbrKeys > 0 then 
            (
                obj.TotalSize += obj.KGRT.Size
                obj.KGRT.glbsId = glbsId
            )
            if obj.KGSC.nbrKeys > 0 then 
            (
                obj.TotalSize += obj.KGSC.Size
                obj.KGSC.glbsId = glbsId
            )
        )
        
        mdx.allObjects = allObjects
        if DEBUG_MODE then for o in mdx.allobjects do format "%\n" o
    ),
    function GetSEQS mdx=
    (
        struct WC3AnimSequence ( Name, StartFrame, EndFrame, MovementSpeed=0.0, NoLoop=0, Rarity=0, Priority=0, Default=0, BBox )
        
        local size = 132
        local seqs = #()
        local wc3startFrame = 0
        local wc3EndFrame = 0
        
        if( numNoteTracks rootNode > 0 ) then 
        (
            local track = getNoteTrack rootNode 1
            local keys = track.Keys
            
            for i=1 to keys.count by 2 do
            (
                local note = keys[i].value
                local parts = filterstring note "\r\n"
                local s = WC3AnimSequence()
                
                s.name = parts[1]
                if ( DEBUG_MODE ) then  format "Animation Sequence name: %\n" s.name
                local StartFrame = (getnotekeytime track i)  as integer / TicksPerFrame
                local EndFrame = (getnotekeytime track (i+1)) as integer / TicksPerFrame
            
                s.BBox = _parser.GetMODLBoundingBoxBetweenFrames startFrame endFrame
                s.StartFrame =  startFrame * 1000 / 30 --wc3startFrame
                s.EndFrame =  EndFrame * 1000 / 30 -- wc3EndFrame

                s.Default = 0
                    
                for i=2 to parts.count do
                (
                    local split = filterString parts[i] " = "
                    local key = split[1]
                    local value = split[2]
                    
                    --if ( WC3_DEBUG ) then format " -  %: '%' \n" key value
                    
                    if ( key == "rarity" ) then s.rarity = (value  as float ) / 100.0
                    if ( key == "moveSpeed" ) then s.movementSpeed = value as float
                    if ( key == "nonLoop" ) then 
                    (
                        s.noLoop = value as float
                        if ( value == "true" ) then s.noLoop = 1
                        if ( value == "false" ) then s.noLoop = 0
                        
                    )       
                    if ( key == "defaultPriority" ) then s.Priority = value as float

                )
                
                append seqs s
            )
        )
        else
        (
            local startFrame = 1000 / 30
            local endFrame = 50 * 1000 / 30
            local seq = WC3AnimSequence Name:"Stand 1" StartFrame:startFrame EndFrame:endFrame
            
            seq.BBox = _parser.GetMODLBoundingBoxBetweenFrames 10 60
            
            append seqs seq
        )
        
        mdx.seqs = seqs
        if ( DEBUG_MODE ) then for o in mdx.seqs do format " %\n" o
    ),
    function GetMTLS mdx= 
    (
        struct mtls1000 ( materialRef, txanId ) 
        local uniqueMatList = #()
        
        for obj in objects do
        (
            if ( (classof obj != BoneGeometry ) and ( obj.material != undefined ) and ( classof obj.material == WC3RefMaterial ) ) then 
                appendIfUnique uniqueMatList obj.material
            
        )
        local matList = #()
        for um in uniqueMatList do
            append matList ( mtls1000 materialRef:um txanId:-1 )
        
        if DEBUG_MODE then for m in matList do format "%\n" m
        mdx.mtls = matList
    ),
    function GetTEXS mdx=
    (
        function GetFileName map=
        (
            local fileName = ""
            if map != undefined then (
                local fileName = filenameFromPath map.filename
                local fileNameOnly = getfileNameFile map.filename
                if fileNameOnly == "" then fileName = ""
                    
                if fileNameOnly == "Black32" then fileName = "Textures/Black32.blp"
                if fileNameOnly == "EnvironmentMap" then fileName = "ReplaceableTextures/EnvironmentMap.blp"
                
            )
            
            return fileName
        )
        struct texs1000 ( replacableId = 0, path= "", flags = 3 )
        local texs = #()
        
        for mat in mdx.MTLS do
        (
            appendIfUnique texs ( GetFileName mat.MaterialRef.diffuse_map )
            appendIfUnique texs ( GetFileName mat.MaterialRef.normal_map )
            appendIfUnique texs ( GetFileName mat.MaterialRef.orm_map )
            appendIfUnique texs ( GetFileName mat.MaterialRef.emissive_map )
            appendIfUnique texs "" -- required for team color --> put it here so it makes more sense
            appendIfUnique texs ( GetFileName mat.MaterialRef.reflection_map )
        )
        
        mdx.TEXS = #()
        for tex in texs do
        (
            local t = texs1000 path:tex
            if tex == "" then t.replacableId = 1
            append mdx.TEXS t
        )
        
        if DEBUG_MODE then  for t in mdx.TEXS do format "%\n" t
        
    ),
    function GetGEOS mdx=
    (
        struct geo1000 
            (   meshRef, size, vrtx = #(), nrms = #(), ptyp, pcnt, pvtx = #(), gndx = #() , mtgc = #(), mats, uvas, uvbs = #(), skin = #(), tang =#(), 
                bones = #(),  
                uniqueBoneIds = #() --> the list of bones required for this whole mesh
            )
        struct mats1000 ( LOD_Id = 0, nbrItems, name, matrices = #(), materialId, sectionGroupId, sectionGroupType, Bounding = #(), nbrFloats, floats = #() )
            
        /* get the mesh references that can be exported */
        local geos = #()
        local mtls =  mdx.mtls
            
        for obj in objects do
            if ( classof obj == editable_mesh and classof obj.material == WC3RefMaterial and obj.ishidden == false) then
                append geos ( geo1000 meshRef:obj )
        
        /* for each mesh in this list of meshed do */
        for geo in geos do
        (
            format "Reading data for %\n" geo.meshRef.name
            local theMesh = geo.meshRef
            local original_vertices = #()
            local original_normals  = #()
            local tangents = _parser.CalculateTangents theMesh
            
            local mesh_weights  = _parser.GetWeights theMesh mdx

            /* because a vertex can have multiple vertex coordinates keep track of them */
            for v=1 to theMesh.numVerts do
            (
                original_vertices[v] = getVert theMesh v
                original_normals[v]  = getNormal theMesh v
            )

            local tvVertices = #()
            local faces = #()
            for i=1 to theMesh.numFaces do
            (
                local f = getFace theMesh i
                local u = getTvFace theMesh i

                faces[i] = u
                tvVertices[u.x] = f.x
                tvVertices[u.y] = f.y
                tvVertices[u.z] = f.z
            )

            -- if there are isolated vertices, these will show up in the tvVertices as undefined -> fix this
            for i=1 to tvVertices.count do
            (
                if (tvVertices[i] == undefined ) then tvVertices[i] = i as float
            )
            
            local vertices = #()
            local normals = #()
            local uvs = #()
            
            for i=1 to tvVertices.count do
            (
                local uv = getTvert theMesh i
                
                if WC3REF_INVERT_UVW then 
                    uvs[i] = [uv.x, 1.0 - uv.y]
                else
                    uvs[i] = [uv.x, uv.y]
                
                vertices[i] = original_vertices[tvVertices[i]]
                normals[i]  = original_normals[tvVertices[i]]
            )
        
            geo.Size = 4 --> start initial size
            
            -- VRTX
            geo.Size += 8
            geo.vrtx = vertices --> vector 3
            geo.Size += vertices.count * 12
            
            -- NRMS
            geo.Size += 8
            geo.nrms = normals --> vector 3
            geo.Size += normals.count * 12
            
            -- PTYP --> type = triangle
            geo.Size += 12
            geo.PTYP = 4
            
            -- PCNT
            geo.Size += 12
            geo.pcnt = theMesh.numFaces * 3 --> number of corners or indices in the group
            
            -- PVTX
            geo.Size += 8
            for f=1 to faces.count do
            (
                local face = faces[f]
                append geo.pvtx [face.x - 1, face.y - 1, face.z - 1]
            )
            geo.Size += theMesh.numFaces * 6
            
            -- GNDX
            geo.Size += 8
            
            -- MATS
            geo.Size += 8
            geo.mats = mats1000 name:theMesh.Name
            geo.mats.matrices = mesh_weights.matrices
            geo.Size += geo.mats.matrices.count * 4
            
            local theMaterial = undefined 
            for x=1 to mtls.count do
            (
                if ( theMesh.material.name == mtls[x].materialRef.name ) then 
                (
                    geo.mats.materialId = x - 1
                    theMaterial = mtls[x].materialRef
                    exit
                )
            )
            geo.Size += 4 --> texture ID
            
            geo.mats.LOD_Id = _parser.GetLODId theMesh
            geo.Size += 4 --> LOD ID
            
            geo.mats.sectionGroupId = 0 --> always 0
            geo.mats.sectionGroupType = 0 --> if this would be an unselectable mesh, it should be 4
            geo.Size += 8 --> section group id, section group type

            geo.Size += 80 --> name

            geo.Size += 7 * 4
            geo.Size += 4 --> 0

            -- TANG
            geo.Size += 8
            geo.TANG = tangents --> vector 4
            geo.Size += tangents.count * 16
            
            -- SKIN
            geo.Size += 8
            geo.SKIN = mesh_weights.vertex_weight_list
            geo.Size += geo.SKIN.count * 8 --> 8 bytes
            
             -- UVAS / UVBS
            geo.Size += 8

            geo.uvas = 1 --help.GetNumUVMaps m
            for u=1 to geo.uvas do
            (
                geo.Size += 8
                geo.uvbs = uvs
                geo.Size += uvs.count * 8
            )
            -- MTGC
            geo.Size += 8
            geo.MTGC = geo.mats.matrices
            geo.Size += geo.MTGC.count * 4
        )
        
        mdx.geos = geos
        if DEBUG_MODE then for g in mdx.geos do format "%\n" g
    ),
    function GetGEOA mdx=
    (
        mdx.geoa = #()
        struct geoa1000 ( size, opacity, geoId, color, type, KGAO)
        struct anim1000 ( numPts, LineType = 0, glbsId = -1, KG = #() )
        struct kg1000   ( Time, Point = 0.0, inTan, outTan, LineType = 0 )
    
        local seqs_frames = #()
        append seqs_frames 0
        for s in mdx.SEQS do append seqs_frames ( _parser.RoundToFrame s.startframe )
        
        for g=1 to mdx.geos.count do
        (
            local geoa = geoa1000 size:28 opacity:1.0 color:[1.0,1.0,1.0] type:0 geoId:(g - 1)
            append mdx.geoa geoa
            local theMesh = mdx.geos[g].meshRef
            local visController = GetVisController theMesh
            local frames = undefined
            if (visController != undefined and classof visController == On_Off ) then 
            (
                frames = #()
                geoa.size += 16 --> KGAO, nbr of points, linetype, glbsId
                
                for key in visController.keys do append frames ( key.time as integer / TicksPerFrame )
                
                for f in seqs_frames do
                    appendIfUnique frames f
                
                frames = sort frames
                
                geoa.KGAO = anim1000 numPts:frames.count

                geoa.size += geoa.KGAO.numPts * 8
                
                for f in frames do
                (
                    local kg = kg1000()
                    at time f
                    (
                        kg.Time = f * 1000 / 30
                        if theMesh.visibility then kg.Point = 1.0
                    )
                    append geoa.KGAO.KG kg
                )
                
                if DEBUG_MODE then format "%\n" geoa
                
            )
        )
        
        
    ),
    function GetFAFX mdx=
    (
        -- only one can exist
        struct WC3Ref_FAFX ( Name = "Node", ExternalFileName, objRef, size )
        for obj in objects do
            if ( classof obj == WC3RefFaceFX ) then (
                mdx.FAFX = WC3Ref_FAFX objRef:obj TotalSize:340 ExternalFileName:obj.fileName
                exit
            )
    )
)