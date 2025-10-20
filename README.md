# WebView control for Flet

`WebView` control for Flet.

## Platform Support

The WebView control is supported on the following platforms:
- iOS
- Android  
- macOS
- Windows (requires WebView2 Runtime)
- Web

### Windows Requirements

On Windows, the WebView control requires the **Microsoft Edge WebView2 Runtime** to be installed. This runtime is included by default on Windows 11 and recent Windows 10 updates. If not present, it can be downloaded from [Microsoft's website](https://developer.microsoft.com/en-us/microsoft-edge/webview2/).

### Platform-Specific Limitations

Some WebView methods have platform-specific limitations:

**Windows Platform:**
- `get_user_agent()` - Not supported
- `load_file()` - Not supported
- `enable_zoom()` / `disable_zoom()` - Not supported
- `scroll_to()` / `scroll_by()` - Not supported

## Usage

Add `flet-webview` as dependency (`pyproject.toml` or `requirements.txt`) to your Flet project.

## Example

```py

import flet as ft

import flet_webview as fwv

def main(page: ft.Page):
    wv = fwv.WebView(
        url="https://flet.dev",
        on_page_started=lambda _: print("Page started"),
        on_page_ended=lambda _: print("Page ended"),
        on_web_resource_error=lambda e: print("Page error:", e.data),
        expand=True,
    )
    page.add(wv)

ft.app(main)
```