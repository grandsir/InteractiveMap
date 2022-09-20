# InteractiveMap

A Library to use SVG Based Maps interactively in SwiftUI.


- Works **only with** .svg based maps
- Allows you to modify **all** the provinces in the map with the attributes that SwiftUI's `Shape` provides
- Drag, drop and animate the provinces, as well as the map itself.

<h3 style ="text-align: center">Installation</h3> 
<p>Requires <b>iOS 13+</b> 

InteractiveMap currently can only be installed through the Swift Package Manager.</p>

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

<h2 style="text-align: center; padding: 10px">Usage</h2>

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

<img src="Assets/map_default.png" width=700 alt="Default Map">

# Customization

Instead of using default attributes, you can define your own as well. 

```swift
MapView(svgName: "tr") {
    ProvinceShape($0)
        .initWithAttributes(.init(strokeWidth: 2, strokeColor: .red, background: Color(white: 0.2)))
}
```
<img src="Assets/map_customized_with_attributes.png" width=700 alt="Custom Attributes Map">

## Advanced Customization

Even though `.initWithAttributes` saves time for simple customization, it is neither highly customizable nor editable.

Since `ProvinceShape` is a `Shape`, you can add any attribute to `ProvinceShape` that you can add to `Shape`.
```swift
MapView(svgName: "tr") {
    ProvinceShape($0)
        .stroke(Color.cyan)
        .shadow(color: .cyan, radius: 3, x: 0, y: 0)
        .background(ProvinceShape($0).fill(Color(white: 0.15)))
}
```
<img src="Assets/map_shadow.png" width=700 alt="Shadow Map">
