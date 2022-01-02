/*
    .SYNOPSIS
    | Standard Material for Warcraft III Reforged
    
    .COPYRIGHT
    | ©2020 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse

*/

plugin Material WC3RefMaterial
    name: "Warcraft III Reforged Standard"
    classID:#(0xbc1a66d, 0x64d12aa1)
    category:"Warcraft III Reforged"
    extends:Standard
    replaceUI:true 
    version:1
(
    /* Exposed parameters */
    parameters basic rollout:basicParams
    (
        base_color           type:#color animatable:true  ui:colorPicker_baseColor
        emissive_multiplier  type:#float animatable:true  ui:spn_emissive_multiplier
        teamcolor_multiplier type:#float animatable:true  ui:spn_teamcolor_multiplier
        fresnel_color        type:#color animatable:false ui:colorPicker_fresnel_color
        fresnel_multiplier   type:#float animatable:false ui:spn_fresnel_multiplier
    )
    parameters main rollout:params
    (
        priorityPlane   type:#integer   animatable:false  ui:spn_priority
        material_alpha  type:#float     animatable:true   ui:spn_alpha
        filtermode      type:#integer   animatable:false  ui:lb_filterMode
        
        unlit       type:#boolean animatable:false ui:cbx_unlit
        envmap      type:#boolean animatable:false ui:cbx_environment
        wrapwidth   type:#boolean animatable:false ui:cbx_wrapwidth
        wrapheight  type:#boolean animatable:false ui:cbx_wrapheight
        twosided    type:#boolean animatable:false ui:cbx_twosided
        nofog       type:#boolean animatable:false ui:cbx_nofog
        nodepthtest type:#boolean animatable:false ui:cbx_nodepthtest
        nodepthset  type:#boolean animatable:false ui:cbx_nodepthset
        nofallback type:#boolean animatable:false ui:cbx_nofallback
        replacableTexture  type:#integer animatable:false ui:ddl_replaceableTexture

        on material_alpha set val do 
        (
            delegate.opacity = val
        )
        on twosided set val do 
        (
            delegate.TwoSided = val
        )
        
    )
    parameters textureMaps rollout:maps
    (
        diffuse_map     type:#texturemap animatable:false ui:mb_diffuse
        normal_map      type:#texturemap animatable:false ui:mb_normal
        orm_map         type:#texturemap animatable:false ui:mb_orm  --> R = occlusion, G = Roughness, B = Metal
        emissive_map    type:#texturemap animatable:false ui:mb_emissive
        
        reflection_map  type:#texturemap animatable:false ui:mb_reflection
        
        on diffuse_map set val do 
		(
            delegate.diffuseMap = diffuse_map
            
            if (diffuse_map != undefined ) then showTextureMap this delegate.diffusemap true
		)
        
    )
    parameters flags rollout:additionalFlags
    (
        DONT_INHERIT_TRANSLATION type:#boolean animatable:false ui:cbx_DONT_INHERIT_TRANSLATION
        DONT_INHERIT_SCALING type:#boolean animatable:false ui:cbx_DONT_INHERIT_SCALING
        DONT_INHERIT_ROTATION type:#boolean animatable:false ui:cbx_DONT_INHERIT_ROTATION

    )
    parameters animation rollout:animationTypes
    (
        LineType  type:#integer  animatable:false   ui:ddl_AnimationType
    )
    
    /* UI */
    rollout params "Material Texture Parameters"
    (
        
        dropdownlist lb_filterMode "Filter Mode:" items:#("Opaque","Mask","Blend", "Add", "BlendAdd", "Mod", "Mod2x") width:150 
        dropdownlist ddl_replaceableTexture      items:#( "Not Replacable","Team Color","Team Glow") width:150 
        
        spinner spn_priority "Priority :" range:[0,10,0] type:#integer width:60 offset:[-20,-50] width:100 align:#right
        spinner spn_alpha  "Alpha :"     range:[0,100.0,100.0] offset:[-20,0] width:60 align:#right
        
        checkbox cbx_unlit "Unlit" offset:[0,20]
        checkbox cbx_environment "Environment" 
        checkbox cbx_wrapwidth "Wrap Width" 
        checkbox cbx_wrapheight "Wrap Height" 
        checkbox cbx_twosided "2-sided" offset:[200,-100]
        checkbox cbx_nofog "No fog" offset:[200,0]
        checkbox cbx_nodepthtest "No depth test" offset:[200,0]
        checkbox cbx_nodepthset "No depth set" offset:[200,0]
        checkbox cbx_nofallback "No fallback" offset:[200,0]
        
    )
    rollout basicParams "Basic Parameters"
    (
        label lblBC "Basic Color:" align:#left width:200
        colorPicker colorPicker_baseColor align:#right offset:[-100,-20]
        label lblEM "Emissive Multiplier:" align:#Left width:200
        spinner spn_emissive_multiplier   range:[0,100,0] align:#right width:80 offset:[-100,-20]
        label lblTCM "TeamColor Multiplier:" align:#Left width:200
        spinner spn_teamcolor_multiplier  range:[0,100,0] align:#right width:80 offset:[-100,-20]
        label lblFC "Fresnel Color: " align:#Left width:200
        colorPicker colorPicker_fresnel_color align:#right offset:[-100,-20]
        label lblFCM "Fresnel Multiplier:" align:#Left width:200
        spinner spn_fresnel_multiplier  range:[0,100,0] align:#right width:80 offset:[-100,-20]
        
    )
    rollout maps "Texture Maps"
    (
        label lbl1 "Diffuse . . . . ." align:#left 
            mapbutton mb_diffuse "(drag & drop texture here)" height:22 offset:[0,-25] width:250 align:#right
        
        label lbl2 "Normal . . . . ." align:#left offset:[0,10]
            mapbutton mb_normal  "(drag & drop texture here)" height:22 width:250  offset:[0,-25] align:#right
        
        label lbl3 "ORM . . . . . . ." align:#left offset:[0,10]
            mapbutton mb_orm     "(drag & drop texture here)" height:22 width:250  offset:[0,-25] align:#right
        
        label lbl5 "Emissive . . . ." align:#left offset:[0,10]
            mapbutton mb_emissive  "(drag & drop texture here)" height:22 width:250 offset:[0,-25] align:#right
                    
        label lbl7 "Environment . . ."   align:#left offset:[0,10]
            mapbutton mb_reflection "(drag & drop texture here)" height:22 width:250  offset:[0,-25] align:#right tooltip:"Select spherical reflection map"
    
        
    )
    rollout additionalFlags "Additional Flags"
    (
        checkbox cbx_DONT_INHERIT_TRANSLATION "Don't inherit translation"
        checkbox cbx_DONT_INHERIT_SCALING "Don't inherit scaling"
        checkbox cbx_DONT_INHERIT_ROTATION "Don't inherit rotation"
        
    )
    rollout animationTypes "UV Interpolation Types"
    (
        label lbl_animationType "Type:" align:#left
        dropdownlist ddl_AnimationType items:#( "None", "Linear", "Hermite", "Bezier" ) align:#left width:100 offset:[50,-20]
        
        on ddl_AnimationType selected selectedItem do
        (
            if selectedItem == 2 then 
            ( Diffuse_Map.coords.u_offset.controller = Linear_Float()
              Diffuse_Map.coords.v_offset.controller = Linear_Float() )
            
            if selectedItem == 4 or selectedItem == 1 then 
            ( Diffuse_Map.coords.u_offset.controller = Bezier_Float()
              Diffuse_Map.coords.v_offset.controller = Bezier_Float() )
            
            if selectedItem == 3 then 
            ( Diffuse_Map.coords.u_offset.controller = TCB_Float()
              Diffuse_Map.coords.v_offset.controller = TCB_Float() )

        )
        
    )
    rollout info "Info"
    (
        label lbl1 "Warcraft 3 Reforged Material"
        label lbl2 "\x00A9 2022 - Created by Taylor Mouse" offset:[0,10]
        
    )
    on create do
    (

        delegate.shadertype = 1
        filtermode = 1
        replacableTexture = 1
        material_alpha = 100
        emissive_multiplier = 1
        teamcolor_multiplier = 0
        LineType = 1
        diffuse_map = Bitmaptexture fileName:""
        normal_map = Bitmaptexture fileName:""
        orm_map = Bitmaptexture fileName:""
        teamcolor_map = Bitmaptexture fileName:""
        emissive_map = Bitmaptexture fileName:""
        alphamask_map = Bitmaptexture fileName:""
        reflection_map = Bitmaptexture fileName:""
        replacable_map = Bitmaptexture fileName:""
        base_color = color 255 255 255
    )
)