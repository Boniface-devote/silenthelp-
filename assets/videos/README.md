# Video Assets for Learn Screen

This directory contains video demonstrations for Ugandan Sign Language (UgSL) signs used in the Learn screen.

## Required Videos

Each video should be approximately 3-5 seconds long, showing a clear demonstration of the sign from the signer's perspective.

### Video Specifications
- **Format**: MP4 (H.264 codec)
- **Resolution**: 480p (640x480) or higher
- **Frame Rate**: 30 fps
- **File Size**: Less than 1MB each (lightweight for offline use)
- **Audio**: None required (silent)

### Required Video Files

1. **hello.mp4** - "Hello" greeting sign
   - Open hand, palm outward, waving side to side in front of face
   - Duration: 3-5 seconds

2. **help.mp4** - "Help" assistance sign
   - Hands positioned as if lifting something, moving upward together
   - Duration: 3-5 seconds

3. **my_name_is.mp4** - "My name is..." introduction sign
   - Point to yourself with both index fingers, then finger spell a name
   - Duration: 4-6 seconds

4. **thank_you.mp4** - "Thank you" gratitude sign
   - Open hand moving from chin outward in a graceful motion
   - Duration: 3-5 seconds

5. **i_am_deaf.mp4** - "I am deaf" identity sign
   - Point to ear and shake head, then point to yourself
   - Duration: 4-5 seconds

## Video Sourcing

- **Best Source**: Original Deaf community members or professional sign language educators
- **Alternative**: Licensed stock footage from sign language educational platforms
- **Considerations**: 
  - Ensure proper representation of UgSL
  - Use appropriate lighting and clear hand visibility
  - Focus on clarity and accuracy of sign execution

## Integration Notes

Videos are automatically played with:
- ✅ Autoplay enabled (starts automatically when modal opens)
- ✅ Loop enabled (continuously repeats)
- ✅ Play/pause controls available
- ✅ Progress bar with timestamp display
- ✅ Loading indicator while initializing
- ✅ Error handling if video file is missing

## Testing

To test video playback:
1. Place MP4 files in this directory
2. Run: `flutter pub get`
3. Run the app and navigate to Learn screen
4. Tap any sign card to open the modal with video player
