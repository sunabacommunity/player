using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using Godot.Collections;
using Godot;
using System.Linq;

namespace Sunaba.Engine;

[GlobalClass]
public partial class IoInterfaceZip : IoInterface
{
    ZipArchive zipArchive;

    IoInterfaceZip()
    {
    }

    public void LoadFromPath(string path, string pathUrl)
    {
        PathUrl = pathUrl;
        if (path.EndsWith(".snb") || path.EndsWith(".slib") || path.EndsWith(".zip"))
        {
            zipArchive = ZipFile.OpenRead(path);
        }
        else
        {
            throw new Exception("Invalid Zip File");
        }
    }

    public void LoadFromBytes(byte[] buffer, string pathUrl)
    {
        PathUrl = pathUrl;
        MemoryStream ms = new MemoryStream(buffer);
        zipArchive = new ZipArchive(ms);
    }

    public override string GetFilePath(string path)
    {
        if (path.StartsWith(PathUrl))
        {
            path = path.Replace(PathUrl, "");
            if (path == null)
            {
                throw new Exception("Path Conversion Error");
            }
        }
        else if (path.StartsWith("./"))
        {
            path = path.Replace("./", "");
            if (path == null)
            {
                throw new Exception("Path Conversion Error");
            }
        }
        if (path.Contains("\\"))
        {
            path = path.Replace("\\/", "/");
            path = path.Replace("\\", "/");
        }
        if (path.Contains("/"))
        {
            path = path.Replace("/", "\\");
        }
        path = path.Replace("\\", "/");
        return path;
    }

    public string SanitizePath(string path)
    {
        path = path.Replace("\\/", "\\");
        path = path.Replace("\\", "/");
        return path;
    }

    public override string LoadText(string assetPath)
    {
        string path = GetFilePath(assetPath);
        ZipArchiveEntry entry = zipArchive.GetEntry(path);
        if (entry == null)
        {
            return null;
        }
        using (StreamReader reader = new StreamReader(entry.Open()))
        {
            return reader.ReadToEnd();
        }
    }

    public override byte[] LoadBytes(string assetPath)
    {
        string path = GetFilePath(assetPath);
        ZipArchiveEntry entry = zipArchive.GetEntry(path);
        if (entry == null)
        {
            return null;
        }
        using (MemoryStream ms = new MemoryStream())
        {
            entry.Open().CopyTo(ms);
            return ms.ToArray();
        }
    }

    public override Array<string> GetFileList(string path, string extension = "", bool recursive = true)
    {
        if (!path.EndsWith("/"))
            path  += "/";
        var ogPath = path;
        path = GetFilePath(path);
        Array<string> assets = new Array<string>();
        if (extension != "" && extension != "/" && !recursive)
        {
            var subDirs = GetFileList(path, "/", true);

            foreach (var entry in zipArchive.Entries)
            {
                var filePath = PathUrl + entry.FullName;
                bool isInSubDir = false;
                foreach (var subDir in subDirs)
                {
                    if ((filePath).StartsWith(subDir))
                    {
                        isInSubDir = true;
                        break;
                    }
                }
                if (isInSubDir) continue;
                assets.Add(filePath);
            }
        }
        foreach (var entry in zipArchive.Entries)
        {
            if (extension != "" && extension != "/")
            {
                if (entry.FullName.StartsWith(path) && entry.FullName.EndsWith(extension))
                {
                    var filePath = SanitizePath(entry.FullName);
                    if (filePath.StartsWith("/"))
                    {
                        filePath = filePath[1..];
                    }
                    assets.Add(PathUrl + filePath);
                }
            }
            else if (extension == "/")
            {
                var pathStrArr = (path).Split("/");
                if (path != "")
                {
                    pathStrArr.Append("");
                }
                var baseDir = entry.FullName.GetBaseDir();
                if (path != "") Console.WriteLine(1);
                Console.WriteLine(baseDir.StartsWith(path));
                if(baseDir.StartsWith(path)) {
                    if (path != "") Console.WriteLine(2);
                    if (baseDir != path)
                    {
                        if (path != "") Console.WriteLine(3);
                        var baseDirArr = baseDir.Split("/").ToList();
                        if (recursive != true)
                        {
                            while (baseDirArr.Count == pathStrArr.Length + 1)
                            {
                                baseDirArr.RemoveAt(baseDirArr.Count - 1);
                            }
                        }
                        baseDir = baseDirArr.ToArray().Join("/");
                        baseDir = PathUrl + baseDir;
                        if (path != "") Console.WriteLine(4);

                        if (assets.Contains(baseDir)) continue;
                        if (baseDir == ogPath) continue;

                        if (path != "") Console.WriteLine(5);
                       
                        assets.Add(baseDir);
                        
                    }
                }
            }
            else
            {
                if (entry.FullName.StartsWith(path))
                {
                    assets.Add(PathUrl + SanitizePath(entry.FullName));
                }
            }
        }
        return assets;
    }
    public override bool DirectoryExists(string path)
    {
        path = GetFilePath(path);
        foreach (var entry in zipArchive.Entries)
        {
            if (entry.FullName.StartsWith(path))
                return true;
            
        }

        return false;
    }
}
