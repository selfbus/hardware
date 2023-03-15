<h2>Master-Branch</h2>
This branch contains released Selfbus hardware

The top level directories contain:

<ul>
<li> Apps - applications/devices that require a controller board
<li> Controller - controller boards
<li> Module - devices that do not require a controller board
<li> Misc - other stuff that is not an EIB bus device
</ul>


<h2>Develop-Branch</h2>

This branch contains hardware which is under development and not fully tested yet. 
Merges from develop to master must be done just for dedicated directories and not for the whole branch. 
Thus master will always contain just released hardware. 