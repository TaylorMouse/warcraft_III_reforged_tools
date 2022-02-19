/*
    .SYNOPSIS
    | Opens up a popup window that reads the data from the notes track in Max and interpretes them as animation sequences
    | Compatible with Warcraft III, Warcraft III Reforged and StarCraft II
    
    .COPYRIGHT
    | © 2020 - 2022 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

*/

rollout GriffonStudios_AnimationWindow_v2 "Animation Window v2" 
    width:250 
(

    dropdownlist ddlTracks "" height:20
    dotNetControl lv "System.Windows.Forms.ListView" width:230 height:350 align:#center
    checkbox cbUpdateTimeLine "Update timeline" checked:true
    checkbox cbSortByTime "Sort by time" checked:true
    --checkbox cbAutoPlay "Auto play animation" checked:false
    
    button btn_RefreshList "Refresh" align:#right offset:[0,-40] width:80
    button btn_PlayAnimation "►" align:#right offset:[-30,0] height:25 width:25 tooltip:"Play selected animation"
    button btn_StopAnimation "█" align:#right offset:[0,-30] height:25 width:25 tooltip:"Stop animation"
    
    
    local leftPos = - 20
    local selectedAnimationTrack = undefined 
    local selectedAnimation = undefined
    local selectedAnimationName = ""
    
    group "Properties"
    (
        edittext txt_newName "" width:120 
        button btn_rename "Update" width:80 height:20 offset:[70,-25] tooltip:"Update the name or the properties of this animation sequence"
        
        label lblStartFrame "Start "    align:#left
        spinner txt_StartFrame ""       width:50 offset:[leftPos,-20] type:#integer range:[0,100000,0]

        label lblEndFrame "End "        align:#left
        spinner txt_EndFrame ""         width:50 offset:[leftPos,-20] type:#integer range:[0,100000,0]

        label lblRarity "Rarity (%)"    align:#left
        spinner spinRarity ""           width:50 offset:[leftPos,-20] type:#integer

        label lblMovementSpeed "Movement Speed" align:#left
        spinner spinMovementSpeed ""    width:50 offset:[leftPos,-20] type:#float range:[0,1000,0]
        
        label lblPriority "Priority"    align:#left
        spinner spinPriority ""         width:50 offset:[leftPos,-20] type:#integer

        label lblNonLooping "Non-Looping" align:#left
        checkbox chkNonLooping "" offset:[122,-20]
        

    )

    group "Add new animation"
    (
        edittext txt_newAnimName "" width:120 
        button btn_add "Add" width:80 height:20 offset:[70,-25]
        checkbox chk_useTrackBar "Use start and end frame from the track bar"
    )
    
    group "Other"
    (
        button btn_delete "Remove selected animation" width:180 height:30
        button btn_removeNoteTrack "Remove all animations (note track)" width:180 height:30
        button btn_ExportNoteTrack "Export note track" width:180 height:30
        button btn_ImportNoteTrack "Import note track" width:180 height:30
    )
    
    label lblTM "\xa9 2021 Taylor Mouse"
    
    function ExportNoteTrack= 
    (
        if( hasNoteTracks rootNode == true ) then
        (
            local output_file = getSaveFileName \
                            caption:"Note Track Export" \
                            types:"Note track (*.notetrack)|*.notetrack|All Files (*.*)|*.*|" \
                            historyCategory:"NoteTrackImportExportHistory"


            if output_file != undefined then ( 
                local stream = fOpen output_file "wb"
                local myTrack = getNoteTrack rootNode 1

                writeLong stream myTrack.keys.count
                
                for key in myTrack.keys do
                (
                    local t =  (key.time as integer / TicksPerFrame)
                    
                    local note = key.value
                    local noteParts = filterString note "\r\n"
                    local nNotes = noteParts.Count
                    
                    writeLong stream t
                    writeLong stream nNotes
                    format "%\n" t
                    format "%\n" nNotes
                    for n=1 to nNotes do (
                        format "%\n" noteParts[n]
                        writeString stream noteParts[n]
                    )
                    format "\n"
                )
                
                fClose stream
                fflush stream
            )
        )
    )

    function SetAnimationNoteTrack anim validate=
    (
        local starAnimTrack = undefined
        if selectedAnimationTrack == undefined or selectedAnimationTrack == 0 then selectedAnimationTrack = 1
           
        local strLastNoteFrame = "0f"
        local lastNoteFrame = 0
        
        if( (hasNoteTracks rootNode) == true ) then
        (
            starAnimTrack    = getNoteTrack rootNode selectedAnimationTrack
            if ( starAnimTrack.keys.count > 0 ) then
                lastNoteFrame = ( getNoteKeyTime starAnimTrack starAnimTrack.keys.count ) as integer / TicksPerFrame
                
        )
        else
        (
            starAnimTrack = notetrack "AnimTrack"
            addNoteTrack rootNode starAnimTrack
        )
        
        local noteExists = getNoteKeyIndex starAnimTrack  anim.start_frame
        
        /* validation */
        local isValid = true
        if ( anim.start_frame >= anim.end_frame ) then isValid = false
        if ( anim.start_frame <= lastNoteFrame ) then isValid = false
        
        if isValid == false and validate == true then 
        (
            messagebox "One of the following was invalid:\nEnd Frame must be higher then the Start Frame\nThe start frame must start later then the previous end frame"
            return false
        )
        /* apply new notes */
        
        if( noteExists == undefined) then
        (
            --( name, start_frame, end_frame, rarity, movement_speed, priority, non_looping )
            
            local startNote = AddNewNoteKey starAnimTrack anim.start_frame
            local endNote = AddNewNoteKey starAnimTrack anim.end_frame
            
            /* this is based on StarCraft 2 animation note track */
            local val = anim.name + "\r\n"
                  val += "rarity = " + anim.rarity + "\r\n"
                  val += "moveSpeed = " + anim.movement_speed + "\r\n"
                  val += "nonLoop = " + anim.non_looping + "\r\n"
                  val += "default_Anim = false\r\nsub_anim = false\r\ndefaultPriority = " + anim.priority

            startNote.Value = val
            endNote.Value = val
            
        )

        return true
    )

    function ResetTrackList=
    (
        local nNoteTracks = numNoteTracks rootNode
        local items = #()
        for i=1 to nNoteTracks do
        (
            local track = getNoteTrack rootNode i
            local name = track.name
            if track.name == undefined or track.name == "" then
            (
                name = "Animation track " + ( i as string )
            )
            append items name
        )
        
        if items.count > 0 then 
        (
            selectedAnimationTrack = 1
            ddlTracks.items = items
            ddlTracks.selection = 1
        )
    )
    
    function ResetListView=
    (
        local items = #()
        lv.Items.Clear()
        lv.ListViewItemSorter = undefined
        lv.Sorting = undefined
        
        /* Check if there is a note track */
        local nNoteTracks = numNoteTracks rootNode

        local animationNames = #()
        
        if(nNoteTracks > 0) then
        (
            if selectedAnimationTrack == undefined or selectedAnimationTrack == 0 then selectedAnimationTrack = 1
            local track = getNoteTrack rootNode selectedAnimationTrack

            keys = track.Keys
            for i=1 to keys.count by 2 do
            (
                 local note = keys[i].value
                
                local parts = filterString note "\r\n"
                
                if ( parts.count > 0 ) then
                    append animationNames parts[1]
            )
            if (cbSortByTime.state == false ) then
                animationNames = sort animationNames
            
            for a in animationNames do
            (
                item = dotNetObject "System.Windows.Forms.ListViewItem"
                item.Text = a
                append items item
            )
            lv.Items.AddRange items
        )

    )
    
    function InitializeListView =
    (
        --format "Initializing listview ... \n"
        lv.View = (dotNetClass "System.Windows.Forms.View").Details
        lv.FullRowSelect = true
        lv.HideSelection = false
        lv.Columns.Add "Animation Name" -2

        lv.Sorting = (dotNetClass "System.Windows.Forms.SortOrder").Ascending

        ResetListView()
        ResetTrackList()
    )
    
    on btn_PlayAnimation pressed do playAnimation()
	on btn_StopAnimation pressed do stopAnimation()
    
    on btn_refreshList pressed do
    (
        ResetTrackList()
        ResetListView()
    )
    
    on cbSortByTime changed theState do
    (
        ResetTrackList()
        ResetListView()
    )
    
    function ImportNoteTrack= 
    (
        local input_file = getOpenFileName \
                            caption:"Note Track Import" \
                            types:"Note track (*.notetrack)|*.notetrack|All Files (*.*)|*.*|" \
                            historyCategory:"NoteTrackImportExportHistory"

        
        
        if input_file == undefined then return undefined
        
        if( hasNoteTracks rootNode ) then
        (
            local nNoteTracks = numNoteTracks rootNode
            for n=1 to nNoteTracks do 
                deleteNoteTrack rootNode ( getNoteTrack rootNode n )
        )

        local myTrack = noteTrack ( getfilenamefile input_file )
        
        format "My Track %\n" myTrack.name
        
        addNoteTrack rootNode myTrack
        
        local stream = fOpen input_file "rb"

        local nNotes = readLong stream
        
        format "Number of Notes %\n" nNotes
        
        for n=1 to nNotes do
        (
            local t = readLong stream
            local val = ""
            
            local nValues = readLong stream
            for v=1 to nValues do (
                val += readString stream + "\r\n"
            )

            local note = addNewNoteKey myTrack t
            note.value = val
            
            format "At time %: %\n" t val
            
        )
        fClose stream
        ResetTrackList()
        ResetListView()
    )
    
    on btn_removeNoteTrack pressed do
    (
        if selectedAnimationTrack == undefined or selectedAnimationTrack == 0 then selectedAnimationTrack = 1
        
        
        try(
            if ( numNoteTracks rootnode == 1 ) then
            (
                local track = getNoteTrack rootNode selectedAnimationTrack
                deleteNoteTrack rootnode track
                selectedAnimationTrack = undefined
                ResetTrackList()
                ResetListView()
            )
            
        )catch
        (
            messageBox "Unable to remove the animation note track" title:"Error occured deleting note track"
        )
    )
    
    on btn_add pressed do
    (
        if( txt_newAnimName.Text == "") then 
        (
            messageBox "Please enter a valid animation name!" title:"Incorrect Animation name"
            return undefined
        )
        
        struct animStruct ( name, start_frame, end_frame, rarity, movement_speed, priority, non_looping )
        
        local anim = animStruct()
        anim.name = txt_newAnimName.Text
        anim.start_frame    = txt_StartFrame.value
        anim.end_frame      = txt_EndFrame.value
        
        if ( chk_useTrackBar.checked ) then 
        (
            anim.start_frame    = animationrange.start as integer / ticksperframe
            anim.end_frame      = animationrange.end as integer / ticksperframe
        )   
        anim.rarity         = spinRarity.value as string
        anim.movement_speed = spinMovementSpeed.value as string
        anim.priority       = spinPriority.value as string
        anim.non_looping    = chkNonLooping.checked as string
        
        if ( SetAnimationNoteTrack anim true == true ) then (
            txt_newName.Text = anim.name
            txt_newAnimName.Text = ""
        )
        ResetTrackList()
        ResetListView()

        
    )
    
    on btn_rename pressed do
    (
        format "Updating %\n" selectedAnimation.name
        if( selectedAnimation == undefined or txt_newName.text == "") then return undefined
        if selectedAnimationTrack == undefined or selectedAnimationTrack == 0 then selectedAnimationTrack = 1
        
        local newName = txt_newName.text
        local track = getNoteTrack rootNode selectedAnimationTrack
        local keys = track.Keys

        struct animStruct ( name, start_frame, end_frame, rarity, movement_speed, priority, non_looping )
        
        local anim = animStruct()
        anim.name           = txt_newName.text
        anim.start_frame    = txt_StartFrame.value
        anim.end_frame      = txt_EndFrame.value
        anim.rarity         = spinRarity.value as string
        anim.movement_speed = spinMovementSpeed.value as string
        anim.priority       = spinPriority.value as string
        anim.non_looping    = chkNonLooping.checked as string
        
        format "%\n" anim
        
        for i=1 to keys.count by 2 do
        (
            local note = keys[i].value
            local parts = filterString note "\r\n"
            local animationName = parts[1]
            if( animationName == selectedAnimation.Text) then
            (
                local theKey = keys[i]
                try 
                (
                    deleteNoteKey keys (i+1)
                    deleteNoteKey keys i

                    local result = SetAnimationNoteTrack anim false
                    if ( result == false ) then
                    (
                        local startNote = AddNewNoteKey starAnimTrack anim.start_frame
                        local endNote = AddNewNoteKey starAnimTrack anim.end_frame
                        
                        /* this is based on StarCraft 2 animation note track */
                        local val = anim.name + "\r\n"
                              val += "rarity = " + anim.rarity + "\r\n"
                              val += "moveSpeed = " + anim.movement_speed + "\r\n"
                              val += "nonLoop = " + anim.non_looping + "\r\n"
                              val += "default_Anim = false\r\nsub_anim = false\r\ndefaultPriority = " + anim.priority

                        startNote.Value = val
                        endNote.Value = val
                    )
                    
                    exit
                )
                catch 
                (
                    format "[Error] %\n" (getCurrentException())
                        
                )
            )
        )
        
        ResetListView()
        ResetTrackList()
        selectedAnimation = undefined
        txt_newName.text = ""
    )
 
    on btn_delete pressed do
    (
        --format "Animation found:%\n" selectedAnimation
        if ( selectedAnimation == undefined) then return undefined
        
        local msg = "Are you sure you want to delete the animation ("+ selectedAnimation.Text + ")?\n\nNOTE:\nThis does not delete the actual keyframes only the entry in the list!"
        if selectedAnimationTrack == undefined or selectedAnimationTrack == 0 then selectedAnimationTrack = 1
        
       -- if( querybox msg Title:"Confirm animation delete" ) then
        (
            track = getNoteTrack rootNode selectedAnimationTrack
            keys = track.Keys

            for i=1 to keys.count by 2 do
            (
                local note = keys[i].value
                local pos = (findString note "\n") - 2
                local animationName = substring note 1 pos
                if( animationName == selectedAnimation.Text) then
                (
                    try 
                    (
                        deleteNoteKey keys (i+1)
                        deleteNoteKey keys i
                        exit
                    )
                    catch 
                    (
                        format "[Error] %\n" (getCurrentException())
                    )
                )
            )
            ResetListView()
        )
    )
    
    on GriffonStudios_AnimationWindow_v2 open do
    (
        
        --format "lv.ListViewItemSorter %\n" lv.ListViewItemSorter
        
        InitializeListView()


    )

    on lv ItemSelectionChanged arg do
    (
        if selectedAnimationTrack == undefined or selectedAnimationTrack == 0 then selectedAnimationTrack = 1
        stopAnimation()
        
        selectedAnimation = arg.Item
        local selectedAnimationName = selectedAnimation.Text
        txt_newName.text = selectedAnimationName
        
        local track = getNoteTrack rootNode selectedAnimationTrack
        local keys = track.Keys

        for i=1 to keys.count by 2 do
        (
            local note = keys[i].value
            local parts = filterString note "\r\n"
            local animationName = parts[1]
            
            if( animationName == selectedAnimation.Text) then
            (
                
                local startTime = (getnotekeytime track i)  as integer / TicksPerFrame
                local endTime = (getnotekeytime track (i+1)) as integer / TicksPerFrame

                --format "% (%-%)\n" selectedAnimationName startTime endTime
                    
                if ( startTime == endTime ) then endTime = startTime + 1
                
                if( cbUpdateTimeLine.checked ) then
                (
                    animationrange = interval startTime endTime
                    slidertime = startTime
                )

                txt_StartFrame.value = startTime
                txt_EndFrame.value = endTime
                chkNonLooping.checked = false
                
                local pos = findString note "\r\n"
                
                if pos != undefined then (
                    local props = substring note (pos+2) -1
                    parts = filterString props "\r\n "
                    
                    if parts.count >= 3 then spinRarity.value = parts[3] as integer
                    if parts.count >= 6 then spinMovementSpeed.value = parts[6] as float
                    if parts.count >= 9 then if parts[9] == "true" then chkNonLooping.checked = true
                    if parts.count >= 18 then spinPriority.value = parts[18] as integer
                    
                )
                exit
            )
        )
        
    )
    
    on ddlTracks selected selectedItem do
    (
        selectedAnimationTrack = selectedItem
        ResetListView()
    
    )
    
    on btn_ExportNoteTrack pressed do ExportNoteTrack()
    on btn_ImportNoteTrack pressed do ImportNoteTrack()
    
)