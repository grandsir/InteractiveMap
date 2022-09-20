# InteractiveMap

A Library to use SVG Based Maps in interactively in SwiftUI.


- Works **only with** .svg based maps
- Allows you to modify **all** the provinces in map with the attributes that SwiftUI's `Shape` provides
- Drag, drop and animate the provinces, as well as the map itself.

### Installation 
Requires iOS 13+. InteractiveMap currently can only be installed through the Swift Package Manager.


<table>
<tr>
<td>
<strong>
Swift Package Manager
</strong>
<br>
Add the Package URL:
</td>
</tr>
<tr>
<td>
<br>
    
```
https://github.com/GrandSir/InteractiveMap
```
    
</td>
</table>

## Usage

To draw your svg map in SwiftUI, use `MapView` with a closure taking `Province` as the parameter.

```swift
import SwiftUI
import InteractiveMap

struct ContentView: View {
    var body: some View {
        MapView(svgName: "tr") {
            ProvinceShape($0)
                .initWithAttributes()
        }
    }
}
```
MapView resizes itself to the assigned frame, and takes all available space by default.
<img src="Assets/map_default.png" width=800 alt="Default Map">

# Customization




