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

struct Warcraft_3_Ref_Build
(
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
    function CreateGEOS mdx=
    (
        local geos = mdx.geos
        if (geos == undefined ) then return undefined
        format "Building Meshes\n"
        local wireColor = color 128 128 128

        for geo in geos do
        (
            if DEBUG_MODE then format "Building % \n" geo.MATS.name
            
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
            
            if ( geo.MATS.LOD_Id == 0 and geo.MATS.id != 0 ) then hide theMesh

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
                local diameter = distance cl.startPosition cl.EndPosition
                local radius = diameter / 2.0 * 0.8
                clObj = Sphere radius:radius name:cl.name pos:cl.startPosition
            )
            
            -- PLANE
            if(cl.CollisionType == 1 ) then 
            (
                local x = distance [cl.startPosition.x,0,0] [cl.EndPosition.x,0,0]
                local y = distance [0,cl.startPosition.y,0] [0,cl.EndPosition.y,0]
                
                clObj = Plane length:x width:y name:cl.name pos:cl.startPosition
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

            clObj.pos = mdx.BPOS[cl.id].translationpart

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
            
            clObj.boxmode = true
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
            
            cObj.FileName = path + fileNameOnly + ".pkb"
            
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
 
        for f=1 to fafx.Count do
        (
            local fafxObj = WC3RefFaceFX()   
            
            fafxObj.Name = fafx[f].Name
            fafxObj.fileName = fafx[f].ExternalFileName
            
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
            local ribbon = undefined
            ribbon = WC3RefRibbon()
            
            layer.addNode ribbon
            
            ribbon.name = r.name
            if ( boneList != undefined ) then 
            (
                if ( r.ParentBoneId > 0 ) then (
                    ribbon.transform = boneList[r.parentBoneId].boneRef.transform
                    ribbon.parent = boneList[r.parentBoneId].boneref
                )
            )
            ribbon.staticHeightAbove = r.staticHeightAbove
            ribbon.staticHeightBelow = r.staticHeightBelow
            ribbon.staticAlpha = r.staticAlpha
            ribbon.staticColor = r.staticColor
            ribbon.lifeSpan = r.lifeSpan
            ribbon.emissionRate = r.emissionRate
            ribbon.flipbookRows = r.flipbookRows
            ribbon.flipbookColumns = r.flipbookColumns
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
                
                
                local msh = geo
                local obj = geo.meshRef

                format "Applying Skin modifier to %\n" obj.name
                
                if ( obj == undefined ) then continue
                
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
    function Create mdx=
    (
        format "\n"
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
    )
    
)
