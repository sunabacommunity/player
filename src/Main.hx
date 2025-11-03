package;
import sunaba.App;

import sunaba.player.PlayerView;

class Main extends App {
    public static function main() {
        new Main();
    }

    public override function init() {
        var playerView = new PlayerView();
        rootNode.addChild(playerView);
    }
}