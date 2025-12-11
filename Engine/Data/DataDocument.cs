using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

namespace Sunaba.Engine.Config;

public class DataDocument
{
    private DataTable _table = new();

    public DataDocument()
    {
    }

    public void CreateTable(string path)
    {
        var pathArray = path.Split("/").ToList();
        var tableName = pathArray.Last();
        pathArray = pathArray.Slice(0, pathArray.Count - 1);
        var dataObj = Find(_table, pathArray);
        if (dataObj == null)
        {
            throw new Exception("Table not found");
        }

        if (dataObj is DataTable dataTable)
        {
            dataTable[tableName] = new DataTable();
        }
        else
        {
            throw new Exception("Table parent is invalid");
        }
    }

    public void StoreData(string path, Variant variant)
    {
        var pathArray = path.Split("/").ToList();
        var valueName = pathArray.Last();
        pathArray = pathArray.Slice(0, pathArray.Count - 1);
        var dataObj = Find(_table, pathArray);
        if (dataObj == null)
        {
            throw new Exception("Table not found");
        }

        if (dataObj is DataTable dataTable)
        {
            dataTable[valueName] = VariantToIData(variant);
        }
        else
        {
            throw new Exception("Table parent is invalid");
        }
    }

    protected IData VariantToIData(Variant variant)
    {
        if (variant.VariantType == Variant.Type.Color)
        {
            return new DataColor(variant.As<Color>());
        }
        else if (variant.VariantType == Variant.Type.Bool)
        {
            return new DataBoolean(variant.AsBool());
        }
        else if (variant.VariantType == Variant.Type.PackedByteArray)
        {
            return new DataBytes(variant.AsByteArray());
        }
        else if (variant.VariantType == Variant.Type.Float)
        {
            return new DataFloat(variant.AsSingle());
        }
        else if (variant.VariantType == Variant.Type.Int)
        {
            return new DataInteger(variant.AsInt32());
        }
        else if (variant.VariantType == Variant.Type.String)
        {
            return new DataString(variant.AsString());
        }
        else if (variant.VariantType == Variant.Type.Array)
        {
            var dataList = new DataList();
            foreach (var subvariant in variant.AsGodotArray())
            {
                dataList.Add(VariantToIData(subvariant));
            }

            return dataList;
        }
        
        return null;
    }

    protected IData Find(IData data, List<string> list, int idx = 0)
    {
        if (idx == list.Count - 1) return data;

        if (data is DataTable dataTable)
        {
            foreach (var key in dataTable.Keys())
            {
                if (key == list[idx])
                {
                    var childData = dataTable[key];
                    if (childData is DataTable childDataTable)
                    {
                        return Find(childDataTable, list, idx + 1);
                    }
                }
            }
        }

        return null;
    }
}