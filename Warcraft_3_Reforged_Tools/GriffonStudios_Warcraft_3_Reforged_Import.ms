/*
    .SYNOPSIS
    | Importer for Warcraft III Reforged mdx
    
    .COPYRIGHT
    | (c)2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

    .CHANGELOG
    | 0.1 - Initial setup

*/

(
    fileIn "GriffonStudios_Helpers.ms"
    fileIn "GriffonStudios_Warcraft_3_Reforged_Read.ms"
    fileIn "GriffonStudios_Warcraft_3_Reforged_Build.ms"

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
            
        format "\nReading '%'\n\n" ( filenameFromPath  file )
            
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
            if( tag.Name == "CORN" ) then mdx.corn = _reader.ReadCORN stream tag
            if( tag.Name == "FAFX" ) then mdx.fafx = _reader.ReadFAFX stream tag
            if( tag.Name == "BPOS" ) then mdx.bpos = _reader.ReadBPOS stream tag
            
        )
        
        fClose stream
        _build.Create mdx
        format "Done!\n"
        gc()
        clearSelection()
        max tool zoomextents all
        setArrowCursor() 
    )
)