# floorplan

```
% mix run priv/convert_from_max.exs
```

converts floorplan-json from max' schema to the schema used here.
resulting json is put in `priv/out`.


```
% mix run priv/render.exs  
```

creates SVG from the json in `priv/out` and put it in `priv/out`.
