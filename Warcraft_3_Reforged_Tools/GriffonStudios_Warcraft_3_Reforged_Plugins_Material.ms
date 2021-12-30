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
        replacableTexture  type:#integer animatable:false ui:ddl_replaceableTexture
        /* filterMode
         0x0: Opaque
         0x1: Mask
         0x2: Blend
         0x3: Add
         0x4: BlendAdd
         0x5: Mod
         0x6: Mod 2x
         0x7: --> 0x0
        */
        /* ShadingFlag -- > bit.and seqs.Flags 0x1
             0x1: Unlit
             0x2: Environment map
             0x4: Wrap Width
             0x8: Wrap Height
             0x10: 2-sided
             0x20: No fog
             0x40: no depth test
             0x80: no depth set               
             0x100: Fallback
        */

        on material_alpha set val do 
        (
            delegate.opacity = val
        )
        on diffuse_map set val do 
		(
            delegate.diffuseMap = diffuse_map
            
            if (diffuse_map != undefined ) then showTextureMap this delegate.diffusemap true
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
        emissive_alpha  type:#float      animatable:false ui:spn_emissive
        emissive_multiplier type:#float  animatable:true  ui:spn_emissive_multiplier
        reflection_map  type:#texturemap animatable:false ui:mb_reflection
        
        
    )
    parameters flags rollout:additionalFlags
    (
        DONT_INHERIT_TRANSLATION type:#boolean animatable:false ui:cbx_DONT_INHERIT_TRANSLATION
        DONT_INHERIT_SCALING type:#boolean animatable:false ui:cbx_DONT_INHERIT_SCALING
        DONT_INHERIT_ROTATION type:#boolean animatable:false ui:cbx_DONT_INHERIT_ROTATION

    )
    rollout params "Material Texture Parameters"
    (
        
        dropdownlist lb_filterMode "Filter Mode" items:#("Opaque","Mask","Blend", "Add", "BlendAdd", "Mod", "Mod2x") width:150 
        dropdownlist ddl_replaceableTexture      items:#( "Not Replacable","Team Color","Team Glow") width:150 
        
        spinner spn_priority "Priority :" range:[0,10,0] type:#integer width:60 offset:[-20,-50] width:100 align:#right
        spinner spn_alpha  "Alpha :"     range:[0,100.0,100.0] offset:[-20,5] width:60 align:#right
        
        checkbox cbx_unlit "Unlit"
        checkbox cbx_environment "Environment" 
        checkbox cbx_wrapwidth "Wrap Width" 
        checkbox cbx_wrapheight "Wrap Height" 
        checkbox cbx_twosided "2-sided" offset:[200,-80]
        checkbox cbx_nofog "No fog" offset:[200,0]
        checkbox cbx_nodepthtest "No depth test" offset:[200,0]
        checkbox cbx_nodepthset "No depth set" offset:[200,0]
        
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
            spinner spn_emissive "Alpha:"   range:[0,100.0,100.0] align:#right width:70 
            spinner spn_emissive_multiplier "Multiplier:"   range:[0,100,0] align:#right width:80 
        
        label lbl7 "Environment . . ."   align:#left offset:[0,10]
            mapbutton mb_reflection "(drag & drop texture here)" height:22 width:250  offset:[0,-25] align:#right tooltip:"Select spherical reflection map"
    
        
    )
    rollout additionalFlags "Additional Flags"
    (
        checkbox cbx_DONT_INHERIT_TRANSLATION "Don't inherit translation"
        checkbox cbx_DONT_INHERIT_SCALING "Don't inherit scaling"
        checkbox cbx_DONT_INHERIT_ROTATION "Don't inherit rotation"
        
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
        emissive_alpha = 100
        emissive_multiplier = 1
        
        diffuse_map = Bitmaptexture fileName:""
        normal_map = Bitmaptexture fileName:""
        orm_map = Bitmaptexture fileName:""
        teamcolor_map = Bitmaptexture fileName:""
        emissive_map = Bitmaptexture fileName:""
        alphamask_map = Bitmaptexture fileName:""
        reflection_map = Bitmaptexture fileName:""
        replacable_map = Bitmaptexture fileName:""
        
    )
)