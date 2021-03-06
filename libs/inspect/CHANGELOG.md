## v3.0.2
* Fixes a bug when a table was garbage-collected while inspect was trying to render it

## v3.0.1
* Fixes a bug when dealing with tables which have a __len metamethod in Lua >= 5.2

## v3.0.0

The basic functionality remains as before, but there's one backwards-incompatible change if you used `options.filter`.

* **Removed** `options.filter`
* **Added** `options.process`, which can be used to do the same as `options.filter`, and more.
* **Added** two new constants, `inspect.METATABLE` and `inspect.KEY`
* **Added** `options.indent` & `options.newline`.


## v2.0.0

* Ability to deal with LuaJit's custom types
* License change from BSD to MIT
* Moved second parameter (depth) to options (options.depth)
* Added a new parameter, options.filter.
* Reimplemented some parts of the system without object orientation
