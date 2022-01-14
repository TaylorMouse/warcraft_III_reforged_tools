/*
    .DESCRIPTION
    | Plugins for Warcraft III Reforged
    | Written by Taylor Mouse
    
    .DATE
    | 17.12.2021
    
    .RELEASENOTES
    | 0.3 - Additional settings added ( Alpha, Emission, Life Span, Speed, Color, Team Color )
    | 0.2 - Revisit
    | 0.1 - INIT
    
*/


plugin simpleManipulator WC3RefPopCorn
    name: "Popcorn FX"
    classID:#(0x3617a48c, 0x391672fe)
    category:"Warcraft III Reforged"
(
    /* PARAMETERS */
    parameters file_params rollout:file_rollout (
        fileName  type:#string animatable:false  ui:txt_fileName
    )
    parameters main_params rollout:main_rollout
    (
        always    type:#boolean animatable:false ui:chk_always
        death     type:#boolean animatable:false ui:chk_death
        dissipate type:#boolean animatable:false ui:chk_dissipate
        portrait  type:#boolean animatable:false ui:chk_portrtait
    )
    parameters settings_params rollout:settings_rollout
    (
        alpha            type:#float animatable:true ui:spn_alpha
        emission_rate    type:#float animatable:true ui:spn_emission_rate
        life_span        type:#float animatable:true ui:spn_life_span
        speed            type:#float animatable:true ui:spn_speed
        
        base_color       type:#color animatable:true ui:colorPicker_base_color
        base_color_multi type:#float animatable:false ui:spn_base_color_multi
        team_color       type:#color animatable:false ui:colorPicker_team_color
        team_color_alpha type:#float animatable:false ui:spn_team_color_alpha
        
        
    )
    parameters info_params rollout:info_rollout 
    (
    )
    
    /* ROLLOUTS */
    rollout file_rollout "Popcorn FX File" (
        editText txt_fileName readonly:true
        button btn_browse "Browse..." 
        
        on btn_browse pressed do
        (
            local file = ""
            
            if fileName != "" then 
                file = getOpenFileName \
                        filename:fileName \
                        caption:"Warcraft 3 Reforged" \
                        types:"Supported Files|*.pkb|Facial Effects(*.pkb)|*.pkb|All Files|*.*" \
                        historyCategory:"ReforgedPopcornFXPreset"
            else
                file = getOpenFileName \
                        filename:fileName \
                        caption:"Warcraft 3 Reforged" \
                        types:"Supported Files|*.pkb|Facial Effects(*.pkb)|*.pkb|All Files|*.*" \
                        historyCategory:"ReforgedPopcornFXPreset"
            
            if ( file != undefined ) then fileName = file
        )
    )
    
    rollout main_rollout "Popcorn FX Parameters"
    (
        checkbox chk_always    "Always On" default:true
        checkbox chk_death     "Death"
        checkbox chk_dissipate "Dissipate"
        checkbox chk_portrtait "Portrait"
        
    )
    
    rollout settings_rollout "Popcorn FX Settings"
    (
        label lblAlpha "Alpha:"             align:#left 
        spinner spn_alpha                   align:#right width:40 offset:[0,-20]
        label lblEmmRate "Emission Rate:"   align:#left 
        spinner spn_emission_rate           align:#right width:40 offset:[0,-20]
        label lblLifeSpan "Life Span:"      align:#left 
        spinner spn_life_span               align:#right width:40 offset:[0,-20]
        label lblSpeed "Speed:"             align:#left 
        spinner spn_speed                   align:#right width:40 offset:[0,-20]
        
        
        label lbl_base_color "Color:"       align:#left offset:[0,5]
        colorPicker colorPicker_base_color  offset:[0,-20] align:#right
        
        label   lbl_bcm "Color Multiplier:" align:#left 
        spinner spn_base_color_multi        align:#right width:40 offset:[0,-20]
        
        label lbl_team_color "Team Color:"  align:#left offset:[0,5]
        colorPicker colorPicker_team_color  offset:[0,-20] align:#right
        
        label lbl_tca  "Team Color Alpha:"  align:#left 
        spinner spn_team_color_alpha        align:#right width:40 offset:[0,-20]
    )

    rollout info_rollout "Info" (
        label lblInfo1 "Created by Taylor Mouse"
        label lblInfo2 "\xa9 2022 Griffon Studios"
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
        
        BuildGizmoCircle 3.4 [12.6726,-7.75778,0]
        BuildGizmoCircle 2.2 [25.2409,-5.09385,0]
        BuildGizmoCircle 1.2 [23.5332,12.5291,0]
        
        BuildGizmo #( [-1.78839,2.987,0], [1.37882,2.987,0], [2.17535,2.5253,0], [2.65518,1.77951,0], [2.77593,0.861821,0], [2.67933,0.064877,0], [2.17529,-0.707061,0], [1.42711,-1.21506,0], [-1.71594,-1.21506,0], [-1.78839,2.987,0] )
        BuildGizmo #( [-5.95865,7.14973,0], [1.82823,7.14973,0], [3.36512,6.63743,0], [4.86785,5.647,0], [5.92659,4.48579,0], [6.88288,2.64153,0], [7.22441,1.17295,0], [7.25856,-0.159014,0], [6.74627,-1.59344,0], [5.85829,-2.89125,0], [4.73124,-4.05246,0], [3.50173,-4.94043,0], [1.82823,-5.45273,0], [-1.75783,-5.45273,0], [-1.75783,-13.8202,0], [-5.9928,-13.8202,0], [-5.95865,7.14973,0] )
        BuildGizmo #( [-20.2227,-7.44002,0], [-17.1315,-6.32913,0], [-13.6539,-4.92844,0], [-11.6736,-3.38285,0], [-11.3355,-2.17536,0], [-11.8668,-0.871269,0], [-13.6539,0.915818,0], [-18.339,4.10359,0], [-13.0743,4.00699,0], [-11.6253,4.20019,0], [-9.98315,4.92469,0], [-8.53416,6.22878,0], [-8.00286,7.53287,0], [-7.90627,11.0104,0], [-8.29263,13.3771,0], [-9.83822,19.1731,0], [-7.47154,14.7778,0], [-6.26405,12.7975,0], [-4.52526,10.9139,0], [-3.41437,10.286,0], [-1.96538,9.94787,0], [-1.09599,10.286,0], [0.497899,12.3628,0], [2.23669,15.5506,0], [6.48712,27.6256,0], [4.36194,17.6275,0], [3.87894,14.3915,0], [3.78234,11.8316,0], [3.87894,10.4309,0], [4.16874,9.85129,0], [4.79663,9.46489,0], [5.85923,9.80299,0], [13.3457,15.4057,0], [19.6729,20.6704,0], [29.6227,29.7508,0], [20.6873,19.2697,0], [14.6981,11.8316,0], [11.8968,7.96763,0], [11.124,6.22884,0], [11.3172,5.35945,0], [12.1866,4.10366,0], [14.0702,3.52406,0], [22.4744,3.08936,0], [16.6785,1.49554,0], [12.6696,-0.291545,0], [8.66074,-3.14122,0], [7.59815,-4.59021,0], [6.58385,-6.7637,0], [6.24576,-8.64738,0], [6.63215,-11.4488,0], [7.50155,-13.0426,0], [8.99884,-14.6365,0], [6.87365,-13.6705,0], [4.94167,-13.0909,0], [3.15458,-12.9943,0], [2.52669,-13.429,0], [2.09199,-14.9263,0], [2.04375,-17.0031,0], [2.67165,-22.5576,0], [1.17436,-19.1766,0], [0.0634651,-17.4378,0], [-1.04743,-16.3269,0], [-2.25492,-15.6024,0], [-4.3318,-16.0371,0], [-7.03658,-19.2732,0], [-9.78966,-23.91,0], [-12.3978,-29.0297,0], [-10.0312,-22.3161,0], [-9.06517,-18.5487,0], [-8.82367,-16.4235,0], [-8.82367,-14.6848,0], [-9.30666,-14.0569,0], [-10.2244,-14.0569,0], [-11.625,-14.7331,0], [-16.938,-18.5004,0], [-20.7537,-21.7365,0], [-25.3421,-25.9386,0], [-29.0129,-29.3678,0], [-25.2455,-24.876,0], [-20.5605,-19.563,0], [-16.938,-15.5058,0], [-13.074,-10.9174,0], [-12.108,-9.61329,0], [-12.108,-9.082,0], [-12.9774,-8.3092,0], [-14.6196,-7.92281,0], [-16.7448,-7.68131,0], [-20.2227,-7.44002,0])

    )
    
)

