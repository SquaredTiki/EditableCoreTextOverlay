I have been working on this for a while now and have got it to work fairly well but due to some remaining issues I have decided to open-source it in the case that someone else may want to work on it.

# More Info

This is basically a Core Text View overlaid onto a `UITextView`. The text in the text view is hidden but can still be edited. Any editing in the `UITextView` is passed onto the Core Text View where it is added. This simulates the feel of proper editing.

The only supported font is a custom `Courier` font which has been edited to align closely to what it looks like in a `UITextView`. Even though it lines up very well there are still some issues with line breaking. 

# Issues

- Line breaking rule differs between the `UITextView` and Core Text.
- A few issues with Attributes and the movement as the user enters text.

# Credits

Thanks to akosma for his CoreTextWrapper available here on GitHub which I used to actually do the drawing of the text.
