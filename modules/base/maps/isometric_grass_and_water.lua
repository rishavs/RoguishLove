return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "0.14.2",
  orientation = "isometric",
  renderorder = "right-down",
  width = 25,
  height = 25,
  tilewidth = 64,
  tileheight = 32,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "isometric_grass_and_water",
      firstgid = 1,
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "isometric_grass_and_water.png",
      imagewidth = 256,
      imageheight = 384,
      tileoffset = {
        x = 0,
        y = 16
      },
      properties = {},
      terrains = {
        {
          name = "Grass",
          tile = 0,
          properties = {}
        },
        {
          name = "Water",
          tile = 22,
          properties = {}
        }
      },
      tilecount = 24,
      tiles = {
        {
          id = 0,
          terrain = { 0, 0, 0, 0 }
        },
        {
          id = 1,
          terrain = { 0, 0, 0, 0 }
        },
        {
          id = 2,
          terrain = { 0, 0, 0, 0 }
        },
        {
          id = 3,
          terrain = { 0, 0, 0, 0 }
        },
        {
          id = 4,
          terrain = { 0, 0, 0, 1 }
        },
        {
          id = 5,
          terrain = { 0, 0, 1, 0 }
        },
        {
          id = 6,
          terrain = { 1, 0, 0, 0 }
        },
        {
          id = 7,
          terrain = { 0, 1, 0, 0 }
        },
        {
          id = 8,
          terrain = { 0, 1, 1, 1 }
        },
        {
          id = 9,
          terrain = { 1, 0, 1, 1 }
        },
        {
          id = 10,
          terrain = { 1, 1, 1, 0 }
        },
        {
          id = 11,
          terrain = { 1, 1, 0, 1 }
        },
        {
          id = 12,
          terrain = { 0, 0, 1, 1 }
        },
        {
          id = 13,
          terrain = { 1, 0, 1, 0 }
        },
        {
          id = 14,
          terrain = { 1, 1, 0, 0 }
        },
        {
          id = 15,
          terrain = { 0, 1, 0, 1 }
        },
        {
          id = 16,
          terrain = { 0, 0, 1, 1 }
        },
        {
          id = 17,
          terrain = { 1, 0, 1, 0 }
        },
        {
          id = 18,
          terrain = { 1, 1, 0, 0 }
        },
        {
          id = 19,
          terrain = { 0, 1, 0, 1 }
        },
        {
          id = 20,
          terrain = { 0, 1, 1, 0 }
        },
        {
          id = 21,
          terrain = { 1, 0, 0, 1 }
        },
        {
          id = 22,
          terrain = { 1, 1, 1, 1 }
        },
        {
          id = 23,
          terrain = { 1, 1, 1, 1 }
        }
      }
    },
    {
      name = "Roadways",
      firstgid = 25,
      tilewidth = 64,
      tileheight = 32,
      spacing = 0,
      margin = 0,
      image = "grassland_tiles.png",
      imagewidth = 1024,
      imageheight = 1344,
      transparentcolor = "#ff00ff",
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {},
      tilecount = 672,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "Tile Layer 1",
      x = 0,
      y = 0,
      width = 25,
      height = 25,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "base64",
      compression = "zlib",
      data = "eJx1lWlSwzAMhe0kTRegO22uUAopB2IYfrDd/wTYg97ki+r+eJN4kZ42S10IoUs4Jtwl7Az3ttfhfJpQGWLCGes6oTFErCPkM5Z2ljEzHnFsnXz+9jd0R1vrLNu+Mkzd+R7+yQfqeYX+uuCT7m8Ld7SWL1vs66w2jotDD5+EJfiawv/MfJgkbBJacNRhHJPGOCq3vzA56tZd6pBP/j5RwQ+eK5/R8b+Y7a19HxLmyA3rpsa3B4/QWbzELb0ns/1gulXH3g/pn2CfHHm9g10R8T9hrRpWjS9cbiiX/5+RL8ZRnKq9s0E1TA5h62SUz7PLk/gU8xa8OScfafEb/78ZX/j/iUP8M54MJ5cP+bAuxLsJwztUPrJu/S/DOAYN8qLaYc724Tqvvqfk80/HIZ+V93kYv2v6Il2S5z35mPEex3do59pxq3eoxsnDelbNrOzsO5Z7WGUcR3DLfr5l8ezCuI+zF7/F63rXu5oXYsg+yD5CuRZ39L5oF3uAnwPsBewJlZPTTGGvkC353mMYZlqHGHo/+E44N2iTYqv+zbetODEXnCH8Mvcr5MXX/QV7G+jPPhzC8JZ9fPwMujVH2PdVq6wz1hb7FevDzx/GUueXMNQZ53QTxnXJnFduzffJupCPfUGe9jAu/p34+HgZyV3C2K/a6fCzi+BZiZP1W5rntIn6/wACGxuz"
    }
  }
}
