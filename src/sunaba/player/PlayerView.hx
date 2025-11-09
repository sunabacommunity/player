package sunaba.player;

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

class PlayerView extends Widget {
    var subViewport: SubViewport;
    var appView: AppView = null;

    var menuBarControl: Control;

    var abouDialog: AcceptDialog;

    public override function init() {
        load("player://PlayerView.suml");
    }

    public override function onReady() {
        subViewport = getNodeT(SubViewport, "vbox/gameView/container/subViewport");

        abouDialog = getNodeT(AcceptDialog, "aboutDialog");
        buildAboutDialog(abouDialog);

        menuBarControl = getNodeT(Control, "vbox/menuBarControl");
        if (PlatformService.osName == "macOS") {
            menuBarControl.customMinimumSize = new Vector2(0, 0);
        }

        var fileMenu: PopupMenu = getNodeT(PopupMenu, "vbox/menuBarControl/menuBar/File");
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
                //
            }
        })));

        var viewMenu: PopupMenu = getNodeT(PopupMenu, "vbox/menuBarControl/menuBar/View");
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

        var helpMenu: PopupMenu = getNodeT(PopupMenu, "vbox/menuBarControl/menuBar/Help");
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

        var window = getParent().getWindow();
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
        aboutString += "Version 0.7.0\n";
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
        aboutString += "Version 0.7.0\n";
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
        Debug.info(aboutString, "About Sunaba Studio");
    }

    public override function onInput(event: InputEvent) {
        if (OSService.getName() != "macOS") {
            if (InputService.isKeyLabelPressed(Key.ctrl) && InputService.isKeyLabelPressed(Key.f1)) {
                //
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
    }

    inline  function toggleMenuBar() {
        menuBarControl.visible = !menuBarControl.visible;
    }

    inline function toggleFullscreen() {
        var window = getWindow();
        if (window.mode != WindowMode.fullscreen) {
            window.mode = WindowMode.fullscreen;
        }
        else {
            window.mode = WindowMode.windowed;
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
            appView.loadApp(path);
        }
        catch (e: Exception) {
            Debug.error(e.message, "Error loading game");
        }
    }
}