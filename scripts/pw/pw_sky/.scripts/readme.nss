/*


The sun tracking system is first initialized inside

    x2_mod_def_load

The heartbeat system keeps the sun's details updated and sends them
to the shader using

    hb_updatetime

This system makes use of the following scriptable variables, which
you'll need to change if you use other shader-driven systems like
the custom targeting telegraphs

    scriptableVec1  =  module sun position
    scriptableVec2  =  module moon position
    scriptableVec3  =  module sun diffuse color
    scriptableVec4  =  module moon diffuse color

    scriptableFloat1  =  precalculated module time in decimal hours

On area enter, the most simplified version of shrinking down a
character is applied. I've left out the associated 2da since you'll
probably prefer to use NWNx. The player will run fast until that is
replaced, which is fine for building/DM testing.






*/





void main()
{

}
