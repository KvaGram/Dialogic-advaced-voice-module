# Dialogic advaced voice module
 A more advanced voice support module for the Godot dialogic plugin
 While working on voice support event for the dialogic plugin, I was essentially called out for feature-creeping it.
 And so this has branch out to becoming a "dialogic addition".
 This event act as a complete replacement to the existing voice event, reusing most of its code. It will be tested with and without that event installed, but it is recommended to remove the existing voice event from dialogic when using this module.

# How to test or install
option 1: Make a directory link of /addons/dialogic_additions/AdvancedVoice to /addons/dialogic_additions in your dialogic test project.
Option 2: Copy the /addons/dialogic_additions/AdvancedVoice directory, and paste it into /addons/dialogic_additions

Option 1 is recommended for development and testing, as it allows live update with git-tracking within the original repository.
Option 2 is recommended when installing the plugin in a project, as the code stays in a true directory with the rest of the project.

Do note that the godot engine treats a linked directory as indistinguishable from a true directory. I does not tell the difference.
option 1 is done by me on Linux. Do not ask how to do it on Windows or MacOS. I don't develop on those, and would not know.

