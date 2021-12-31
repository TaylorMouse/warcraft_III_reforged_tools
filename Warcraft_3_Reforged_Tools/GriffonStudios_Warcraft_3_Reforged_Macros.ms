/*
    .DESCRIPTION
    | Set of macros to handle Warcraft III Reforged Tools
    | Written by Taylor Mouse
    
    .DATE
    | 18.12.2021
    
    .RELEASENOTES
    | 0.2 - Revisit
    | 0.1 - INIT
    
*/

global Warcraft3_AssetFolder
global Warcraft3_ImportAllLOD = false

macroscript Warcaft3Reforged_ImportModel category:"Warcraft III Reforged Tools" tooltip:"Import model" 
(
    filein "GriffonStudios_Warcraft_3_Reforged_Import_Dialog.ms"
    if(GriffonStudios_WC3Ref_ImportWindow != undefined) then destroydialog GriffonStudios_WC3Ref_ImportWindow
        CreateDialog GriffonStudios_WC3Ref_ImportWindow width:320 lockwidth: true 
)

macroscript Warcraft3Reforged_ResetAnimationTracks category:"Warcraft III Reforged Tools" tooltip:"Reset Animation Tracks"
(
    local nNoteTracks = numNoteTracks rootNode
        
    if(  nNoteTracks > 0 ) then
    (
        for n=1 to nNoteTracks do 
            deleteNoteTrack rootNode (getNoteTrack rootNode 1)
    )
)

macroscript Warcaft3Reforged_ExportModel category:"Warcraft III Reforged Tools" tooltip:"Export model" 
(
    filein "GriffonStudios_Warcraft_3_Reforged_Exporter_Dialog.ms"
    if(GriffonStudios_WC3_ExportDialog != undefined) then destroydialog GriffonStudios_WC3_ExportDialog
        CreateDialog GriffonStudios_WC3_ExportDialog lockwidth: true
)

macroscript Warcaft3Reforged_Animations category:"Warcraft III Reforged Tools" tooltip:"Animation Selector" 
(
    filein "GriffonStudios_Warcraft_3_Reforged_AnimationProperties.ms"
    if(GriffonStudios_AnimationWindow_v2 != undefined) then destroydialog GriffonStudios_AnimationWindow_v2
        CreateDialog GriffonStudios_AnimationWindow_v2 lockwidth: true     
)

macroscript Warcaft3Reforged_About category:"Warcraft III Reforged Tools" tooltip:"About"
(
    if ( aboutWindow != undefined ) then destroydialog aboutWindow
    
    rollout aboutWindow "Warcraft III Reforged Tools" 
    (
        label lbl1 "©2020~2022 Griffon Studios" align:#center
        label lbl3 "Created by Taylor Mouse" align:#center
        label lbl2 "Get the latest version from my github:\n" align:#center
        hyperlink lnk1 "github.com/TaylorMouse/Warcraft III Reforged"  address:"https://github.com/TaylorMouse/warcraft_III_reforged_tools" align:#center color:(color 255 128 0)
        button btn "Close" height:30 width:80 offset:[0,10]
        
        on btn pressed do
        (
            destroydialog aboutWindow
        )
 
    )
    createdialog aboutWindow  width:300 lockwidth: true
    
)

macroscript Warcaft3Reforged_Ribbon category:"Warcraft III Reforged Tools" tooltip:"Create Ribbon" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Ribbon.ms"
    WC3RefRibbon()
)

macroscript Warcaft3Reforged_Event category:"Warcraft III Reforged Tools" tooltip:"Create Event" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Event.ms"
    WC3RefEvent()
)

macroscript Warcaft3Reforged_FaceFX category:"Warcraft III Reforged Tools" tooltip:"Create Face FX" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_FaceFX.ms"
    WC3RefFaceFX()
)

macroscript Warcaft3Reforged_Attachment category:"Warcraft III Reforged Tools" tooltip:"Create Attachment" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Attachment.ms"
    WC3RefAttachment()
)

macroscript Warcaft3Reforged_Particles  category:"Warcraft III Reforged Tools" tooltip:"Create Particle Emitter" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_Emitter.ms"
    WC3RefEmitter()
)

macroscript Warcaft3Reforged_PopCorn    category:"Warcraft III Reforged Tools" tooltip:"Create Popcorn Emitter" 
(
    fileIn "GriffonStudios_Warcraft_3_Reforged_Plugins_PopCorn.ms"
    WC3RefPopCorn()
)

macroscript Warcaft3Reforged_CollapseHitTests category:"Warcraft III Reforged Tools" tooltip:"Collapse Hit Tests" 
(
    for obj in objects do 
    (
        if ( findstring obj.name "B_KGS_" != undefined ) then
        (
            obj.wirecolor = color 0 64 255
            
            if ( obj.name == "B_KGS_Root") then obj.wirecolor = color 255 64 0
        
            freeze obj
            obj.boxmode = on
        )
    )    
)

macroscript Warcaft3Reforged_ExpandHitTests category:"Warcraft III Reforged Tools" tooltip:"Expand Hit Tests" 
(
    for obj in objects do 
    (
        if ( findstring obj.name "B_KGS_" != undefined ) then
        (
            unfreeze obj
            obj.boxmode = off
        )
    )    
)

macroscript Warcaft3Reforged_CollapseAttachments category:"Warcraft III Reforged Tools" tooltip:"Collapse Attachments" 
(
    for obj in objects do 
    (
        if( classof obj == WC3RefAttachment ) then 
        (
            freeze obj
        )
    )
)

macroScript Warcaft3Reforged_UserPropertyWindow
    category:"Warcraft III Reforged Tools"
    buttonText:"Show User Property Window"
    toolTip:"Show User Property Window"
    icon:#("GriffonStudios",5)
(
    on execute do (
        filein "GriffonStudios_Warcraft_3_Reforged_UserPropertyEditor.ms"

        if ( $ == undefined ) then 
        (
            messagebox "Please select an object first"
            return undefined
        )
        if ( $ != undefined ) then 
        (
        
            if(GriffonStudios_WC3Ref_UserPropertyEditor != undefined) then destroydialog GriffonStudios_WC3Ref_UserPropertyEditor
                CreateDialog GriffonStudios_WC3Ref_UserPropertyEditor lockwidth: true  
        )
    )
)


macroscript Warcaft3Reforged_ExpandAttachments category:"Warcraft III Reforged Tools" tooltip:"Expand Attachments" 
(
    for obj in objects do 
    (
        if( classof obj == WC3RefAttachment ) then 
        (
            unfreeze obj
        )
    )
)