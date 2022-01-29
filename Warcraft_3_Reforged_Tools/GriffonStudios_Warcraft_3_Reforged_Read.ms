/*
    .DESCRIPTION
    | Set of read methods for importing to handle Warcraft III Reforged Tools
    | Written by Taylor Mouse
    
    .DATE
    | 18.12.2021
    
    .RELEASENOTES
    | 0.2 - Revisit
    | 0.1 - INIT
    
*/
/*

    .FLAGS
        0x0: helper
        0x1: dont inherit translation
        0x2: dont inherit rotation
        0x4: dont inherit scaling
        0x8: billboarded
        0x10: billboarded lock x
        0x20: billboarded lock y
        0x40: billboarded lock z
        0x80: camera anchored
        0x100: bone
        0x200: light
        0x400 event object
        0x800: attachment
        0x1000 particle emitter
        0x2000: collision shape
        0x4000: ribbon emitter
        0x8000: if particle emitter: emitter uses mdl, if particle emitter 2: unshaded
        0x10000: if particle emitter: emitter uses tga, if particle emitter 2: sort primitives far z
        0x20000: line emitter
        0x40000: unfogged
        0x80000: model space
        0x100000: xy quad
        
*/
struct Warcraft_3_Ref_Read
(
    function ReadColor stream=
    (
        local r = (readFloat stream * 255.0) as integer
        local g = (readFloat stream * 255.0) as integer
        local b = (readFloat stream * 255.0) as integer
        return ( color r g b )
    ),
    function ReadColorAnim stream=
    (
        struct anim800 ( numPts, LineType, glbsId, KG )
        struct kg800   ( Time, Point, inTan, outTan, LineType )
        local anim = anim800()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = kg800()
            
            k.Time = _helper.RoundToFrame ( ReadLong stream )
            k.Point = _reader.ReadColor stream -- always 1, indicating it starts or ends
            k.LineType = anim.lineType
            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadFloatAnim stream=
    (
        struct WC3Ref_ANIM ( numPts, LineType, glbsId, KG )  
        struct WC3Ref_KG   ( Time, Point, inTan, outTan, LineType ) 
        
        local anim = WC3Ref_ANIM()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = WC3Ref_KG()
            
            k.Time = _helper.RoundToFrame ( ReadLong stream )
            k.Point = readFloat stream -- always 1, indicating it starts or ends

            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadVector3Anim stream=
    (
        struct WC3Ref_ANIM ( numPts, LineType, glbsId, KG )  
        struct WC3Ref_KG   ( Time, Point, inTan, outTan, LineType ) 
        
        local anim = WC3Ref_ANIM()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = WC3Ref_KG()
            
            k.Time = _helper.RoundToFrame ( ReadLong stream )
            k.Point = [readFloat stream, readFloat stream, readFloat stream]

            if( anim.lineType > 1)  then
            (
                k.inTan = [readFloat stream, readFloat stream, readFloat stream]
                k.outTan = [readFloat stream, readFloat stream, readFloat stream]
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadQuatAnim stream=
    (
        struct WC3Ref_ANIM ( numPts, LineType, glbsId, KG ) 
        struct WC3Ref_KG   ( Time, Point, inTan, outTan, LineType ) 
        
        local anim = WC3Ref_ANIM()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = WC3Ref_KG()
            
            k.Time = _helper.RoundToFrame ( ReadLong stream )
            k.Point = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
            k.LineType = lineType
            if( anim.lineType > 1)  then
            (
                --format "Linetype: %\n" lineType
                k.inTan = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
                k.outTan = quat (readFloat stream) (readFloat stream) (readFloat stream) (readFloat stream) 
            )
            append kg k
        )
        anim.KG = kg
        return anim
    ),
    function ReadLongAnim stream=
    (
        struct WC3Ref_anim ( numPts, LineType, glbsId, KG )
        struct WC3Ref_kg   ( Time, Point, inTan, outTan, LineType )
        local anim = WC3Ref_anim()
        local kg = #()
        
        anim.numPts = readLong stream
        anim.lineType = readLong stream
        anim.glbsId = readLong stream + 1
        
        for i=1 to anim.numPts do
        (
            local k = WC3Ref_kg()
            
            k.Time = _helper.RoundToFrame ( ReadLong stream )
            k.Point = readLong stream -- always 1, indicating it starts or ends
            k.LineType = anim.lineType
            if( anim.lineType > 1)  then
            (
                k.inTan = readFloat stream
                k.outTan = readFloat stream
            )
            append kg k
        )
        anim.KG = kg
        return anim
        
    ),
    function ReadTAGS1000 stream streamLen=
    (
        struct WC3Ref_TAG ( Name, Offset, Size )
        local tags = #() 
        local mainTag = WC3Ref_TAG()

        mainTag.Name = _helper.ReadFixedString stream 4
        mainTag.Offset = 0
        mainTag.Size = 0
        
        local currentStreamPos = ftell stream
        local streamLen = _helper.GetStreamLength stream
        
        while (currentStreamPos < streamLen ) do
        (
            local tag = WC3Ref_TAG()
            
            tag.Offset = ftell stream + 8 -- the +8 indicates where the data starts
            tag.Name = _helper.ReadFixedString stream 4
            tag.Size = ReadLong stream
            
            _helper.SkipBytes stream tag.Size

            currentStreamPos = ftell stream
            if DEBUG_MODE then format "%\n" tag
            append tags tag
        )
        
        tags
    ),
    function ReadVERS stream tag=
    (
        fseek stream tag.Offset #seek_set
        local version = readLong stream
            
        if (version != 1000) then throw (format "[Error] Incorrect version: %, expected version: 1000\n" version)
        
        if DEBUG_MODE then format "Version: %\n" version
        
        return version
    ),
    function ReadMODL stream tag=
    (
        struct WC3Ref_MODL ( name, path, radius, bBox = #(), Always150 )
        fseek stream tag.offset #seek_set
        
        local modl = WC3Ref_MODL()
        modl.name = _helper.ReadFixedString stream 80
        modl.path = _helper.ReadFixedString stream 260
        modl.radius = readFloat stream
        append modl.bbox [readFloat stream, readFloat stream, readFloat stream]
        append modl.bbox [readFloat stream, readFloat stream, readFloat stream]
        modl.Always150 = readLong stream
        
        if DEBUG_MODE then Format "Name: % (%)\n" modl.name modl.bbox
            
        return modl
    ),
    function ReadSEQS stream tag=
    (
        struct WC3Ref_SEQS
            ( Name, StartFrame, EndFrame, MovementSpeed, NoLoop, Rarity, Priority, Default, BBox )
        
        fseek stream tag.offset #seek_set
        
        local nbrSeqs = tag.size / 132
        local tmpSeqs = #()
        local seqs = #()
        
        for i=1 to nbrSeqs do
        (
            local seq = WC3Ref_SEQS()
            seq.Name = _helper.ReadFixedString stream 80
            
            local originalStartFrame = readLong stream
            local originalEndFrame = readLong stream

            seq.StartFrame    = ( _helper.RoundToFrame ( originalStartFrame ) ) + 10
            seq.EndFrame      = ( _helper.RoundToFrame ( originalEndFrame ) ) + 10
            seq.MovementSpeed = readFloat stream
            seq.NoLoop        = readLong stream
            seq.Rarity        = readFloat stream
            seq.Default       = readlong stream
            seq.Priority      = readFloat stream
            
            seq.BBox = #([readfloat stream,readfloat stream,readfloat stream], [readfloat stream,readfloat stream,readfloat stream] )

            append tmpSeqs seq
        )

        -- validate the sequences and clean up
        for s=1 to tmpSeqs.count do
        (
            local addSeq = true
            for w=s+1 to tmpSeqs.count do
                if ( tmpSeqs[s].startFrame == tmpSeqs[w].startFrame ) then (
                    addSeq = false
                    exit
                )

            if addSeq then append seqs tmpSeqs[s]

        )
        if DEBUG_MODE then for s in seqs do format "%\n" s
            
        return seqs
        
    ),
    function ReadGLBS stream tag=
    (
        fseek stream tag.offset #seek_set
        local gbls = #()
        
        local nbr = tag.Size / 4
        
        for i=1 to nbr do 
        (
            local endFrame = (_helper.RoundToFrame (readLong stream)) + 10

            if DEBUG_MODE then Format "%\n" endFrame
            append gbls endFrame
        )
        return gbls
        
    ),
    function ReadMTLS stream tag=
    (
        fseek stream tag.offset #seek_set
        
        local mtls = #()
        
        while ( ftell stream < ( tag.offset + tag.size ) ) do
        (
            local shdr = _reader.ReadShader stream
            append mtls shdr
            if DEBUG_MODE then format "%\n" shdr
        )
        return mtls
    ),
    function ReadShader stream=
    (
        struct WC3Ref_MTLS ( Size, PriorityPlane, Flags, Name, Lays, NumberOfLayers, Layers = #(), MaterialRef )
        
        local shdr = WC3Ref_MTLS()
        shdr.Size = readLong stream
        shdr.PriorityPlane = readLong stream
        shdr.Flags = readLong stream
        shdr.Name = _helper.ReadFixedString stream 80
        shdr.Lays = _helper.ReadFixedString stream 4
        shdr.NumberOfLayers = readLong stream
        
        local currentOffset = fTell stream
        
        for i=1 to shdr.NumberOfLayers do
        (
            fSeek stream currentOffset #seek_set
            local layer = _reader.ReadLayer stream
            append shdr.Layers layer
            
            currentOffset = currentOffset + layer.Size
        )

        return shdr
    ),
    function ReadLayer stream=
    (
        -- FilterMode   (0:none; 1:transparent; 2:blend; 3:add)
        -- ShadingFlags (1:unshaded; +16:two sided; +32:unfogged)
        
        struct WC3Ref_LAYR 
            ( Size, FilterMode, ShadingFlags, TextureId, TXAN_ID, CoordId, Alpha, EmissiveMultiplier, FresnelR, FresnelG, FresnelB, FresnelMultiplier, TeamColorMultiplier, KMTA, KMTE, KMTF ) 
        
        local lay = WC3Ref_LAYR()
        
        lay.Size                = readLong stream
        lay.FilterMode          = readLong stream + 1
        lay.ShadingFlags        = readLong stream
        lay.TextureId           = readLong stream + 1
        lay.TXAN_ID             = readLong stream + 1
        lay.CoordId             = readLong stream
        lay.Alpha               = readfloat stream
        lay.EmissiveMultiplier  = readfloat stream
        lay.FresnelR            = readfloat stream
        lay.FresnelG            = readfloat stream
        lay.FresnelB            = readfloat stream
        lay.FresnelMultiplier   = readfloat stream
        lay.TeamColorMultiplier = readfloat stream
     
        if DEBUG_MODE then format " - %\n" lay
        
        if (lay.Size > 52 ) then
        (
            for x=1 to 3 do
            (
                local km = _helper.ReadFixedString stream 4
                if ( km == "KMTA" ) then lay.KMTA = _reader.ReadFloatAnim stream --> Alpha
                if ( km == "KMTE" ) then lay.KMTE = _reader.ReadFloatAnim stream --> Emissive
                if ( km == "KMTF" ) then lay.KMTF = _reader.ReadLongAnim stream --> .FLI 
                
            )
            if ( lay.KMTA == undefined ) then fseek stream -4 #seek_cur
            if ( lay.KMTE == undefined ) then fseek stream -4 #seek_cur
            if ( lay.KMTF == undefined ) then fseek stream -4 #seek_cur
        )
       
        return lay
    ),
    function ReadTEXS stream tag=
    (
        struct WC3Ref_TEXS
            ( Id, FileNameOnly, ReplacableId, File,  Path, Extension, Flags )
        
        fseek stream tag.offset #seek_set
        
        local texs = #()
        local numTexs = tag.Size / 268
        
        for i=1 to numTexs do
        (
            local t = WC3Ref_TEXS()
            t.Id = i
            
            t.replacableId  = readLong stream
            t.file          = _helper.ReadFixedString stream 260
            t.path          = getFilenamePath t.file
            t.fileNameOnly  = getFilenameFile t.file
            t.extension     = getFilenameType t.file 
            t.flags         = readLong stream
            
            if DEBUG_MODE then Format "%\n" t
            append texs t
        )
        return texs
    ),
    function ReadGEOS stream tag=
    (
        struct WC3Ref_GEO
            ( MATS, VRTX = #(), NRMS = #(), PTYP = #(), PCNT = #(), PVTX = #(), GNDX = #(), MTGC = #(), TANG = #(), SKIN = #(), UVS = #(), meshRef ) 

        struct WC3Ref_MATS
            ( MTLS_Id, LOD_Id, Name, SectionGroupId, SectionGroupType, Matrices = #(), floats =  #(), bounding = #() )
        
        struct WC3Ref_SKIN
            ( BoneIds = #(), Weights = #() )
        
        fseek stream tag.offset #seek_set
        
        local id = 1
        local geos = #()

        while ( fTell stream < ( tag.offset + tag.Size ) ) do
        (
            local geo = WC3Ref_GEO() 

            id +=1
            local nextOffset = ftell stream
            local chunk_size = readLong stream
            nextOffset += chunk_size
            for h=1 to 11 do
            (
                local header = _helper.ReadFixedString stream 4

                if header == "VRTX" then (
                    for v=1 to (readLong stream) do append geo.vrtx (_helper.ReadVector3 stream)
                )
                    
                if header == "NRMS" then 
                    for v=1 to (readLong stream) do append geo.nrms (_helper.ReadVector3 stream)

                if header == "PTYP" then 
                    for v=1 to (readLong stream) do append geo.ptyp (readLong stream)
                
                if header == "PCNT" then 
                    for v=1 to (readLong stream) do append geo.pcnt (readLong stream)
                
                if header == "PVTX" then 
                    for v=1 to (readLong stream)/3 do append geo.pvtx (_helper.ReadTris stream)
                
                if header == "GNDX" then
                    for v=1 to (readLong stream) do append geo.gndx (readbyte stream + 1)
                
                if header == "MTGC" then 
                    for v=1 to (readLong stream) do append geo.mtgc (readLong stream)
                
                if header == "MATS" then 
                (
                    geo.MATS = WC3Ref_MATS()
                    
                    for v=1 to (readLong stream) do append geo.MATS.matrices (readLong stream + 1)
                    
                    geo.MATS.MTLS_Id = readlong stream + 1
                    geo.MATS.SectionGroupId = readlong stream
                    geo.MATS.SectionGroupType = readLong stream 
                    geo.MATS.LOD_Id = readLong stream
                    geo.MATS.name = _helper.ReadFixedString stream 80
                    
                    for i=1 to 7 do  append geo.MATS.Bounding ( readfloat stream )
                    
                    local nbrFloats = readLong stream
                    for i=1 to nbrFloats * 7 do append geo.MATS.floats ( readFloat stream )
                    
                )
                
                if header == "TANG" then
                    for v=1 to (readLong stream) do append geo.TANG (_helper.ReadVector4 stream)

                if header == "SKIN" then
                (
                    local size = readLong stream 
                    for v=1 to (size/8) do
                    (
                        local boneWeights = WC3Ref_SKIN()
                        for i=1 to 4 do append boneWeights.boneIds ((readByte stream #unsigned) + 1 )
                        for i=1 to 4 do append boneWeights.weights ((readByte stream #unsigned) / 255.0 )
                        
                        append geo.skin boneWeights
                    )
                )
                
                if header == "UVAS" then 
                (
                    for i=1 to (readLong stream) do
                    (
                        local uvs = #()
                        local uvbs = _helper.ReadFixedString stream 4
                        local nUvbs = readLong stream
                        for u=1 to nUvbs do
                            append uvs ( [readFloat stream, 1.0 - readFloat stream, 0.0] )

                        append geo.UVS uvs
                    )
                )
                
                
                
                
            )
            append geos geo

            if DEBUG_MODE then Format "%\n" geo.MATS
            
            fseek stream nextOffset #seek_set
            
        )
        
        return geos
        
    ),
    function ReadGEOA stream tag=
    (
        struct WC3Ref_GEOA (
            size, 
            geoId,   --> referencing mesh object
            opacity, --> starting opacity
            color,   --> starting color
            type,    --> base animation type
            KGAO,    --> animated opacity
            KGAC     --> animated color
        )
        
        local totalSize = tag.Size
        local currentOffset = tag.Offset
        local geoa = #()
        
        while ( totalSize > 0 ) do
        (
            fseek stream currentOffset #seek_set
            local kgao = undefined --> weird memory leak ...
            local g = WC3Ref_GEOA()
            g.size      = readLong stream
            g.opacity   = readFloat stream
            g.type      = readLong stream 
            g.color     = color (readFloat stream * 255.0) (readFloat stream * 255.0) (readFloat stream * 255.0) 1.0
            g.geoId     = readlong stream + 1
            
            if ( g.size > 28 ) then (
            for a=1 to 2 do
            (
                local animBlock = _helper.ReadFixedString stream 4
                if ( animBlock == "KGAO" ) then g.KGAO = _reader.ReadFloatAnim stream 
                if ( animBlock == "KGAC" ) then g.KGAC = _reader.ReadColorAnim stream 
            ))

            append geoa g
            if DEBUG_MODE then format "%\n" g
            totalSize -= g.Size
            currentOffset += g.Size
        )
    
        return geoa
    ),
    function ReadBONE stream tag=
    (
        struct WC3Ref_BONE ( Id, Name, ParentBoneId, Flags, boneRef, KGTR, KGRT, KGSC, offset, geosetId, geosetAnimationId )
        
        fseek stream tag.offset #seek_set
                
        local boneList = #()

        /* read the bone chunks*/
        while ( (ftell stream) < tag.offset + tag.size ) do
        (
            local b = WC3Ref_BONE()
            
            local size = readLong stream
        
            b.Name = _helper.ReadFixedString stream 80
            b.Id = readLong stream + 1
            b.ParentBoneId = readLong stream + 1
            
            b.Flags = readLong stream
            b.offset = ftell stream
            
            _helper.SkipBytes stream ( size - 80 - 16 )
            
            b.geosetId =  readlong stream
            b.geosetAnimationId =  readlong stream

            append boneList b
        )
        /* read the animation frames */
        for b in boneList do
        (
            fseek stream b.offset #seek_set

            local kgtr -- transformation
            local kgrt -- rotation
            local kgsc -- scale
            
            for i=1 to 3 do
            (
                local kg = _helper.ReadFixedString stream 4

                if ( kg == "KGTR" ) then kgtr = _reader.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then kgrt = _reader.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then kgsc = _reader.ReadVector3Anim stream -- Key Global Scale
            )
            
            b.KGTR = kgtr
            b.KGRT = kgrt
            b.KGSC = kgsc
            
            if DEBUG_MODE then Format "%\n" b
            
        )
        
        return boneList
    ),
    function ReadHELP stream tag=
    (
        struct WC3Ref_HELP ( Id, Name, ParentId, Flags, kgtr, kgrt, kgsc )
        
        local totalSize = tag.Size
        local WC3Ref_HELP = #()
        local offset = tag.offset
        
        while ( totalSize > 0 ) do
        (
            fseek stream offset #seek_set        
            local h = WC3Ref_HELP()
            
            size = readLong stream
            h.name = _helper.ReadFixedString stream 80
            h.id = readLong stream + 1 
            h.parentId = readLong stream + 1 
            h.flags = readLong stream
            
            local kgtr -- transformation
            local kgrt -- rotation
            local kgsc -- scale
            
            for i=1 to 3 do
            (
                local kg = _helper.ReadFixedString stream 4

                if ( kg == "KGTR" ) then kgtr = _reader.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then kgrt = _reader.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then kgsc = _reader.ReadVector3Anim stream -- Key Global Scale
            )

            h.KGTR = kgtr
            h.KGRT = kgrt
            h.KGSC = kgsc
            
            totalSize -= size
            offset += size
            if ( _debug_read ) then format "%\n" h
            append wc3_helpers h
        )
        
        
    ),
    function ReadATCH stream tag=
    (
        struct WC3Ref_ATCH ( Id, ParentId, Name, Flags, FullPath, Size, Offset, KGTR, KGRT, KGSC, KATV)
        
        local atchs = #()
        local totalSize = tag.Size
        local offset = tag.Offset
        
        while ( totalSize > 0 ) do
        (
            fseek stream offset #seek_set
            
            local att = WC3Ref_ATCH()
            
            att.size       = readLong stream
            local headerSize = readLong stream --> 96 bytes consisting of name, id, parentId and flagid and headerSize
            att.name     = _helper.ReadFixedString stream 80
            att.Id       = readLong stream + 1
            att.ParentId = readLong stream + 1
            att.flags    = readLong stream
            att.offset   = ftell stream
            append atchs att
            
            totalSize -= att.Size
            offset += att.Size
        )
        
        for att in atchs do
        (
            fseek stream att.offset #seek_set
            local kgtr -- transformation
            local kgrt -- rotation
            local kgsc -- scale
            
            for i=1 to 3 do
            (
                local kg = _helper.ReadFixedString stream 4

                if ( kg == "KGTR" ) then kgtr = _reader.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then kgrt = _reader.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then kgsc = _reader.ReadVector3Anim stream -- Key Global Scale
            )
            
            att.KGTR = kgtr
            att.KGRT = kgrt
            att.KGSC = kgsc
            local correction = 0
            if ( kgtr == undefined ) then correction = correction + 4
            if ( kgrt == undefined ) then correction = correction + 4
            if ( kgsc == undefined ) then correction = correction + 4
           
            _helper.SkipBytes stream ( 264 - correction)

            local katv = _helper.ReadFixedString stream 4
            
            if( katv == "KATV") then att.katv = _reader.ReadFloatAnim stream -- visibility track

            if DEBUG_MODE then format "%\n" att
            
        )
        
        return atchs
        
    ),
    function ReadPIVT stream tag=
    (
        struct WC3Ref_PIVT ( Id, Position )
        fseek stream tag.offset #seek_set
        local nbr = tag.Size / 12.0
        local pivts = #()
        for n=1 to nbr do
        (
            local p = WC3Ref_PIVT()
            p.Id = n as integer
            p.Position = [readfloat stream, readfloat stream, readfloat stream]
            append pivts p
            
            if DEBUG_MODE then format "%\n" p
        )
        return pivts
        
    ),
    function ReadCAMS stream tag=
    (
        struct WC3Ref_CAMS ( Name, Pos,  FOV, FarClip, NearClip, TargetPos, KCTR, KTTR, KCRL, objRef )
        
        fseek stream tag.Offset #seek_set
        
        local cams = #()
        local totalSize = tag.size
        
        while ( totalSize > 0) do
        (
            local size = readLong stream
            local cam = WC3Ref_CAMS()

            cam.Name = _helper.ReadFixedString stream 80
            cam.Pos = [readFloat stream,readFloat stream,readFloat stream]
            cam.FOV = radToDeg ( readFloat stream )
            cam.FarClip = readFloat stream
            cam.NearClip = readFloat stream
            cam.TargetPos = [readFloat stream,readFloat stream,readFloat stream]

            for i=1 to 3 do
            (
                local anim = _helper.ReadFixedString stream 4
                if ( anim == "KCTR" ) then cam.KCTR = _reader.ReadVector3Anim stream
                if ( anim == "KTTR" ) then cam.KTTR = _reader.ReadVector3Anim stream
                if ( anim == "KCRL" ) then cam.KCRL = _reader.ReadFloatAnim stream
            )
            
            if ( cam.KCTR == undefined ) then fseek stream -4 #seek_cur
            if ( cam.KTTR == undefined ) then fseek stream -4 #seek_cur
            if ( cam.KCRL == undefined ) then fseek stream -4 #seek_cur
            
            if DEBUG_MODE then format " - %\n" cam
            append cams cam

            totalSize -= size
        )
        
        return cams
    ),
    function ReadEVTS stream tag=
    (   
        struct WC3Ref_EVTS ( Id, Name, ParentId, Flags, KEVT, objRef )
        
        fseek stream tag.Offset #seek_set
        local evts = #()

        while ( ftell stream < (tag.offset + tag.size)) do
        (
            local evt = WC3Ref_EVTS()
            local size = readLong stream
            
            evt.name = _helper.ReadFixedString stream 80
            evt.id          = readLong stream + 1
            evt.parentId    = readLong stream + 1
            evt.flags       = readLong stream
            local kevt      = _helper.ReadFixedString stream 4
            
            if ( kevt == "KEVT" ) then
            (
                local keys = #()
                local nbr       = readLong stream
                local parentId  = readLong stream + 1
                for i=1 to nbr do 
                (
                    local key =  ( _helper.RoundToFrame ( readLong stream ) ) + 10
                    append keys key
                )
                evt.KEVT = keys
            )
            else
                fseek stream -4 #seek_cur
            
            if DEBUG_MODE then format "%\n" evt
            append evts evt
            
        )
        
        return evts
    ),
    function ReadCLID stream tag=
    (
        struct WC3Ref_CLID ( id, CollisionType, name, parentid, flags, KGTR, KGRT, KGSC,  StartPosition, EndPosition, Radius, size )
        /* Collision Types
            0: cube or box
            1: plane
            2: sphere
            3: cylinder
        */
        local clidList = #()
        local totalSize = tag.size
        local currentOffset = tag.Offset
        
        while ( totalSize > 0 ) do
        (
            fseek stream currentOffset #seek_set
            local startPos = ftell stream
            
            local clid = WC3Ref_CLID()
            
            clid.size = readLong stream
            clid.name = _helper.ReadFixedString stream 80
            clid.Id = readLong stream + 1
            clid.parentId = readLong stream + 1
            clid.flags = readLong stream

            for i=1 to 3 do
            (
                local kg = _helper.ReadFixedString stream 4

                if ( kg == "KGTR" ) then clid.KGTR = _reader.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then clid.KGRT = _reader.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then clid.KGSC = _reader.ReadVector3Anim stream -- Key Global Scale
            )
            local currentPos = ftell stream
            
            if (clid.KGTR == undefined ) then currentPos -=4
            if (clid.KGRT == undefined ) then currentPos -=4
            if (clid.KGSC == undefined ) then currentPos -=4
            
            fseek stream currentPos #seek_set
            
            clid.CollisionType = readLong stream
            clid.StartPosition = [readFloat stream, readFloat stream, readFloat stream]
            
            if ( clid.CollisionType != 2 ) then clid.EndPosition = [readFloat stream, readFloat stream, readFloat stream]
            
            if ( clid.CollisionType == 2 or clid.CollisionType == 3 ) then clid.radius = readFloat stream
            
            currentOffset = ftell stream
            append clidList clid
            local size = currentOffset - startPos
            totalSize -= size
            if DEBUG_MODE then format "%\n" clid
        )
        
        return clidList
    ),
    function ReadLITE stream tag=
    (
        local totalSize = tag.Size
        local lightList = #()
        
        struct WC3Ref_LITE (  
            id, name, parentId, flags, type, 
            farAttenStart, farAttenEnd, 
            rgbColor, rgbIntensity, 
            ambColor, ambIntensity, 
            KGTR, KGRT, KGSC, KLAV, KLAI,
            lightRef, size, headerSize)
        
        local currentOffset = tag.Offset
        while ( totalSize > 0 ) do
        (
            fseek stream currentOffset #seek_set
            local l = WC3Ref_LITE()
            
            l.size       = readLong stream
            l.headerSize = readLong stream
            l.name       = GriffonStudios_Helpers.ReadFixedString stream 80
            l.Id         = readLong stream + 1
            l.parentId   = readLong stream + 1
            l.flags      = readLong stream
            
            for i=1 to 3 do
            (
                local kg = _helper.ReadFixedString stream 4
                
                if ( kg != "KGTR" and kg != "KGRT" and kg != "KGSC" ) then  
                (
                    fseek stream -4 #seek_cur
                    exit
                )
                
                if ( kg == "KGTR" ) then l.KGTR = _reader.ReadVector3Anim stream -- Key Global Transformation
                if ( kg == "KGRT" ) then l.KGRT = _reader.ReadQuatAnim stream -- Key Global Rotation
                if ( kg == "KGSC" ) then l.KGSC = _reader.ReadVector3Anim stream -- Key Global Scale
            )
            
            l.Type          = readLong stream 
            l.farAttenStart = readFloat stream
            l.farAttenEnd   = readFloat stream
            l.rgbColor      = _reader.readColor stream
            l.rgbIntensity  = readFloat stream
            l.ambColor      = _reader.readColor stream
            l.ambIntensity  = readFloat stream
            
            for i=1 to 2 do
            (
                local kg = _helper.ReadFixedString stream 4            
                if ( kg != "KLAV" and kg != "KLAI" ) then  (
                    fseek stream -4 #seek_cur
                    exit
                )
                
                if ( kg == "KLAV" ) then l.KLAV = _reader.ReadFloatAnim stream -- visibility
                if ( kg == "KLAI" ) then l.KLAI = _reader.ReadFloatAnim stream -- intensity
            
            )
            totalSize -= l.size
            currentOffset = currentOffset + l.Size
            
            if DEBUG_MODE then format "%\n" l
            
            append lightList l
            
        )
        return lightList
    ),
    function ReadTXAN stream tag=
    (
        struct WC3Ref_TXAN ( KTAT, KTAR, KTAS )
        
        local offset = tag.offset
        fseek stream offset #seek_set
        
        local txans = #()
        local totalSize = tag.Size
        
        while ( ftell stream < tag.offset + tag.size ) do
        (
            fseek stream offset #seek_set
            
            local size = readLong stream
            offset += size
            
            local txan = WC3Ref_TXAN()
            
            for i=1 to 3 do
            (
                local kg = _Helper.ReadFixedString stream 4
                if( kg == "KTAT" ) then txan.KTAT = _reader.ReadVector3Anim stream
                if( kg == "KTAR" ) then txan.KTAR = _reader.ReadQuatAnim stream
                if( kg == "KTAS" ) then txan.KTAS = _reader.ReadVector3Anim stream
            )
            if ( txan.KTAT == undefined ) then fseek stream -4 #seek_cur
            if ( txan.KTAR == undefined ) then fseek stream -4 #seek_cur
            if ( txan.KTAS == undefined ) then fseek stream -4 #seek_cur
            append txans txan
            
            if DEBUG_MODE then format "%\n" txan
            
        )
        
        return txans
    ),
    function ReadRIBB stream tag=
    (
        struct WC3Ref_RIBB 
            ( id, name,  parentId, flags, above, below, edgesSec, edgesLife, gravity, vAlpha, vColor, flipbookRows, flipbookCols, flipBookSlot, mtlsId,
              KGTR, KGRT, KGSC, 
              KRHA, -- height above
              KRHB, -- height below
              KRAL, -- alpha
              KRCO, -- color
              KRTX, -- textureSlot
              KRVS, -- visibility
              size, headerSize
            )
        
        fseek stream tag.offset #seek_set
        
        local totalSize = tag.size
        local ribbs = #()
        
        while (totalSize > 0 ) do
        (
            local ribb = WC3Ref_RIBB()
            
            ribb.size         = readLong stream
            ribb.headerSize   = readLong stream
            ribb.name         = _helper.ReadFixedString stream 80
            ribb.id           = readLong stream + 1
            ribb.parentId     = readLong stream + 1
            ribb.flags        = readLong stream
            
            totalSize        -= ribb.size
            
            for i=1 to 3 do
            (
                local kg = _helper.ReadFixedString stream 4
                if( kg == "KGTR" ) then ribb.KGTR = _reader.ReadVector3Anim stream
                if( kg == "KGRT" ) then ribb.KGRT = _reader.ReadQuatAnim stream
                if( kg == "KGSC" ) then ribb.KGSC = _reader.ReadVector3Anim stream
            )
            
            if( ribb.KGSC == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KGTR == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KGRT == undefined ) then fseek stream -4 #seek_cur
            
            ribb.above          = readFloat stream
            ribb.below          = readFloat stream
            ribb.valpha         = readFloat stream
            ribb.vcolor         = _reader.ReadColor stream
            ribb.edgesLife      = readFloat stream
            ribb.flipBookSlot   = readLong stream
            ribb.edgesSec       = readLong stream
            ribb.flipbookRows   = readLong stream
            ribb.flipbookCols   = readLong stream
            ribb.mtlsId         = readLong stream + 1
            ribb.gravity        = readFloat stream
      
            for i=1 to 6 do
            (
                local kg = _helper.ReadFixedString stream 4
                if( kg == "KRHA" ) then ribb.KRHA = _reader.ReadFloatAnim stream -- heightAbove
                if( kg == "KRHB" ) then ribb.KRHB = _reader.ReadFloatAnim stream  -- heightBelow
                if( kg == "KRAL" ) then ribb.KRAL = _reader.ReadFloatAnim stream -- alpha
                if( kg == "KRCO" ) then ribb.KRCO = _reader.ReadColorAnim stream -- color
                if( kg == "KRTX" ) then ribb.KRTX = _reader.ReadLongAnim stream  -- texture
                if( kg == "KRVS" ) then ribb.KRVS = _reader.ReadFloatAnim stream -- visibility
            )
            if( ribb.KRHA == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRHB == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRAL == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRCO == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRTX == undefined ) then fseek stream -4 #seek_cur
            if( ribb.KRVS == undefined ) then fseek stream -4 #seek_cur
            
            append ribbs ribb
            if DEBUG_MODE then format "%\n" ribb
        )

        return ribbs
    ),
    function ReadPRE2 stream tag=
    (
        struct WC3Ref_PRE2 (
            Id, Name, ParentId, Flags, FlagSettings, 
            KGTR, KGRT, KGSC, KP2V, KP2E,
            speed,
            variation,
            coneAngle,
            gravity,    
            lifespan,
            emissionrate,
            length, 
            width,
            emitterType,
            rowCount,
            colCount,
            particleType,
            tailLength,
            midTime,
            startColor,
            midColor,
            endColor,
            startAlpha,
            midAlpha,
            endAlpha,
            startSize,
            midSize,
            endSize,
            startLifespanUVAnim,
            midLifespanUVAnim,
            endLifespanUVAnim,
            startDecayUVAnim,
            midDecayUVAnim,
            endDecayUVAnim,
            startTailUVAnim,
            midTailUVAnim,
            endTailUVAnim,
            startTailDecayUVAnim,
            midTailDecayUVAnim,
            endTailDecayUVAnim,
            squirt,
            textureId,
            replacableTextureId,
            priorityPlane,
            size, headersize
        )
        
        struct WC3Ref_PRE2_FlagSettings(
            UNSHADED = false,
            SORT_PRIMITIVES_FAR_Z = false,
            LINE_EMITTER = false,
            PARTICLE_UNFOGGED = false,
            PARTICLE_USE_MODEL_SPACE = false,
            PARTICLE_INHERIT_SCALE = false,
            PARTICLE_INSTANT_VELOCITY_LIN = false,
            PARTICLE_0XKILL = false,
            PARTICLE_Z_VELOCITY_ONLY = false,
            PARTICLE_TUMBLER = false,
            PARTICLE_TAIL_GROWS = false,
            PARTICLE_EXTRUDE = false,
            PARTICLE_XYQUADS = false,
            PARTICLE_PROJECT = false,
            PARTICLE_FOLLOW = false
        )
        
        local offset = tag.offset
        local pre2s = #()
        local totalSize = tag.Size
        
        while (ftell stream < (tag.offset + tag.size ) ) do
        (
            fseek stream offset #seek_set
            
            local pe = WC3Ref_PRE2()
            pe.size = readLong stream
            
            offset += pe.size
            
            pe.headerSize = readLong stream
            pe.name      = GriffonStudios_Helpers.ReadFixedString stream 80
            pe.id        = readLong stream + 1
            pe.parentId  = readLong stream + 1
            pe.flags     = readLong stream -- 4096
            
            if DEBUG_MODE then format " - %\n" pe.name
            
            local flagSettings = WC3Ref_PRE2_FlagSettings()
            
            if (pe.flags > 0) then 
            (
                if ( (bit.and pe.flags 0x00008000) > 0 ) then flagSettings.UNSHADED = true
                if ( (bit.and pe.flags 0x00010000) > 0 ) then flagSettings.SORT_PRIMITIVES_FAR_Z = true
                if ( (bit.and pe.flags 0x00020000) > 0 ) then flagSettings.LINE_EMITTER = true
                if ( (bit.and pe.flags 0x00040000) > 0 ) then flagSettings.PARTICLE_UNFOGGED = true
                if ( (bit.and pe.flags 0x00080000) > 0 ) then flagSettings.PARTICLE_USE_MODEL_SPACE = true
                if ( (bit.and pe.flags 0x00100000) > 0 ) then flagSettings.PARTICLE_INHERIT_SCALE = true
                if ( (bit.and pe.flags 0x00200000) > 0 ) then flagSettings.PARTICLE_INSTANT_VELOCITY_LIN = true
                if ( (bit.and pe.flags 0x00400000) > 0 ) then flagSettings.PARTICLE_0XKILL = true
                if ( (bit.and pe.flags 0x00800000) > 0 ) then flagSettings.PARTICLE_Z_VELOCITY_ONLY = true
                if ( (bit.and pe.flags 0x01000000) > 0 ) then flagSettings.PARTICLE_TUMBLER = true
                if ( (bit.and pe.flags 0x02000000) > 0 ) then flagSettings.PARTICLE_TAIL_GROWS = true
                if ( (bit.and pe.flags 0x04000000) > 0 ) then flagSettings.PARTICLE_EXTRUDE = true
                if ( (bit.and pe.flags 0x08000000) > 0 ) then flagSettings.PARTICLE_XYQUADS = true
                if ( (bit.and pe.flags 0x10000000) > 0 ) then flagSettings.PARTICLE_PROJECT = true
                if ( (bit.and pe.flags 0x20000000) > 0 ) then flagSettings.PARTICLE_FOLLOW = true
            )
            pe.FlagSettings = flagSettings
            
            for i=1 to 3 do
            (
                local kg = _helper.ReadFixedString stream 4
                if( kg == "KGTR" ) then pe.KGTR = _reader.ReadVector3Anim stream
                if( kg == "KGRT" ) then pe.KGRT = _reader.ReadQuatAnim stream
                if( kg == "KGSC" ) then pe.KGSC = _reader.ReadVector3Anim stream
            )
            
            if( pe.KGSC == undefined ) then fseek stream -4 #seek_cur
            if( pe.KGTR == undefined ) then fseek stream -4 #seek_cur
            if( pe.KGRT == undefined ) then fseek stream -4 #seek_cur

            pe.speed         = readFloat stream
            pe.variation     = readFloat stream
            pe.coneAngle     = readFloat stream
            pe.gravity       = readFloat stream

            pe.lifespan      = readFloat stream
            pe.emissionrate  = readFloat stream
           
            pe.length        = readFloat stream
            pe.width         = readFloat stream
            
            pe.emitterType   = readLong stream
            pe.rowCount      = readLong stream
            pe.colCount      = readLong stream
            pe.particleType  = readLong stream
            
            pe.tailLength    = readFloat stream
            pe.midTime       = readFloat stream
            
            local r = ( readFloat stream * 255 ) as integer
            local g = ( readFloat stream * 255 ) as integer
            local b = ( readFloat stream * 255 ) as integer
            
            pe.startColor    = color r g b
            
            local r = ( readFloat stream * 255 ) as integer
            local g = ( readFloat stream * 255 ) as integer
            local b = ( readFloat stream * 255 ) as integer
            
            pe.midColor      = color r g b
            
            local r = ( readFloat stream * 255 ) as integer
            local g = ( readFloat stream * 255 ) as integer
            local b = ( readFloat stream * 255 ) as integer
            
            pe.endColor      = color r g b
            
            pe.startAlpha    = readByte stream
            pe.midAlpha      = readByte stream
            pe.endAlpha      = readByte stream 

            pe.startSize    = readFloat stream
            pe.midSize      = readFloat stream
            pe.endSize      = readFloat stream

            pe.startLifespanUVAnim   = readLong stream
            pe.midLifespanUVAnim     = readLong stream
            pe.endLifespanUVAnim     = readLong stream
            pe.startDecayUVAnim      = readLong stream
            pe.midDecayUVAnim        = readLong stream
            pe.endDecayUVAnim        = readLong stream
            pe.startTailUVAnim       = readLong stream
            pe.midTailUVAnim         = readLong stream
            pe.endTailUVAnim         = readLong stream
            pe.startTailDecayUVAnim  = readLong stream
            pe.midTailDecayUVAnim    = readLong stream
            pe.endTailDecayUVAnim    = readLong stream
            pe.textureId             = readLong stream
            pe.squirt                = readLong stream
            pe.replacableTextureId   = readLong stream 
            pe.priorityPlane         = readLong stream
              
            if DEBUG_MODE then format " - Tetxure Id : %\n" pe.textureId
              
            for i=1 to 2 do
            (
                local anim = _helper.ReadFixedString stream 4
                
                if (anim == "KP2V" ) then pe.kp2v = _reader.ReadFloatAnim stream -- visibility
                if (anim == "KP2E" ) then pe.kp2e = _reader.ReadFloatAnim stream -- emission
                
            )
            append pre2s pe
        )
       
        return pre2s
    ),
    function ReadBPOS stream tag=
    (
        struct WC3Ref_BPOS ( Id, Position )
        
        local bposList = #()
        
        fSeek stream tag.offset #seek_set
        
        local nbr = readLong stream
        
        for i=1 to nbr do
        (
            local m = matrix3 1
            m.row1 = [readfloat stream, readfloat stream, readfloat stream]
            m.row2 = [readfloat stream, readfloat stream, readfloat stream]
            m.row3 = [readfloat stream, readfloat stream, readfloat stream]
            m.row4 = [readfloat stream, readfloat stream, readfloat stream]
            append bposList m
            
            if DEBUG_MODE then 
                format "%\n" m.row4
            
        )
        bposList

    ),
    function ReadCORN stream tag=
    (
        fseek stream tag.offset #seek_set
        
        struct WC3Ref_CORN
            ( Id, Name, FileName, Properties, ParentId, Flags, 
                baseColor, baseColorAlpha, 
                teamColor, teamColorAlpha,
                KPPA, --> Alpha
                KPPV, --> Visibility
                KPPE, --> Emission 
                KPPS, --> Speed
                KPPL, --> LifeSpan
                KPPC, --> Color
                KGSC, 
                KGTR, 
                KGRT )
        
        local totalSize = tag.Size
        local corn = #()
        
        while (totalSize > 0 ) do
        (
            local cor = WC3Ref_CORN()
            
            local chunkSize = readLong stream
            totalSize -= chunkSize
            
            local miniSize = readLong stream
            cor.name = _Helper.ReadFixedString stream 80
            cor.id = readLong stream + 1
            cor.parentId = readLong stream + 1
            cor.flags = readLong stream

            for i=1 to 3 do
            (
                local kg = _Helper.ReadFixedString stream 4
                if( kg == "KGSC" ) then cor.KGSC = _reader.ReadVector3Anim stream
                if( kg == "KGTR" ) then cor.KGTR = _reader.ReadVector3Anim stream
                if( kg == "KGRT" ) then cor.KGRT = _reader.ReadQuatAnim stream
            )
            if( cor.KGSC == undefined ) then fseek stream -4 #seek_cur
            if( cor.KGTR == undefined ) then fseek stream -4 #seek_cur
            if( cor.KGRT == undefined ) then fseek stream -4 #seek_cur
            
            cor.baseColor      = _reader.ReadColor stream
            cor.baseColorAlpha = readFloat stream
            cor.teamColor      = _reader.ReadColor stream
            cor.teamColorAlpha = readFloat stream
            
            cor.filename       = _Helper.ReadFixedString stream 260

            local props = _Helper.ReadFixedString stream 260
            cor.properties = filterString props ", "
            
            for i=1 to 6 do
            (
                local anim = GriffonStudios_Helpers.ReadFixedString stream 4
                if (anim == "KPPE") then cor.kppe = _reader.ReadFloatAnim stream -- emissive
                if (anim == "KPPA") then cor.kppa = _reader.ReadFloatAnim stream -- alpha
                if (anim == "KPPV") then cor.kppv = _reader.ReadFloatAnim stream -- visibility
                if (anim == "KPPL") then cor.kppl = _reader.ReadFloatAnim stream -- lifespan
                if (anim == "KPPS") then cor.kpps = _reader.ReadFloatAnim stream -- speed
                if (anim == "KPPC") then cor.kppc = _reader.ReadColorAnim stream -- color
            )
            if( cor.kppe == undefined ) then fseek stream -4 #seek_cur
            if( cor.kppa == undefined ) then fseek stream -4 #seek_cur
            if( cor.kppv == undefined ) then fseek stream -4 #seek_cur
            if( cor.kppc == undefined ) then fseek stream -4 #seek_cur
            if( cor.kppl == undefined ) then fseek stream -4 #seek_cur
            if( cor.kpps == undefined ) then fseek stream -4 #seek_cur

            if DEBUG_MODE then format "%\n" cor
            append corn cor
        )

        return corn
    ),
    function ReadFAFX stream tag=
    (
        fseek stream tag.offset #seek_set
        
        struct WC3Ref_FAFX
            ( Id, Name, ExternalFileName, objRef )
        
        local nbr = tag.size / 340
        
        local fafx = #()
        
        for i=1 to nbr do
        (
            local f = WC3Ref_FAFX()
            f.Id = i
            f.Name = _helper.ReadFixedString stream 80
            f.ExternalFileName = _helper.ReadFixedString stream 260
            if DEBUG_MODE then format "%\n" f
            append fafx f
        )
        
        return fafx
        
    )
)