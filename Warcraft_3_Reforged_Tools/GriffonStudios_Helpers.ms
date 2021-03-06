/*
    .DESCRIPTION
    | Set of helper methods
    | Written by Taylor Mouse
    
    .DATE
    | (c)2015 - 2022
    
    .RELEASENOTES
    | 0.2 - Revisit
    | 0.1 - INIT
    
*/
struct GriffonStudios_Helpers
(
    function ZRotation rot=
    (
        select $*
        group selection name:"MyGroup" select:true
        $MyGroup.pivot = [0,0,0]
        rotate $MyGroup (angleaxis rot [0,0,1])
        ungroup $MyGroup
        
        true
    ),
    function ReplaceString str oldStr newStr = 
    (
        local workingStr = str
        local retStr = ""
        for i=1 to str.count do
        (
            local pos = findstring workingStr oldStr
            if (pos == undefined ) then (

                retStr += workingStr
                exit
                
            )
            retStr += substring workingStr 1 (pos-1)
            retStr += newStr
            
            workingStr = substring workingStr ( pos + oldStr.count ) -1
        )
        retStr
    ),
    function CheckFile file=
    (
        if ( file == undefined ) then  
            return undefined 
        if ( doesFileExist file == false ) then 
        ( 
            throw("File does not exist!"); 
            return undefined 
        )  
        return true
    ),    
    function ReadVector3 stream=
    (
        local vector3 = [readFloat stream, readFloat stream, readFloat stream]
        return vector3
    ),
    function ReadVector4 stream=
    (
        local vector4 = [readFloat stream, readFloat stream, readFloat stream, readFloat stream]
        return vector4
    ),
    function ReadTris stream=
    (
        local tris = [readshort stream + 1, readshort stream + 1, readshort stream + 1]
        return tris
    ),
    function drawLineBetweenTwoPoints pointA pointB =
    (
      local ss = SplineShape pos:pointA
      addNewSpline ss
      addKnot ss 1 #corner #line PointA
      addKnot ss 1 #corner #line PointB
      updateShape ss
      return ss
    ),
    function BuildSpline spline points=
    (
        if spline == undefined then spline = SplineShape pos:[0,0,0]
        spline.WireColor = gray
        spline.renderable = off
        
        local index = addNewSpline spline
        
        for p in points do addKnot spline index #corner #curve p
        
        close spline index

        updateShape spline
        
        return spline
    ),
    function CreateCollisionBox points=
    (
        local c1 = points[1]
        local c2 = points[2]
        
        local verts = #()
        verts[1] = [c1.x,c1.y,c1.z]
        verts[2] = [c2.x,c1.y,c1.z]
        verts[3] = [c1.x,c2.y,c1.z]
        verts[4] = [c2.x,c2.y,c1.z]
        verts[5] = [c1.x,c1.y,c2.z]
        verts[6] = [c2.x,c1.y,c2.z]
        verts[7] = [c1.x,c2.y,c2.z]
        verts[8] = [c2.x,c2.y,c2.z]
        
        local faces = #([1,3,4],[4,2,1],[5,6,8],[8,7,5],[1,2,6],[6,5,1],[2,4,8],[8,6,2],[4,3,7],[7,8,4],[3,1,5],[5,7,3])

        local m = mesh vertices:verts faces:faces
        
        for f=1 to m.numFaces do setFaceSmoothGroup m f 0
        
        m
    ),
    function BuildBoundingBox bbBox=
    (
        local p1 = bbBox[1]
        local p2 = bbBox[2]

        local xMin = 0
        local xMax = 0
        local yMin = 0
        local yMax = 0
        local zMin = 0
        local zMax = 0
        
        if p1.x < p2.x then 
            ( 
                xMin = p1.x
                xMax = p2.X
            )
        else
            ( 
                xMin = p2.x
                xMax = p1.x
            )
        if p1.y < p2.y then 
            ( 
                yMin = p1.y
                yMax = p2.y
            )
        else
            ( 
                yMin = p2.y
                yMax = p1.y
            )
        if p1.z < p2.z then 
            ( 
                zMin = p1.z
                zMax = p2.z
            )
        else
            ( 
                zMin = p2.z
                zMax = p1.z
            )
        
        local help = GriffonStudios_Helpers()
        local s = help.BuildSpline s #([xMin, yMin, zMin], [xMax, yMin, zMin], [xMax,yMin, zMax], [xMin,yMin, zMax], [xMin, yMin, zMin] )
        s = help.BuildSpline s #([xMin, yMax, zMin], [xMax, yMax, zMin], [xMax,yMax, zMax], [xMin,yMax, zMax], [xMin, yMax, zMin] )
        s = help.BuildSpline s #([xMin, yMax, zMin], [xMin, yMin, zMin])
        s = help.BuildSpline s #([xMin, yMax, zMax], [xMin, yMin, zMax])    
        s = help.BuildSpline s #([xMax, yMax, zMin], [xMax, yMin, zMin])
        s = help.BuildSpline s #([xMax, yMax, zMax], [xMax, yMin, zMax])
            
        return s
    ),
    function IsUndefinedBoolean val=
    (
        if (val == undefined ) then false else true
    ),
    function CreateLayer layerName =
    (
        layer = LayerManager.GetLayerFromName layerName
        if(layer == undefined) then
        (
            layer = LayerManager.NewLayerFromName layerName
        )
        return layer
    ),
    function GetStreamLength stream =
    (
        local currentPos = ftell stream
        fseek stream 0 #seek_end
        local streamLen = ftell stream
        
        fseek stream currentPos #seek_set
        
        return streamLen
    ),
    function ReadFixedString stream val =
    (
        /* Read n-length string */
        local str = ""

        for i=1 to val do
        (
            s= bit.IntAsChar(ReadByte stream)

            if ( s !="\0") then str+=s
        )
        return str

    ),
    function SkipBytes stream nBytesToSkip=
    (
        /* Skip n-bytes without reading them into memory */
        fseek stream nBytesToSkip #seek_cur
    ),
    function RoundToFrame val=
    (
        local a = val * 30 / 1000
        local b = val * 30 / 1000.0
        
        if ( b - a ) > 0.5 then return a + 1 else return a
       
    ),
    function CreateAttachmentPoint aName=
    (
        theName = "AttachmentPoint"

        ss = SplineShape pos:[0,0,0]
        ss.renderable = off
        ss.name = theName
        if( aName != undefined ) then ss.name = aName

        addNewSpline ss
        addKnot ss 1 #corner #curve [0,0,10]
        addKnot ss 1 #corner #curve [5,0,0]
        close ss 1
        addNewSpline ss
        addKnot ss 2 #corner #curve [5,0,0]
        addKnot ss 2 #corner #curve [0,5,0]
        addKnot ss 2 #corner #curve [0,-5,0]
        close ss 2
        addNewSpline ss
        addKnot ss 3 #corner #curve [0,0,10]
        addKnot ss 3 #corner #curve [0,5,0]
        addKnot ss 3 #corner #curve [0,-5,0]
        close ss 3
        ss.WireColor = yellow
        updateShape ss
        setUserProp ss "Type" "Attachment Point"
        return ss
    ),
    function CreateAttachmentPoint2 aName=
    (
        theName = "AttachmentPoint"

        ss = SplineShape pos:[0,0,0]
        ss.renderable = off
        ss.name = theName
        if( aName != undefined ) then ss.name = aName

        addNewSpline ss
        addKnot ss 1 #corner #curve [0,0,10]
        addKnot ss 1 #corner #curve [0,-4,0]
        close ss 1
        addNewSpline ss
        addKnot ss 2 #corner #curve [-4,0,0]
        addKnot ss 2 #corner #curve [4,0,0]
        addKnot ss 2 #corner #curve [0,0,10]
        close ss 2
        addNewSpline ss
        addKnot ss 3 #corner #curve [-4,0,0]
        addKnot ss 3 #corner #curve [0,-4,0]
        addKnot ss 3 #corner #curve [4,0,0]
        close ss 3
        ss.WireColor = yellow
        updateShape ss
        
        setUserProp ss "Type" "Attachment Point"
        return ss
    ),
    function CreateFacialEffectsSpline=
    (
        fafxText = Text size:20 alignment:2 text:"FAFX" kerning:-1 wirecolor:yellow 
        centerPivot fafxText
        fafxText.pos = [0,0,0]
        fafxCircle = Circle radius:22.3 wirecolor:yellow pos:[0,0,0]
        
        convertToSplineShape fafxText
        convertToSplineShape fafxCircle
        addAndWeld fafxText fafxCircle -1
        
        fafxText.Name = "FAFX\n"
        setUserProp fafxText "Type" "Facial FX"
        return fafxText
    )
    
)