# Dialogic advaced voice module
 A more advanced voice support module for the Godot dialogic plugin
 
 *This event is currently in early development, and not yet functional*
 
Short backstory:
 While working on voice support event for the dialogic plugin, I was essentially called out for feature-creeping it.
 While I do not disagree with that judgement. I still want these features.
 And so my work on the voice support event has branched out to becoming a "dialogic addition", where I am free to develop this as insanely feature rich as I wish.
 
This event act as a complete replacement to the existing voice event, reusing most of its code. It acts completely independent of the original voice event, but functions slightly differently. To reduse confusion, it is recommended to delete the original voice event from the dialogic plugin when installing this module.

# How this differes from Dialogic's base voice event

Unlike the base event, this advanced event is *disconnected* from the text event, and is meant to be, in a sense, *"preloaded*" at the start of a timeline, or series of dialog.
Further unlike the base event, a voice line will not start automatically.

A text effect is required to trigger the functions of the advanced voice event.

# How to test or install
option 1: Make a directory link of /addons/dialogic_additions/AdvancedVoice to /addons/dialogic_additions in your dialogic test project.

Option 2: Copy the /addons/dialogic_additions/AdvancedVoice directory, and paste it into /addons/dialogic_additions

Option 1 is recommended for development and testing, as it allows live update with git-tracking within the original repository.

Option 2 is recommended when installing the plugin in a project, as the code stays in a true directory with the rest of the project.

Do note that the godot engine treats a linked directory as indistinguishable from a true directory. I does not tell the difference.
option 1 is done by me on Linux. Do not ask how to do it on Windows or MacOS. I don't develop on those, and would not know.

