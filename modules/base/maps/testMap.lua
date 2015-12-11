return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "0.14.2",
  orientation = "staggered",
  renderorder = "right-down",
  width = 50,
  height = 50,
  tilewidth = 128,
  tileheight = 64,
  nextobjectid = 1,
  staggeraxis = "y",
  staggerindex = "odd",
  properties = {},
  tilesets = {
    {
      name = "map",
      firstgid = 1,
      tilewidth = 128,
      tileheight = 128,
      spacing = 0,
      margin = 0,
      image = "map.png",
      imagewidth = 768,
      imageheight = 128,
      tileoffset = {
        x = 0,
        y = 32
      },
      properties = {},
      terrains = {},
      tilecount = 6,
      tiles = {
        {
          id = 0,
          properties = {
            ["type"] = "grass"
          }
        },
        {
          id = 1,
          properties = {
            ["type"] = "road"
          }
        },
        {
          id = 2,
          properties = {
            ["type"] = "water"
          }
        },
        {
          id = 3,
          properties = {
            ["type"] = "wall"
          }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "bg",
      x = 0,
      y = 0,
      width = 50,
      height = 50,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      data = "eJztmNsOgzAMQ2Hl/795T5OiLHET1DUu64MlkED41CS9nMdxnFtfauL6BVTt819YWvH3R/rTzzKxRb0wM4zKA9XKrHrJ5NGc96oZLH8j/q2KnhXlsJ5j40Ce7uQxm6UpZfJAWVTUicwjwtLLo4JDeu9xRPOoUsYb61yYGeNMv1qBhZkDjfnOgz+PzNz5C10Bf3c4ZvJcgONuHhX/l8Ug/UXWJ9Ucl3NtcSAGJo4ei/X+i4Cjx6DH2mJgzMOrE09yrVrNMYqBgcPru55agKNq/oj61wxMHJkcLA7kn4VD96RPn0WsDBzeHhrVMgtH78xPZpBdn8zOo3d2Yc15jBxIsrZX5tC+LG/s/Up7RwzsHJIF7aXYOXr7EMszI8dT8pAciMG6Z+OIcKJ8VtDOg1sr57G19RS9AauHDA4="
    },
    {
      type = "objectgroup",
      name = "obj",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      objects = {}
    },
    {
      type = "tilelayer",
      name = "fg",
      x = 0,
      y = 0,
      width = 50,
      height = 50,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 12,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      data = "eJzt07ENADAIBDEa9l+ZIjsEPbInuOaqAAAA4OntAAiQ+EliM/zmEwAAAIAbBtNnABU="
    }
  }
}
