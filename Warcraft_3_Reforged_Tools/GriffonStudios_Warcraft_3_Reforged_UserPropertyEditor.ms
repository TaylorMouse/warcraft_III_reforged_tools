/*
    .SYNOPSIS
    | Opens up a popup window that gets and set the userpoperies
    | this is a trimmed down version of the original Warcraft III Reforged User Porperty window
    | since the actual one only had a mere functionality anyways
    
    .COPYRIGHT
    | © 2022 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

*/
GLOBAL USERPROP_DEBUG = false

rollout GriffonStudios_WC3Ref_UserPropertyEditor "Reforged Property Editor" 
    width:220 
    height:340
(

    local selectedObject

    group "Selected object"
    (
        label lblSelectedObject "No object selected"
    )
    group "Billboarding"
    (
        dropdownlist ddBillboarding "" items:#("None", "Full", "Pivot on X Axis", "Pivot on Y Axis", "Pivot on Z Axis")
    )
    group "Other properties"
    (
        checkbox chkCollisionObject "Collision Box"
       
    )
    group "Animation options"
    (
        label lblRotType "Rotation:" align:#left 
        dropdownlist ddlRotationAnimationType items:#( "None (Euler XYZ)", "Linear", "Hermite (TCB)", "Bezier" ) align:#right width:120 offset:[0,-20] tooltip:"Change the rotation controller of the selected object"
        label lblPosType "Position:" align:#left
        dropdownlist ddlPositionAnimationType items:#( "None (Position XYZ)", "Linear", "Hermite (TCB)", "Bezier" ) align:#right width:120 offset:[0,-20] tooltip:"Change the position controller of the selected object"
        label lblScaleType "Scale:" align:#left
        dropdownlist ddlScaleAnimationType    items:#( "None (Scale XYZ)", "Linear", "Hermite (TCB)", "Bezier" ) align:#right width:120 offset:[0,-20] tooltip:"Change the scale controller of the selected object"

    )
    
    label lblTM "\xa9 2021 Taylor Mouse"
    button btnClose "Save & Close" height:45 width:190
    
    function UpdateUI=
    (
        local buffer = getUserPropBuffer selectedObject
        if USERPROP_DEBUG then format "Current properties set:\n%" buffer
        
        lblSelectedObject.text =  selectedObject.name + " (" + (classof selectedObject as string) + ")"
        
        chkCollisionObject.checked = false
        if ( getUserProp selectedObject "COLLISION-OBJECT" == true ) then chkCollisionObject.checked = true
        
        ddBillBoarding.selection = 1
        if ( getUserProp selectedObject "BILLBOARD" == true )        then ddBillBoarding.selection = 2
        if ( getUserProp selectedObject "BILLBOARD-LOCK-X" == true ) then ddBillBoarding.selection = 3
        if ( getUserProp selectedObject "BILLBOARD-LOCK-Y" == true ) then ddBillBoarding.selection = 4
        if ( getUserProp selectedObject "BILLBOARD-LOCK-Z" == true ) then ddBillBoarding.selection = 5

        local classOfRotController = classof selectedObject.rotation.controller
        
        if ( classOfRotController == Euler_XYZ )        then ddlRotationAnimationType.selection = 1
        if ( classOfRotController == Linear_Rotation )  then ddlRotationAnimationType.selection = 2
        if ( classOfRotController == TCB_Rotation )     then ddlRotationAnimationType.selection = 3
        if ( classOfRotController == Bezier_Rotation )  then ddlRotationAnimationType.selection = 4
        
        local classOfPosController = classof selectedObject.Position.controller
        
        if ( classOfPosController == Position_XYZ )     then ddlPositionAnimationType.selection = 1
        if ( classOfPosController == linear_position )  then ddlPositionAnimationType.selection = 2
        if ( classOfPosController == TCB_position )     then ddlPositionAnimationType.selection = 3
        if ( classOfPosController == bezier_position )  then ddlPositionAnimationType.selection = 4
        
        local classOfScaleController = classof selectedObject.Scale.controller
        
        if ( classOfScaleController == ScaleXYZ )      then ddlScaleAnimationType.selection = 1
        if ( classOfScaleController == linear_scale )  then ddlScaleAnimationType.selection = 2
        if ( classOfScaleController == TCB_scale )     then ddlScaleAnimationType.selection = 3
        if ( classOfScaleController == bezier_scale )  then ddlScaleAnimationType.selection = 4
         
    )
    
    function ToggleCollisionObject =
    (
        if ( classof selectedObject != box and classof selectedObject != sphere and classof selectedObject != plane and classof selectedObject != cylinder ) then return undefined
        if ( getUserProp selectedObject "COLLISION-OBJECT" == true ) then
        (
            selectedObject.boxmode = true
            selectedObject.wirecolor = color 64 128 255
            selectedObject.renderable = off
            selectedObject.castShadows = off
            selectedObject.receiveshadows = off
            freeze selectedObject
        )
        else
        (
            selectedObject.boxmode = false
            unfreeze selectedObject
        )
    )
    
    on GriffonStudios_WC3Ref_UserPropertyEditor open do
    (
        if USERPROP_DEBUG then format "selected object: %\n" $
        selectedObject = $
        UpdateUI()
    )

    on ddBillboarding selected index do
    (
        
        if USERPROP_DEBUG then format "Selected item :% %\n" index ddBillboarding.selected 
        
        local cleanBuffer = ""

        -- remove the previous billboard settings
        local buffer = getUserPropBuffer selectedObject
        local parts  = filterstring buffer "\r\n"
        for p in parts do
            if ( substring p 1 9 != "BILLBOARD" ) then cleanBuffer += p + "\r\n"
        setUserPropBuffer selectedObject cleanBuffer

        if ( index == 2 ) then setUserProp selectedObject "BILLBOARD" true
        if ( index == 3 ) then setUserProp selectedObject "BILLBOARD-LOCK-X" true
        if ( index == 4 ) then setUserProp selectedObject "BILLBOARD-LOCK-Y" true
        if ( index == 5 ) then setUserProp selectedObject "BILLBOARD-LOCK-Z" true

    )
 
    on chkCollisionObject changed theState do
    (
        if ( theState == false ) then 
        (
            local cleanBuffer = ""
            local buffer = getUserPropBuffer selectedObject
            local parts  = filterstring buffer "\r\n"
            for p in parts do
                if ( substring p 1 9 != "COLLISION" ) then cleanBuffer += p + "\r\n"
            setUserPropBuffer selectedObject cleanBuffer
        )
        if ( theState == true ) then 
        (
            setUserProp selectedObject "COLLISION-OBJECT" true
        )
        ToggleCollisionObject()
    )
    
    on ddlRotationAnimationType selected index do
    (
        if (index == 1 ) then selectedObject.rotation.controller = Euler_XYZ()
        if (index == 2 ) then selectedObject.rotation.controller = Linear_Rotation()
        if (index == 3 ) then selectedObject.rotation.controller = TCB_Rotation()
        if (index == 4 ) then selectedObject.rotation.controller = Bezier_Rotation()
    )
    
    on ddlPositionAnimationType selected index do
    (
        if (index == 1 ) then selectedObject.Position.controller = Position_XYZ()
        if (index == 2 ) then selectedObject.Position.controller = Linear_Position()
        if (index == 3 ) then selectedObject.Position.controller = TCB_Position()
        if (index == 4 ) then selectedObject.Position.controller = Bezier_Position()
    )
    
    on ddlScaleAnimationType selected index do
    (
        if (index == 1 ) then selectedObject.Scale.controller = ScaleXYZ()
        if (index == 2 ) then selectedObject.Scale.controller = Linear_Scale()
        if (index == 3 ) then selectedObject.Scale.controller = TCB_Scale()
        if (index == 4 ) then selectedObject.Scale.controller = Bezier_Scale()
    )
    
    on btnClose pressed do
    (
        local buffer = getUserPropBuffer selectedObject
        if USERPROP_DEBUG then format "Current properties set: %\n" buffer
        
        destroydialog GriffonStudios_WC3Ref_UserPropertyEditor
    )
    

)

