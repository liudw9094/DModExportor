--The main script
--included exproting script and UI script
--For exporting 3D max model to DMod( Doublesoftware 3D model )
--Created by Liu Dw.
--Copyright DoubleSoftware (c)
--20:34 2008/7/20
-- Filename		: exportX_OK.ms
-- Made by		: Liu Dw.
-- System  		: Tested on MAX 9 in Windows Vista
-- Target API		: Direct 3D 9
-- Version      	: 3.00
-- Reversion 2.00	: Functions Removed from "bExport pressed" to "exportpress.ms".
-- Reversion 3.00	: Removed "exportpress.ms", included "exportbase.ms"


--objs = $

include "exportbase.ms"

include "export.ms"
MainUI = newRolloutFloater "MAX to MODEL" 400 350
addrollout f_Main MainUI
