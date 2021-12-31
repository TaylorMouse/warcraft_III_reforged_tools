/*
    .COPYRIGHT 
    | (c) 2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse
    
    .DESCRIPTION
    | Warcraft III Reforged mdx exporter 
    
    .PROGRESS

    | 0.01 - Main (re)setup

    
*/

GLOBAL _writer
GLOBAL _parser
GLOBAL DEBUG_MODE = false
GLOBAL WC3REF_INVERT_UVW = true

fileIn "GriffonStudios_Warcraft_3_Reforged_Parser.ms"
fileIn "GriffonStudios_Warcraft_3_Reforged_Write.ms"

STRUCT GriffonStudios_Warcraft_3_Reforged_Exporter
(
    function Export file=
    (
        -- do some checks first
        if ( file == undefined ) then return "No file name given"
        if ( objects.count == 0 ) then return "No objects to export"
        
        clearlistener()
        clearselection()
        setWaitCursor()
        --disableSceneRedraw()
        
        struct mdx1000 
            ( file, stream, VERS, MODL, SEQS, GLBS, MTLS, TEXS, GEOS, CORN, FAFX,
              BONE, HELP, ATCH, CLID, GEOA, EVTS, PIVT, CAMS, LITE, TXAN, RIBB, PRE2, BPOS,
              allObjects = #()
            )

        _writer = Warcraft_3_Ref_Write()
        _parser = Warcraft_3_Ref_Parser()
            
        local mdx = mdx1000 file:file
        
        -- set the scene for exporting
        local animationInterval = animationrange
        animationrange = interval 0 100
        slidertime = 0

        -- gather data from the scene
        _parser.GetObjects mdx
        _parser.GetSEQS mdx
        _parser.GetMTLS mdx
        _parser.GetTEXS mdx
        _parser.GetGEOS mdx
        _parser.GetGEOA mdx
        _parser.GetCAMS mdx
        _parser.GetFAFX mdx     


        -- write the parts to file
        mdx.stream = fOpen file "wb"

        _writer.WriteMDLX mdx
        _writer.WriteMODL mdx
        _writer.WriteSEQS mdx
        _writer.WriteMTLS mdx
        _writer.WriteTEXS mdx
        _writer.WriteGEOS mdx
        _writer.WriteGEOA mdx
        _writer.WriteBONE mdx
        _writer.WriteHELP mdx
        _writer.WriteATCH mdx
        _writer.WritePIVT mdx
        _writer.WriteEVTS mdx
        _writer.WriteCAMS mdx
        _writer.WriteCLID mdx
        _writer.WriteBPOS mdx

--         _writer.WriteCAMS mdx
--         _writer.WriteCORN mdx
--         _writer.WriteLITE mdx
--         _writer.WritePRE2 mdx
--         _writer.WriteRIBB mdx
--         _writer.WriteFAFX mdx


        fFlush mdx.stream
        fClose mdx.stream
        
        animationrange = interval animationInterval.start animationInterval.end
        gc() 
        --enableSceneRedraw() 
        setArrowCursor()   
    )
)