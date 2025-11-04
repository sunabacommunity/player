package sunaba.player;

import sunaba.ui.Widget;
import sunaba.ui.Panel;
import sunaba.ui.Control;
import sunaba.ui.VBoxContainer;
import sunaba.ui.MenuBar;
import sunaba.desktop.PopupMenu;
import sunaba.ui.SubViewportContainer;
import sunaba.SubViewport;

class PlayerView extends Widget {
    public override function init() {
        load("player://PlayerView.suml");
    }
}