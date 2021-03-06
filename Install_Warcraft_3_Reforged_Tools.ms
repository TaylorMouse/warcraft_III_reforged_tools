/* 
    .SYNOPSIS
    | Setup the tools for Importing and Exporting Warcraft 3 Reforged Art Tools
        
    .COPYRIGHT
    | (c)2010-2021 Griffon Studios
    
    .AUTHOR
    | Taylor Mouse
        
*/

global STARCRAFT_II_ARTTOOLS_INSTALLED = true


fileIn "Warcraft_3_Reforged_Tools\\GriffonStudios_Warcraft_3_Reforged_Macros.ms"
fileIn "Warcraft_3_Reforged_Tools\\GriffonStudios_Warcraft_3_Reforged_Plugins_Material.ms"
fileIn "Warcraft_3_Reforged_Tools\\GriffonStudios_Warcraft_3_Reforged_Menu.ms"

try (
    Warcraft3_Reforged_Menu.CreateMenu()
)
catch (    
    messagebox "Unable to install Warcraft III Reforged Art Tools"
)

/* Check if this version of Max supports SC2 Art Tools */
try   ( test = SC2_Standard_Material() ) 
catch ( STARCRAFT_II_ARTTOOLS_INSTALLED = false )