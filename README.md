# simple-onvif-controls
Bash scripts to work on onvif cameras

This is about as simple as you can get.
Clone the repo, set your initial values in the settings.cfg
file and attempt a run.

**Requirements:**
- You need **curl** and **xml2** installed in your path somewhere.
- You must know your user and password
- You must know your camera IP address
- You must know your ONVIF port

  
From the help (./controlCamera.sh -h)
```
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
```

- This has been tested on a couple of different generic Chinese V380 cameras with consistent
results.
- I have tried to keep the XML to the simplest form possible so others can modify
it to their camera or use case.

- For example, if someone knows the SOAP XML for turning the lights on or off, it would be simple
to add to this script.  
- This is not intended to be a full blown "application" but simply
a solution to more easily control these poorly documented ONVIF cameras.
- To find more goodies to add, parse your XML output in the responses directory and make the XML function
to use the goodie you found.
- cat ./responses/???.xml | xml2 will show the XML in a readable way

### Possible Future ###
- Figure out a working example for Zoom to work.  Appears that the commands are in place but I have never gotten any ONVIF camera to "do" anything
- Add brightness control
- Add switch for different config files (likely to happen)
