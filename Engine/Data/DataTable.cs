using System.Collections.Generic;

namespace Sunaba.Engine.Config;

public class DataTable : IData
{
    private Dictionary<string, IData> _dictionary = new();

    public DataTable() {}

    public IData Get(string name)
    {
        return _dictionary[name];
    }

    public void Set(string name, IData d)
    {
        _dictionary[name] = d;
    }

    public IData this[string s]
    {
        get => Get(s);
        set => Set(s, value);
    }

    public List<string> Keys()
    {
        List<string> keys = new();
        foreach (var dictionaryKey in _dictionary.Keys)
        {
            keys.Add(dictionaryKey);
        }

        return keys;
    }

    public List<IData> Values()
    {
        List<IData> values = new();
        foreach (var dictionaryValue in _dictionary.Values)
        {
            values.Add(dictionaryValue);
        }

        return values;
    }
}