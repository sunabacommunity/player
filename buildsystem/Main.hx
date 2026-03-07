import sys.FileSystem;
import sys.io.File;
import js.node.Os;
import haxe.io.BytesInput;
import haxe.zip.Reader;
import haxe.io.Bytes;

class Main {

    static var godotCommand = "godot-mono";

    static var targetPlatform = "";

    static var exportType = ExportType.debug;

    static var packageFormat = PackageFormat.none;

    static var targetName:String = "";

    static var installFlatpak = false;

    static var flatpakSingleFileBundle = false;

    public static function main() {
        var args = Sys.args();

        if (args[0] == "-h" || args[0] == "--help") {
            Sys.println("Usage: node build [run|export] [--godot-command=<command>] [--target=<platform>] [-debug|-release]");
            Sys.println("  run: Run Sunaba Player");
            Sys.println("  --godot-command=<command>: Specify the Godot command to use (default: godot)");
            Sys.println("  --skip: Skip the build step");
            Sys.println("  publish: Export Sunaba Player for the specified platform");
            Sys.println("  --skip -s: Skip the build step");
            Sys.println("  --godot-command=<command>: Specify the Godot command to use (default: godot)");
            Sys.println("  --target=<platform> -t=<platform>: Specify the target platform (default: auto-detect based on OS)");
            Sys.println("  --debug -d: Export in debug mode");
            Sys.println("  --release -r: Export in release mode");
            Sys.println("  --pkgformat=<format> -p: Specify the package format (none, nsis, deb, dmg)");
            return;
        }

        if (args[0] == "libupdate") {
            var filepath = FileSystem.absolutePath(args[1]);
            if (!StringTools.endsWith(filepath, ".zip")) {
                Sys.println("Invalid File");
                Sys.exit(-1);
            }
            var filebytes = File.getBytes(filepath);
            extractArchiveV2(filebytes);
            return;
        }

        var skipbuild: Bool = false;

        for (i in 0...args.length) {
            var arg = args[i];
            if (StringTools.startsWith(arg, "--godot-command=")) {
                godotCommand = StringTools.replace(arg, "--godot-command=", "");
                Sys.println("Using godot command: " + godotCommand);
            }
            else if (StringTools.startsWith(arg, "--target=")) {
                targetPlatform = StringTools.replace(arg, "--target=", "");
            }
            else if (arg == "--debug" || arg == "-d") {
                exportType = ExportType.debug;
            }
            else if (arg == "--release" || arg == "-r") {
                exportType = ExportType.release;
            }
            else if (StringTools.startsWith(arg, "-t=")) {
                targetPlatform = StringTools.replace(arg, "-t=", "");
            }
            else if (arg == "--skip") {
                skipbuild = true;
            }
            else if (StringTools.startsWith(arg, "--pkgformat=")) {
                packageFormat = StringTools.replace(arg, "--pkgformat=", "");
                trace(packageFormat);
            }
            else if (packageFormat == PackageFormat.flatpak && arg == "--install") {
                installFlatpak = true;
            } 
            else if (packageFormat == PackageFormat.flatpak && arg == "--single-file-bundle") {
                flatpakSingleFileBundle = true;
            }
        }

        var currentDir = Sys.getCwd();
        if (StringTools.contains(currentDir, "\\"))
            currentDir = StringTools.replace(currentDir, "\\", "/");

        if (!skipbuild) {
            var gamepak = new Gamepak();
            gamepak.zipOutputPath = currentDir + "player.snb";
            gamepak.build(currentDir + "Player.sproj");

            var dotnetRestore = Sys.command("dotnet restore Sunaba.Player.sln");
            if (dotnetRestore != 0) {
                Sys.exit(dotnetRestore);
            }

            var dotnetBuild = Sys.command("dotnet build Sunaba.Player.sln");
            if (dotnetBuild != 0) {
                Sys.exit(dotnetBuild);
            }
        }

        if (args[0] == "run") {
            run();
        }
        else if (args[0] == "publish") {
            publish();
        }

        if (packageFormat == PackageFormat.nsis) {
            buildNsis();
        }
        else if (packageFormat == PackageFormat.dmg) {
            exportDmg();
        } else if (packageFormat == PackageFormat.zip) {
            exportZip();
        }
        else if (packageFormat == PackageFormat.deb) {
            exportDeb();
        }
        else if (packageFormat == PackageFormat.flatpak) {
            exportFlatpak();
        }
    }

    public static function run() {
        var args = Sys.args();
        args.remove("run"); // Remove the "run" argument
        var argString = "";
        for (arg in args) {
            argString += arg + " ";
        }
        var result = Sys.command(godotCommand + " --path ./ " + argString);
        Sys.exit(result);
    }

    public static function setupBin() {
        if (targetPlatform == "") {
            var systemName = Sys.systemName();
            var arch = Os.arch();
            if (systemName == "Windows") {
                if (arch == "x64") {
                    targetPlatform = "windows-x86_64";
                }
                else if (arch == "ia32") {
                    targetPlatform = "windows-x86_32";
                }
                else if (arch == "arm64") {
                    targetPlatform = "windows-arm64";
                }
            }
            else if (systemName == "Mac") {
                targetPlatform = "mac-universal";
            }
            else if (systemName == "Linux") {
                if (arch == "x64") {
                    targetPlatform = "linux-x86_64";
                }
                else if (arch == "arm64") {
                    targetPlatform = "linux-arm64";
                }
            }
        }

        if (targetPlatform == "")  {
            Sys.println("Unknown target platform");
            Sys.exit(-1);
        }

        if (targetPlatform == "mac-universal") {
            targetName = "Sunaba Player.app";
        }
        else if (StringTools.startsWith(targetPlatform, "windows")) {
            if (targetPlatform != "windows-x86_64" && targetPlatform != "windows-x86_32" && targetPlatform != "windows-arm64") {
                Sys.println("Invalid target platform: " + targetPlatform);
                Sys.exit(-1);
            }
            targetName = "Sunaba.Player.exe";
        }
        else if (StringTools.startsWith(targetPlatform, "linux")) {
            if (targetPlatform != "linux-x86_64") {
                Sys.println("Invalid target platform: " + targetPlatform);
                Sys.exit(-1);
            }
            targetName = "sunaba-player";
        }
        else {
            Sys.println("Invalid target platform: " + targetPlatform);
            Sys.exit(-1);
        }

        var rootPath = Sys.getCwd() + "bin";
        if (!FileSystem.exists(rootPath)) {
            FileSystem.createDirectory(rootPath);
        }

        var targetPath = rootPath + "/" + targetPlatform + "-" + exportType;
        if (!FileSystem.exists(targetPath)) {
            FileSystem.createDirectory(targetPath);
        }
    }

    public static function extractArchiveV2(bytes:Bytes) {
        if (bytes.length == 0) {
            trace("Download failed: empty archive");
            return;
        }
        var cwd = Sys.getCwd();
        var input = new BytesInput(bytes);
        var entries = Reader.readZip(input);
        if (!FileSystem.exists(cwd + "/lib/")) {
            FileSystem.createDirectory(cwd + "/lib/");
        }
        for (entry in entries) {
            var entryPath = cwd + "/lib/" + entry.fileName;
            if (StringTools.contains(entryPath, "\\")) {
                entryPath = StringTools.replace(entryPath, "\\", "/");
            }
            if (StringTools.endsWith(entryPath, "/") || StringTools.endsWith(entryPath, "\\") || !StringTools.contains(entryPath, ".")) {
                Sys.println("Creating Directory: " + entryPath);
                FileSystem.createDirectory(entryPath);
                continue;
            }
            var stringArray = entryPath.split("/");
            var baseDir:String = "";
            for (i in 0...stringArray.length - 1) {
                baseDir += stringArray[i] + "/";
                checkDir(baseDir);
            }
            Sys.println("Updating File: " + entryPath);
            var entryBytes = entry.data;
            File.saveBytes(entryPath, entryBytes);
        }
    }

    public static function checkDir(path:String) {
		if (!FileSystem.exists(path)) {
			Sys.println("Creating Directory: " + path);
			FileSystem.createDirectory(path);
		}
	}

    public static function publish() {
        setupBin();

        Sys.println("Exporting for target platform: " + targetPlatform);
        Sys.println("Exporting for " + exportType);

        var command = godotCommand + " --path ./ --headless --editor --export-" + exportType + " \"" + targetPlatform + "\" \"./bin/" + targetPlatform + "-" + exportType + "/" + targetName + "\"";

        var result = Sys.command(command);
        if (result != 0) {
            trace("Godot export failed with code " + result);
            Sys.println(godotCommand + " exited with code " + result);
            Sys.exit(result);
        }
    }

    public static function buildNsis() {
        var nsisCommand = "makensis";
        if (Sys.systemName() == "Windows") {
            if (Sys.command(nsisCommand + " /VERSION") != 0) {
                Sys.println("NSIS is not installed or not found in PATH.");
                Sys.exit(-1);
            }
        } else if (Sys.systemName() == "Linux" || Sys.systemName() == "Mac") {
            nsisCommand = "makensis";
            if (Sys.command(nsisCommand + " -VERSION") != 0) {
                Sys.println("NSIS is not installed or not found in PATH.");
                Sys.exit(-1);
            }
        }

        var nsisScript = "player.x86_64.nsi";
        if (exportType == ExportType.debug) {
            nsisScript = "player.x86_64.debug.nsi";
        }

        var command = nsisCommand + " " + nsisScript;
        trace("Running NSIS command: " + command);
        var result = Sys.command(command);
        if (result != 0) {
            Sys.println("NSIS installer creation failed with code " + result);
            Sys.exit(result);
        }

        Sys.println("NSIS installer created at: " + Sys.getCwd() + "/bin");
        buildNsisSystem();
    }

    public static function buildNsisSystem() {
        var nsisCommand = "makensis";
        if (Sys.systemName() == "Windows") {
            if (Sys.command(nsisCommand + " /VERSION") != 0) {
                Sys.println("NSIS is not installed or not found in PATH.");
                Sys.exit(-1);
            }
        } else if (Sys.systemName() == "Linux" || Sys.systemName() == "Mac") {
            nsisCommand = "makensis";
            if (Sys.command(nsisCommand + " -VERSION") != 0) {
                Sys.println("NSIS is not installed or not found in PATH.");
                Sys.exit(-1);
            }
        }

        var nsisScript = "player.x86_64.system.nsi";
        if (exportType == ExportType.debug) {
            nsisScript = "player.x86_64.system.debug.nsi";
        }

        var command = nsisCommand + " " + nsisScript;
        trace("Running NSIS command: " + command);
        var result = Sys.command(command);
        if (result != 0) {
            Sys.println("NSIS installer creation failed with code " + result);
            Sys.exit(result);
        }

        Sys.println("NSIS installer created at: " + Sys.getCwd() + "/bin");
    }

    public static function exportZip() {
        var zipPath = Sys.getCwd() + "bin/" + targetPlatform + "-" + exportType + ".zip";
        var binPath = Sys.getCwd() + "bin/" + targetPlatform + "-" + exportType + "/";
        if (!FileSystem.exists(binPath)) {
            Sys.println("Export directory does not exist: " + binPath);
            Sys.exit(-1);
        }
        var output = new haxe.io.BytesOutput();
        var zipWriter = new haxe.zip.Writer(output);
        var entries:haxe.ds.List<haxe.zip.Entry> = new haxe.ds.List();
        for (file in FileSystem.readDirectory(binPath)) {
            if (FileSystem.isDirectory(file)) {
                continue; // Skip directories
            }
            var relativePath = StringTools.replace(file, binPath, "");
            Sys.println("Writing file to zip: " + relativePath);
            var fileBytes = File.getBytes(binPath + file);
            if (fileBytes == null) {
                Sys.println("Failed to read file: " + file);
                continue;
            }

            var entry:haxe.zip.Entry = {
                fileName: relativePath,
                fileSize: fileBytes.length,
                fileTime: Date.now(),
                dataSize: fileBytes.length,
                data: fileBytes,
                crc32: null,  // Proper CRC32 calculation
                compressed: false,
                extraFields: null
            };
            entries.push(entry);
        }
        zipWriter.write(entries);
        var zipBytes = output.getBytes();
        File.saveBytes(zipPath, zipBytes);
    }

    public static function exportDmg() {
        var applicationsFolder = "/Applications/";
        Sys.command("ln -s /Applications/ " + Sys.getCwd() + "/bin/" + targetPlatform + "-" + exportType + "/Applications");
        Sys.command("hdiutil create -volname 'Sunaba Player' -srcfolder 'bin/"
        + targetPlatform
        + "-"
        + exportType
        + "' -ov -format UDZO 'bin/sunaba-player-"
        + exportType
        + ".dmg'");
        Sys.println("DMG package created at: bin/sunaba-player-" + exportType + ".dmg");
        var dmgPath = Sys.getCwd() + "bin/sunaba-player-" + exportType + ".dmg";
        if (!FileSystem.exists(dmgPath)) {
            Sys.println("DMG package creation failed.");
            Sys.exit(-1);
        } else {
            Sys.println("DMG package created successfully at: " + dmgPath);
        }
    }

    public static function exportFlatpak() {
        if (Sys.systemName() != "Linux") {
            Sys.println("Cannot build a flatpak on a non-Linux environment");
        }

        var cwd = Sys.getCwd();
        if (!StringTools.endsWith(cwd, "/")) {
            cwd += "/";
        }

        var flatpakBasePath = cwd + "flatpak/gg.sunaba.player/";

        var flatpakAppPath = flatpakBasePath + "app/";
        var binPath = Sys.getCwd() + "bin/" + targetPlatform + "-" + exportType + "/";
        if (!FileSystem.exists(binPath)) {
            Sys.println("Export directory does not exist: " + binPath);
            Sys.exit(-1);
        }

        dclone(binPath, flatpakAppPath);

        var additionalOptions = "";
        if (installFlatpak == true) {
            additionalOptions = "--user --install-deps-from=flathub --repo=" + cwd + "repo --install";
        }

        var flatpakBuilder = Sys.command("flatpak-builder --force-clean " + additionalOptions +  " bin/flatpakBuild " + flatpakBasePath + "/gg.sunaba.player.json");

        if (flatpakBuilder != 0) {
            Sys.exit(flatpakBuilder);
        }
        File.saveContent(cwd + "bin/flatpakBuild/.gdignore", "");
        if (FileSystem.exists(cwd + "repo/"))
            File.saveContent(cwd + "repo/.gdignore", "");
        if (FileSystem.exists(cwd + ".flatpak-builder/"))
            File.saveContent(cwd + ".flatpak-builder/.gdignore", "");

        if (flatpakSingleFileBundle == true) {
            Sys.command("flatpak build-bundle " + cwd + "repo " + cwd + "bin/sunaba-player-" + targetPlatform + "-" + exportType + ".flatpak gg.sunaba.player");
        }
    }

    public static function exportDeb() {
        if (Sys.systemName() != "Linux") {
            Sys.println("Cannot build a deb package on a non-Linux environment");
            Sys.exit(-1);
        }

        var cwd = Sys.getCwd();

        if (!StringTools.endsWith(cwd, "/")) {
            cwd += "/";
        }

        var debRootPath = cwd + ".debian/";
        if (!FileSystem.exists(debRootPath)) {
            FileSystem.createDirectory(debRootPath);
        }

        var debPackagePath = debRootPath + "sunaba-player-" + exportType + "/";
        if (!FileSystem.exists(debPackagePath)) {
            FileSystem.createDirectory(debPackagePath);
        }
        else {
            FileSystem.deleteDirectory(debPackagePath);
            FileSystem.createDirectory(debPackagePath);
        }

        var optPath = debPackagePath + "opt/";
        if (!FileSystem.exists(optPath)) {
            FileSystem.createDirectory(optPath);
        }
        
        var sunabaRootPath = optPath + "sunaba/";
        if (!FileSystem.exists(sunabaRootPath)) {
            FileSystem.createDirectory(sunabaRootPath);
        }

        var playerBinPath = sunabaRootPath + "player/";
        if (!FileSystem.exists(playerBinPath)) {
            FileSystem.createDirectory(playerBinPath);
        }

        var binPath = Sys.getCwd() + "bin/" + targetPlatform + "-" + exportType + "/";
        if (!FileSystem.exists(binPath)) {
            Sys.println("Export directory does not exist: " + binPath);
            Sys.exit(-1);
        }

        dclone(binPath, playerBinPath);

        var usrPath = debPackagePath + "usr/";
        if (!FileSystem.exists(usrPath)) {
            FileSystem.createDirectory(usrPath);
        }

        var sharePath = usrPath + "share/";
        if (!FileSystem.exists(sharePath)) {
            FileSystem.createDirectory(sharePath);
        }

        var desktopPath = sharePath + "applications/";
        if (!FileSystem.exists(desktopPath)) {
            FileSystem.createDirectory(desktopPath);
        }

        var ogDesktopEntryPath = cwd + "debian_files/gg.sunaba.player.desktop";
        if (!FileSystem.exists(ogDesktopEntryPath)) {
            Sys.print("Original desktop entry somehow doesn't exist.");
            Sys.exit(-1);
        }

        var desktopEntryPath = desktopPath + "gg.sunaba.player.desktop";
        Sys.println(ogDesktopEntryPath + " -> " + desktopEntryPath);
        File.copy(ogDesktopEntryPath, desktopEntryPath);

        var pixmapsPath = sharePath + "pixmaps/";
        if (!FileSystem.exists(pixmapsPath)) {
            FileSystem.createDirectory(pixmapsPath);
        }

        var ogDesktopIconPath = cwd + "debian_files/gg.sunaba.player.png";
        if (!FileSystem.exists(ogDesktopIconPath)) {
            Sys.print("Original desktop icon somehow doesn't exist.");
            Sys.exit(-1);
        }

        var desktopIconPath = pixmapsPath + "gg.sunaba.player.png";
        Sys.println(ogDesktopIconPath + " -> " + desktopIconPath);
        File.copy(ogDesktopIconPath, desktopIconPath);

        var debMetadataPath = debPackagePath + "DEBIAN/";
        if (!FileSystem.exists(debMetadataPath)) {
            FileSystem.createDirectory(debMetadataPath);
        }

        var ogControlPath = cwd + "debian_files/control";
        if (!FileSystem.exists(ogControlPath)) {
            Sys.print("Original control file somehow doesn't exist.");
            Sys.exit(-1);
        }

        var controlPath = debMetadataPath + "control";
        Sys.println(ogControlPath + " -> " + controlPath);
        File.copy(ogControlPath, controlPath);

        /*var licensePath = cwd + "LICENSE";
        if (!FileSystem.exists(ogControlPath)) {
            Sys.print("License file somehow doesn't exist.");
            Sys.exit(-1);
        }

        var debCopyrightPath = debMetadataPath + "copyright";
        Sys.println(licensePath + " -> " + debCopyrightPath);
        File.copy(licensePath, debCopyrightPath);*/

        var result = Sys.command("dpkg-deb --build " + debPackagePath);
        
        if (result != 0) {
			Sys.println("dpkg-deb failed at " + result);
		}

		var debOutputPath = cwd + "bin/";
		if (!FileSystem.exists(debOutputPath)) {
			FileSystem.createDirectory(debOutputPath);
		}

		var debPackageName = "sunaba-player-" + exportType + ".deb";

        var ogDebPath = debRootPath + debPackageName;
        var debPath =  debOutputPath + debPackageName;
        Sys.println(ogDebPath + " -> " + debPath);
		File.copy(ogDebPath, debPath);
    }

    public static function dclone(source: String, dest: String) {
        if (!StringTools.endsWith(source, "/")) {
            source += "/";
        }
        if (!StringTools.endsWith(dest, "/")) {
            dest += "/";
        }
        if (!FileSystem.exists(dest)) {
            FileSystem.createDirectory(dest);
        }
        Sys.println(source + " -> " + dest);
        for (file in FileSystem.readDirectory(source)) {
            var filePath = source + file;
            var destFilePath = dest + file;
            if (FileSystem.isDirectory(filePath)) {
                dclone(filePath, destFilePath);
            }
            else {
                Sys.println(filePath + " -> " + destFilePath);
                File.copy(filePath, destFilePath);
            }
        }
    }
}