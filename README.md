# floorplan

```
% mix run priv/convert_from_max.exs
% mix run priv/convert_from_revit.exs
```

converts floorplan-json from max' and the revit-plugin's schemas to the schema used here.
resulting jsons are put in `priv/out`.


```
% mix run priv/render.exs  
```

creates SVGs from the jsons in `priv/out` and puts them in `priv/out`.
