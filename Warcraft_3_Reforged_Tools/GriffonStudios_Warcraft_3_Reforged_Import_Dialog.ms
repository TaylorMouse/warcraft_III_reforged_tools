/*
    .SYNOPSIS
    | Opens up a popup window for importing Warcraft III Reforged mdx models
    
    .COPYRIGHT
    | �2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

*/
global DEBUG_MODE = false
global WC3Ref_IMPORT_ALL_LOD = true

rollout GriffonStudios_WC3Ref_ImportWindow "Warcraft III Reforged Import"
    width:320 
    height:270
(
    local configFile = (getdir #temp) + "\\wc3reftools.config"
    
    group "Settings"
    (
        checkbox chkDebugMode "Debug Mode" tooltip:"Warning, if checked this may take a long time to import"
        checkbox chkImportAllLOD "Import all Level of Details (LOD's)" checked:true
        label    lblSharedTextures "Shared texture folder:" align:#left
        edittext txtSharedTextureFolder "" width:270 height:25 align:#left offset:[-5,0]
        button   btnBrowseSharedTextures "..." height:25 align:#right offset:[4,-30]
    )
    group "Select mdx file:"
    (
        edittext txtSelectedFile width:270 height:25 align:#left offset:[-5,0]
        button btnBrowse "..." height:25 align:#right offset:[4,-30]
    )
    
    group "Import"
    (
        button btnImport "Import mdx (WC3 Reforged)" height:30 width:270 
    )
    label lbl1 "�2021 Warcraft III Reforged Tools by Taylor Mouse" align:#center
    
    
    on chkImportAllLOD changed theState do (
        WC3Ref_IMPORT_ALL_LOD = theState
        format "Import all LOD's: %\n" WC3Ref_IMPORT_ALL_LOD
    )
            
    on GriffonStudios_WC3Ref_ImportWindow open do
    (
        WC3Ref_IMPORT_ALL_LOD = true
        local sharedFolder = getinisetting configFile "WarcraftIIIReforged" "SharedTextureFolder"
        if sharedFolder == undefined then 
            txtSharedTextureFolder.text = "" 
        else 
            txtSharedTextureFolder.text = sharedFolder
    )    
    on btnBrowseSharedTextures pressed do
    (
        local sharedFolder = getSavePath \
                                caption:"Select Shared Teture Folder" \
                                initialDir:(txtSharedTextureFolder.text) \
                                historyCategory:"ReforgedSharedTexturePreset"
        
        if ( sharedFolder != undefined) then 
        (
            sharedFolder = sharedFolder  + "\\"   
            txtSharedTextureFolder.text = sharedFolder 
            setIniSetting configFile "WarcraftIIIReforged" "SharedTextureFolder" sharedFolder
        )
    )
    on btnBrowse pressed do
    (
        local file = getOpenFileName \
                    caption:"Warcraft III Reforged" \
                    types:"Supported Files|*.mdx|Warcraft III Reforged(*.mdx)|*.mdx|All Files|*.*" \
                    historyCategory:"ReforgedPreset"
        if (file != undefined) then 
            if (doesfileexist file == true ) then 
                txtSelectedFile.Text = file
    )
    on btnImport pressed do
    (
        fileIn "GriffonStudios_Warcraft_3_Reforged_Import.ms"
        local file = txtSelectedFile.Text
        if (doesfileexist file == true ) then 
            WC3REF_MDX.Import file
        else
            MessageBox "GriffonStudios_Warcraft_3_Reforged_Import.ms not found!" 
        
    )
)