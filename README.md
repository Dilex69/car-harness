# IMPORTANT
```
* Delate seatbelt.lua from qb-smallresources/client/
* Remove anything to do with harnes from server.lua from qb-smallresources 
# Installation
```
* Download the script and put it in the [resource] folder.

* Upload SQL found harness.sql

* Copy Img And Paste In qb-inventory\html\images

* Replace exports['qb-smallresources']:HasHarness() with exports['car-harness']:HasHarness()

* Add Following Items to qb-core > items.lua

```
    ["harness"] 	= {["name"] = "harness",        ["label"] = "Car Harness",	 	["weight"] = 1000, 		["type"] = "item", 		["image"] = "harness.png", 		["unique"] = false, 		["useable"] = true, 	["shouldClose"] = true,   	["combinable"] = nil,   ["description"] = "Racing Harness so no matter what you stay in the car"},
     
    ["harness_remover"] 	= {["name"] = "harness_remover",        ["label"] = "Harness Removing Tool",	 	["weight"] = 1000, 		["type"] = "item", 		["image"] = "harness_removetool.png", 		["unique"] = false, 		["useable"] = true, 	["shouldClose"] = true,   	["combinable"] = nil,   ["description"] = "To be able to remove harness from owned vehicles"},
```
Add the following code to your server.cfg/resouces.cfg
```
ensure car-harness
```

# Dependencies
* [ox_lib](https://github.com/overextended/ox_lib)




