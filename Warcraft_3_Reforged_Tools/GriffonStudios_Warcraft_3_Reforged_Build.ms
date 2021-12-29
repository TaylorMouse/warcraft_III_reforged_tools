/*
    .DESCRIPTION
    | Set of build methods for creating stuff in max for Warcraft III Reforged Tools
    | Written by Taylor Mouse
    
    .DATE
    | 18.12.2021
    
    .RELEASENOTES
    | 0.1 - INIT
    
*/

fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Event.ms"
fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Attachment.ms"
fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Popcorn.ms"
fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_FaceFX.ms"
fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Ribbon.ms"
fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Emitter.ms"
fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Material.ms"

struct Warcraft_3_Ref_Build
(
    function GetAssetFolder mdx=
    (
        local fullPath = getFilenamePath mdx.fileName
        local assetFolder  = fullPath
        local assetsPos = findString fullPath @"\Assets\"
        if ( assetsPos != undefined ) then (
            local pos = assetsPos + (@"\Assets\").count - 1
            assetFolder = (substring fullPath 1 pos )  
        )   
        assetFolder
    ),
    function ApplyUserProperties flags obj=
    (
        if ( bit.and flags 0x0008 > 0 ) then setUserProp obj "BILLBOARD" true
        if ( bit.and flags 0x0010 > 0 ) then setUserProp obj "BILLBOARD-LOCK-X" true
        if ( bit.and flags 0x0020 > 0 ) then setUserProp obj "BILLBOARD-LOCK-Y" true
        if ( bit.and flags 0x0040 > 0 ) then setUserProp obj "BILLBOARD-LOCK-Z" true
        if ( bit.and flags 0x2000 > 0 ) then setUserProp obj "COLLISION-OBJECT" true
    ),
    function SortTrack dummy_track=
    (
        
        for t in dummy_track do
        for i=2 to dummy_track.count do
        (
            local tmp = dummy_track[i-1]
            if tmp.time > dummy_track[i].time then
            (
                dummy_track[i-1] = dummy_track[i]
                dummy_track[i] = tmp
            )
            
        )
        return dummy_track
    ),
    function CreateMTLS mdx=
    (
        if ( mdx.mtls == undefined ) then return undefined
        
        format "Building Materials\n"
        
        local mtls = mdx.mtls
        local texs = mdx.texs
        local modlName = mdx.modl.name
        local geos = mdx.geos
        local assetFolder = _build.GetAssetFolder mdx
        
        if DEBUG_MODE then format "Asset folder: %\n" assetFolder
        
        for m=1 to mtls.count do
        (
            local mtl = mtls[m]
            local possibleName = modlName 
            
            for geo in geos where geo.MATS.LOD_Id == 0 and geo.MATS.MTLS_Id == m and (findstring geo.MATS.name ":") != undefined do
            (
                local colonparts = filterString geo.MATS.name ":"
                local parts = filterString colonparts[colonparts.count] "_"
                possibleName = modlName + "_" + parts[1]
            )
            local mat = WC3RefMaterial()
            
            mat.Name = "MAT_" + possibleName + "_" + (m as string )
            format "Building material: %\n" mat.Name
            
            if (mtl.Layers.count > 0) then mat.filtermode = mtl.Layers[1].filterMode
            
            for l=1 to mtl.layers.count do
            (
                local layer = mtl.layers[l]
                if DEBUG_MODE then format "Building layer %\n" layer
                    
                local textureId = layer.TextureId
                local tex = texs[textureId]
                local textureFile = assetFolder + tex.path + tex.fileNameOnly + ".dds"
                
                if DEBUG_MODE then format "Building tex %\n" tex.fileNameOnly
                
                case of
                (
                    ( bit.and layer.ShadingFlags 0x1 > 0 ): ( mat.unlit = true )
                    ( bit.and layer.ShadingFlags 0x2 > 0 ): ( mat.envmap = true )
                    ( bit.and layer.ShadingFlags 0x4 > 0 ): ( mat.wrapwidth = true )
                    ( bit.and layer.ShadingFlags 0x8 > 0 ): ( mat.wrapheight = true )
                    ( bit.and layer.ShadingFlags 0x10 > 0 ): ( mat.twosided = true )
                    ( bit.and layer.ShadingFlags 0x20 > 0 ): ( mat.nofog = true )
                    ( bit.and layer.ShadingFlags 0x40 > 0 ): ( mat.nodepthtest = true )
                    ( bit.and layer.ShadingFlags 0x80 > 0 ): ( mat.nodepthset = true )
                )
                case l of 
                (
                    1:  ( 
                            if tex.fileNameOnly != "" then mat.diffuse_map = Bitmaptexture fileName:textureFile
                            if layer.FilterMode == 2 then 
                            (
                                mat.alphamask_map = Bitmaptexture fileName:textureFile
                                mat.alphamask_map.monooutput = 1
                            )
                        )
                    2:  ( if tex.fileNameOnly != "" then mat.normal_map = Bitmaptexture fileName:textureFile)
                    3:  ( if tex.fileNameOnly != "" then mat.orm_map = Bitmaptexture fileName:textureFile )
                    4:  (
                            mat.emissive_map = Bitmaptexture fileName:textureFile
                            mat.emissive_alpha = layer.alpha * 100.0
                            mat.emissive_multiplier = 1.0
                        )
                    5:  (
                            mat.replacableTexture = tex.ReplacableId
                            if tex.ReplacableId == 2 and tex.fileNameOnly != "" then mat.teamcolor_map = Bitmaptexture fileName:textureFile
                        )
                    6:  ( if tex.fileNameOnly != "" then mat.reflection_map = Bitmaptexture fileName:textureFile )
                )

                showTextureMap mat true
                
                /* animated alpha */
                if ( layer.KMTA != undefined ) then
                    for anim in layer.KMTA.KG do
                        with animate on 
                            at time ( anim.Time + 10 ) mat.material_alpha = anim.Point * 100.0

                /* animated emissive */
                if ( layer.KMTE != undefined ) then
                    for anim in layer.KMTE.KG do
                        with animate on 
                            at time ( anim.Time + 10 ) mat.emissive_multiplier = anim.Point * 100.0

                   
            )
            if( m < 25 ) then meditMaterials[m] = mat
            
            mtl.materialRef = mat
        )

    ),
    function CreateGEOS mdx=
    (
        local geos = mdx.geos
        if (geos == undefined ) then return undefined
        format "Building Meshes\n"
        local wireColor = color 128 128 128

        for geo in geos do
        (
            if DEBUG_MODE then format "Building % \n" geo.MATS.name
            
            if WC3Ref_IMPORT_ALL_LOD == false and geo.MATS.LOD_Id > 0 then continue
            
            local layer = _helper.CreateLayer ( "LOD - " + (geo.MATS.LOD_Id as string ))
            
            local v  = geo.VRTX
            local n  = geo.NRMS
            local f  = geo.PVTX
            local uv = geo.UVS[1]
            local theMesh = mesh vertices:v vnorms:n name:geo.MATS.name faces:f tverts:uv 

            theMesh.WireColor = wireColor
            
            buildTVFaces theMesh false
            for i = 1 to f.count do
            ( setTVFace theMesh i f[i] )

            layer.AddNode theMesh
            update theMesh
            geo.meshRef = theMesh
            
            if ( geo.MATS.LOD_Id != 0 ) then layer.on = false

        ) 
        
    ),
    function CreateBoneObj mdx b=
    (

        local boneLayer = _Helper.CreateLayer "Bones"
        local aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
        aBone.Name = b.name
        aBone.showLinks = true
        aBone.Width = 0.0
        aBone.Height = 0.0
        aBone.setBoneEnable false 0
        
        b.boneRef = aBone
        b.boneRef.pos = mdx.BPOS[b.id].translationpart
        boneLayer.AddNode aBone
        mdx.objs[b.Id] = aBone

    ),
    function CreateHelperObj mdx b=
    (
        local boneLayer = _Helper.CreateLayer "Helpers"
        local aBone = BoneSys.CreateBone [0,0,0] [0,0,0]  [0,0,1]
        aBone.Name = b.name
        aBone.showLinks = true
        aBone.Width = 0.05
        aBone.Height = 0.05
        aBone.setBoneEnable false 0
        
        b.helperRef = aBone
        b.helperRef.pos = mdx.BPOS[b.id].translationpart
        boneLayer.AddNode aBone
        mdx.objs[b.Id] = aBone

    ),
    function CreateBoneAndHelpers mdx=
    (
        mdx.objs = #()
        
        if mdx.bone != undefined then
        for b in mdx.bone do
        (
            _build.CreateBoneObj mdx b
        )
        if mdx.help != undefined then
        for h in mdx.help do
        (
            _build.CreateHelperObj mdx h
        )
        
    ),
    function CreateHELP mdx=
    (
        if mdx.help == undefined then return undefined
        format "Building Helpers\n"
        for h in mdx.help do
        (
            local d = h.helperRef
            
            if DEBUG_MODE then format "Building %\n" d.name
            
            _build.ApplyUserProperties h.flags d
            
            if( h.parentId > 0 ) then 
                d.parent = mdx.objs[h.parentId]
            
            -- lock the animation
            addNewKey d.controller 0
            for seq in mdx.seqs do
            (
                addnewkey d.scale.controller seq.startFrame
                addnewkey d.scale.controller seq.endFrame 
            )
            
            d.assumeSkinPose()

            if ( h.KGRT != undefined ) then 
            (
                
                local dr = dummy name:"DummyRotationController"
                dr.rotation.controller = d.rotation.controller
                local q0 = dr.transform
                if d.parent != undefined then q0 = d.parent.transform
                local prevTime = 0
                
                for anim in h.KGRT.KG do
                (
                    local t = anim.Time + 10
                    if h.KGRT.glbsId > 0 then t = anim.Time
                    local q = anim.Point
                    
                    if ( prevTime == t ) then continue else prevTime = t
                    with animate on 
                        at time t
                        (
                            in coordsys q0 dr.rotation = q
                        )
                )
                with animate on d.rotation.controller = copy dr.rotation.controller
                
                delete dr

            )
            if ( h.KGTR != undefined ) then
            (
                    local dp = dummy name:"DummyPositionController" 
                    dp.position.controller = d.position.controller
                    local p0 = dp.transform
                    local prevTime = 0

                    for anim in h.KGTR.KG do
                    (
                        local t = anim.Time + 10
                        if h.KGTR.glbsId > 0 then t = anim.Time
                        local p = anim.Point

                        if ( prevTime == t ) then continue else prevTime = t
                        with animate on 
                            at time t
                            (
                                in coordsys p0 dp.position = p 
                            )
                    )
                    with animate on d.position.controller = copy dp.position.controller
                    
                    delete dp
            )
            
            if ( h.KGSC != undefined ) then
            (
                
                local ds = dummy name:"DummyScaleController" 
                ds.scale.controller = d.scale.controller
                local p0 = ds.transform
                local prevTime = 0
                
                for anim in h.KGSC.KG do
                (
                    local t = anim.Time + 10
                    if h.KGSC.glbsId > 0 then t = anim.Time
                    local p = anim.Point
                        
                    if ( prevTime == t ) then continue else prevTime = t

                    with animate on 
                        at time t
                        (
                            in coordsys p0 
                                ds.scale = p 
                        )
                )
                with animate on d.scale.controller = copy ds.scale.controller
                
                delete ds
            )
        )
        
    ),
    function CreateBONE mdx=
    (
        if mdx.bone == undefined then return undefined
        format "Building Bones\n"
        
        local boneList = mdx.BONE
        local bpos = mdx.BPOS
        
        -- build the hierarchy
        for b in boneList do
            if ( b.ParentBoneId > 0 ) then b.boneRef.parent = mdx.objs[b.parentBoneId]

        for obj in boneList do
        (
            local b = obj.boneRef
            if DEBUG_MODE then format "Building %\n" b.name
            -- lock the animation
            addNewKey b.controller 0
            for seq in mdx.SEQS do
            (
                addnewkey b.scale.controller seq.startFrame
                addnewkey b.scale.controller seq.endFrame 
            )

            _build.ApplyUserProperties obj.flags b
            
            b.assumeSkinPose()

            -- Rotation
            if ( obj.KGRT != undefined ) then 
            (
                local dr = dummy name:"DummyRotationController"
                dr.rotation.controller = b.rotation.controller

                if ( obj.KGRT.lineType == 0x0 ) then  dr.rotation.controller = Euler_XYZ()
                if ( obj.KGRT.lineType == 0x1 ) then  dr.rotation.controller = linear_Rotation()
                if ( obj.KGRT.lineType == 0x2 ) then  dr.rotation.controller = TCB_Rotation()
                if ( obj.KGRT.lineType == 0x3 ) then  dr.rotation.controller = bezier_Rotation()

                local q0 = dr.transform
                if b.parent != undefined then q0 = b.parent.transform
                local prevTime = 0
                
                for anim in obj.KGRT.KG do
                (
                    local t = anim.Time + 10
                    if obj.KGRT.glbsId > 0 then t = anim.Time
                    
                    local q = anim.Point
                    
                    if ( prevTime == t ) then continue else prevTime = t --> prevent from applying multiple times the same rotation
                    with animate on 
                        at time t
                        (
                            in coordsys q0 dr.rotation = q
                        )
                )
                with animate on b.rotation.controller = copy dr.rotation.controller
                
                delete dr

            )
            
            -- Translation
            if ( obj.KGTR != undefined ) then
            (
                local dp = dummy name:"DummyPositionController" 
                dp.position.controller = b.position.controller
                
                if ( obj.KGTR.lineType == 0x0 ) then  dp.position.controller = position_XYZ()
                if ( obj.KGTR.lineType == 0x1 ) then  dp.position.controller = linear_position()
                if ( obj.KGTR.lineType == 0x2 ) then  dp.position.controller = TCB_position()
                if ( obj.KGTR.lineType == 0x3 ) then  dp.position.controller = bezier_position()
                
                local p0 = dp.transform
                local prevTime = 0

                for anim in obj.KGTR.KG do
                (
                    local t = anim.Time + 10
                    if obj.KGTR.glbsId > 0 then t = anim.Time
                        
                    local p = anim.Point

                    if ( prevTime == t ) then continue else prevTime = t
                    with animate on 
                        at time t
                        (
                            in coordsys p0 dp.position = p  
                        )
                )
                with animate on b.position.controller = copy dp.position.controller
                
                delete dp
            )
            
            -- Scale
            if ( obj.KGSC != undefined ) then
            (
                
                local ds = dummy name:"DummyScaleController" 
                ds.scale.controller = b.scale.controller
                
                if ( obj.KGSC.lineType == 0x0 ) then  ds.scale.controller = scaleXYZ()
                if ( obj.KGSC.lineType == 0x1 ) then  ds.scale.controller = linear_scale()
                if ( obj.KGSC.lineType == 0x2 ) then  ds.scale.controller = TCB_scale()
                if ( obj.KGSC.lineType == 0x3 ) then  ds.scale.controller = bezier_scale()
                
                local p0 = ds.transform
                local prevTime = 0
                
                for anim in obj.KGSC.KG do
                (
                    local t = anim.Time + 10
                    if obj.KGSC.glbsId > 0 then t = anim.Time
                        
                    local p = anim.Point
                        
                    if ( prevTime == t ) then continue else prevTime = t
                    with animate on 
                        at time t
                        (
                             in coordsys p0 
                                ds.scale = p 
                        )
                )
                with animate on b.scale.controller = copy ds.scale.controller
                
                delete ds
            )
            
        )
    ),
    function CreateSEQS mdx=
    (
        if mdx.seqs == undefined then return undefined
        format "Building Animation Sequences\n"
        local animTrack1 = undefined 
        local nNoteTracks = numNoteTracks rootNode
        if(  nNoteTracks > 0 ) then
        (
            for n=1 to nNoteTracks do 
                deleteNoteTrack rootNode (getNoteTrack rootNode 1)
        )
        if( numNoteTracks rootNode == 0 ) then
        (
            animTrack1 = notetrack "AnimTrack1"
            addNoteTrack rootNode animTrack1
        )
        local prevEndFrame = 0                       
        
        for t=1 to mdx.seqs.count do
        (
            local seq = mdx.seqs[t]
            local theAnimTrack = animTrack1 --> always pick first one

            local startNote = AddNewNoteKey theAnimTrack seq.startFrame
            local endNote = AddNewNoteKey theAnimTrack seq.endFrame
            
            local val = seq.name + "\r\n"
                  val += "rarity = " 	 + (seq.Rarity as string)    + "\r\n"
                  val += "moveSpeed = "  + (seq.MovementSpeed as string) + "\r\n"
                  val += "nonLoop = " 	 + (seq.Noloop as string)    + "\r\n"
                  val += "default_Anim = false\r\nsub_anim = false\r\ndefaultPriority = " + (seq.Priority as string)

           
            startNote.Value = val
            endNote.Value = val

            if DEBUG_MODE then 
                format "- Anim: % (%-%)\n" seq.name seq.startFrame seq.endFrame
			
        )
        
    ),
    function CreateEVTS mdx=
    (
        if mdx.evts == undefined then return undefined
        format "Building Events\n"
        local evts = mdx.evts
        
        if (evts == undefined ) then return undefined
        local layer = _helper.CreateLayer "Events"
        
        for evt in evts do
        (
            if DEBUG_MODE then format "Building %\n" evt.name
                
            local pnt = WC3RefEvent()
            
            pnt.Name = evt.name
            
            pnt.pos = mdx.BPOS[evt.id].translationpart
            
            if ( evt.parentId > 0 ) then 
                pnt.pos = mdx.BPOS[evt.parentId].translationpart
            
            for key in evt.KEVT do
                append pnt.keyList key
            
            evt.objRef = pnt
            layer.AddNode pnt
        )
        
    ),
    function CreateCLID mdx=
    (
        if mdx.clid == undefined then return undefined
        format "Building Collision Objects\n"
        local bpos = mdx.BPOS
        local layer = _helper.CreateLayer "Collision Objects"
        
        for cl in mdx.clid do
        (
            if DEBUG_MODE then format "Building %\n" cl.name
                
            local clObj = undefined
            
            -- CUBE
            if(cl.CollisionType == 0 ) then 
            (
                local w = distance [cl.StartPosition.X,0,0] [cl.EndPosition.X,0,0] 
                local l = distance [0,cl.StartPosition.Y,0] [0,cl.EndPosition.Y,0] 
                local h = distance [0,0, cl.StartPosition.Z] [0,0,cl.EndPosition.Z]
                clObj = Box pos:[0,0,0] width:w length:l height:h name:cl.name
            )
            
            -- PLANE
            if(cl.CollisionType == 1 ) then 
            (
                local w = distance [cl.startPosition.x,0,0] [cl.EndPosition.x,0,0] * -1
                local l = distance [0,cl.startPosition.y,0] [0,cl.EndPosition.y,0] * -1
                clObj = Plane length:l width:w name:cl.name pos:cl.startPosition
            )
            
            -- SPHERE
            if(cl.CollisionType == 2 ) then
            (
                clObj = Sphere radius:cl.Radius name:cl.name pos:cl.startPosition
            )
            
            -- Cylinder
            if(cl.CollisionType == 3 ) then
            (
                local height = distance [0, 0, cl.startPosition.z] [0, 0, cl.endPosition.z]
                clObj = Cylinder radius:cl.Radius name:cl.name pos:cl.startPosition height:height heightsegs:1 sides:12
            )

            if clObj == undefined then return undefined

            clObj.Transform = mdx.BPOS[cl.id]
            
            if cl.parentId > 0 then cl.parent = mdx.bone[cl.parentId].boneRef
            
            local mtrx = bpos[cl.id]
            
            if ( cl.KGRT != undefined ) then 
            (
                
                for anim in cl.KGRT.KG do
                (
                    local t = anim.time + 10
                    local q = anim.Point
                    
                    with animate on at time t in coordsys mtrx clObj.rotation = q
                )
            )
            
            if ( cl.KGTR != undefined ) then 
            (

                local prevTime = 0
                for anim in cl.KGTR.KG do
                (
                    local t = anim.time + 10
                    local p = anim.Point
                    
                    if ( prevTime == t ) then continue else prevTime = t
                    
                    with animate on at time t in coordsys mtrx clObj.pos = p
                )
                    
            )
            
            rotate clObj (angleaxis 180 [1,0,0])
            
            clObj.boxmode = on
            clObj.wirecolor = color 64 128 255
            clObj.renderable = off
            clObj.castShadows = off
            clObj.receiveshadows = off
            clObj.ApplyAtmospherics = off
            clObj.inheritVisibility = off
            clObj.primaryVisibility = off
            clObj.secondaryVisibility = off
            setUserProp clObj "COLLISION-OBJECT" true
            freeze clObj
            layer.addnode clObj
        )
    ),
    function CreateATCH mdx=
    (
        if mdx.atch == undefined then return undefined
        format "Building Attachments\n"
        local layer = _helper.CreateLayer "Attachments"
        sliderTime = 0f
        
        for a in mdx.atch do
        (
            if DEBUG_MODE then format "Building %\n" a.name
            local pnt = WC3RefAttachment name:a.name
            pnt.pos = mdx.BPOS[a.id].translationpart
            layer.AddNode pnt
            
            if ( a.ParentId > 0 ) then
                pnt.parent = mdx.objs[a.ParentId]

        )
        
    ),
    function CreateCAMS mdx=
    (
        local cams = mdx.cams
        
        if (cams == undefined ) then return undefined
        format "Building Cameras \n"
        
        local layer = _helper.CreateLayer "Cameras"
        for i=1 to cams.count do
        (   
            local c = cams[i]
            if DEBUG_MODE then format "Building %\n" c.name
            local targetName = c.name + ".Target." + ( i as string)
            local camName = c.name + ( i as string)
            local target = Targetobject pos:c.targetPos name:targetName wirecolor:red 
            local cam = Targetcamera fov:c.FOV farclip:c.farClip nearclip:c.nearClip pos:c.pos name:camName wirecolor:yellow target:target
            layer.AddNode target
            layer.AddNode cam
            local prevPos = c.pos
            local prevTPos = c.targetPos
            
            if( c.KCTR != undefined) then 
                for anim in c.KCTR.KG do
                (
                    with animate on at time ( anim.Time + 10 ) 
                        cam.pos = prevPos + anim.Point

                )

            if( c.KTTR != undefined ) then 
                for anim in c.KTTR.KG do
                (
                    with animate on at time ( anim.Time + 10 ) 
                        target.pos = prevTPos + anim.Point
                )

            if( c.KCRL != undefined ) then 
                for anim in c.KCRL.KG do
                (
                    with animate on at time ( anim.Time + 10 ) 
                    (
                        target.rotation = anim.Point
                        cam.rotation = anim.point
                    )
                )
        )
    ),
    function CreateGEOA mdx=
    (
        local geoa = mdx.geoa
        local geos = mdx.geos
        
        if( geoa == undefined ) then return undefined 
        format "Building Mesh Alpha Animations \n"
        
        struct wc3_opacity_track ( time, point )
        
        for a in geoa do
        (
            local theMesh = geos[a.GeoId].meshRef
            if ( theMesh == undefined ) then continue
            local isVisibilityTrackRequired = false -- by default evertythng is 1
            
            if a.KGAO == undefined then continue
            
            for anim in a.KGAO.KG do
            (
                if ( anim.point == 0) then isVisibilityTrackRequired = true
            )
            
            if ( isVisibilityTrackRequired == true ) then
            (
                theMesh.Visibility = on
                theMesh.Visibility.controller = on_off()

                local opacity_tracks = #()
                
                append opacity_tracks (wc3_opacity_track time:0 point:a.opacity)
                
                --> set the visibility per sequence back to its original state
                for seq in mdx.seqs do
                    append opacity_tracks (wc3_opacity_track time:(seq.StartFrame - 2) point:a.opacity)
                
                for anim in a.KGAO.KG do
                    append opacity_tracks ( wc3_opacity_track time:(anim.Time + 10) point:anim.point )
                
                -- sort the opacity_tracks by time
                opacity_tracks = _build.SortTrack opacity_tracks
                
                for anim in opacity_tracks do 
                    with animate on at time anim.Time
                        if (anim.point == 1) then 
                            theMesh.Visibility = on
                        else
                            theMesh.Visibility = off
            )
            
        )  
        
    ),
    function CreateLITE mdx=
    (
        local lites = mdx.lite
        local pivots = mdx.pivt
        format "Building Lights \n"
        if ( lites == undefined ) then return undefined
        
        for lite in lites do
        (
            /*
                0x0: Omni
                0x1: Directional
                0x2: Ambient
                0x3: Default
            */
            local l = undefined
            
            local layer = _helper.CreateLayer "Lights"
            
            if ( lite.Type == 0 ) then 
                l = Omnilight name:lite.name rgb:lite.rgbColor multiplier:lite.rgbIntensity farAttenStart:lite.FarAttenStart farAttenEnd:lite.FarAttenEnd

            if ( lite.Type == 1 ) then 
                l = DirectionalLight name:lite.name rgb:lite.rgbColor multiplier:lite.rgbIntensity farAttenStart:lite.FarAttenStart farAttenEnd:lite.FarAttenEnd
            
            if ( lite.Type == 2 ) then
            (
                ambientcolor = lite.ambColor
                lightLevel = lite.ambIntensity
            )

            if ( lite.Type > 2 ) then 
                l = Omnilight name:lite.name rgb:lite.rgbColor multiplier:lite.rgbIntensity farAttenStart:lite.FarAttenStart farAttenEnd:lite.FarAttenEnd
            
            if ( l != undefined ) then 
            (
                layer.addnode l
                
                if( lite.KGRT != undefined ) then 
                    for anim in lite.KGRT.KG do
                    (
                        with animate on at time ( anim.Time + 10 ) in coordsys world
                            l.rotation = anim.Point
                    )
                
                for p in pivots do
                    if( p.Id == lite.Id ) then 
                    (
                        l.pos = p.translationPart
                        exit
                    )
                local prevPos = l.pos  
                if( lite.KGTR != undefined) then 
                    for anim in lite.KGTR.KG do
                    (
                        with animate on at time ( anim.Time + 10 ) 
                            l.pos =  prevPos + anim.Point

                    )

                if( lite.KGSC != undefined ) then 
                    for anim in lite.KGSC.KG do
                    (
                        with animate on at time ( anim.Time + 10 ) 
                            l.scale = anim.Point
                    )

            )
        )
    ),
    function CreateCORN mdx=
    (
        local corn = mdx.corn
        local boneList = mdx.bone
        local assetFolder = _build.GetAssetFolder mdx
        format "Building PopCorn FX \n"
        if( corn == undefined ) then return undefined
        
        local layer = _helper.CreateLayer "Popcorn"
        
        for c in corn do
        (
            if DEBUG_MODE then format "Building %\n" c.name
            local cObj = WC3RefPopCorn()
            layer.addnode cObj
            cObj.Name = c.Name
            
            local path = getFilenamePath c.FileName
            local fileNameOnly = getfilenamefile c.fileName
            
            cObj.FileName = assetFolder + path + fileNameOnly + ".pkb"
            
            for prop in c.Properties do
            (
                local parts = filterString prop "="
                
                if (parts[1] == "Always" and parts[2] == "On" )  then cObj.Always = true
                if (parts[1] == "Death" and parts[2] == "On" )  then cObj.Death = true
                if (parts[1] == "Dissipate" and parts[2] == "On" )  then cObj.Dissipate = true
                if (parts[1] == "Portrait" and parts[2] == "On" )  then cObj.Portrait = true
            )
    
            if ( c.ParentId > 0 ) then
                if ( boneList != undefined) then
                    if ( boneList[c.ParentId].boneRef != undefined ) then cObj.Parent = boneList[c.ParentId].boneRef

            if( c.KGRT != undefined) then 
                for anim in c.KGRT.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        cObj.rotation = anim.Point

            if( c.KGTR != undefined) then 
                for anim in c.KGTR.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        cObj.pos = anim.Point
            
            if( c.KGSC != undefined) then 
                for anim in c.KGSC.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        cObj.scale = anim.Point
            
            if( c.KPPV != undefined) then
            (
                local isVisibilityTrackRequired = false -- by default evertythng is 1
                
                for anim in c.KPPV.KG do
                    if ( anim.point == 0) then isVisibilityTrackRequired = true

                if ( isVisibilityTrackRequired == true ) then
                (
                    cObj.Visibility = on
                    cObj.Visibility.controller = on_off()

                    for anim in c.KPPV.KG do 
                        with animate on at time ( anim.Time + 10 )
                            if (anim.point == 1) then 
                                cObj.Visibility = on
                            else
                                cObj.Visibility = off
                ) 
            )
        )
        
        
    ),
    function CreateFAFX mdx=
    (
        local fafx = mdx.fafx
        format "Building Facial Effects\n"
        if ( fafx == undefined ) then return undefined
        local layer = _helper.CreateLayer "Facial Effects"
        local assetFolder = _build.GetAssetFolder mdx
        for f=1 to fafx.Count do
        (
            local fafxObj = WC3RefFaceFX()   
            
            fafxObj.Name = fafx[f].Name
            fafxObj.fileName = assetFolder + fafx[f].ExternalFileName
            
            layer.AddNode fafxObj
        )
        
        
    ),
    function CreateRIBB mdx=
    (
        
        local ribb = mdx.ribb
        local boneList = mdx.bone
        local mtls = mdx.mtls
        
        if (ribb == undefined ) then return undefined
        
        format "Building Ribbons\n"
        
        local layer = _Helper.CreateLayer "Ribbons"
        
        for r in ribb do
        (
            if DEBUG_MODE then format "Building %\n" r.name
            local ribbon = WC3RefRibbon()
            
            layer.addNode ribbon
            
            ribbon.name = r.name
            if ( boneList != undefined ) then 
            (
                if ( r.parentId > 0 ) then (
                    ribbon.transform = boneList[r.parentId].boneRef.transform
                    ribbon.parent = boneList[r.parentId].boneref
                )
            )
            ribbon.staticHeightAbove = r.above
            ribbon.staticHeightBelow = r.below
            ribbon.staticAlpha = r.vAlpha
            ribbon.staticColor = r.vColor
            ribbon.lifeSpan = r.edgesLife
            ribbon.emissionRate = r.edgesSec
            ribbon.flipbookRows = r.flipbookRows
            ribbon.flipbookColumns = r.flipbookCols
            ribbon.flipbookSlot = r.flipBookSlot
            ribbon.gravity = r.gravity
            if ( mtls != undefined) then ribbon.mtlsId = mtls[r.mtlsId].materialRef
            
            -- animation time !
            -- heightAbove
            if ( r.KRHA != undefined ) then
            for anim in r.KRHA.KG do
            (
                local t = anim.time + 10
                local p = anim.point
                with animate on at time t ribbon.staticHeightAbove = p
            )
            -- heightBelow
            if ( r.KRHB != undefined ) then
            for anim in r.KRHB.KG do
            (
                local t = anim.time + 10
                local p = anim.point
                with animate on at time t ribbon.staticHeightBelow = p
            )
            -- alpha
            if ( r.KRAL != undefined ) then
            for anim in r.KRAL.KG do
            (
                local t = anim.time + 10
                local p = anim.point
                with animate on at time t ribbon.staticAlpha = p
            )
            -- color
            if ( r.KRCO != undefined ) then
            for anim in r.KRCO.KG do
            (
                local t = anim.time + 10
                local p = anim.point
                with animate on at time t ribbon.staticColor = p
            )
            -- texture
            if ( r.KRTX != undefined ) then
            for anim in r.KRTX.KG do
            (
                local t = anim.time + 10
                local p = anim.point + 1
                with animate on at time t ribbon.mtlsId = mtls[p].materialRef
            )
            -- visibility
            if ( r.KRVS != undefined ) then
            (
                local isVisibilityTrackRequired = false
                for anim in r.KRVS.KG do
                (
                    if ( anim.point == 0) then isVisibilityTrackRequired = true
                )
                if ( isVisibilityTrackRequired == true ) then
                (
                    ribbon.Visibility = on
                    ribbon.Visibility.controller = on_off()

                    for anim in r.KRVS.KG do 
                        with animate on at time ( anim.Time + 10 )
                            if (anim.point == 1) then 
                                ribbon.Visibility = on
                            else
                                ribbon.Visibility = off
                )
            )
            
            
        )
    ),
    function ApplySKIN mdx=
    (
        local geos = mdx.geos
        local boneList = mdx.bone
        if ( geos == undefined or boneList == undefined ) then return undefined
        
        try(
            for geo in geos do
            (
                local obj = geo.meshRef
                if ( obj == undefined ) then continue

                format "Applying Skin modifier to %\n" obj.name

                -- clean up the bonesIds and vertex weights
                for v=1 to geo.VRTX.count do
                (
                    local boneIds = geo.SKIN[v].BoneIds
                    local weights = geo.SKIN[v].Weights
                    
                    for i=1 to 4 do
                        if weights[i] == 0.0 then boneIds[i] = 1

                    geo.SKIN[v].BoneIds = boneIds
                    geo.SKIN[v].Weights = weights
                )

                
                
                local mshSkin = skin name:"Skin"
                mshSkin.bone_Limit = 4
                max modify mode
                addmodifier obj mshSkin

                modPanel.setCurrentObject mshSkin

                for i=1 to boneList.count do
                (
                    local b = boneList[i].boneRef
                    skinOps.addBone mshSkin b 0
                )

                update obj
                max views redraw

                for v=1 to geo.VRTX.count do
                (
                    skinOps.ReplaceVertexWeights mshSkin v geo.SKIN[v].BoneIds geo.SKIN[v].Weights
                )
                update obj
            )
        )
        catch()
        redrawViews()

    ),
    function AssignMTLS mdx=
    (
        format "Assigning material to the meshes\n"
        for geo in mdx.GEOS do
            if geo.meshRef != undefined then (
                try (
                    geo.meshRef.Material = mdx.MTLS[geo.MATS.MTLS_Id].materialRef
                ) 
                catch (
                    format "[ERROR] Unable assign the material to %!\n" geo.MATS.name
                )
            )
    ),
    function CreateTXAN mdx=
    (
        
    ),
    function CreatePRE2 mdx=
    (
        if( mdx.PRE2 == undefined ) then return undefined

        local particleEmitters = mdx.PRE2
        local boneList = mdx.BONE
        local textures = mdx.TEXS

        format "Building Particle Emitters \n"
        
        local layer = GriffonStudios_Helpers.CreateLayer "Emitters"
        
        for pe in particleEmitters do
        (
            local emitter = WC3RefEmitter()
            layer.addNode emitter
            
            emitter.name =  pe.name
            
            if ( boneList != undefined ) then 
            (
                if pe.ParentId > 0 then 
                (
                    emitter.transform = boneList[pe.ParentId].boneRef.transform
                    emitter.parent = boneList[pe.ParentId].boneRef
                )
            )
            if (pe.Flags != undefined ) then
            (
                emitter.DONT_INHERIT_TRANSLATION = _helper.IsUndefinedBoolean pe.Flags.DONT_INHERIT_TRANSLATION
                emitter.DONT_INHERIT_SCALING = _helper.IsUndefinedBoolean pe.Flags.DONT_INHERIT_SCALING
                emitter.DONT_INHERIT_ROTATION = _helper.IsUndefinedBoolean pe.Flags.DONT_INHERIT_ROTATION
                emitter.BILLBOARDED = _helper.IsUndefinedBoolean pe.Flags.BILLBOARDED
                emitter.BILLBOARD_LOCK_X = _helper.IsUndefinedBoolean pe.Flags.BILLBOARD_LOCK_X
                emitter.BILLBOARD_LOCK_Y = _helper.IsUndefinedBoolean pe.Flags.BILLBOARD_LOCK_Y
                emitter.BILLBOARD_LOCK_Z = _helper.IsUndefinedBoolean pe.Flags.BILLBOARD_LOCK_Z
                emitter.GENOBJECT_MDLBONESECTION = _helper.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLBONESECTION
                emitter.GENOBJECT_MDLLIGHTSECTION = _helper.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLLIGHTSECTION
                emitter.GENOBJECT_MDLEVENTSECTION = _helper.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLEVENTSECTION
                emitter.GENOBJECT_MDLATTACHMENTSECTION = _helper.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLATTACHMENTSECTION
                emitter.GENOBJECT_MDLPARTICLEEMITTER2 = _helper.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLPARTICLEEMITTER2
                emitter.GENOBJECT_MDLHITTESTSHAPE = _helper.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLHITTESTSHAPE
                emitter.GENOBJECT_MDLRIBBONEMITTER = _helper.IsUndefinedBoolean pe.Flags.GENOBJECT_MDLRIBBONEMITTER
                emitter.PROJECT = _helper.IsUndefinedBoolean pe.Flags.PROJECT
                emitter.UNSHADED = _helper.IsUndefinedBoolean pe.Flags.UNSHADED
                emitter.SORT_PRIMITIVES_FAR_Z = _helper.IsUndefinedBoolean pe.Flags.SORT_PRIMITIVES_FAR_Z
                emitter.LINE_EMITTER = _helper.IsUndefinedBoolean pe.Flags.LINE_EMITTER
                emitter.PARTICLE_UNFOGGED = _helper.IsUndefinedBoolean pe.Flags.PARTICLE_UNFOGGED
                emitter.PARTICLE_USE_MODEL_SPACE = _helper.IsUndefinedBoolean pe.Flags.PARTICLE_USE_MODEL_SPACE
                emitter.PARTICLE_INHERIT_SCALE = _helper.IsUndefinedBoolean pe.Flags.PARTICLE_INHERIT_SCALE
                emitter.PARTICLE_INSTANT_VELOCITY_LIN = _helper.IsUndefinedBoolean pe.Flags.PARTICLE_INSTANT_VELOCITY_LIN
                emitter.PARTICLE_0XKILL = _helper.IsUndefinedBoolean pe.Flags.PARTICLE_0XKILL
                emitter.PARTICLE_Z_VELOCITY_ONLY = _helper.IsUndefinedBoolean pe.Flags.PARTICLE_Z_VELOCITY_ONLY
                emitter.PARTICLE_TUMBLER = _helper.IsUndefinedBoolean pe.Flags.PARTICLE_TUMBLER
                emitter.PARTICLE_TAIL_GROWS = _helper.IsUndefinedBoolean pe.Flags.PARTICLE_TAIL_GROWS
                emitter.PARTICLE_EXTRUDE = _helper.IsUndefinedBoolean pe.Flags.PARTICLE_EXTRUDE
                emitter.PARTICLE_XYQUADS = _helper.IsUndefinedBoolean pe.Flags.PARTICLE_XYQUADS
                emitter.PARTICLE_PROJECT = _helper.IsUndefinedBoolean pe.Flags.PARTICLE_PROJECT
                emitter.PARTICLE_FOLLOW = _helper.IsUndefinedBoolean pe.Flags.PARTICLE_FOLLOW

            )
            emitter.speed = pe.speed  
            emitter.variation = pe.variation 
            emitter.coneAngle = pe.coneAngle / 2.0 
            emitter.gravity = pe.gravity 
            emitter.lifespan = pe.lifespan 
            emitter.emissionRate = pe.emissionrate 
            emitter.length = pe.length 
            emitter.width = pe.width  
            emitter.emitterType = pe.emitterType 
            emitter.rowCount = pe.rowCount 
            emitter.colCount = pe.colCount 
            emitter.particleType = pe.particleType + 1
            emitter.tailLength = pe.tailLength 
            emitter.midTime = pe.midTime 
            emitter.startColor  = pe.startColor 
            emitter.midColor  = pe.midColor 
            emitter.endColor  = pe.endColor 
            emitter.startAlpha  = pe.startAlpha 
            emitter.midAlpha  = pe.midAlpha 
            emitter.endAlpha  = pe.endAlpha 
            emitter.startSize  = pe.startSize 
            emitter.midSize  = pe.midSize 
            emitter.endSize  = pe.endSize 
            emitter.startLifespanUVAnim  = pe.startLifespanUVAnim 
            emitter.midLifespanUVAnim  = pe.midLifespanUVAnim 
            emitter.endLifespanUVAnim  = pe.endLifespanUVAnim 
            emitter.startDecayUVAnim  = pe.startDecayUVAnim 
            emitter.midDecayUVAnim  = pe.midDecayUVAnim 
            emitter.endDecayUVAnim  = pe.endDecayUVAnim 
            emitter.startTailUVAnim  = pe.startTailUVAnim 
            emitter.midTailUVAnim  = pe.midTailUVAnim 
            emitter.endTailUVAnim  = pe.endTailUVAnim 
            emitter.startTailDecayUVAnim = pe.startTailDecayUVAnim 
            emitter.midTailDecayUVAnim  = pe.midTailDecayUVAnim 
            emitter.endTailDecayUVAnim  = pe.endTailDecayUVAnim 
            emitter.blendMode  = pe.blendMode 
            emitter.priorityPlane  = pe.priorityPlane 
            emitter.replacableTextureId  = pe.replacableTextureId  + 1
            emitter.texture = textures[pe.TextureId + 1].path  + textures[pe.TextureId + 1].fileNameOnly + ".dds"


            if( pe.KP2E != undefined) then
                for anim in pe.KP2E do
                    with animate on at time ( anim.Time + 10 ) 
                        emitter.emissionRate = anim.Point

            if( pe.KGRT != undefined) then 
                for anim in pe.KGRT.KG do
                    with animate on at time ( anim.Time + 10 )  in coordsys parent 
                        emitter.rotation = anim.Point

            local prevPos = [0,0,0]
            if(emitter.parent != undefined ) then prevPos = emitter.parent.pos
            if( pe.KGTR != undefined) then 
                for anim in c.KGTR.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        emitter.pos = prevPos + anim.Point
            
            if( pe.KGSC != undefined) then 
                for anim in pe.KGSC.KG do
                    with animate on at time ( anim.Time + 10 ) 
                        emitter.scale = anim.Point
            
            if( pe.KP2V != undefined) then
            (
                local isVisibilityTrackRequired = false -- by default evertythng is 1
                
                for anim in pe.KP2V.KG do
                    if ( anim.point == 0) then isVisibilityTrackRequired = true

                if ( isVisibilityTrackRequired == true ) then
                (
                    emitter.Visibility = on
                    emitter.Visibility.controller = on_off()

                    for anim in pe.KP2V.KG do 
                        with animate on at time ( anim.Time + 10 )
                            if (anim.point == 1) then 
                                emitter.Visibility = on
                            else
                                emitter.Visibility = off
                ) 
            )



        )
    ),
    function Create mdx=
    (
        format "\n"
        --DEBUG_MODE = true
        CreateMTLS mdx
        CreateGEOS mdx
        CreateSEQS mdx
        CreateBoneAndHelpers mdx
        CreateHELP mdx
        CreateBONE mdx
        ApplySKIN mdx
        CreateEVTS mdx
        CreateCLID mdx
        CreateATCH mdx
        CreateCAMS mdx
        CreateGEOA mdx
        CreateLITE mdx
        CreateCORN mdx
        CreateFAFX mdx
        CreateRIBB mdx
        CreateTXAN mdx
        CreatePRE2 mdx
        AssignMTLS mdx
    )
    
)
