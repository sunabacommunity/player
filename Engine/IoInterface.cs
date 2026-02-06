using System;
using System.Collections.Generic;
using System.IO;
using Godot.Collections;
using Godot;

namespace Sunaba.Engine
{

	[GlobalClass]
    public partial class IoInterface : RefCounted
    {
        public String PathUrl = "files://";

        public void SetPathUrl(String pathUrl)
        {
	        PathUrl = pathUrl;
        }

        public String GetPathUrl()
        {
	        return PathUrl;
        }

        public virtual string GetFilePath(string path)
        {
            return path;
        }

        public virtual String LoadText(string assetPath)
        {
            var bytes = LoadBytes(assetPath);
            var base64 = Marshalls.RawToBase64(bytes);
            return Marshalls.Base64ToUtf8(base64);
        }

        public virtual void SaveText(string assetPath, string text)
        {
            var base64 = Marshalls.Utf8ToBase64(text);
            var bytes = Marshalls.Base64ToRaw(base64);
            SaveBytes(assetPath, bytes);
        }

        public virtual byte[] LoadBytes(string assetPath)
        {
            return null;
        }

        public virtual void SaveBytes(string assetPath, byte[] bytes)
        {

        }

        public Array<String> GetFileListAll(string extension, bool recursive = true)
        {
            return GetFileList(PathUrl, extension, recursive);
        }

        public virtual Array<String> GetFileList(string path, string extension = "", bool recursive = true)
        {
            return null;
        }

        public bool FileExists(string path)
        {
            return LoadBytes(path) != null;
        }

        public virtual void DeleteFile(string path)
        {

        }

        public void MoveFile(string source, string dest)
        {
            byte[] buffer = LoadBytes(source);
            SaveBytes(dest, buffer);
            DeleteFile(source);
        }

        public virtual int CreateDirectory(string path)
        {
            return 1;
        }

        public virtual void DeleteDirectory(string path)
        {

        }

        public virtual bool DirectoryExists(string path)
        {
            return false;
        }

        public String GetTempFilename()
        {
            return PathUrl + Path.GetTempFileName();
        }
    }
}
