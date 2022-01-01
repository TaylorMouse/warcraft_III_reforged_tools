/*
    .DESCRIPTION
    | Write stuff specifically for Warcraft III Reforged
    | Written by Taylor Mouse
    
    .DATE
    | (c)2015 - 2022
    
    .RELEASENOTES
    | 0.3 - Added exporter functions
    | 0.2 - Revisit
    | 0.1 - INIT
    
*/
struct Warcraft_3_Ref_Write
(
    function WriteFixedString stream str len=
    (
        if ( WC3_DEBUG ) then  Format " - Writing %\n" str
        for i=1 to str.count do
        (
            local byte = bit.charasint str[i]
            writeByte stream byte
        )
        for i=1 to (len - str.count) do
            writeByte stream 0
    ),
    function WriteTris stream tris=
    (
        writeShort stream tris[1]
        writeShort stream tris[2]
        writeShort stream tris[3]
    ),
    function WriteVector3 stream vector3=
    (
         writeFloat stream vector3.X
         writeFloat stream vector3.Y
         writeFloat stream vector3.Z
    ),
    function WriteVertexWeights stream vertexWeights=
    (
        
        for i=1 to 4 do writeByte stream vertexWeights.boneIndices[i]
        for i=1 to 4 do writeByte stream vertexWeights.vertexWeights[i]
        
    ),
    function WriteQuat stream quaternian=
    (
        writeFloat stream quaternian.x
        writeFloat stream quaternian.y
        writeFloat stream quaternian.z
        writeFloat stream quaternian.w

    ),
    function WriteVector4 stream vector4=
    (
        writeFloat stream vector4[1]
        writeFloat stream vector4[2]
        writeFloat stream vector4[3]
        writeFloat stream vector4[4]
    ),
    function WriteKGAnim stream kgAnim=
    (
        if kgAnim == undefined then return undefined
        if ( kgAnim.nbrKeys > 0 ) then 
        (
            _writer.WriteFixedString stream kgAnim.Type 4            
            writeLong stream kgAnim.nbrKeys
            writeLong stream kgAnim.lineType
            writeLong stream kgAnim.glbsId #signed
            
            for anim in kgAnim.AnimBlock do
            (
                
                local theKey = anim.Key * 1000 / 30
                writeLong stream theKey
                              
                if ( kgAnim.Type == "KGTR" ) then _writer.WriteVector3 stream anim.Val
                if ( kgAnim.Type == "KGRT" ) then _writer.WriteQuat    stream anim.Val 
                if ( kgAnim.Type == "KGSC" ) then _writer.WriteVector3 stream anim.Val
                
            )
            
            
        )
        
        
    ),
    function WriteMDLX mdx=
    (
        format "Writing MDLX\n"
        _writer.WriteFixedString mdx.stream "MDLX" 4
        format "Writing VERS\n"
        _writer.WriteFixedString mdx.stream "VERS" 4
        writeLong mdx.stream 4
        writeLong mdx.stream 1000
    ),
    function WriteMODL mdx=
    (
        format "Writing MODL\n"
        _writer.WriteFixedString mdx.stream "MODL" 4
        writeLong mdx.stream 372
        
        local fileName = getfilenamefile mdx.file
        _writer.WriteFixedString mdx.stream fileName 80
        _writer.WriteFixedString mdx.stream "" 260
        
        local radius = 0.0
        local selectionSphere = getnodebyname "Selection_Sphere"
        if( classOf selectionSphere == sphere ) then radius = selectionSphere.radius * 4.0
        
        writefloat mdx.stream radius

        local bbox = _parser.GetMODLBoundingBoxBetweenFrames 0 1
        
        _writer.WriteVector3 mdx.stream bbox[1]
        _writer.WriteVector3 mdx.stream bbox[2]

        writeLong mdx.stream 150
    ),
    function WriteSEQS mdx=
    (
        format "Writing SEQS\n"
        _writer.WriteFixedString mdx.stream "SEQS" 4
        
        writeLong mdx.stream ( 132 * mdx.seqs.count)
        
        for seq in mdx.seqs do
        (
            if DEBUG_MODE then format "%\n" seq
            _writer.WriteFixedString mdx.stream seq.Name 80
            WriteLong  mdx.stream seq.StartFrame
            WriteLong  mdx.stream seq.EndFrame
            WriteFloat mdx.stream seq.MovementSpeed
            WriteLong  mdx.stream seq.NoLoop
            WriteFloat mdx.stream seq.Rarity
            WriteLong  mdx.stream seq.Default
            WriteFloat mdx.stream seq.Priority
            
            _writer.WriteVector3 mdx.stream seq.BBox[1]
            _writer.WriteVector3 mdx.stream seq.BBox[2]
        )
    ),
    function WriteMTLS mdx=
    (
        format "Writing MTLS\n"
        _writer.WriteFixedString mdx.stream "MTLS" 4

        local totalSize = 0
        local ShaderSizes = #()
        
        -- calculate the total size
        for mat in mdx.mtls do
        (
            local ShaderSizeIncluded = 0
            
            ShaderSizeIncluded  += 100 + ( 52 * 6 )
            -- KMTA
            if ( mat.materialRef.material_alpha.controller != undefined ) then 
                ShaderSizeIncluded += 16 + ( 8 * mat.materialRef.material_alpha.controller.keys.count)
            
            -- KMTE
            if ( mat.materialRef.emissive_multiplier.controller != undefined ) then 
                ShaderSizeIncluded += 16 + ( 8 * mat.materialRef.emissive_multiplier.controller.keys.count)
            
            append ShaderSizes ShaderSizeIncluded
            totalSize += ShaderSizeIncluded
        )
        writeLong mdx.stream totalSize
        
        for i=1 to mdx.mtls.count do
        (
            if DEBUG_MODE then format "%\n" mdx.mtls[i]
            
            writeLong mdx.stream ShaderSizes[i]
            writeLong mdx.stream mdx.mtls[i].materialRef.priorityPlane
            
            local flags = 0x0 
            if (mdx.mtls[i].materialRef.DONT_INHERIT_TRANSLATION == true) then flags += 0x1
            if (mdx.mtls[i].materialRef.DONT_INHERIT_SCALING == true) then flags += 0x2
            if (mdx.mtls[i].materialRef.DONT_INHERIT_ROTATION == true) then flags += 0x4
            writeLong mdx.stream flags

            _writer.WriteFixedString mdx.stream "Shader_HD_DefaultUnit" 80

            _writer.WriteFixedString mdx.stream "LAYS" 4 
            writeLong mdx.stream 6 --> nLayers
            for l=1 to 6 do
                _writer.WriteLAYS mdx i l
            
        )
    ),
    function WriteLAYS mdx mtlsIndex layerIndex=
    (
        local mat = mdx.mtls[mtlsIndex].MaterialRef
        local laySize = 52
        
        if ( layerIndex == 1 ) then (
            if ( mat.material_alpha.controller != undefined ) then laySize = laySize + 16 + ( mat.material_alpha.controller.keys.count * 8 )
            if ( mat.emissive_multiplier.controller != undefined ) then laySize = laySize + 16 + ( mat.emissive_multiplier.controller.keys.count * 8 )
        )
        
        writeLong mdx.stream laySize --> size
        
        local filterMode = 0
        if layerIndex == 1 then filterMode = mat.filtermode - 1
        writeLong mdx.stream filtermode
        
        local shadingFlags = 0
        
        local fresnel_r = 1.0
        local fresnel_g = 1.0
        local fresnel_b = 1.0
        local fresnel_multi = 0.0
        local tealcolor_multi = 0.0
        local alpha_init = 1.0
        
        if layerIndex == 1 then (
            if mat.unlit        then shadingFlags += 0x01
            if mat.envmap       then shadingFlags += 0x02
            if mat.wrapwidth    then shadingFlags += 0x04
            if mat.wrapheight   then shadingFlags += 0x04
            if mat.twosided     then shadingFlags += 0x10
            if mat.nofog        then shadingFlags += 0x20
            if mat.nodepthset   then shadingFlags += 0x40
            if mat.nodepthtest  then shadingFlags += 0x80
                
            fresnel_r = (mat.fresnel_color.r / 255)
            fresnel_g = (mat.fresnel_color.g / 255)
            fresnel_b = (mat.fresnel_color.b / 255)
            fresnel_multi = mat.fresnel_multiplier
            tealcolor_multi = mat.teamcolor_multiplier
            alpha_init = mat.material_alpha
        )

        writeLong mdx.stream shadingFlags

        local texsID = _parser.GetTextureId mat layerIndex mdx.TEXS
        
        writeLong mdx.stream texsID
        writeLong mdx.stream mdx.mtls[mtlsIndex].txanId #unsigned
        writeLong mdx.stream 0 --> uv mapping layer
        writeFloat mdx.stream alpha_init
        writeFloat mdx.stream mat.emissive_multiplier 
        writeFloat mdx.stream fresnel_r
        writeFloat mdx.stream fresnel_g
        writeFloat mdx.stream fresnel_b
        writeFloat mdx.stream fresnel_multi
        writeFloat mdx.stream tealcolor_multi
        
        local glbsId = -1
        
        if ( layerIndex == 1 ) then (
            -- Write KMTA
            local hasKMTA = false
            local lineType = 0
            if ( mat.material_alpha.controller != undefined ) then hasKMTA = true
            if (hasKMTA) then
            (
                _writer.WriteFixedString mdx.stream "KMTA" 4
                writeLong mdx.stream mat.material_alpha.controller.keys.count
                writeLong mdx.stream 1
                writeLong mdx.stream glbsId #unsigned
                
                for key in mat.material_alpha.controller.keys do
                    at time key.time 
                    (
                        local frame = ( key.time as integer / ticksperframe ) * 1000 / 30 as integer
                        writeLong mdx.stream frame
                        writeFloat mdx.stream ( mat.material_alpha / 100.0 )
                    )
            )
            -- Write KMTE
            local hasKMTE = false
            if ( mat.emissive_multiplier.controller != undefined ) then hasKMTE = true
            if (hasKMTE) then
            (
                _writer.WriteFixedString mdx.stream "KMTE" 4
                writeLong mdx.stream mat.emissive_multiplier.controller.keys.count
                writeLong mdx.stream 1
                writeLong mdx.stream glbsId #unsigned
                
                for key in mat.emissive_multiplier.controller.keys do
                    at time key.time 
                    (
                        local frame = ( key.time as integer / ticksperframe ) * 1000 / 30 as integer
                        writeLong mdx.stream frame
                        writeFloat mdx.stream ( mat.emissive_multiplier / 100.0 )
                    )
            )
            
            -- Parse TXAN
            _parser.GetTXAN mat mdx
            
        )
    ),
    function WriteTXAN mdx=
    (
        if mdx.TXAN == undefined then return undefined
            
        format "Writing TXAN\n"
        
        _writer.WriteFixedString mdx.stream "TXAN" 4
        
        local totalSize = 0
        for t in mdx.TXAN do totalSize += t.size
        
        writeLong mdx.stream totalSize
        
        for t in mdx.TXAN do (
        
            writelong mdx.stream t.size
            if t.KTAT != undefined then (
                _writer.WriteFixedString mdx.stream "TXAN" 4
                writeLong mdx.stream t.KTAT.nbr
                writeLong mdx.stream t.KTAT.lineType
                writeLong mdx.stream t.KTAT.GLBS_ID
                
                for anim in t.KTAT.AnimBlock do (
                    writeLong mdx.stream ( anim.Key * 30 / 1000 )
                    _writer.WriteVector3 mdx.stream anim.val
                )
            )
        
        )
    ),
    function WriteTEXS mdx=
    (
        format "Writing TEXS\n"
        _writer.WriteFixedString mdx.stream "TEXS" 4
        
        writeLong mdx.stream ( mdx.texs.count * 268 ) 
        
        for tex in mdx.texs do
        (
            if DEBUG_MODE then format "%\n" tex
            writeLong mdx.stream tex.replacableId
            _writer.WriteFixedString mdx.stream tex.path 260
            writeLong mdx.stream tex.flags
        )

    ),
    function WriteGEOS mdx=
    (
        format "Writing GEOS\n"
        _writer.WriteFixedString mdx.stream "GEOS" 4
        
        local totalSize = 0
        for geo in mdx.geos do totalSize += geo.size
        writeLong mdx.stream totalSize
        
        if DEBUG_MODE then format "Total size: %\n" totalSize
        
        for geo in mdx.geos do
        (
            writeLong mdx.stream geo.size
            
            if DEBUG_MODE then format "VRTX\n"
            _writer.WriteFixedString mdx.stream "VRTX" 4
            writeLong mdx.stream geo.VRTX.count
            for v in geo.VRTX do _writer.WriteVector3 mdx.stream v

            if DEBUG_MODE then format "NRMS\n"
            _writer.WriteFixedString mdx.stream "NRMS" 4
            writeLong mdx.stream geo.NRMS.count
            for n in geo.NRMS do _writer.WriteVector3 mdx.stream n

            if DEBUG_MODE then format "PTYP\n"
            _writer.WriteFixedString mdx.stream "PTYP" 4
            writeLong mdx.stream 1
            writeLong mdx.stream geo.PTYP

            if DEBUG_MODE then format "PCNT\n"
            _writer.WriteFixedString mdx.stream "PCNT" 4
            writeLong mdx.stream 1
            writeLong mdx.stream geo.PCNT

            if DEBUG_MODE then format "PVTX\n"
            _writer.WriteFixedString mdx.stream "PVTX" 4
            writeLong mdx.stream ( geo.PVTX.count * 3 )
            for p in geo.PVTX do _writer.WriteTris mdx.stream p

            if DEBUG_MODE then format "GNDX\n"
            _writer.WriteFixedString mdx.stream "GNDX" 4
            writeLong mdx.stream 0

            if DEBUG_MODE then format "MTGC\n"
            _writer.WriteFixedString mdx.stream "MTGC" 4 --> matching bone group counts
            writeLong mdx.stream geo.MTGC.count
            for m in geo.MTGC do writeLong mdx.stream 1

            if DEBUG_MODE then format "MATS\n"
            _writer.WriteFixedString mdx.stream "MATS" 4 --> matching bone sets
            writeLong mdx.stream geo.MATS.matrices.count
            for m in geo.MATS.matrices do writeLong mdx.stream m
            writeLong mdx.stream geo.MATS.materialID
            writeLong mdx.stream geo.MATS.sectionGroupId
            writeLong mdx.stream geo.MATS.sectionGroupType
            writeLong mdx.stream geo.MATS.LOD_Id
            if DEBUG_MODE then format "%\n" geo.MATS.Name
            _writer.WriteFixedString mdx.stream geo.MATS.Name 80
            
            for f=1 to 7 do writeFloat mdx.stream 0.0
            writeLong mdx.stream 0

            if DEBUG_MODE then format "TANG\n"
            _writer.WriteFixedString mdx.stream "TANG" 4
            writeLong mdx.stream geo.TANG.count
            for t in geo.TANG do _writer.WriteVector4 mdx.stream t

            if DEBUG_MODE then format "SKIN\n"
            _writer.WriteFixedString mdx.stream "SKIN" 4
            writeLong mdx.stream ( geo.SKIN.count * 8 )
            for s in geo.SKIN do _writer.WriteVertexWeights mdx.stream s
            
            if DEBUG_MODE then format "UVAS\n"
            _writer.WriteFixedString mdx.stream "UVAS" 4
            writeLong mdx.stream 1
            _writer.WriteFixedString mdx.stream "UVBS" 4
            writeLong mdx.stream geo.UVBS.count
            for uv in geo.UVBS do 
            (
                writeFloat mdx.stream uv[1]
                writeFloat mdx.stream uv[2]
            )
        
        )
        
    ),
    function WriteGEOA mdx=
    (
        format "Writing GEOA\n"
        _writer.WriteFixedString mdx.stream "GEOA" 4
        
        local totalSize = 0
        for geoa in mdx.geoa do totalSize += geoa.size
        writeLong  mdx.stream totalSize
        for geoa in mdx.geoa do
        (
            writeLong  mdx.stream geoa.size
            writeFloat mdx.stream geoa.opacity
            writeLong  mdx.stream geoa.type
            for i=1 to 3 do writeFloat mdx.stream geoa.color[i]
            writeLong  mdx.stream geoa.geoId

            if ( geoa.KGAO != undefined ) then 
            (
                _writer.WriteFixedString mdx.stream "KGAO" 4
                writeLong  mdx.stream geoa.KGAO.numPts
                writeLong  mdx.stream geoa.KGAO.LineType
                writeLong  mdx.stream geoa.KGAO.GLBSID #signed
                for kg in geoa.KGAO.KG do
                (
                    writeLong  mdx.stream kg.time
                    writeFloat mdx.stream kg.point
                )
                
            )
        )
    ),
    function WriteBONE mdx=
    (
        format "Writing BONE\n"
        _writer.WriteFixedString mdx.stream "BONE" 4
        
        local totalSize = 0
        
        for obj in mdx.allObjects do
            if ( obj.ObjectType == #wc3BONE ) then
                totalSize += obj.totalSize + 8 --> headersize + geosetid + geosetAnimId

        writeLong mdx.stream totalSize
        
        for obj in mdx.allObjects do
        (                
            if ( obj.ObjectType == #wc3BONE ) then
            (
                if DEBUG_MODE then format "%\n" obj.name
                writeLong mdx.stream obj.totalSize
                _writer.WriteFixedString mdx.stream obj.name 80
                writeLong mdx.stream obj.id
                writeLong mdx.stream obj.parentId #signed
                writeLong mdx.stream obj.flags
                
                _writer.WriteKGAnim mdx.stream obj.KGTR
                _writer.WriteKGAnim mdx.stream obj.KGRT
                _writer.WriteKGAnim mdx.stream obj.KGSC
                
                writeLong mdx.stream obj.geosetId
                writeLong mdx.stream obj.geosetAnimationId
            )
        )
    ),
    function WriteHELP mdx=
    (
        local nbrHelpers = 0
        for obj in mdx.allObjects do
            if ( obj.ObjectType == #wc3HELP ) then nbrHelpers += 1
        
        if nbrHelpers == 0 then return undefined
        format "Writing HELP\n"
        _writer.WriteFixedString mdx.stream "HELP" 4
        
        local totalSize = 0
        
        for obj in mdx.allObjects do
            if ( obj.ObjectType == #wc3HELP ) then
                totalSize += obj.totalSize
        
        writeLong mdx.stream totalSize
        
        for obj in mdx.allObjects do
        (                
            if ( obj.ObjectType == #wc3HELP ) then
            (
                if DEBUG_MODE then format "%\n" obj.name
                writeLong mdx.stream obj.totalSize
                _writer.WriteFixedString mdx.stream obj.name 80
                writeLong mdx.stream obj.id
                writeLong mdx.stream obj.parentId #signed
                writeLong mdx.stream obj.flags
                
               _writer.WriteKGAnim mdx.stream obj.KGTR
               _writer.WriteKGAnim mdx.stream obj.KGRT
               _writer.WriteKGAnim mdx.stream obj.KGSC
                
            )
        )
        
    ),
    function WriteATCH mdx=
    (
        format "Writing ATCH\n"
        _writer.WriteFixedString mdx.stream "ATCH" 4
        
        local totalSize = 0
        
        for obj in mdx.allObjects do
            if obj.ObjectType == #wc3ATCH then totalSize += 364  -- obj.TotalSize --> no animations yet
        
        writeLong mdx.stream totalSize
            
        local index = 0
        for obj in mdx.allObjects do
        (
            if obj.ObjectType == #wc3ATCH then 
            (
                if DEBUG_MODE then format "- %\n" obj.name
                writeLong mdx.stream 364 --obj.totalSize
                writeLong mdx.stream obj.headerSize
                _writer.WriteFixedString mdx.stream obj.name 80
                writeLong mdx.stream obj.id
                writeLong mdx.stream obj.parentId #signed
                writeLong mdx.stream obj.flags
                _writer.WriteFixedString mdx.stream "" 260
                writeLong mdx.stream index
                
                index += 1
            )
        )
        
    ),
    function WritePIVT mdx=
    (
        format "Writing PIVT\n"
        _writer.WriteFixedString mdx.stream "PIVT" 4  
        
        local totalSize = mdx.allObjects.count * 12
        writeLong mdx.stream totalSize
        
        if DEBUG_MODE then format "Nbr of PIVT's % Size: %\n" mdx.allObjects.count totalSize
            
        for obj in mdx.allobjects do
        (
            if DEBUG_MODE then format "- %\n" obj.name
            writeFloat mdx.stream obj.objRef.pos.x
            writeFloat mdx.stream obj.objRef.pos.y
            writeFloat mdx.stream obj.objRef.pos.z
        )
        
    ),
    function WriteEVTS mdx=
    (
        format "Writing EVTS\n"
        
        local totalSize = 0
        for obj in mdx.allObjects do
        (
            if ( obj.ObjectType == #wc3EVTS ) then 
            if ( obj.objRef.keyList.count > 0 ) then 
            (
                totalSize += obj.headerSize
                totalSize += 12 --> KEVT + nbrKeys + ParentId 
                totalSize += obj.objRef.keyList.count * 4
            )
        )
        if totalSize == 0 then return undefined
        _writer.WriteFixedString mdx.stream "EVTS" 4
        writeLong mdx.stream totalSize
        
        if DEBUG_MODE then format "- Size %\n" totalSize
            
        for obj in mdx.allObjects do
        (
            if ( obj.ObjectType == #wc3EVTS ) then 
            if ( obj.objRef.keyList.count > 0 ) then 
            (
                if DEBUG_MODE then format "- %\n" obj.name
                writeLong mdx.stream obj.headerSize
                _writer.WriteFixedString mdx.stream obj.name 80
                writeLong mdx.stream obj.id
                writeLong mdx.stream obj.parentId #signed
                writeLong mdx.stream obj.flags
                
                _writer.WriteFixedString mdx.stream "KEVT" 4
                writeLong mdx.stream obj.objRef.keyList.count
                writeLong mdx.stream -1 #signed
                for k in obj.objRef.keyList do writeLong mdx.stream ( k * 1000 / 30 )
            )
        )
        
    ),
    function WriteCLID mdx=
    (
        format "Writing CLID\n"
        
        local totalSize = 0
        for obj in mdx.allobjects do
        (
            if obj.ObjectType == #wc3CLID then
            (
                totalSize += obj.headerSize
                if ( classof obj.objRef == box ) then totalSize += 28
                if ( classof obj.objRef == plane ) then totalSize += 28
                if ( classof obj.objRef == sphere ) then totalSize += 20
                if ( classof obj.objRef == cylinder ) then totalSize += 32
            )
        )
        if totalSize == 0 then return undefined
        _writer.WriteFixedString mdx.stream "CLID" 4 
        writeLong mdx.stream totalSize
        if DEBUG_MODE then format "- Size %\n" totalSize
        
        for obj in mdx.allobjects do
        (
            if obj.ObjectType == #wc3CLID then
            ( 
                if DEBUG_MODE then format "- %\n" obj.name
                writeLong mdx.stream obj.headerSize
                _writer.WriteFixedString mdx.stream obj.name 80
                writeLong mdx.stream obj.id
                writeLong mdx.stream obj.parentId #signed
                writeLong mdx.stream obj.flags
                
                if ( classof obj.objRef == box ) then 
                (
                    writeLong mdx.stream 0
                    writeFloat mdx.stream obj.objRef.min.x
                    writeFloat mdx.stream obj.objRef.min.y
                    writeFloat mdx.stream obj.objRef.min.z
                    writeFloat mdx.stream obj.objRef.max.z
                    writeFloat mdx.stream obj.objRef.max.z
                    writeFloat mdx.stream obj.objRef.max.z
                )    
                if ( classof obj.objRef == plane ) then 
                (
                    writeLong mdx.stream 1
                    writeFloat mdx.stream obj.objRef.min.x
                    writeFloat mdx.stream obj.objRef.min.y
                    writeFloat mdx.stream obj.objRef.min.z
                    writeFloat mdx.stream obj.objRef.max.z
                    writeFloat mdx.stream obj.objRef.max.z
                    writeFloat mdx.stream obj.objRef.max.z
                )    
                if ( classof obj.objRef == sphere ) then 
                (
                    writeLong mdx.stream 2
                    writeFloat mdx.stream obj.objRef.pos.x
                    writeFloat mdx.stream obj.objRef.pos.y
                    writeFloat mdx.stream obj.objRef.pos.z
                    writeFloat mdx.stream obj.objRef.radius
                )                
                if ( classof obj.objRef == cylinder ) then 
                (
                    writeLong mdx.stream 3
                    writeFloat mdx.stream obj.objRef.pos.x
                    writeFloat mdx.stream obj.objRef.pos.y
                    writeFloat mdx.stream obj.objRef.pos.z
                    writeFloat mdx.stream obj.objRef.pos.x
                    writeFloat mdx.stream obj.objRef.pos.y
                    writeFloat mdx.stream ( obj.objRef.pos.z + obj.objRef.height )
                    writeFloat mdx.stream obj.objRef.radius
                ) 
            )
        )
        
    ),
    function WriteBPOS mdx=
    (
        format "Writing BPOS\n"
        _writer.WriteFixedString mdx.stream "BPOS" 4  
        
        local totalSize = mdx.allObjects.count * 48 + 4
        writeLong mdx.stream totalSize
        writeLong mdx.stream mdx.allObjects.count
        
        if DEBUG_MODE then format "Nbr: % Size: %\n" mdx.allObjects.count totalSize
            
        for obj in mdx.allobjects do
        (
             for r=1 to 4 do
                for c=1 to 3 do
                    writeFloat mdx.stream obj.objRef.Transform[r][c]
        ) 
    ),
    function WriteCAMS mdx=
    (
        /*
            struct WC3RefCam ( cameraObj, KCTR = #(), KCRL = #(), KTTR = #(), size = 120 )
            struct _anim ( size, lineType = 1, GLBS_ID = -1, nbr, AnimBlock = #() )
            struct _keyVal ( key, val )
        */
        if mdx.CAMS == undefined or mdx.CAMS.count == 0 then return undefined
        format "Writing CAMS\n"
        _writer.WriteFixedString mdx.stream "CAMS" 4
        
        -- calc totalsize
        local totalSize = 0
        for cam in mdx.CAMS do
            totalSize += cam.size
        
        writeLong mdx.stream totalSize
        
        if DEBUG_MODE then format " - Nbr: % Size: %\n" mdx.CAMS.count totalSize
        
        for cam in mdx.CAMS do
        (
            if DEBUG_MODE then format " - %\n" cam.cameraObj.name
            writeLong mdx.stream cam.size
            _writer.WriteFixedString mdx.stream cam.cameraObj.name 80
            _writer.WriteVector3 mdx.stream cam.cameraObj.pos
            writeFloat mdx.stream ( degToRad cam.cameraObj.FOV )
            writeFloat mdx.stream cam.cameraObj.FarClip
            writeFloat mdx.stream cam.cameraObj.NearClip
            _writer.WriteVector3 mdx.stream cam.cameraObj.Target.Pos
            
            -- KCTR
            if ( cam.KCTR != undefined ) then (
                _writer.WriteFixedString mdx.stream "KCTR" 4
                writeLong mdx.stream cam.KCTR.nbr
                writeLong mdx.stream cam.KCTR.lineType
                writeLong mdx.stream cam.KCTR.GLBS_ID #unsigned
                
                for ab in cam.KCTR.AnimBlock do (
                    writelong mdx.stream ( ab.key * 1000 / 30 )
                    _writer.WriteVector3 mdx.stream ab.val
                )
            )
            -- KCRL
            if ( cam.KCRL != undefined ) then (
                _writer.WriteFixedString mdx.stream "KCRL" 4
                writeLong mdx.stream cam.KCRL.nbr
                writeLong mdx.stream cam.KCRL.lineType
                writeLong mdx.stream cam.KCRL.GLBS_ID #unsigned
                
                for ab in cam.KCRL.AnimBlock do (
                    writeLong mdx.stream ( ab.key * 1000 / 30 )
                    writeFloat mdx.stream ab.val
                )
            )
            -- KTTR
            if ( cam.KTTR != undefined ) then (
                _writer.WriteFixedString mdx.stream "KTTR" 4
                writeLong mdx.stream cam.KTTR.nbr
                writeLong mdx.stream cam.KTTR.lineType
                writeLong mdx.stream cam.KTTR.GLBS_ID #unsigned
                
                for ab in cam.KTTR.AnimBlock do (
                    writeLong mdx.stream ( ab.key * 1000 / 30 )
                    _writer.WriteVector3 mdx.stream ab.val
                )
            )
        )
        
    )
)