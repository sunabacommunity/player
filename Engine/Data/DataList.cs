using System.Collections.Generic;

namespace Sunaba.Engine.Config;

public class DataList : IData
{
    private List<IData> _list = new();

    public DataList()
    {
    }

    public IData Get(int idx)
    {
        return _list[idx];
    }

    public void Set(int idx, IData data)
    {
        _list[idx] = data;
    }

    public void Add(IData data)
    {
        _list.Add(data);
    }

    public IData this[int idx]
    {
        get => Get(idx);
        set => Set(idx, value);
    }

    public int Count()
    {
        return _list.Count;
    }

    public List<IData> Foreach()
    {
        return _list;
    }
}