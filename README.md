# simple-onvif-controls
Bash scripts to work on onvif cameras

This is about as simple as you can get.
Clone the repo, set your initial values in the settings.cfg
file and attempt a run.

Requirements:
You need curl and xml2 installed in your path somewhere.

From the help (./controlCamera.sh -h)

Values are set in the settings.cfg file
The script ATTEMPTS to find your profile for ONVIF, however if it is already known, add
it and skip that discovery attempt.

The horizontal and vertical values are default values of 0.1, however if the camera
does not respond to that small of a value, attempt 0.5 for each.

Options:
  usage | -h  show this help screen
  left        move left
  right       move right
  up          move up
  down        move down

Example:
./controlCamera.sh up


This has been tested on a couple of different generic Chinese V380 cameras with consistent
results.  I have tried to keep the XML to the simplest form possible so others can modify
it to their camera or use case.

For example, if someone knows the SOAP XML for turning the lights on or off, it would be simple
to add to this script.  This is not intended to be a full blown "application" but simply
a solution to more easily control these poorly documented ONVIF cameras.
