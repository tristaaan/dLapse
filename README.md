# dLapse
A robust timelapse app. Ideal for the 4th generation iPod Touch. Time lapse compilation takes place off-device to save battery to enable longer time lapses.

## Usage

- Open the app, and set the time per frame (default is five seconds). 
- Press "start", the time lapse is started. To save battery the screen is dimmed to the minimum.
- Press "stop" to stop the time lapse.

## Time Lapse Compilation
To save battery, the time lapse is not done on the device.

- Connect the device to iTunes and go to the device tab.
- Under _Apps_, scroll to _File Sharing_ at bottom and click on _dLapse_. The document browser will show a list of folders containing time lapse images. 
- Drag and drop the desired folder on the desktop and wait for it to transfer.
- Navigate to the folder in a terminal and with [ffmpeg](http://ffmpeg.org/download.html): 

```
ffmpeg -f image2 -pattern_type glob -i '*.png' -r 30 -pix_fmt yuv420p out.mp4
```
- This generates `out.mp4` in the same directory, watch and enjoy.

## Notes
- Compilation tested on OSX 10.9.5 with `ffpmeg 2.2.4`. Feel free to contribute other compilation methods either with `ffmpeg` or another tool.
- This app has only been tested on a 4th generation iPod Touch running iOS 6, because it's a legacy device with a legacy OS you will need to download XCode 5 to put it on the device.
