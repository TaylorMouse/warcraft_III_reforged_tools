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


plugin simpleManipulator WC3RefPopCorn
    name: "Popcorn"
    classID:#(0x3617a48c, 0x391672fe)
    category:"Warcraft III Reforged"
(
    parameters main rollout:params
    (
        fileName type:#string ui:txt_fileName
        always type:#boolean ui:chk_always
        death type:#boolean ui:chk_death
        dissipate type:#boolean ui:chk_dissipate
        portrait type:#boolean ui:chk_portrtait
    )

    rollout params "Popcorn Parameters"
    (
        edittext txt_fileName "" offset:[-15,0] width:140 align:#left
        button btn_browse "..." width:20 height:20 offset:[10,-25] align:#right
        
        checkbox chk_always "Always On" default:true
        checkbox chk_death "Death"
        checkbox chk_dissipate "Dissipate"
        checkbox chk_portrtait "Portrait"
        
        on btn_browse pressed do
        (
             local file = getOpenFileName \
                        caption:"Warcraft 3 Reforged" \
                        types:"Supported Files|*.pkb|Facial Effects(*.pkb)|*.pkb|All Files|*.*" \
                        historyCategory:"ReforgedDDSPreset"
                
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
                        nodeTM.translation = gridPoint
                         #stop
                      )
                  )
        )
    )
    
    function BuildGizmoCircle radius center=
    (
        
        local unselectedColor = [0.8,0.8,0.8] 
        local selectedColor = [1,0,0]

        local giz = manip.makeCircle center radius 32

        this.addGizmoShape giz 0 unselectedColor selectedColor
    )
    on updateGizmos do
    (
        this.clearGizmos()
        
        BuildGizmoCircle 25.0 [0,0,0]
        BuildGizmoCircle 20.0 [0,0,0]
        BuildGizmoCircle 10.0 [0,0,0]

        
    )
    
)

