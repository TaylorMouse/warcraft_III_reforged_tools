/*
    .SYNOPSIS
    | Importer for Warcraft III Reforged mdx
    
    .COPYRIGHT
    | (c)2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

    .CHANGELOG
    | 0.1 - Initial setup

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

/* Helper methods */
(
    fileIn "GriffonStudios_Helpers.ms"
    fileIn "GriffonStudios_Warcraft_3_Reforged_Read.ms"
    fileIn "GriffonStudios_Warcraft_3_Reforged_Build.ms"


    global DEBUG_MODE = false
    global WC3Ref_IMPORT_ALL_LOD = false
    global _helper = undefined
    global _reader = undefined
    global _build = undefined
)

STRUCT WC3REF_MDX
(
    function Import file=
    (
        if ( doesFileExist file != true ) then throw (format "[ERROR] File does not exist: %\n\n" file )
        
        clearListener()
        SetWaitCursor()
        
        animationRange = interval 0 100
        sliderTime = 0
        
        _helper = GriffonStudios_Helpers()
        _reader = Warcraft_3_Ref_Read()
        _build  = Warcraft_3_Ref_Build()
        
        struct mdx1000 
            ( TAGS, fileName, VERS, MODL, SEQS, GLBS, MTLS, TEXS, GEOS, CORN, FAFX,
              BONE, HELP, ATCH, CLID, GEOA, EVTS, PIVT, CAMS, LITE, TXAN, RIBB, PRE2, BPOS,
              objs = #()
            )
        local mdx = mdx1000 fileName:file
            
        format "Reading '%'\n" ( filenameFromPath  file )
            
        local stream = fOpen file "rb"        
        local streamLen = _helper.GetStreamLength stream
        
        mdx.TAGS = _reader.ReadTAGS1000 stream streamLen
            
        for tag in mdx.TAGS do
        (
            format "Processing %\n" tag.name

            if( tag.Name == "VERS" ) then mdx.vers = _reader.ReadVERS stream tag
            if( tag.Name == "MODL" ) then mdx.modl = _reader.ReadMODL stream tag
            if( tag.Name == "SEQS" ) then mdx.seqs = _reader.ReadSEQS stream tag
            if( tag.Name == "MTLS" ) then mdx.mtls = _reader.ReadMTLS stream tag
            if( tag.Name == "GLBS" ) then mdx.glbs = _reader.ReadGLBS stream tag
            if( tag.Name == "TEXS" ) then mdx.texs = _reader.ReadTEXS stream tag
            if( tag.Name == "GEOS" ) then mdx.geos = _reader.ReadGEOS stream tag
            if( tag.Name == "GEOA" ) then mdx.geoa = _reader.ReadGEOA stream tag
            if( tag.Name == "BONE" ) then mdx.bone = _reader.ReadBONE stream tag
            if( tag.Name == "HELP" ) then mdx.help = _reader.ReadHELP stream tag
            if( tag.Name == "ATCH" ) then mdx.atch = _reader.ReadATCH stream tag 
            if( tag.Name == "PIVT" ) then mdx.pivt = _reader.ReadPIVT stream tag
            if( tag.Name == "CAMS" ) then mdx.cams = _reader.ReadCAMS stream tag
            if( tag.Name == "EVTS" ) then mdx.evts = _reader.ReadEVTS stream tag            
            if( tag.Name == "CLID" ) then mdx.clid = _reader.ReadCLID stream tag
            if( tag.Name == "LITE" ) then mdx.lite = _reader.ReadLITE stream tag
            if( tag.Name == "TXAN" ) then mdx.txan = _reader.ReadTXAN stream tag
            if( tag.Name == "RIBB" ) then mdx.ribb = _reader.ReadRIBB stream tag
            if( tag.Name == "PRE2" ) then mdx.pre2 = _reader.ReadPRE2 stream tag
            if( tag.Name == "BPOS" ) then mdx.bpos = _reader.ReadBPOS stream tag
            if( tag.Name == "CORN" ) then mdx.bpos = _reader.ReadCORN stream tag
            if( tag.Name == "FAFX" ) then mdx.bpos = _reader.ReadFAFX stream tag
            
        )
        
        fClose stream
        
        _build.Create mdx
        
        format "Done!\n"
        gc()
        clearSelection()
        max tool zoomextents all --> zoom out
        setArrowCursor() 
    )
)

(
    max unhide all
    max unfreeze all
    max select all
    max delete

    local file = @"G:\Blizzard\Warcraft - Reforged\Extracted\Assets\units\critters\frog\frog.mdx"
    WC3REF_MDX.Import file
)
