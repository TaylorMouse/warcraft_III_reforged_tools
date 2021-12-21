/*
    .DESCRIPTION
    | Plugins for Warcraft III Reforged
    | Written by Taylor Mouse
    
    .DATE
    | 17.12.2021
    
    .RELEASENOTES
    | 0.2 - Revisit
    | 0.1 - INIT
    
*/


plugin simpleManipulator WC3RefFaceFX
    name: "Face FX"
    classID:#(0x1f1f6643, 0x153d2ca1)
    category:"Warcraft III Reforged"
(
    parameters main rollout:params
    (
        fileName type:#string ui:txt_fileName
    )

    rollout params "Face FX Parameters"
    (
        edittext txt_fileName "" offset:[-15,0] width:140 align:#left
        button btn_browse "..." width:20 height:20 offset:[10,-25] align:#right
        
        on btn_browse pressed do
        (
             local file = getOpenFileName \
                        caption:"Warcraft 3 Reforged" \
                        types:"Supported Files|*.facefx_ingame|Facial Effects(*.facefx_ingame)|*.facefx_ingame|All Files|*.*" \
                        historyCategory:"ReforgedFaceFxPreset"
                
                if ( file != undefined ) then 
                    this.fileName = file
            
        )
    )

    tool create
    (
        on mousePoint click do
        (
            case click of
                 (
                    1:(
                        nodeTM.translation = [0,0,0]
                        #stop
                      )
                  )
        )

    )
    
    function BuildGizmo points=
    (
        
        local unselectedColor = [0,1,0] 
        local selectedColor = [1,1,0]
        local giz = manip.makeGizmoShape()
        giz.startNewLine()
        for pnt in points do giz.addpoint pnt
        this.addGizmoShape giz 0 unselectedColor selectedColor
    )
    function BuildGizmoCircle radius center=
    (
        local unselectedColor = [0,1,0] 
        local selectedColor = [1,1,0]

        local giz = manip.makeCircle center radius 32

        this.addGizmoShape giz 0 unselectedColor selectedColor
    )
    on updateGizmos do
    (
        this.clearGizmos()
        
        BuildGizmoCircle 19.0 [0,0,0]
        BuildGizmoCircle 3.0 [8,3.5,0]
        BuildGizmoCircle 3.0 [-8,3.5,0]
        BuildGizmo #([-11,-5.6,0], [-7.1,-8.9,0], [-2.4,-10.6,0], [2.4,-10.6,0], [7.1,-8.9,0],[11,-5.6,0] )
        
    )
    
)