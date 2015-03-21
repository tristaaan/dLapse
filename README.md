# dLapse
A robust, maybe old school, timelapse app. Ideal for the 4th generation iPod Touch.

## In-App Usage
- Open the app, and set the time per frame (default is five seconds). 
- When "start" is pressed the screen is dimmed to the minimum and the timelapse starts.
- Pressing "stop" stops the time lapse.

## Compilation
To save battery, the time-lapse is not compiled on the device.

- Connect the device to iTunes and go to the device tab.
- Under _Apps_, scroll to _File Sharing_ at bottom and click on dLapse. The document browser will show a list of folders containing time lapse images. 
- Drag and drop the desired folder on the desktop and wait for it to transfer.
- Navigate to the folder in a terminal and with ffmpeg: 

```
ffmpeg -f image2 -pattern_type glob -i '*.png' -r 30 -pix_fmt yuv420p out.mp4
```
- This generates `out.mp4` in the same directory, watch and enjoy.

##Notes: 
- Compilation tested on OSX 10.9.5 with `ffpmeg 2.2.4`. Feel free to contribute other compilation methods either with `ffmpeg` or another tool. 
- This app has only been tested on a 4th generation iPod Touch running iOS 6.