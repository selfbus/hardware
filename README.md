<h2>Deprecation Notice</h2>
Until May 11th 2023 selfbus hardware was split into "hardware" (stable projects) and "hardware-incubation" (dev projects). Since this split constantly lead to confusion mainly because stable hardware was not migrated to "hardware" but also because namings and structures differed between these two repositories, we decided to re-structe both to the same folder structure and merge them. In combination with clear collaboration rules it should be much easier now to understand what can be found where. 
<br/><br/>The newly created repository is located here: https://github.com/selfbus/hardware-merged

<hr/>

<h2>Master-Branch</h2>
This branch contains released Selfbus hardware

The top level directories contain:

<ul>
<li> Apps - applications/devices that require a controller board
<li> Controller - controller boards
<li> Module - devices that do not require a controller board
<li> Misc - other stuff that is not an EIB bus device
</ul>
