import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
  id: root

  function registerBindings() {
    console.log("[Command++] Registering Hyprland bindings from plugin")
    bindProc.running = true
  }

  function unregisterBindings() {
    console.log("[Command++] Restoring default bindings on plugin unload")
    unbindProc.running = true
  }

  Process {
    id: bindProc
    command: [
      "hyprctl", "eval",
      'local cmdpp_bind_file = (os.getenv("HOME") or "") .. "/.config/omarchy/plugins/yuri.cmdpp/cmdpp-bindings.lua"; local cmdpp_handle = io.open(cmdpp_bind_file, "r"); if cmdpp_handle then cmdpp_handle:close(); dofile(cmdpp_bind_file) end'
    ]
    stdout: StdioCollector {
      onStreamFinished: {
        if (text.trim() && text.trim() !== "ok")
          console.log("[Command++] bind out:", text.trim())
      }
    }
    stderr: StdioCollector {
      onStreamFinished: {
        if (text.trim())
          console.warn("[Command++] bind err:", text.trim())
      }
    }
  }

  Process {
    id: unbindProc
    command: [
      "hyprctl", "eval",
      'hl.unbind("SUPER + SHIFT + H")'
    ]
  }

  Component.onCompleted: {
    registerBindings()
  }

  Component.onDestruction: {
    unregisterBindings()
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event && event.name === "configreloaded") {
        registerBindings()
      }
    }
  }
}
