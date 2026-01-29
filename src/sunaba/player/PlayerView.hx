package sunaba.player;

import sunaba.core.native.NativeObject;
import sunaba.core.Reference;
import sunaba.ui.StyleBoxEmpty;
import sunaba.core.StringArray;
import sunaba.input.InputEventMouseButton;
import sunaba.core.native.NativeReference;
import sunaba.desktop.Window;
import sunaba.core.Vector2i;
import sunaba.core.Callable;
import sunaba.ui.Widget;
import sunaba.ui.Panel;
import sunaba.ui.Control;
import sunaba.ui.VBoxContainer;
import sunaba.ui.MenuBar;
import sunaba.desktop.PopupMenu;
import sunaba.ui.SubViewportContainer;
import sunaba.SubViewport;
import sunaba.desktop.AcceptDialog;
import sunaba.PlatformService;
import sunaba.PlatformDeviceType;
import sunaba.core.Vector2;
import sunaba.OSService;
import sunaba.core.TypedArray;
import sunaba.input.InputEvent;
import sunaba.input.InputService;
import haxe.Exception;
import sunaba.desktop.FileDialog;
import sunaba.ui.HBoxContainer;
import sunaba.ui.Label;
import sunaba.ui.Button;
import sunaba.ui.CenterContainer;
import sunaba.ui.TextureRect;
import sunaba.core.ArrayList;
import sunaba.core.native.ScriptType;

class PlayerView extends Widget {
    var subViewport: SubViewport;
    var appView: AppView = null;

    var menuBarControl: Control;

    var abouDialog: AcceptDialog;

    public override function init() {
        load("player://PlayerView.suml");
    }

    public var window:Window;
    public var windowSize:Vector2i;
    private var ogWindowSize: Vector2i;
    public var titlebarLmbPressed:Bool = false;
    public var clickcount = 0;
    public var timeSinceClick = 0.1;
    public var windowTitle:Label;
    var maximizeButton: Button;
    var windowIsMaximized: Bool = false;

    private var resizePreview: Bool = true;
    private var resizeThreshold: Float = 10.0;
    private var resizeThresholdBottomRight: Float = 0.25;

    public var customTitlebar(get, set): Bool;
    function get_customTitlebar() {
        return window.borderless;
    }
    inline function set_customTitlebar(value: Bool): Bool {
        var minimizeButton = getNodeT(Button, "vbox/menuBarControl/hbox/minimizeButton");
        minimizeButton.visible = value;
        var maximizeButton = getNodeT(Button, "vbox/menuBarControl/hbox/maximizeButton");
        maximizeButton.visible = value;
        var closeButton = getNodeT(Button, "vbox/menuBarControl/hbox/closeButton");
        closeButton.visible = value;
        var iconContainer = getNodeT(Control, "vbox/menuBarControl/hbox/iconContainer");
        iconContainer.visible = value;
        windowTitle = getNodeT(Label, "vbox/menuBarControl/windowTitle");
        windowTitle.visible = value;
        return window.borderless = value;
    }

    var isMaximized: Bool;

    private var vbox: VBoxContainer;
    private var menuBarHbox: HBoxContainer;

    public override function onReady() {
        vbox = getNodeT(VBoxContainer, "vbox");
        menuBarHbox = getNodeT(HBoxContainer, "vbox/menuBarControl/hbox");

        window = getWindow();
        var displayScale = DisplayService.screenGetScale(window.currentScreen);
        if (OSService.getName() == "Windows") {
            var dpi = DisplayService.screenGetDpi(window.currentScreen);
            displayScale = dpi * 0.01;
        }
        window.contentScaleFactor = displayScale;
        windowSize = new Vector2i(cast 1152 * displayScale, cast 648 * displayScale);
        ogWindowSize = windowSize;
        window.size = windowSize;
        window.minSize = windowSize;
        window.alwaysOnTop = false;
        window.moveToCenter();
        window.extendToTitle = true;
        window.mode = WindowMode.windowed;
        window.unresizable = false;
        if (OSService.getName() == "macOS") {
            DisplayService.windowSetWindowButtonsOffset(new Vector2i(35, 37), window.getWindowId());
        }
        else {
            window.borderless = true;
        }

        subViewport = getNodeT(SubViewport, "vbox/gameView/container/subViewport");

        abouDialog = getNodeT(AcceptDialog, "aboutDialog");
        buildAboutDialog(abouDialog);

        menuBarControl = getNodeT(Control, "vbox/menuBarControl");
        var menuBarSpacer = getNodeT(Control, "vbox/menuBarControl/hbox/spacer");
        var eventFunc = function(eventN: NativeReference) {
            if (window == null && customTitlebar == false && OSService.getName() != "macOS")
                return;

            if (InputService.isMouseButtonPressed(MouseButton.left) && !titlebarLmbPressed && window.mode == WindowMode.windowed && clickcount == 0) {
                titlebarLmbPressed = true;
                if (eventN.isClass("InputEventMouseButton")) {
                    var eventMouseButton = new InputEventMouseButton(eventN);
                    clickcount++;
                    window.startDrag();
                }        
            }
            else if (InputService.isMouseButtonPressed(MouseButton.left) && !titlebarLmbPressed) {
                titlebarLmbPressed = true;
                clickcount++;
            }
            else if (!InputService.isMouseButtonPressed(MouseButton.left) && titlebarLmbPressed) {
                titlebarLmbPressed = false;
            }

            if (clickcount == 2) {
                trace(clickcount);
                clickcount = 0;
                var maximizeButton = getNodeT(Button, "vbox/menuBarControl/hbox/maximizeButton");
                if (windowIsMaximized == true) {
                    var maximizedSize = window.size;
                    window.mode = WindowMode.windowed;
                    windowIsMaximized = false;
                    if (window.size.x == maximizedSize.x && window.size.y == maximizedSize.y) {
                        window.size = ogWindowSize;
                        window.moveToCenter();
                    }
                    else {
                        window.size = windowSize;
                    }
                    maximizeButton.text = "🗖";
                    if (OSService.getName() == "Windows") {
                        maximizeButton.text = "";
                    }
                }
                else if (windowIsMaximized == false) {
                    windowSize = window.size;
                    window.mode = WindowMode.maximized;
                    windowIsMaximized = true;
                    maximizeButton.text = "🗗";
                    if (OSService.getName() == "Windows") {
                        maximizeButton.text = "";
                    }
                }
            }
        };

        var menuBar: Control = getNodeT(Control, "vbox/menuBarControl/hbox/menuBarContainer/menuBar");
        var iconContainer = getNodeT(Control, "vbox/menuBarControl/hbox/iconContainer");
        var iconRect = getNodeT(Control, "vbox/menuBarControl/hbox/iconContainer/icon");
        menuBar.guiInput.connect(eventFunc);
        menuBarSpacer.guiInput.connect(eventFunc);
        iconContainer.guiInput.connect(eventFunc);
        iconRect.guiInput.connect(eventFunc);

        var fileMenu: PopupMenu = getNodeT(PopupMenu, "vbox/menuBarControl/hbox/menuBarContainer/menuBar/File");
        fileMenu.idPressed.connect(Callable.fromFunction((function(id: Int) {
            if (id == 0) {
                var fileDialog = new FileDialog();
                fileDialog.fileMode = FileDialogMode.openFile;
                fileDialog.useNativeDialog = true;
                fileDialog.access = 2;
                fileDialog.title = "Open Sunaba game";
                fileDialog.addFilter("*.snb", "Sunaba game");
                addChild(fileDialog);

                fileDialog.fileSelected.connect(Callable.fromFunction(function(path: String) {
                    fileDialog.hide();
                    fileDialog.queueFree();
                    openSnb(path);
                }));

                fileDialog.popupCentered();
            }
            else if (id == 1) {
                App.exit(0);
            }
        })));

        var viewMenu: PopupMenu = getNodeT(PopupMenu, "vbox/menuBarControl/hbox/menuBarContainer/menuBar/View");
        if (OSService.getName() == "macOS") {
            viewMenu.removeItem(1);
            viewMenu.setItemText(0, "Toggle Fullscreen (Cmd+F)");
        }
        viewMenu.idPressed.connect(Callable.fromFunction(function(id: Int) {
            if (id == 0) {
                toggleFullscreen();
            }
            else if (id == 1) {
                toggleMenuBar();
            }
        }));

        var helpMenu: PopupMenu = getNodeT(PopupMenu, "vbox/menuBarControl/hbox/menuBarContainer/menuBar/Help");
        if ((PlatformService.deviceType == PlatformDeviceType.desktop) && (OSService.getName() != "Windows")) {
            helpMenu.systemMenuId = 4;
        }
        if (OSService.getName() == "macOS") {
            helpMenu.removeItem(helpMenu.itemCount - 1);
        }
        helpMenu.idPressed.connect(Callable.fromFunction(function(id: Int) {
            if (id == (helpMenu.itemCount - 1)) {
                showAboutDialog();
            }
            else if (id == 0) {
                var res = sunaba.OSService.shellOpen("https://docs.sunaba.gg");
            }
        }));

        var styleBoxEmpty = new StyleBoxEmpty();
            
        var buttonFont = new SystemFont();
        if (OSService.getName() == "Windows") {
            buttonFont.fontNames = StringArray.fromArray([
                "Segoe Fluent icons",
                "Segoe MDL2 Assets"
            ]);
        }
        else if (OSService.getName() == "Linux") {
            var fontNames = buttonFont.fontNames;
            fontNames.add("Noto Sans Symbols2");
            fontNames.add("DejaVu Sans");
            buttonFont.fontNames = fontNames;
            trace(fontNames.toArray().toString());
            trace(buttonFont.fontNames.toArray().toString());
        }

        var minimizeButton = getNodeT(Button, "vbox/menuBarControl/hbox/minimizeButton");
        minimizeButton.addThemeStyleboxOverride("normal", styleBoxEmpty);
        minimizeButton.focusMode = FocusModeEnum.none;
        minimizeButton.addThemeFontOverride("font", buttonFont);
        var newCustomMinimumSize = minimizeButton.customMinimumSize;
        minimizeButton.text = "🗕";
        if (OSService.getName() == "Windows") {
            minimizeButton.text = "";
            newCustomMinimumSize.x = 40;
            minimizeButton.customMinimumSize = newCustomMinimumSize;
        }
        minimizeButton.alignment = HorizontalAlignment.center;
        isMaximized = true;
        minimizeButton.pressed.add(() -> {
            if (window.mode != WindowMode.minimized || windowIsMaximized == false) {
                isMaximized = window.mode == WindowMode.maximized;
                window.mode = WindowMode.minimized;
            }
            else {
                if (isMaximized == true) {
                    window.mode = WindowMode.maximized;
                }
                else {
                    window.mode = WindowMode.windowed;
                }
            }
        });

        maximizeButton = getNodeT(Button, "vbox/menuBarControl/hbox/maximizeButton");
        maximizeButton.addThemeStyleboxOverride("normal", styleBoxEmpty);
        maximizeButton.focusMode = FocusModeEnum.none;
        maximizeButton.addThemeFontOverride("font", buttonFont);
        maximizeButton.text = "🗗";
        maximizeButton.alignment = HorizontalAlignment.center;
        if (OSService.getName() == "Windows") {
            maximizeButton.customMinimumSize = newCustomMinimumSize;
        }
        if (window.mode != WindowMode.windowed) {
            maximizeButton.text = "🗗";
            if (OSService.getName() == "Windows") {
                maximizeButton.text = "";
            }
        }
        else {
            maximizeButton.text = "🗖";
            if (OSService.getName() == "Windows") {
                maximizeButton.text = "";
            }
        }
        maximizeButton.pressed.add(() -> {
            if (windowIsFullscreen == true) {
                toggleFullscreen();
                return;
            }
            if (windowIsMaximized == true) {
                maximizeButton.text = "🗖";
                if (OSService.getName() == "Windows") {
                    maximizeButton.text = "";
                }
                var maximizedSize = window.size;
                window.mode = WindowMode.windowed;
                windowIsMaximized = false;
                if (window.size.x == maximizedSize.x && window.size.y == maximizedSize.y) {
                    window.size = ogWindowSize;
                    window.moveToCenter();
                }
                else {
                    window.size = windowSize;
                }
            }
            else {
                windowIsMaximized = true;
                maximizeButton.text = "🗗";
                if (OSService.getName() == "Windows") {
                    maximizeButton.text = "";
                }
                windowSize = window.size;
                window.mode = WindowMode.maximized;
            }
        });

        var closeButton = getNodeT(Button, "vbox/menuBarControl/hbox/closeButton");
        closeButton.addThemeStyleboxOverride("normal", styleBoxEmpty);
        closeButton.focusMode = FocusModeEnum.none;
        closeButton.addThemeFontOverride("font", buttonFont);
        closeButton.text = "🗙";
        if (OSService.getName() == "Windows") {
            closeButton.text = "";
            closeButton.customMinimumSize = newCustomMinimumSize;
        }
        closeButton.alignment = HorizontalAlignment.center;
        closeButton.pressed.add(() -> {
            App.exit(0);
        });

        if (OSService.getName() == "macOS") {
            iconContainer.hide();
            minimizeButton.hide();
            maximizeButton.hide();
            closeButton.hide();
        }
        else {
            var osArgs: TypedArray<String> = OSService.getCmdlineArgs();
            for (i in 0...osArgs.size()) {
                var arg = osArgs[i];
                trace(arg);
                if (arg == "--no-custom-titlebar") {
                    customTitlebar = false;
                }
            }
        }

        window.filesDropped.connect(Callable.fromFunction(function(fileStringArray: TypedArray<String>) {
            var fileStringArr: Array<String> = fileStringArray;
            if (fileStringArr.length == 0) {
                trace("No files dropped");
            }
            else if (fileStringArr.length > 1) {
                Debug.error("Too many files dropped");
            }
            var firstSnbPath = fileStringArr[0];
            if (StringTools.endsWith(firstSnbPath, ".snb")) {
                openSnb(firstSnbPath);
            }
        }));

        var snbPath: String = "";
        var args = OSService.getCmdlineArgs().toArray();
        for (arg in args) {
            if (StringTools.endsWith(arg, ".snb")) {
                snbPath = arg;
                break;
            }
        }

        if (snbPath != "") {
            openSnb(snbPath);
        }
    }

    function buildAboutDialog(dialog: AcceptDialog) {
        var aboutString = "Sunaba Player\n";
        aboutString += "Version 0.7.7\n";
        aboutString += "(C) 2022-2025 mintkat\n";
        aboutString += "\n";

        var osname = OSService.getName();
        aboutString += "OS: " + osname + "\n";
        var deviceTypeStr = "Unknown";
        if (PlatformService.deviceType == PlatformDeviceType.desktop) {
            deviceTypeStr = "Desktop";
        }
        else if (PlatformService.deviceType == PlatformDeviceType.mobile) {
            deviceTypeStr = "Mobile";
        }
        else if (PlatformService.deviceType == PlatformDeviceType.web) {
            deviceTypeStr = "Web";
        }
        else if (PlatformService.deviceType == PlatformDeviceType.xr) {
            deviceTypeStr = "XR";
        }
        aboutString += "Device Type: " + deviceTypeStr + "\n";

        dialog.dialogText = aboutString;
    }

    public function showAboutDialog() {
        var aboutString = "Sunaba Player\n";
        aboutString += "Version 0.7.7\n";
        aboutString += "(C) 2022-2025 mintkat\n";
        aboutString += "\n";

        var osname = OSService.getName();
        aboutString += "OS: " + osname + "\n";
        var deviceTypeStr = "Unknown";
        if (PlatformService.deviceType == PlatformDeviceType.desktop) {
            deviceTypeStr = "Desktop";
        }
        else if (PlatformService.deviceType == PlatformDeviceType.mobile) {
            deviceTypeStr = "Mobile";
        }
        else if (PlatformService.deviceType == PlatformDeviceType.web) {
            deviceTypeStr = "Web";
        }
        else if (PlatformService.deviceType == PlatformDeviceType.xr) {
            deviceTypeStr = "XR";
        }
        aboutString += "Device Type: " + deviceTypeStr + "\n";
        Debug.info(aboutString, "About Sunaba Player");
    }

    public override function onProcess(delta:Float) {
        if (OSService.getName() == "macOS") {
            if (OSService.getName() == "macOS") {
                menuBarControl.visible = window.mode != WindowMode.fullscreen;
            }
        }
        if ((windowIsMaximized == false) && OSService.getName() != "macOS" && customTitlebar == true) {
            vbox.offsetBottom = -5;
            vbox.offsetLeft = 5;
            vbox.offsetRight = -5;
            vbox.offsetTop = 5;
            menuBarHbox.offsetLeft = 0;
            menuBarHbox.offsetRight = 0;
        }
        else {
            vbox.offsetBottom = 0;
            vbox.offsetLeft = 0;
            vbox.offsetRight = 0;
            if (menuBarControl.visible) {
                vbox.offsetTop = 5;
                menuBarHbox.offsetLeft = 5;
                menuBarHbox.offsetRight = -5;
            }
            else {
                vbox.offsetTop = 0;
            }
        }
        
        timeSinceClick -= delta;
        if (timeSinceClick <= 0.0) {
            timeSinceClick = 1.0;
            if (clickcount != 0) {
                clickcount = 0;
            }
        }

        if (OSService.getName() != "macOS" && customTitlebar == true) {
            window = getWindow();
            if (window != null) {
                if (window.mode != WindowMode.windowed) return;

                var windowsize = window.getVisibleRect().size;

                var mousePosition = window.getMousePosition();
                if (mousePosition.x < resizeThreshold && mousePosition.y < resizeThreshold) { // Top left
                    DisplayService.cursorSetShape(CursorShape.fdiagsize);
                    return;
                }
                if (mousePosition.x > windowsize.x - resizeThreshold && mousePosition.y < resizeThreshold) { // Top Right
                    DisplayService.cursorSetShape(CursorShape.bdiagsize);
                    return;
                }
                if (mousePosition.x < resizeThreshold && mousePosition.y > windowsize.y - resizeThreshold) { // Bottom left
                    DisplayService.cursorSetShape(CursorShape.bdiagsize);
                    return;
                }
                if (mousePosition.x > windowsize.x - resizeThreshold && mousePosition.y > windowsize.y - resizeThreshold) { // Bottom Right
                    DisplayService.cursorSetShape(CursorShape.fdiagsize);
                    return;
                }
                if (mousePosition.x < resizeThreshold) { // left
                    DisplayService.cursorSetShape(CursorShape.hsize);
                    return;
                }
                if (mousePosition.x > windowsize.x - resizeThreshold) { // Right
                    DisplayService.cursorSetShape(CursorShape.hsize);
                    return;
                }
                if (mousePosition.y < resizeThreshold) { // Top
                    DisplayService.cursorSetShape(CursorShape.vsize);
                    return;
                }
                if (mousePosition.y > windowsize.y - resizeThreshold) { // Bottom
                    DisplayService.cursorSetShape(CursorShape.vsize);
                    return;
                }
            }
        }
    }

    public override function onInput(event: InputEvent) {
        if (OSService.getName() != "macOS") {
            if (InputService.isKeyLabelPressed(Key.ctrl) && InputService.isKeyLabelPressed(Key.f1)) {
                App.exit(0);
            }
            if (InputService.isKeyLabelPressed(Key.f2)) {
                toggleMenuBar();
            }
            if (InputService.isKeyLabelPressed(Key.f11)) {
                toggleFullscreen();
            }
        }
        else {
            if (InputService.isKeyLabelPressed(Key.meta) && InputService.isKeyLabelPressed(Key.f)) {
                toggleFullscreen();
            }
            if (InputService.isKeyLabelPressed(Key.meta) && InputService.isKeyLabelPressed(Key.q)) {
                App.exit(0);
            }
        }

        if (OSService.getName() != "macOS" && customTitlebar == true) {
            if (event.native.isClass("InputEventMouseButton")) {
                var eventMouseButton = Reference.castTo(event, InputEventMouseButton);
                window = getWindow();
                if (window.mode != WindowMode.windowed) return;
                if (
                    eventMouseButton.buttonIndex == MouseButton.left &&
                    eventMouseButton.pressed
                ) {
                    var localX = eventMouseButton.position.x;
                    var localY = eventMouseButton.position.y;

                    // Top left
                    if (localX < resizeThreshold && localY < resizeThreshold) {
                        DisplayService.cursorSetShape(CursorShape.fdiagsize);
                        window.startResize(WindowResizeEdge.topLeft);
                        return;
                    }
                    // Top Right
                    if (
                        localX > window.getVisibleRect().size.x - resizeThreshold &&
                        localY < resizeThreshold
                    ) {
                        DisplayService.cursorSetShape(CursorShape.bdiagsize);
                        window.startResize(WindowResizeEdge.topRight);
                        return;
                    }
                    // Bottom left
                    if (
                        localX < resizeThreshold &&
                        localY > window.getVisibleRect().size.y - resizeThreshold
                    ) {
                        DisplayService.cursorSetShape(CursorShape.bdiagsize);
                        window.startResize(WindowResizeEdge.bottomLeft);
                        return;
                    }
                    // Bottom Right
                    if (
                        localX > window.getVisibleRect().size.x - resizeThreshold &&
                        localY > window.getVisibleRect().size.y - resizeThreshold
                    ) {
                        DisplayService.cursorSetShape(CursorShape.fdiagsize);
                        window.startResize(WindowResizeEdge.bottomRight);
                        return;
                    }
                    // Left
                    if (localX < resizeThreshold) {
                        DisplayService.cursorSetShape(CursorShape.hsize);
                        window.startResize(WindowResizeEdge.left);
                        return;
                    }
                    // Right
                    if (localX > window.getVisibleRect().size.x - resizeThreshold) {
                        DisplayService.cursorSetShape(CursorShape.hsize);
                        window.startResize(WindowResizeEdge.right);
                        return;
                    }
                    // Top
                    if (localY < resizeThreshold) {
                        DisplayService.cursorSetShape(CursorShape.vsize);
                        window.startResize(WindowResizeEdge.top);
                        return;
                    }
                    // Bottom
                    if (localY > window.getVisibleRect().size.y - resizeThreshold) {
                        DisplayService.cursorSetShape(CursorShape.vsize);
                        window.startResize(WindowResizeEdge.bottom);
                        return;
                    }
                }
            }
        }
    }

    inline  function toggleMenuBar() {
        menuBarControl.visible = !menuBarControl.visible;
    }

    public var windowIsFullscreen: Bool = false;

    inline function toggleFullscreen() {
        var window = getWindow();
        if (windowIsMaximized != true) {
            window.mode = WindowMode.fullscreen;
            windowIsFullscreen == true;
            windowIsMaximized = true;
        }
        else {
            if (isMaximized == true) {
                window.mode = WindowMode.maximized;
                windowIsMaximized = true;
            }
            else {
                window.mode = WindowMode.windowed;
                windowIsMaximized = false;
            }
            windowIsFullscreen = false;
        }
        if (window.mode != WindowMode.windowed) {
            maximizeButton.text = "🗗";
            if (OSService.getName() == "Windows") {
                maximizeButton.text = "";
            }
        }
        else {
            maximizeButton.text = "🗖";
            if (OSService.getName() == "Windows") {
                maximizeButton.text = "";
            }
        }
    }

    inline  function openSnb(path: String) {
        try {
            if (appView != null) {
                appView.queueFree();
                appView = null;
            }
            appView = new AppView();
            subViewport.addChild(appView);
            appView.init();
            var playerUtils = new NativeObject("res://Player/PlayerUtils.cs", new ArrayList(), ScriptType.csharp);
            var baseDir: String = playerUtils.call("GetAssemblyDirectory", new ArrayList());
            appView.loadLibrary(baseDir + "basetxt.slib");
            appView.loadLibrary(baseDir + "basesfx.slib");
            appView.loadApp(path);
            playerUtils.call("queue_free", new ArrayList());
        }
        catch (e: Exception) {
            Debug.error(e.message, "Error loading game");
        }
    }

    public override function onNotification(what: Int) {
        if (what == 2011) {
            showAboutDialog();
        }
    }
}