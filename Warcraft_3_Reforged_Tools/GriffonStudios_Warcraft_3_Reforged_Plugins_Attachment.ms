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

plugin simpleManipulator WC3RefAttachment
    name: "Attachment"
    classID:#(0xbf7f681, 0x44ab1223)
    category:"Warcraft III Reforged"
(
    
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
    
    function BuildGizmo points=
    (
        
        local unselectedColor = [1,1,0] 
        local selectedColor = [1,1,0]
        local giz = manip.makeGizmoShape()
        giz.startNewLine()
        for pnt in points do giz.addpoint pnt
        this.addGizmoShape giz 0 unselectedColor selectedColor
    )
    
    on updateGizmos do
    (
        this.clearGizmos()

        BuildGizmo #([-4,0,0], [0,-5,0], [4,0,0], [-4,0,0], [0,0,10],[4,0,0] )
        BuildGizmo #([0,0,10],[0,-5,0])
        
    )
    
)

if ( DisplayWC3RefAttachments != undefined ) then 
	UnregisterRedrawViewsCallback DisplayWC3RefAttachments
	
function DisplayWC3RefAttachments=
(
            
    gw.setTransform ( matrix3 1 )
    for obj in objects where 
        ( classof obj == WC3RefAttachment and obj.ishidden == false and obj.isfrozen == false ) do
    (
        gw.text ( obj.pos + [0, 0, 10] ) ( obj.name as string ) color:Yellow
    )
    gw.updateScreen()
    
)
RegisterRedrawViewsCallback DisplayWC3RefAttachments